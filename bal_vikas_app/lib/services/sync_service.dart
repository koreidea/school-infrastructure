import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../database/app_database.dart';
import 'database_service.dart';
import 'supabase_service.dart';
import 'admin_supabase_service.dart';
import 'connectivity_service.dart';

class SyncService {
  static bool _isSyncing = false;
  static bool _isPullingChildren = false;

  static void _log(String msg) {
    dev.log(msg, name: 'Sync');
    // ignore: avoid_print
    print('[Sync] $msg');
  }

  /// Process all pending items in the sync queue
  static Future<void> processQueue() async {
    if (kIsWeb) return; // No sync queue on web
    if (_isSyncing) {
      _log('Already syncing, skipping');
      return;
    }
    if (!ConnectivityService.isOnline) {
      _log('Offline, skipping sync');
      return;
    }

    _isSyncing = true;
    try {
      final db = DatabaseService.db;
      final items = await db.syncQueueDao.getPendingItems();
      _log('Processing ${items.length} pending sync items');

      for (final item in items) {
        if (!ConnectivityService.isOnline) break;

        try {
          _log('Syncing ${item.entityType} (localId=${item.entityLocalId})');
          await _processItem(db, item);
          await db.syncQueueDao.removeItem(item.id);
          _log('Synced ${item.entityType} OK');
        } catch (e) {
          _log('SYNC FAILED ${item.entityType}: $e');
          await db.syncQueueDao.markFailed(item.id, e.toString());
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  static Future<void> _processItem(AppDatabase db, SyncQueueData item) async {
    switch (item.entityType) {
      case 'session':
        await _syncSession(db, item.entityLocalId);
        break;
      case 'responses':
        await _syncResponses(db, item.entityLocalId);
        break;
      case 'result':
        await _syncResult(db, item.entityLocalId);
        break;
      case 'referral':
        await _syncReferral(db, item.entityLocalId);
        break;
      case 'nutrition':
        await _syncNutrition(db, item.entityLocalId);
        break;
      case 'environment':
        await _syncEnvironment(db, item.entityLocalId);
        break;
      case 'followup':
        await _syncFollowup(db, item.entityLocalId);
        break;
      case 'consent':
        await _syncConsent(db, item.entityLocalId);
        break;
      case 'audit_log':
        await _syncAuditLog(db, item.entityLocalId);
        break;
    }
  }

  /// Sync a screening session to Supabase
  static Future<void> _syncSession(AppDatabase db, int sessionLocalId) async {
    final session = await db.screeningDao.getSessionByLocalId(sessionLocalId);
    if (session == null) return;
    if (session.remoteId != null) return; // already synced

    final remoteSession = await SupabaseService.saveScreeningSession(
      childId: session.childRemoteId ?? 0,
      conductedBy: session.conductedBy,
      assessmentDate: session.assessmentDate,
      childAgeMonths: session.childAgeMonths,
      status: session.status,
      deviceSessionId: session.deviceSessionId,
    );

    final remoteId = remoteSession['id'] as int;
    await db.screeningDao.markSessionSynced(sessionLocalId, remoteId);
  }

  /// Sync screening responses to Supabase
  static Future<void> _syncResponses(AppDatabase db, int sessionLocalId) async {
    // Get the session to find the remote ID
    final session = await db.screeningDao.getSessionByLocalId(sessionLocalId);
    if (session == null) return;
    if (session.remoteId == null) {
      throw Exception('Session not yet synced (no remoteId) — retry later');
    }

    final responses = await db.screeningDao.getResponsesForSession(sessionLocalId);
    for (final resp in responses) {
      if (resp.syncedAt != null) continue;

      final responseMap = jsonDecode(resp.responsesJson) as Map<String, dynamic>;
      await SupabaseService.saveScreeningResponses(
        sessionId: session.remoteId!,
        toolType: resp.toolType,
        responses: responseMap,
      );

      await db.screeningDao.markResponsesSynced(resp.id);
    }
  }

  /// Sync screening result to Supabase
  static Future<void> _syncResult(AppDatabase db, int sessionLocalId) async {
    final session = await db.screeningDao.getSessionByLocalId(sessionLocalId);
    if (session == null) return;
    if (session.remoteId == null) {
      throw Exception('Session not yet synced (no remoteId) — retry later');
    }

    final result = await db.screeningDao.getResultForSession(sessionLocalId);
    if (result == null || result.syncedAt != null) return;

    final toolResults = result.toolResultsJson != null
        ? jsonDecode(result.toolResultsJson!) as Map<String, dynamic>
        : null;
    final concerns = result.concernsJson != null
        ? (jsonDecode(result.concernsJson!) as List).cast<String>()
        : null;
    final concernsTe = result.concernsTeJson != null
        ? (jsonDecode(result.concernsTeJson!) as List).cast<String>()
        : null;

    await SupabaseService.saveScreeningResult(
      sessionId: session.remoteId!,
      childId: session.childRemoteId ?? 0,
      overallRisk: result.overallRisk,
      overallRiskTe: result.overallRiskTe,
      referralNeeded: result.referralNeeded,
      gmDq: result.gmDq,
      fmDq: result.fmDq,
      lcDq: result.lcDq,
      cogDq: result.cogDq,
      seDq: result.seDq,
      compositeDq: result.compositeDq,
      toolResults: toolResults,
      concerns: concerns,
      concernsTe: concernsTe,
      toolsCompleted: result.toolsCompleted,
      toolsSkipped: result.toolsSkipped,
    );

    await db.screeningDao.markResultSynced(result.id, session.remoteId!);
  }

  /// Sync a referral to Supabase
  static Future<void> _syncReferral(AppDatabase db, int referralLocalId) async {
    final referral = await db.referralDao.getReferralById(referralLocalId);
    if (referral == null || referral.syncedAt != null) return;

    // Need child remote ID to link in Supabase
    if (referral.childRemoteId == null) {
      throw Exception('Referral has no childRemoteId — retry later');
    }

    // Resolve screening result remote ID if we have a local one
    int? screeningResultRemoteId = referral.screeningResultRemoteId;
    if (screeningResultRemoteId == null && referral.screeningResultLocalId != null) {
      final result = await db.screeningDao.getResultByLocalId(referral.screeningResultLocalId!);
      screeningResultRemoteId = result?.sessionRemoteId;
    }

    await SupabaseService.saveReferral(
      childId: referral.childRemoteId!,
      screeningResultId: screeningResultRemoteId,
      referralTriggered: referral.referralTriggered,
      referralType: referral.referralType,
      referralReason: referral.referralReason,
      referralStatus: referral.referralStatus,
      referredBy: referral.referredBy,
      referredDate: referral.referredDate,
      completedDate: referral.completedDate,
      notes: referral.notes,
    );

    await db.referralDao.markReferralSynced(referralLocalId);
  }

  /// Sync a nutrition assessment to Supabase
  static Future<void> _syncNutrition(AppDatabase db, int nutritionLocalId) async {
    final nutr = await db.challengeDao.getNutritionById(nutritionLocalId);
    if (nutr == null || nutr.syncedAt != null) return;

    if (nutr.childRemoteId == null) {
      throw Exception('Nutrition assessment has no childRemoteId — retry later');
    }

    // Resolve session remote ID
    int? sessionRemoteId;
    if (nutr.sessionLocalId != null) {
      final session = await db.screeningDao.getSessionByLocalId(nutr.sessionLocalId!);
      sessionRemoteId = session?.remoteId;
    }

    await SupabaseService.saveNutritionAssessment(
      childId: nutr.childRemoteId!,
      sessionId: sessionRemoteId,
      heightCm: nutr.heightCm,
      weightKg: nutr.weightKg,
      muacCm: nutr.muacCm,
      underweight: nutr.underweight,
      stunting: nutr.stunting,
      wasting: nutr.wasting,
      anemia: nutr.anemia,
      nutritionScore: nutr.nutritionScore,
      nutritionRisk: nutr.nutritionRisk,
      assessedDate: nutr.assessedDate,
    );

    await db.challengeDao.markNutritionSynced(nutritionLocalId);
  }

  /// Sync an environment assessment to Supabase
  static Future<void> _syncEnvironment(AppDatabase db, int envLocalId) async {
    final env = await db.challengeDao.getEnvironmentById(envLocalId);
    if (env == null || env.syncedAt != null) return;

    if (env.childRemoteId == null) {
      throw Exception('Environment assessment has no childRemoteId — retry later');
    }

    // Resolve session remote ID
    int? sessionRemoteId;
    if (env.sessionLocalId != null) {
      final session = await db.screeningDao.getSessionByLocalId(env.sessionLocalId!);
      sessionRemoteId = session?.remoteId;
    }

    await SupabaseService.saveEnvironmentAssessment(
      childId: env.childRemoteId!,
      sessionId: sessionRemoteId,
      parentChildInteractionScore: env.parentChildInteractionScore,
      parentMentalHealthScore: env.parentMentalHealthScore,
      homeStimulationScore: env.homeStimulationScore,
      playMaterials: env.playMaterials,
      caregiverEngagement: env.caregiverEngagement,
      languageExposure: env.languageExposure,
      safeWater: env.safeWater,
      toiletFacility: env.toiletFacility,
    );

    await db.challengeDao.markEnvironmentSynced(envLocalId);
  }

  /// Sync a follow-up to Supabase
  static Future<void> _syncFollowup(AppDatabase db, int followupLocalId) async {
    final fu = await db.challengeDao.getFollowupById(followupLocalId);
    if (fu == null || fu.syncedAt != null) return;

    if (fu.childRemoteId == null) {
      throw Exception('Followup has no childRemoteId — retry later');
    }

    // Resolve screening result remote ID
    int? screeningResultRemoteId;
    if (fu.screeningResultLocalId != null) {
      final result = await db.screeningDao.getResultByLocalId(fu.screeningResultLocalId!);
      screeningResultRemoteId = result?.sessionRemoteId;
    }

    await SupabaseService.saveFollowup(
      childId: fu.childRemoteId!,
      screeningResultId: screeningResultRemoteId,
      followupConducted: fu.followupConducted,
      followupDate: fu.followupDate,
      improvementStatus: fu.improvementStatus,
      reductionInDelayMonths: fu.reductionInDelayMonths,
      domainImprovement: fu.domainImprovement,
      exitHighRisk: fu.exitHighRisk,
      notes: fu.notes,
      createdBy: fu.createdBy,
    );

    await db.challengeDao.markFollowupSynced(followupLocalId);
  }

  /// Sync a consent record to Supabase
  static Future<void> _syncConsent(AppDatabase db, int consentLocalId) async {
    final consent = await db.dpdpDao.getConsentById(consentLocalId);
    if (consent == null || consent.syncedAt != null) return;

    final remote = await SupabaseService.saveConsent(
      childId: consent.childRemoteId,
      guardianName: consent.guardianName,
      guardianRelation: consent.guardianRelation,
      guardianPhone: consent.guardianPhone,
      consentPurpose: consent.consentPurpose,
      consentGiven: consent.consentGiven,
      consentVersion: consent.consentVersion,
      digitalSignatureBase64: consent.digitalSignatureBase64,
      collectedByUserId: consent.collectedByUserId,
      collectedByRole: consent.collectedByRole,
      languageUsed: consent.languageUsed,
      consentTimestamp: consent.consentTimestamp.toIso8601String(),
    );

    final remoteId = remote['id'] as int;
    await db.dpdpDao.markConsentSynced(consentLocalId, remoteId);
  }

  /// Sync an audit log entry to Supabase
  static Future<void> _syncAuditLog(AppDatabase db, int logLocalId) async {
    final log = await db.dpdpDao.getLogById(logLocalId);
    if (log == null || log.syncedAt != null) return;

    final remote = await SupabaseService.saveAuditLog(
      userId: log.userId,
      userRole: log.userRole,
      action: log.action,
      entityType: log.entityType,
      entityId: log.entityId,
      entityName: log.auditEntityName,
      detailsJson: log.detailsJson,
      deviceInfo: log.deviceInfo,
      timestamp: log.timestamp.toIso8601String(),
    );

    final remoteId = remote['id'] as int;
    await db.dpdpDao.markLogSynced(logLocalId, remoteId);
  }

  /// Pull screening configs (tools, questions, options, rules, activities) from Supabase → Drift
  static Future<void> pullScreeningConfigs() async {
    if (kIsWeb) return; // No Drift on web
    if (!ConnectivityService.isOnline) return;

    try {
      final db = DatabaseService.db;
      final client = SupabaseService.client;

      // 1. Tool configs
      final toolConfigs = await client
          .from('screening_tool_configs')
          .select()
          .eq('is_active', true)
          .order('sort_order');

      // Map remote tool config id → local tool config id
      final remoteToLocalToolId = <int, int>{};

      for (final row in toolConfigs) {
        await db.screeningConfigDao.upsertToolConfig(row);
        final localConfig = await db.screeningConfigDao
            .getToolConfigByType(row['tool_type'] as String);
        if (localConfig != null) {
          remoteToLocalToolId[row['id'] as int] = localConfig.id;
        }
      }

      // 2. Questions
      final questions = await client
          .from('screening_questions')
          .select()
          .eq('is_active', true)
          .order('sort_order');

      for (final row in questions) {
        final remoteToolId = row['tool_config_id'] as int;
        final localToolId = remoteToLocalToolId[remoteToolId];
        if (localToolId != null) {
          await db.screeningConfigDao.upsertQuestion(row, localToolId);
        }
      }

      // 3. Response options
      final options = await client
          .from('response_options')
          .select()
          .order('sort_order');

      for (final row in options) {
        final remoteToolId = row['tool_config_id'] as int;
        final localToolId = remoteToLocalToolId[remoteToolId];
        if (localToolId != null) {
          await db.screeningConfigDao.upsertResponseOption(row, localToolId);
        }
      }

      // 4. Scoring rules
      final rules = await client
          .from('scoring_rules')
          .select();

      for (final row in rules) {
        final remoteToolId = row['tool_config_id'] as int;
        final localToolId = remoteToLocalToolId[remoteToolId];
        if (localToolId != null) {
          await db.screeningConfigDao.upsertScoringRule(row, localToolId);
        }
      }

      // 5. Activities
      final activities = await client
          .from('activities')
          .select()
          .eq('is_active', true);

      for (final row in activities) {
        await db.screeningConfigDao.upsertActivity(row);
      }
    } catch (_) {
      // Config sync failed — app will use hardcoded fallback
    }
  }

  /// Pull screening results from Supabase into Drift for the given children.
  static Future<void> pullScreeningResults(List<int> childIds) async {
    if (kIsWeb) return; // No Drift on web
    if (!ConnectivityService.isOnline || childIds.isEmpty) return;

    try {
      final results = await SupabaseService.getScreeningResultsForChildren(childIds);
      if (results.isEmpty) {
        _log('pullScreeningResults: no results from Supabase');
        return;
      }

      final db = DatabaseService.db;
      int upserted = 0;
      for (final row in results) {
        try {
          await db.screeningDao.upsertResultFromRemote(row);
          upserted++;
        } catch (e) {
          _log('pullScreeningResults: FAILED to upsert result session_id=${row['session_id']}: $e');
        }
      }
      _log('pullScreeningResults: upserted $upserted / ${results.length} results into Drift');
    } catch (e) {
      _log('pullScreeningResults: FAILED: $e');
    }
  }

  /// Pull children from Supabase and upsert into local Drift DB
  static Future<void> pullChildren(Map<String, dynamic> userProfile) async {
    if (kIsWeb) return; // No Drift on web
    if (!ConnectivityService.isOnline) return;
    if (_isPullingChildren) {
      _log('pullChildren: already in progress, skipping');
      return;
    }
    _isPullingChildren = true;

    try {
      final remoteChildren = await SupabaseService.getChildrenForUser(userProfile);
      _log('pullChildren: got ${remoteChildren.length} children from Supabase (role=${userProfile['role']}, awc_id=${userProfile['awc_id']})');
      final db = DatabaseService.db;

      // Collect remote IDs so we can prune stale children
      final remoteIds = <int>{};
      for (final row in remoteChildren) {
        try {
          final id = row['id'] as int;
          remoteIds.add(id);
          await db.childrenDao.upsertFromRemote(row);
        } catch (e) {
          _log('pullChildren: FAILED to upsert child id=${row['id']}, name=${row['name']}: $e');
          // Continue with next child — don't let one bad row block all
        }
      }

      _log('pullChildren: upserted ${remoteIds.length} children successfully');

      // Remove children that are no longer in the Supabase result set
      if (remoteIds.isNotEmpty) {
        await db.childrenDao.deleteChildrenNotIn(remoteIds);
      }

      // Remove any duplicate entries (same remoteId, multiple rows)
      final deduped = await db.childrenDao.deduplicateByRemoteId();
      if (deduped > 0) {
        _log('pullChildren: removed $deduped duplicate children');
      }
    } catch (e) {
      _log('pullChildren: FAILED: $e');
    } finally {
      _isPullingChildren = false;
    }
  }

  /// Pull tool configs (tools, questions, response options, scoring rules) from Supabase into Drift.
  static Future<int> pullToolConfigs() async {
    if (kIsWeb) return 0;
    if (!ConnectivityService.isOnline) return 0;

    try {
      final toolsData = await AdminSupabaseService.fetchAllToolsWithDetails();
      if (toolsData.isEmpty) {
        _log('pullToolConfigs: no tools from Supabase');
        return 0;
      }

      final db = DatabaseService.db;
      int toolCount = 0;

      for (final toolData in toolsData) {
        try {
          // Upsert tool config
          await db.screeningConfigDao.upsertToolConfig(toolData);
          toolCount++;

          // Get the local tool config ID for linking questions/options
          final toolType = toolData['tool_type'] as String;
          final localConfig = await db.screeningConfigDao.getToolConfigByType(toolType);
          if (localConfig == null) continue;
          final localToolId = localConfig.id;

          // Upsert questions
          final questions = toolData['questions'] as List<Map<String, dynamic>>? ?? [];
          for (final q in questions) {
            await db.screeningConfigDao.upsertQuestion(q, localToolId);
          }

          // Upsert response options
          final options = toolData['options'] as List<Map<String, dynamic>>? ?? [];
          for (final o in options) {
            await db.screeningConfigDao.upsertResponseOption(o, localToolId);
          }

          // Upsert scoring rules
          final rules = toolData['scoring_rules'] as List<Map<String, dynamic>>? ?? [];
          for (final r in rules) {
            await db.screeningConfigDao.upsertScoringRule(r, localToolId);
          }
        } catch (e) {
          _log('pullToolConfigs: FAILED to upsert tool ${toolData['tool_id']}: $e');
        }
      }

      _log('pullToolConfigs: upserted $toolCount / ${toolsData.length} tools into Drift');
      return toolCount;
    } catch (e) {
      _log('pullToolConfigs: FAILED: $e');
      return 0;
    }
  }

  /// Pull intervention activities from Supabase into Drift.
  static Future<int> pullActivities() async {
    if (kIsWeb) return 0;
    if (!ConnectivityService.isOnline) return 0;

    try {
      final activities = await AdminSupabaseService.getActivities();
      if (activities.isEmpty) {
        _log('pullActivities: no activities from Supabase');
        return 0;
      }

      final db = DatabaseService.db;
      int count = 0;

      for (final activity in activities) {
        try {
          await db.screeningConfigDao.upsertActivity(activity);
          count++;
        } catch (e) {
          _log('pullActivities: FAILED to upsert activity ${activity['activity_code']}: $e');
        }
      }

      _log('pullActivities: upserted $count / ${activities.length} activities into Drift');
      return count;
    } catch (e) {
      _log('pullActivities: FAILED: $e');
      return 0;
    }
  }

  /// Pull all admin-configurable data from Supabase into Drift.
  /// Returns a summary map with counts.
  static Future<Map<String, int>> pullAllConfigs() async {
    if (kIsWeb) return {};
    if (!ConnectivityService.isOnline) return {};

    _log('pullAllConfigs: starting...');
    final tools = await pullToolConfigs();
    final activities = await pullActivities();
    _log('pullAllConfigs: done — $tools tools, $activities activities');

    return {
      'tools': tools,
      'activities': activities,
    };
  }
}
