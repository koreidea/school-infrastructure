import 'dart:convert';
import 'dart:developer' as dev;
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../services/supabase_service.dart';
import '../services/sync_service.dart';
import '../services/connectivity_service.dart';
import '../services/referral_service.dart';
import '../services/prediction_service.dart';
import '../utils/ml/feature_extractor.dart';
import 'admin_global_config_provider.dart';
import '../database/app_database.dart';
import 'screening_hub_provider.dart';
import 'children_provider.dart';

/// Saved screening result for a child (persists across navigation within app session)
class SavedScreeningResult {
  final int childId;
  final DateTime date;
  final String overallRisk;
  final String overallRiskTe;
  final bool referralNeeded;
  final Map<String, double> domainDqScores; // gm_dq, fm_dq, lc_dq, cog_dq, se_dq
  final Map<String, bool> domainDelays; // gm_delay, fm_delay, etc.
  final List<String> concerns;
  final List<String> concernsTe;
  final int toolsCompleted;
  final int toolsSkipped;
  // Challenge extension fields
  final String assessmentCycle; // 'Baseline', 'Follow-up', 'Re-screen'
  final int baselineScore;
  final String baselineCategory; // 'Low', 'Medium', 'High'
  final int numDelays;
  final String autismRisk; // 'Low', 'Moderate', 'High'
  final String adhdRisk;
  final String behaviorRisk;
  final int behaviorScore;
  // Predictive risk scoring fields
  final double? predictedRiskScore;
  final String? predictedRiskCategory;
  final String? riskTrend;
  final List<String>? topRiskFactors;
  final List<String>? topRiskFactorsTe;

  const SavedScreeningResult({
    required this.childId,
    required this.date,
    required this.overallRisk,
    required this.overallRiskTe,
    required this.referralNeeded,
    required this.domainDqScores,
    required this.domainDelays,
    required this.concerns,
    required this.concernsTe,
    required this.toolsCompleted,
    required this.toolsSkipped,
    this.assessmentCycle = 'Baseline',
    this.baselineScore = 0,
    this.baselineCategory = 'Low',
    this.numDelays = 0,
    this.autismRisk = 'Low',
    this.adhdRisk = 'Low',
    this.behaviorRisk = 'Low',
    this.behaviorScore = 0,
    this.predictedRiskScore,
    this.predictedRiskCategory,
    this.riskTrend,
    this.topRiskFactors,
    this.topRiskFactorsTe,
  });

  /// Create a copy with prediction fields updated
  SavedScreeningResult withPrediction(PredictiveScore prediction) {
    return SavedScreeningResult(
      childId: childId,
      date: date,
      overallRisk: overallRisk,
      overallRiskTe: overallRiskTe,
      referralNeeded: referralNeeded,
      domainDqScores: domainDqScores,
      domainDelays: domainDelays,
      concerns: concerns,
      concernsTe: concernsTe,
      toolsCompleted: toolsCompleted,
      toolsSkipped: toolsSkipped,
      assessmentCycle: assessmentCycle,
      baselineScore: baselineScore,
      baselineCategory: baselineCategory,
      numDelays: numDelays,
      autismRisk: autismRisk,
      adhdRisk: adhdRisk,
      behaviorRisk: behaviorRisk,
      behaviorScore: behaviorScore,
      predictedRiskScore: prediction.score,
      predictedRiskCategory: prediction.category,
      riskTrend: prediction.trend,
      topRiskFactors: prediction.topFactors,
      topRiskFactorsTe: prediction.topFactorsTe,
    );
  }
}

/// Map tool scorer risk levels (LOW/MEDIUM/HIGH) to challenge format (Low/Moderate/High)
String mapRiskLevel(String toolRisk) {
  switch (toolRisk) {
    case 'HIGH':
      return 'High';
    case 'MEDIUM':
      return 'Moderate';
    default:
      return 'Low';
  }
}

/// Compute baseline risk score from configurable formula.
/// Defaults: numDelays×5 + autismRisk(High:15,Mod:8) + adhdRisk(High:8,Mod:4) + behaviorRisk(High:7)
/// When [config] is provided, uses admin-configured weights.
int computeBaselineScore({
  required int numDelays,
  required String autismRisk,
  required String adhdRisk,
  required String behaviorRisk,
  GlobalConfig? config,
}) {
  final wDelays = config?.baselineWeightDelays ?? 5;
  final wAutismHigh = config?.baselineWeightAutismHigh ?? 15;
  final wAutismMod = config?.baselineWeightAutismModerate ?? 8;
  final wAdhdHigh = config?.baselineWeightAdhdHigh ?? 8;
  final wAdhdMod = config?.baselineWeightAdhdModerate ?? 4;
  final wBehaviorHigh = config?.baselineWeightBehaviorHigh ?? 7;

  int score = numDelays * wDelays;
  score += autismRisk == 'High' ? wAutismHigh : (autismRisk == 'Moderate' ? wAutismMod : 0);
  score += adhdRisk == 'High' ? wAdhdHigh : (adhdRisk == 'Moderate' ? wAdhdMod : 0);
  score += behaviorRisk == 'High' ? wBehaviorHigh : 0;
  return score;
}

/// Categorize baseline score using configurable cutoffs.
/// Defaults: <=10 Low, 11-25 Medium, >25 High
String baselineCategory(int score, {GlobalConfig? config}) {
  final cutoffLow = config?.baselineCutoffLow ?? 10;
  final cutoffMedium = config?.baselineCutoffMedium ?? 25;
  return score <= cutoffLow ? 'Low' : (score <= cutoffMedium ? 'Medium' : 'High');
}

class ScreeningResultsStorageNotifier extends Notifier<Map<int, SavedScreeningResult>> {
  bool _loaded = false;

  @override
  Map<int, SavedScreeningResult> build() {
    // Reset loaded flag so ref.invalidate() triggers a fresh reload
    _loaded = false;
    // Auto-load from Drift on first access
    _loadAllFromDrift();
    return {};
  }

  /// Load all screening results from Drift DB and populate in-memory cache
  Future<void> _loadAllFromDrift() async {
    if (_loaded) return;
    _loaded = true;

    // On web, skip Drift entirely — go straight to Supabase
    if (kIsWeb) {
      _loadFromSupabase();
      return;
    }

    try {
      final db = DatabaseService.db;
      final allResults = await db.screeningDao.getAllResults();
      if (allResults.isEmpty) {
        // No Drift results — try Supabase
        _loadFromSupabase();
        return;
      }

      // Group by childRemoteId, keep latest (highest id) for each child
      final latestByChild = <int, LocalScreeningResult>{};
      for (final r in allResults) {
        if (r.childRemoteId == null) continue;
        final existing = latestByChild[r.childRemoteId!];
        if (existing == null || r.id > existing.id) {
          latestByChild[r.childRemoteId!] = r;
        }
      }

      if (latestByChild.isEmpty) {
        _loadFromSupabase();
        return;
      }

      final newState = <int, SavedScreeningResult>{...state};
      for (final entry in latestByChild.entries) {
        final childId = entry.key;
        final r = entry.value;
        // Don't overwrite a more recent in-memory result
        if (newState.containsKey(childId)) continue;
        newState[childId] = _driftResultToSaved(childId, r);
      }

      state = newState;
      // ignore: avoid_print
      print('[ResultsStorage] Loaded ${latestByChild.length} results from Drift');

      // Backfill predictions for existing results that don't have them
      _backfillAndRefresh(latestByChild);

      // Also load from Supabase to fill in results for children not in Drift
      _loadFromSupabase();
    } catch (e) {
      // ignore: avoid_print
      print('[ResultsStorage] ERROR loading from Drift: $e');
      _loadFromSupabase();
    }
  }

  /// Fallback: load screening results from Supabase for all children
  Future<void> _loadFromSupabase() async {
    try {
      // Await children — they may still be loading from Supabase
      final children = await ref.read(childrenProvider.future);
      if (children.isEmpty) return;

      final childIds = children
          .map((c) => c['child_id'] as int?)
          .where((id) => id != null)
          .cast<int>()
          .toList();
      if (childIds.isEmpty) return;

      final results = await SupabaseService.getScreeningResultsForChildren(childIds);
      if (results.isEmpty) return;

      // Group by child_id, keep latest
      final latestByChild = <int, Map<String, dynamic>>{};
      for (final r in results) {
        final childId = r['child_id'] as int?;
        if (childId == null) continue;
        if (!latestByChild.containsKey(childId)) {
          latestByChild[childId] = r; // results are ordered newest-first
        }
      }

      final newState = <int, SavedScreeningResult>{...state};
      for (final entry in latestByChild.entries) {
        final childId = entry.key;
        if (newState.containsKey(childId)) continue;
        final r = entry.value;
        final domainDqs = <String, double>{};
        final domainDelays = <String, bool>{};
        if (r['gm_dq'] != null) { domainDqs['gm_dq'] = (r['gm_dq'] as num).toDouble(); domainDelays['gm_delay'] = domainDqs['gm_dq']! < 85; }
        if (r['fm_dq'] != null) { domainDqs['fm_dq'] = (r['fm_dq'] as num).toDouble(); domainDelays['fm_delay'] = domainDqs['fm_dq']! < 85; }
        if (r['lc_dq'] != null) { domainDqs['lc_dq'] = (r['lc_dq'] as num).toDouble(); domainDelays['lc_delay'] = domainDqs['lc_dq']! < 85; }
        if (r['cog_dq'] != null) { domainDqs['cog_dq'] = (r['cog_dq'] as num).toDouble(); domainDelays['cog_delay'] = domainDqs['cog_dq']! < 85; }
        if (r['se_dq'] != null) { domainDqs['se_dq'] = (r['se_dq'] as num).toDouble(); domainDelays['se_delay'] = domainDqs['se_dq']! < 85; }

        final risk = r['overall_risk'] as String? ?? 'LOW';
        // Parse challenge fields from Supabase
        final numDelays = (r['num_delays'] as int?) ?? domainDelays.values.where((d) => d).length;
        final autismRisk = r['autism_risk'] as String? ?? 'Low';
        final adhdRisk = r['adhd_risk'] as String? ?? 'Low';
        final behaviorRisk = r['behavior_risk'] as String? ?? 'Low';
        final behaviorScore = (r['behavior_score'] as int?) ?? 0;
        final assessmentCycle = r['assessment_cycle'] as String? ?? 'Baseline';
        final baselineScore = (r['baseline_score'] as int?) ?? 0;
        final baseCat = r['baseline_category'] as String? ?? 'Low';

        newState[childId] = SavedScreeningResult(
          childId: childId,
          date: DateTime.tryParse(r['created_at'] as String? ?? '') ?? DateTime.now(),
          overallRisk: risk,
          overallRiskTe: '',
          referralNeeded: risk == 'HIGH',
          domainDqScores: domainDqs,
          domainDelays: domainDelays,
          concerns: const [],
          concernsTe: const [],
          toolsCompleted: (r['tools_completed'] as int?) ?? 0,
          toolsSkipped: (r['tools_skipped'] as int?) ?? 0,
          numDelays: numDelays,
          autismRisk: autismRisk,
          adhdRisk: adhdRisk,
          behaviorRisk: behaviorRisk,
          behaviorScore: behaviorScore,
          assessmentCycle: assessmentCycle,
          baselineScore: baselineScore,
          baselineCategory: baseCat,
        );
      }

      state = newState;
      // ignore: avoid_print
      print('[ResultsStorage] Loaded ${latestByChild.length} results from Supabase');

      // Run predictions on Supabase-loaded results
      _predictForSupabaseResults(results, latestByChild, newState);
    } catch (e) {
      // ignore: avoid_print
      print('[ResultsStorage] ERROR loading from Supabase: $e');
    }
  }

  /// Convert a Drift LocalScreeningResult to SavedScreeningResult.
  /// [delayThreshold] is configurable (default 85).
  static SavedScreeningResult _driftResultToSaved(int childId, LocalScreeningResult r, {double delayThreshold = 85}) {
    final domainDqs = <String, double>{};
    final domainDelays = <String, bool>{};
    if (r.gmDq != null) { domainDqs['gm_dq'] = r.gmDq!; domainDelays['gm_delay'] = r.gmDq! < delayThreshold; }
    if (r.fmDq != null) { domainDqs['fm_dq'] = r.fmDq!; domainDelays['fm_delay'] = r.fmDq! < delayThreshold; }
    if (r.lcDq != null) { domainDqs['lc_dq'] = r.lcDq!; domainDelays['lc_delay'] = r.lcDq! < delayThreshold; }
    if (r.cogDq != null) { domainDqs['cog_dq'] = r.cogDq!; domainDelays['cog_delay'] = r.cogDq! < delayThreshold; }
    if (r.seDq != null) { domainDqs['se_dq'] = r.seDq!; domainDelays['se_delay'] = r.seDq! < delayThreshold; }

    final concerns = r.concernsJson != null
        ? (jsonDecode(r.concernsJson!) as List).cast<String>()
        : <String>[];
    final concernsTe = r.concernsTeJson != null
        ? (jsonDecode(r.concernsTeJson!) as List).cast<String>()
        : <String>[];

    // Parse prediction fields
    List<String>? topFactors;
    List<String>? topFactorsTe;
    if (r.topRiskFactorsJson != null) {
      try {
        topFactors = (jsonDecode(r.topRiskFactorsJson!) as List).cast<String>();
      } catch (_) {}
    }

    return SavedScreeningResult(
      childId: childId,
      date: r.createdAt,
      overallRisk: r.overallRisk,
      overallRiskTe: r.overallRiskTe,
      referralNeeded: r.referralNeeded,
      domainDqScores: domainDqs,
      domainDelays: domainDelays,
      concerns: concerns,
      concernsTe: concernsTe,
      toolsCompleted: r.toolsCompleted,
      toolsSkipped: r.toolsSkipped,
      assessmentCycle: r.assessmentCycle,
      baselineScore: r.baselineScore,
      baselineCategory: r.baselineCategory,
      numDelays: r.numDelays,
      autismRisk: r.autismRisk,
      adhdRisk: r.adhdRisk,
      behaviorRisk: r.behaviorRisk,
      behaviorScore: r.behaviorScore,
      predictedRiskScore: r.predictedRiskScore,
      predictedRiskCategory: r.predictedRiskCategory,
      riskTrend: r.riskTrend,
      topRiskFactors: topFactors,
      topRiskFactorsTe: topFactorsTe,
    );
  }

  /// Compute predictions in-memory for results loaded from Supabase (not in Drift).
  Future<void> _predictForSupabaseResults(
    List<Map<String, dynamic>> allSupabaseResults,
    Map<int, Map<String, dynamic>> latestByChild,
    Map<int, SavedScreeningResult> currentState,
  ) async {
    try {
      // Get child ages from children data
      final childAgeMap = <int, int>{};
      if (DatabaseService.isAvailable) {
        final db = DatabaseService.db;
        final allChildren = await db.childrenDao.getAllChildren();
        final now = DateTime.now();
        for (final child in allChildren) {
          if (child.remoteId != null) {
            final ageMonths = ((now.difference(child.dob).inDays) / 30.44).floor();
            childAgeMap[child.remoteId!] = ageMonths.clamp(0, 72);
          }
        }
      } else {
        // On web: try to get ages from in-memory children data
        try {
          final children = await ref.read(childrenProvider.future);
          for (final c in children) {
            final childId = c['child_id'] as int?;
            final ageMonths = c['age_months'] as int?;
            if (childId != null && ageMonths != null) {
              childAgeMap[childId] = ageMonths;
            }
          }
        } catch (_) {}
      }

      int predictedCount = 0;
      final updatedState = <int, SavedScreeningResult>{...state};
      final predictor = FormulaPredictor();

      for (final entry in latestByChild.entries) {
        final childId = entry.key;
        final saved = updatedState[childId];
        if (saved == null || saved.predictedRiskScore != null) continue;

        // Get child age from session or DOB
        final session = entry.value['screening_sessions'] as Map<String, dynamic>?;
        final childAgeMonths = (session?['child_age_months'] as int?) ?? childAgeMap[childId] ?? 36;

        // Extract features (no previousResults since Drift is empty — use static features only)
        final features = FeatureExtractor.extract(
          current: saved,
          childAgeMonths: childAgeMonths,
          previousResults: const [],
        );
        final prediction = predictor.predict(features);

        updatedState[childId] = saved.withPrediction(prediction);
        predictedCount++;
      }

      if (predictedCount > 0) {
        state = updatedState;
        // ignore: avoid_print
        print('[ResultsStorage] Predicted risk for $predictedCount Supabase-loaded results');
      }
    } catch (e) {
      // ignore: avoid_print
      print('[ResultsStorage] Supabase prediction error (non-fatal): $e');
    }
  }

  /// Run backfill for existing results missing predictions, then refresh state.
  Future<void> _backfillAndRefresh(Map<int, LocalScreeningResult> latestByChild) async {
    // No backfill on web — Drift not available
    if (kIsWeb) return;

    try {
      final count = await PredictionService.backfillPredictions();
      if (count > 0) {
        // Reload the affected results from Drift to pick up new predictions
        final db = DatabaseService.db;
        final newState = <int, SavedScreeningResult>{...state};
        for (final childId in latestByChild.keys) {
          final latest = await db.screeningDao.getLatestResultForChildByRemoteId(childId);
          if (latest != null && latest.predictedRiskScore != null) {
            newState[childId] = _driftResultToSaved(childId, latest);
          }
        }
        state = newState;
        // ignore: avoid_print
        print('[ResultsStorage] Refreshed state after backfilling $count predictions');
      }
    } catch (e) {
      // ignore: avoid_print
      print('[ResultsStorage] Backfill refresh error: $e');
    }
  }

  void saveResult(int childId, SavedScreeningResult result) {
    state = {...state, childId: result};

    // Persist to Drift and enqueue for sync
    _persistToDrift(childId, result);
  }

  Future<void> _persistToDrift(int childId, SavedScreeningResult result) async {
    // On web, save directly to Supabase (no Drift)
    if (kIsWeb) {
      await _persistToSupabaseDirectly(childId, result);
      return;
    }

    try {
      final hub = ref.read(screeningHubProvider);
      final localSessionId = hub?.localSessionId;
      if (localSessionId == null) return;

      final db = DatabaseService.db;

      // Save result to Drift
      final toolResultsMap = <String, dynamic>{};
      for (final entry in result.domainDqScores.entries) {
        toolResultsMap[entry.key] = entry.value;
      }
      for (final entry in result.domainDelays.entries) {
        toolResultsMap[entry.key] = entry.value;
      }

      // Embed per-tool raw responses from hub so export can read them
      final perToolResponses = <String, dynamic>{};
      for (final tool in hub!.tools) {
        if (tool.responses.isNotEmpty) {
          perToolResponses[tool.config.type.name] = tool.responses;
        }
      }
      if (perToolResponses.isNotEmpty) {
        toolResultsMap['tool_responses'] = perToolResponses;
      }

      final resultLocalId = await db.screeningDao.saveResult(LocalScreeningResultsCompanion.insert(
        sessionLocalId: localSessionId,
        childLocalId: Value(hub?.child['local_id'] as int?),
        childRemoteId: Value(childId),
        overallRisk: result.overallRisk,
        overallRiskTe: Value(result.overallRiskTe),
        referralNeeded: Value(result.referralNeeded),
        gmDq: Value(result.domainDqScores['gm_dq']),
        fmDq: Value(result.domainDqScores['fm_dq']),
        lcDq: Value(result.domainDqScores['lc_dq']),
        cogDq: Value(result.domainDqScores['cog_dq']),
        seDq: Value(result.domainDqScores['se_dq']),
        compositeDq: Value(result.domainDqScores.values.isNotEmpty
            ? result.domainDqScores.values.reduce((a, b) => a + b) /
                result.domainDqScores.values.length
            : null),
        toolResultsJson: Value(jsonEncode(toolResultsMap)),
        concernsJson: Value(jsonEncode(result.concerns)),
        concernsTeJson: Value(jsonEncode(result.concernsTe)),
        toolsCompleted: Value(result.toolsCompleted),
        toolsSkipped: Value(result.toolsSkipped),
        // Challenge extension fields
        assessmentCycle: Value(result.assessmentCycle),
        baselineScore: Value(result.baselineScore),
        baselineCategory: Value(result.baselineCategory),
        numDelays: Value(result.numDelays),
        autismRisk: Value(result.autismRisk),
        adhdRisk: Value(result.adhdRisk),
        behaviorRisk: Value(result.behaviorRisk),
        behaviorScore: Value(result.behaviorScore),
      ));

      // Auto-create referrals based on risk scoring
      await ReferralService.evaluateAndCreateReferrals(
        childRemoteId: childId,
        screeningResultLocalId: resultLocalId,
        baselineCategory: result.baselineCategory,
        numDelays: result.numDelays,
        autismRisk: result.autismRisk,
        adhdRisk: result.adhdRisk,
        behaviorRisk: result.behaviorRisk,
        assessmentCycle: result.assessmentCycle,
        conductedByUserId: hub?.session['conducted_by']?.toString(),
      );

      // Run predictive risk scoring
      try {
        final childAgeMonths = hub?.childAgeMonths ?? 0;
        final prediction = await PredictionService.predictRisk(
          current: result,
          childAgeMonths: childAgeMonths,
          childRemoteId: childId,
        );
        // Update the Drift row with prediction
        await db.screeningDao.updatePrediction(
          resultLocalId: resultLocalId,
          predictedRiskScore: prediction.score,
          predictedRiskCategory: prediction.category,
          riskTrend: prediction.trend,
          topRiskFactorsJson: jsonEncode(prediction.topFactors),
        );
        // Update in-memory cache with prediction
        final updatedResult = result.withPrediction(prediction);
        state = {...state, childId: updatedResult};
        // ignore: avoid_print
        print('[ResultsStorage] Prediction: score=${prediction.score}, category=${prediction.category}, trend=${prediction.trend}');
      } catch (e) {
        // ignore: avoid_print
        print('[ResultsStorage] Prediction error (non-fatal): $e');
      }

      // Mark session completed
      await db.screeningDao.markSessionCompleted(localSessionId);

      // Enqueue for sync: session(p=0) → responses(p=1) → result(p=2)
      await db.syncQueueDao.enqueue(
        entityType: 'session',
        entityLocalId: localSessionId,
        operation: 'create',
        priority: 0,
      );
      await db.syncQueueDao.enqueue(
        entityType: 'responses',
        entityLocalId: localSessionId,
        operation: 'create',
        priority: 1,
      );
      await db.syncQueueDao.enqueue(
        entityType: 'result',
        entityLocalId: localSessionId,
        operation: 'create',
        priority: 2,
      );

      // Try immediate sync if online
      // ignore: avoid_print
      print('[ResultsStorage] Saved to Drift, session=$localSessionId, online=${ConnectivityService.isOnline}');
      if (ConnectivityService.isOnline) {
        // ignore: avoid_print
        print('[ResultsStorage] Triggering sync...');
        SyncService.processQueue();
      } else {
        // ignore: avoid_print
        print('[ResultsStorage] OFFLINE — sync queued for later');
      }
    } catch (e) {
      // ignore: avoid_print
      print('[ResultsStorage] ERROR persisting to Drift: $e');
    }
  }

  /// Web fallback: save screening result directly to Supabase (no Drift/sync queue).
  Future<void> _persistToSupabaseDirectly(int childId, SavedScreeningResult result) async {
    try {
      final hub = ref.read(screeningHubProvider);
      final session = hub?.session;
      final childAgeMonths = hub?.childAgeMonths ?? 0;

      // 1. Create session in Supabase
      final remoteSession = await SupabaseService.saveScreeningSession(
        childId: childId,
        conductedBy: session?['conducted_by']?.toString() ?? '',
        assessmentDate: DateTime.now().toIso8601String().split('T')[0],
        childAgeMonths: childAgeMonths,
        status: 'completed',
        deviceSessionId: session?['device_session_id']?.toString(),
      );
      final sessionId = remoteSession['id'] as int;

      // 2. Save responses
      if (hub != null) {
        for (final tool in hub.tools) {
          if (tool.responses.isNotEmpty) {
            await SupabaseService.saveScreeningResponses(
              sessionId: sessionId,
              toolType: tool.config.type.name,
              responses: tool.responses,
            );
          }
        }
      }

      // 3. Save result
      final toolResultsMap = <String, dynamic>{};
      for (final entry in result.domainDqScores.entries) {
        toolResultsMap[entry.key] = entry.value;
      }
      for (final entry in result.domainDelays.entries) {
        toolResultsMap[entry.key] = entry.value;
      }

      await SupabaseService.saveScreeningResult(
        sessionId: sessionId,
        childId: childId,
        overallRisk: result.overallRisk,
        overallRiskTe: result.overallRiskTe,
        referralNeeded: result.referralNeeded,
        gmDq: result.domainDqScores['gm_dq'],
        fmDq: result.domainDqScores['fm_dq'],
        lcDq: result.domainDqScores['lc_dq'],
        cogDq: result.domainDqScores['cog_dq'],
        seDq: result.domainDqScores['se_dq'],
        compositeDq: result.domainDqScores.values.isNotEmpty
            ? result.domainDqScores.values.reduce((a, b) => a + b) /
                result.domainDqScores.values.length
            : null,
        toolResults: toolResultsMap,
        concerns: result.concerns,
        concernsTe: result.concernsTe,
        toolsCompleted: result.toolsCompleted,
        toolsSkipped: result.toolsSkipped,
      );

      // 4. Run in-memory prediction (FormulaPredictor works on web)
      try {
        final prediction = await PredictionService.predictRisk(
          current: result,
          childAgeMonths: childAgeMonths,
          childRemoteId: childId,
        );
        final updatedResult = result.withPrediction(prediction);
        state = {...state, childId: updatedResult};
        // ignore: avoid_print
        print('[ResultsStorage] Web: saved to Supabase, prediction=${prediction.category}');
      } catch (e) {
        // ignore: avoid_print
        print('[ResultsStorage] Web: prediction error (non-fatal): $e');
      }

      // 5. Auto-create referrals
      await ReferralService.evaluateAndCreateReferrals(
        childRemoteId: childId,
        screeningResultLocalId: 0,
        baselineCategory: result.baselineCategory,
        numDelays: result.numDelays,
        autismRisk: result.autismRisk,
        adhdRisk: result.adhdRisk,
        behaviorRisk: result.behaviorRisk,
        assessmentCycle: result.assessmentCycle,
        conductedByUserId: hub?.session['conducted_by']?.toString(),
      );
    } catch (e) {
      // ignore: avoid_print
      print('[ResultsStorage] ERROR persisting to Supabase (web): $e');
    }
  }

  SavedScreeningResult? getResult(int childId) => state[childId];

  bool hasResult(int childId) => state.containsKey(childId);
}

final screeningResultsStorageProvider =
    NotifierProvider<ScreeningResultsStorageNotifier, Map<int, SavedScreeningResult>>(() {
  return ScreeningResultsStorageNotifier();
});
