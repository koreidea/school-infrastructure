import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/database_service.dart';
import '../services/connectivity_service.dart';
import '../services/audit_service.dart';

/// Generates a multi-tab Excel workbook matching the ECD_sample_data_sets format.
/// Merges data from BOTH Supabase (primary) and Drift local DB (fallback).
class EcdExcelExportService {
  static SupabaseClient get _client => Supabase.instance.client;

  /// Export all children data to a multi-tab Excel file and share it.
  /// Set [anonymize] to true to replace PII (names, IDs, phone numbers).
  static Future<void> exportAndShare({
    required BuildContext context,
    required List<Map<String, dynamic>> children,
    bool isTelugu = false,
    bool anonymize = false,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('Export not supported on web');
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(isTelugu
                ? 'ECD డేటా ఎగుమతి చేస్తోంది...'
                : 'Exporting ECD data...'),
          ],
        ),
      ),
    );

    try {
      final file = await _generateExcel(children, anonymize: anonymize);

      // Audit log the export
      AuditService.log(
        action: 'export_data',
        entityType: 'export',
        details: {
          'children_count': children.length,
          'anonymized': anonymize,
          'format': 'xlsx',
        },
      );

      if (!context.mounted) return;
      Navigator.pop(context);

      if (!context.mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(file.path)],
        text: isTelugu ? 'బాల Vikas ECD డేటాసెట్' : 'Bal Vikas ECD Dataset',
        subject: 'ECD_Data_Export',
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null,
      );
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isTelugu
                ? 'ఎగుమతి విఫలమైంది: $e'
                : 'Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Core generation — merges Supabase + Drift
  // ---------------------------------------------------------------------------

  static Future<File> _generateExcel(
      List<Map<String, dynamic>> children, {bool anonymize = false}) async {
    final excel = Excel.createExcel();

    await addEcdDataTabs(excel, children, anonymize: anonymize);

    // Remove default "Sheet1"
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    final dir = await getTemporaryDirectory();
    final dateStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final filePath = '${dir.path}/ECD_Dataset_$dateStr.xlsx';
    final fileBytes = excel.encode();
    if (fileBytes == null) throw Exception('Failed to encode Excel');
    final file = File(filePath);
    await file.writeAsBytes(fileBytes, flush: true);
    return file;
  }

  /// Public method: Add all 12 ECD per-child data tabs to an existing Excel workbook.
  /// Used by both the AWW direct export and the Reports tab combined export.
  /// Fetches data from Supabase (primary) + Drift (fallback) for all children.
  /// Set [anonymize] to true to replace PII (names, unique IDs) with pseudonyms.
  static Future<void> addEcdDataTabs(
      Excel excel, List<Map<String, dynamic>> children, {bool anonymize = false}) async {
    // If anonymizing, create a copy with PII replaced
    final exportChildren = anonymize ? _anonymizeChildren(children) : children;

    final childIds = <int>[];
    for (final c in exportChildren) {
      final cid = c['child_id'] as int?;
      if (cid != null) childIds.add(cid);
    }

    // ---- Fetch screening results: Supabase first, then Drift fallback ----
    final latestResult = <int, Map<String, dynamic>>{}; // childId → unified map

    // Source 1: Supabase (if online)
    if (ConnectivityService.isOnline && childIds.isNotEmpty) {
      try {
        final remoteResults = await _client
            .from('screening_results')
            .select('*, screening_sessions!inner(*)')
            .inFilter('child_id', childIds)
            .order('created_at', ascending: false);
        for (final r in remoteResults) {
          final cid = r['child_id'] as int?;
          if (cid != null && !latestResult.containsKey(cid)) {
            latestResult[cid] = _normalizeScreeningResult(r);
          }
        }
      } catch (e) {
        debugPrint('[ECD-Export] Supabase screening query failed: $e');
      }
    }

    // Source 2: Drift (fallback for children not found in Supabase)
    if (!kIsWeb) {
      try {
        final db = DatabaseService.db;
        final allResults = await db.screeningDao.getAllResults();
        allResults.sort((a, b) => b.id.compareTo(a.id));
        for (final r in allResults) {
          final cid = r.childRemoteId;
          if (cid != null && !latestResult.containsKey(cid)) {
            Map<String, dynamic>? toolResultsRaw;
            if (r.toolResultsJson != null) {
              try {
                toolResultsRaw = jsonDecode(r.toolResultsJson!) as Map<String, dynamic>?;
              } catch (_) {}
            }
            latestResult[cid] = {
              'overall_risk': r.overallRisk,
              'gm_dq': r.gmDq,
              'fm_dq': r.fmDq,
              'lc_dq': r.lcDq,
              'cog_dq': r.cogDq,
              'se_dq': r.seDq,
              'composite_dq': r.compositeDq,
              'autism_risk': r.autismRisk,
              'adhd_risk': r.adhdRisk,
              'behavior_risk': r.behaviorRisk,
              'behavior_score': r.behaviorScore,
              'baseline_score': r.baselineScore,
              'baseline_category': r.baselineCategory,
              'num_delays': r.numDelays,
              'assessment_cycle': r.assessmentCycle,
              'referral_needed': r.referralNeeded,
              'tools_completed': r.toolsCompleted,
              '_tool_results_raw': toolResultsRaw,
            };
          }
        }
      } catch (e) {
        debugPrint('[ECD-Export] Drift screening query failed: $e');
      }
    }

    // ---- Fetch nutrition: Supabase + Drift ----
    final latestNutrition = <int, Map<String, dynamic>>{};
    if (ConnectivityService.isOnline && childIds.isNotEmpty) {
      try {
        final rows = await _client
            .from('nutrition_assessments')
            .select()
            .inFilter('child_id', childIds)
            .order('created_at', ascending: false);
        for (final r in rows) {
          final cid = r['child_id'] as int?;
          if (cid != null && !latestNutrition.containsKey(cid)) {
            latestNutrition[cid] = r;
          }
        }
      } catch (_) {}
    }
    // Drift fallback
    if (!kIsWeb) {
      try {
        final allNut = await DatabaseService.db.challengeDao.getAllNutritionAssessments();
        for (final n in allNut) {
          final cid = n.childRemoteId;
          if (cid != null && !latestNutrition.containsKey(cid)) {
            latestNutrition[cid] = {
              'underweight': n.underweight,
              'stunting': n.stunting,
              'wasting': n.wasting,
              'anemia': n.anemia,
              'nutrition_score': n.nutritionScore,
              'nutrition_risk': n.nutritionRisk,
            };
          }
        }
      } catch (_) {}
    }

    // ---- Fetch environment: Supabase + Drift ----
    final latestEnvironment = <int, Map<String, dynamic>>{};
    if (ConnectivityService.isOnline && childIds.isNotEmpty) {
      try {
        final rows = await _client
            .from('environment_assessments')
            .select()
            .inFilter('child_id', childIds)
            .order('created_at', ascending: false);
        for (final r in rows) {
          final cid = r['child_id'] as int?;
          if (cid != null && !latestEnvironment.containsKey(cid)) {
            latestEnvironment[cid] = r;
          }
        }
      } catch (_) {}
    }
    // Drift fallback
    if (!kIsWeb) {
      try {
        for (final cid in childIds) {
          if (latestEnvironment.containsKey(cid)) continue;
          final env = await DatabaseService.db.challengeDao.getLatestEnvironmentForChild(cid);
          if (env != null) {
            latestEnvironment[cid] = {
              'parent_child_interaction_score': env.parentChildInteractionScore,
              'parent_mental_health_score': env.parentMentalHealthScore,
              'home_stimulation_score': env.homeStimulationScore,
              'play_materials': env.playMaterials,
              'caregiver_engagement': env.caregiverEngagement,
              'language_exposure': env.languageExposure,
              'safe_water': env.safeWater,
              'toilet_facility': env.toiletFacility,
            };
          }
        }
      } catch (_) {}
    }

    // ---- Fetch referrals: Supabase + Drift ----
    final latestReferral = <int, Map<String, dynamic>>{};
    if (ConnectivityService.isOnline && childIds.isNotEmpty) {
      try {
        final rows = await _client
            .from('referrals')
            .select()
            .inFilter('child_id', childIds)
            .order('created_at', ascending: false);
        for (final r in rows) {
          final cid = r['child_id'] as int?;
          if (cid != null && !latestReferral.containsKey(cid)) {
            latestReferral[cid] = r;
          }
        }
      } catch (_) {}
    }
    // Drift fallback
    if (!kIsWeb) {
      try {
        final allRef = await DatabaseService.db.referralDao.getAllReferrals();
        for (final r in allRef) {
          final cid = r.childRemoteId;
          if (cid != null && !latestReferral.containsKey(cid)) {
            latestReferral[cid] = {
              'referral_triggered': r.referralTriggered,
              'referral_type': r.referralType,
              'referral_reason': r.referralReason,
              'referral_status': r.referralStatus,
            };
          }
        }
      } catch (_) {}
    }

    // ---- Fetch intervention follow-ups: Supabase + Drift ----
    final latestFollowup = <int, Map<String, dynamic>>{};
    if (ConnectivityService.isOnline && childIds.isNotEmpty) {
      try {
        final rows = await _client
            .from('intervention_followups')
            .select()
            .inFilter('child_id', childIds)
            .order('created_at', ascending: false);
        for (final r in rows) {
          final cid = r['child_id'] as int?;
          if (cid != null && !latestFollowup.containsKey(cid)) {
            latestFollowup[cid] = r;
          }
        }
      } catch (_) {}
    }
    // Drift fallback
    if (!kIsWeb) {
      try {
        final allFu = await DatabaseService.db.challengeDao.getAllFollowups();
        for (final f in allFu) {
          final cid = f.childRemoteId;
          if (cid != null && !latestFollowup.containsKey(cid)) {
            latestFollowup[cid] = {
              'intervention_plan_generated': f.interventionPlanGenerated,
              'home_activities_assigned': f.homeActivitiesAssigned,
              'followup_conducted': f.followupConducted,
              'improvement_status': f.improvementStatus,
              'reduction_in_delay_months': f.reductionInDelayMonths,
              'domain_improvement': f.domainImprovement,
              'autism_risk_change': f.autismRiskChange,
              'exit_high_risk': f.exitHighRisk,
            };
          }
        }
      } catch (_) {}
    }

    // ---- Extract per-tool responses from tool_results in screening_results ----
    // The tool_results / toolResultsJson field contains a 'tool_responses' key
    // with per-tool raw question responses (saved during _persistToDrift).
    final toolResponses = <int, Map<String, Map<String, dynamic>>>{};
    const _targetTools = {'rbskTool', 'isaaAutism', 'rbskBehavioral', 'rbskBirthDefects', 'rbskDiseases'};

    for (final cid in childIds) {
      final result = latestResult[cid];
      if (result == null) continue;
      final rawToolResults = result['_tool_results_raw'];
      if (rawToolResults is Map<String, dynamic>) {
        final responses = rawToolResults['tool_responses'];
        if (responses is Map<String, dynamic>) {
          final childTools = <String, Map<String, dynamic>>{};
          for (final entry in responses.entries) {
            if (_targetTools.contains(entry.key) && entry.value is Map) {
              childTools[entry.key] = Map<String, dynamic>.from(entry.value as Map);
            }
          }
          if (childTools.isNotEmpty) {
            toolResponses[cid] = childTools;
          }
        }
      }
    }

    // ---- Build sheets ----
    _buildRegistration(excel, exportChildren, latestResult);
    _buildDevelopmentalRisk(excel, childIds, latestResult);
    _buildNeuroBehavioral(excel, childIds, latestResult);
    _buildNutrition(excel, childIds, latestNutrition);
    _buildEnvironmentCaregiving(excel, childIds, latestEnvironment);
    _buildDevelopmentalAssessment(excel, childIds, latestResult);
    _buildRiskClassification(excel, childIds, latestResult, latestNutrition);
    _buildBehaviourIndicators(excel, childIds, latestResult);
    _buildBaselineRiskOutput(excel, childIds, latestResult);
    _buildReferralAction(excel, childIds, latestReferral);
    _buildInterventionFollowUp(excel, childIds, latestFollowup);
    _buildOutcomesImpact(excel, childIds, latestFollowup);

    // ---- Per-tool detail sheets ----
    _buildRbskDevelopmental(excel, childIds, toolResponses);
    _buildIsaaAssessment(excel, childIds, toolResponses);
    _buildRbskBehavioral(excel, childIds, toolResponses);
    _buildRbskBirthDefectsTab(excel, childIds, toolResponses);
    _buildRbskDiseasesTab(excel, childIds, toolResponses);
  }

  /// Fetch children data for a scope (used by Reports tab to get children list).
  /// Returns list of maps with child_id, name, dob, age_months, gender, awc_id, child_unique_id.
  static Future<List<Map<String, dynamic>>> fetchChildrenForScope(
      String scope, int scopeId) async {
    try {
      List<int> awcIds = [];

      if (scope == 'sector') {
        final awcs = await _client
            .from('anganwadi_centres')
            .select('id')
            .eq('sector_id', scopeId)
            .eq('is_active', true);
        awcIds = (awcs as List).map<int>((a) => a['id'] as int).toList();
      } else if (scope == 'project') {
        final sectors = await _client
            .from('sectors')
            .select('id')
            .eq('project_id', scopeId);
        final sectorIds = (sectors as List).map<int>((s) => s['id'] as int).toList();
        if (sectorIds.isEmpty) return [];
        final awcs = await _client
            .from('anganwadi_centres')
            .select('id')
            .inFilter('sector_id', sectorIds)
            .eq('is_active', true);
        awcIds = (awcs as List).map<int>((a) => a['id'] as int).toList();
      } else if (scope == 'district') {
        final projects = await _client
            .from('projects')
            .select('id')
            .eq('district_id', scopeId);
        final projectIds = (projects as List).map<int>((p) => p['id'] as int).toList();
        if (projectIds.isEmpty) return [];
        final sectors = await _client
            .from('sectors')
            .select('id')
            .inFilter('project_id', projectIds);
        final sectorIds = (sectors as List).map<int>((s) => s['id'] as int).toList();
        if (sectorIds.isEmpty) return [];
        final awcs = await _client
            .from('anganwadi_centres')
            .select('id')
            .inFilter('sector_id', sectorIds)
            .eq('is_active', true);
        awcIds = (awcs as List).map<int>((a) => a['id'] as int).toList();
      } else if (scope == 'state') {
        final rows = await _client
            .from('children')
            .select('id, name, dob, gender, awc_id, child_unique_id')
            .eq('is_active', true)
            .limit(5000);
        return _mapChildrenRows(rows as List);
      }

      if (awcIds.isEmpty) return [];

      final rows = await _client
          .from('children')
          .select('id, name, dob, gender, awc_id, child_unique_id')
          .inFilter('awc_id', awcIds)
          .eq('is_active', true);
      return _mapChildrenRows(rows as List);
    } catch (e) {
      debugPrint('[ECD-Export] fetchChildrenForScope error: $e');
      return [];
    }
  }

  /// Map Supabase children rows to unified format, computing age_months from dob.
  static List<Map<String, dynamic>> _mapChildrenRows(List rows) {
    final now = DateTime.now();
    return rows.map<Map<String, dynamic>>((r) {
      int? ageMonths;
      final dobStr = r['dob']?.toString();
      if (dobStr != null) {
        final dob = DateTime.tryParse(dobStr);
        if (dob != null) {
          ageMonths = (now.year - dob.year) * 12 + now.month - dob.month;
        }
      }
      return {
        'child_id': r['id'],
        'name': r['name'],
        'dob': r['dob'],
        'age_months': ageMonths,
        'gender': r['gender'],
        'awc_id': r['awc_id'],
        'child_unique_id': r['child_unique_id'],
      };
    }).toList();
  }

  /// Replace PII in children list for anonymized export.
  /// Keeps: age, gender, scores, risk levels, dates.
  /// Replaces: names → "Child-001", unique IDs → hash-based pseudonym.
  static List<Map<String, dynamic>> _anonymizeChildren(
      List<Map<String, dynamic>> children) {
    return List.generate(children.length, (i) {
      final c = Map<String, dynamic>.from(children[i]);
      final idx = (i + 1).toString().padLeft(3, '0');
      c['name'] = 'Child-$idx';
      if (c['child_unique_id'] != null) {
        final hash = c['child_unique_id'].toString().hashCode.toRadixString(16).padLeft(8, '0');
        c['child_unique_id'] = 'ANON-$hash';
      }
      // Remove guardian/phone if present
      c.remove('guardian_name');
      c.remove('guardian_phone');
      c.remove('parent_phone');
      c.remove('parent_name');
      return c;
    });
  }

  /// Normalize a Supabase screening_results row to a unified Map
  static Map<String, dynamic> _normalizeScreeningResult(Map<String, dynamic> r) {
    // DQ values
    final gmDq = _toDouble(r['gm_dq']);
    final fmDq = _toDouble(r['fm_dq']);
    final lcDq = _toDouble(r['lc_dq']);
    final cogDq = _toDouble(r['cog_dq']);
    final seDq = _toDouble(r['se_dq']);
    final compositeDq = _toDouble(r['composite_dq']);

    // Compute delays from DQ scores
    final gmDelay = gmDq != null && gmDq < 75;
    final fmDelay = fmDq != null && fmDq < 75;
    final lcDelay = lcDq != null && lcDq < 75;
    final cogDelay = cogDq != null && cogDq < 75;
    final seDelay = seDq != null && seDq < 75;
    final numDelays = [gmDelay, fmDelay, lcDelay, cogDelay, seDelay]
        .where((d) => d)
        .length;

    // Tool results may contain autism/adhd/behavior risk
    final toolResults = r['tool_results'] as Map<String, dynamic>? ?? {};
    final autismRisk = r['autism_risk'] as String? ??
        toolResults['mchat_risk'] as String? ??
        _mapRiskFromOverall(toolResults, 'mchat');
    final adhdRisk = r['adhd_risk'] as String? ??
        toolResults['adhd_risk'] as String? ??
        _mapRiskFromOverall(toolResults, 'adhd');
    final behaviorRisk = r['behavior_risk'] as String? ??
        toolResults['sdq_risk'] as String? ??
        _mapRiskFromOverall(toolResults, 'sdq');
    final behaviorScore = r['behavior_score'] as int? ??
        toolResults['sdq_score'] as int? ?? 0;

    // Baseline scoring
    final baselineScore = r['baseline_score'] as int? ??
        _computeBaseline(numDelays, autismRisk, adhdRisk, behaviorRisk);
    final baselineCat = r['baseline_category'] as String? ??
        _baselineCategory(baselineScore);

    return {
      'overall_risk': r['overall_risk'] ?? 'LOW',
      'gm_dq': gmDq,
      'fm_dq': fmDq,
      'lc_dq': lcDq,
      'cog_dq': cogDq,
      'se_dq': seDq,
      'composite_dq': compositeDq,
      'autism_risk': autismRisk,
      'adhd_risk': adhdRisk,
      'behavior_risk': behaviorRisk,
      'behavior_score': behaviorScore,
      'baseline_score': baselineScore,
      'baseline_category': baselineCat,
      'num_delays': numDelays,
      'assessment_cycle': r['assessment_cycle'] ?? 'Baseline',
      'referral_needed': r['referral_needed'] ?? false,
      'tools_completed': r['tools_completed'] ?? 0,
      '_tool_results_raw': toolResults,
    };
  }

  // ---------------------------------------------------------------------------
  // Header styling
  // ---------------------------------------------------------------------------
  static CellStyle _headerStyle() {
    return CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#4472C4'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
    );
  }

  static void _addHeaderRow(Sheet sheet, List<String> headers) {
    final style = _headerStyle();
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = style;
    }
  }

  static void _setCell(Sheet sheet, int row, int col, dynamic value) {
    final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    if (value == null) {
      cell.value = TextCellValue('');
    } else if (value is int) {
      cell.value = IntCellValue(value);
    } else if (value is double) {
      cell.value = DoubleCellValue(value);
    } else if (value is bool) {
      cell.value = TextCellValue(value ? 'Yes' : 'No');
    } else {
      cell.value = TextCellValue(value.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Sheet builders — all use Map<String, dynamic> (unified format)
  // ---------------------------------------------------------------------------

  /// 1. Registration
  static void _buildRegistration(
      Excel excel,
      List<Map<String, dynamic>> children,
      Map<int, Map<String, dynamic>> latestResult) {
    final sheet = excel['Registration'];
    final headers = [
      'child_id', 'name', 'dob', 'age_months', 'gender',
      'awc_id', 'child_unique_id', 'assessment_cycle',
    ];
    _addHeaderRow(sheet, headers);

    for (var i = 0; i < children.length; i++) {
      final c = children[i];
      final cid = c['child_id'] as int?;
      final r = cid != null ? latestResult[cid] : null;
      final row = i + 1;
      _setCell(sheet, row, 0, cid);
      _setCell(sheet, row, 1, c['name']);
      _setCell(sheet, row, 2, c['dob']?.toString().split('T').first ?? '');
      _setCell(sheet, row, 3, c['age_months']);
      _setCell(sheet, row, 4, c['gender']);
      _setCell(sheet, row, 5, c['awc_id']);
      _setCell(sheet, row, 6, c['child_unique_id']);
      _setCell(sheet, row, 7, r?['assessment_cycle'] ?? 'Baseline');
    }
  }

  /// 2. Developmental_Risk
  static void _buildDevelopmentalRisk(
      Excel excel, List<int> childIds, Map<int, Map<String, dynamic>> latestResult) {
    final sheet = excel['Developmental_Risk'];
    final headers = [
      'child_id', 'GM_delay', 'FM_delay', 'LC_delay',
      'COG_delay', 'SE_delay', 'num_delays',
    ];
    _addHeaderRow(sheet, headers);

    for (var i = 0; i < childIds.length; i++) {
      final cid = childIds[i];
      final r = latestResult[cid];
      final row = i + 1;
      _setCell(sheet, row, 0, cid);
      if (r != null) {
        final gmDelay = _isDqDelay(r['gm_dq']);
        final fmDelay = _isDqDelay(r['fm_dq']);
        final lcDelay = _isDqDelay(r['lc_dq']);
        final cogDelay = _isDqDelay(r['cog_dq']);
        final seDelay = _isDqDelay(r['se_dq']);
        _setCell(sheet, row, 1, gmDelay);
        _setCell(sheet, row, 2, fmDelay);
        _setCell(sheet, row, 3, lcDelay);
        _setCell(sheet, row, 4, cogDelay);
        _setCell(sheet, row, 5, seDelay);
        _setCell(sheet, row, 6, [gmDelay, fmDelay, lcDelay, cogDelay, seDelay]
            .where((d) => d).length);
      } else {
        for (var c = 1; c <= 6; c++) _setCell(sheet, row, c, '');
      }
    }
  }

  /// 3. Neuro_Behavioral
  static void _buildNeuroBehavioral(
      Excel excel, List<int> childIds, Map<int, Map<String, dynamic>> latestResult) {
    final sheet = excel['Neuro_Behavioral'];
    final headers = ['child_id', 'autism_risk', 'adhd_risk', 'behavior_risk'];
    _addHeaderRow(sheet, headers);

    for (var i = 0; i < childIds.length; i++) {
      final cid = childIds[i];
      final r = latestResult[cid];
      final row = i + 1;
      _setCell(sheet, row, 0, cid);
      _setCell(sheet, row, 1, r?['autism_risk'] ?? '');
      _setCell(sheet, row, 2, r?['adhd_risk'] ?? '');
      _setCell(sheet, row, 3, r?['behavior_risk'] ?? '');
    }
  }

  /// 4. Nutrition
  static void _buildNutrition(
      Excel excel, List<int> childIds, Map<int, Map<String, dynamic>> latestNutrition) {
    final sheet = excel['Nutrition'];
    final headers = [
      'child_id', 'underweight', 'stunting', 'wasting', 'anemia',
      'nutrition_score', 'nutrition_risk',
    ];
    _addHeaderRow(sheet, headers);

    for (var i = 0; i < childIds.length; i++) {
      final cid = childIds[i];
      final n = latestNutrition[cid];
      final row = i + 1;
      _setCell(sheet, row, 0, cid);
      if (n != null) {
        _setCell(sheet, row, 1, n['underweight']);
        _setCell(sheet, row, 2, n['stunting']);
        _setCell(sheet, row, 3, n['wasting']);
        _setCell(sheet, row, 4, n['anemia']);
        _setCell(sheet, row, 5, n['nutrition_score']);
        _setCell(sheet, row, 6, n['nutrition_risk']);
      } else {
        for (var c = 1; c <= 6; c++) _setCell(sheet, row, c, '');
      }
    }
  }

  /// 5. Environment_Caregiving
  static void _buildEnvironmentCaregiving(
      Excel excel, List<int> childIds, Map<int, Map<String, dynamic>> latestEnvironment) {
    final sheet = excel['Environment_Caregiving'];
    final headers = [
      'child_id', 'parent_child_interaction_score',
      'parent_mental_health_score', 'home_stimulation_score',
      'play_materials', 'caregiver_engagement', 'language_exposure',
      'safe_water', 'toilet_facility',
    ];
    _addHeaderRow(sheet, headers);

    for (var i = 0; i < childIds.length; i++) {
      final cid = childIds[i];
      final e = latestEnvironment[cid];
      final row = i + 1;
      _setCell(sheet, row, 0, cid);
      if (e != null) {
        _setCell(sheet, row, 1, e['parent_child_interaction_score']);
        _setCell(sheet, row, 2, e['parent_mental_health_score']);
        _setCell(sheet, row, 3, e['home_stimulation_score']);
        _setCell(sheet, row, 4, e['play_materials']);
        _setCell(sheet, row, 5, e['caregiver_engagement']);
        _setCell(sheet, row, 6, e['language_exposure']);
        _setCell(sheet, row, 7, e['safe_water']);
        _setCell(sheet, row, 8, e['toilet_facility']);
      } else {
        for (var c = 1; c <= 8; c++) _setCell(sheet, row, c, '');
      }
    }
  }

  /// 6. Developmental_Assessment
  static void _buildDevelopmentalAssessment(
      Excel excel, List<int> childIds, Map<int, Map<String, dynamic>> latestResult) {
    final sheet = excel['Developmental_Assessment'];
    final headers = [
      'child_id', 'GM_DQ', 'FM_DQ', 'LC_DQ', 'COG_DQ', 'SE_DQ',
      'Composite_DQ',
    ];
    _addHeaderRow(sheet, headers);

    for (var i = 0; i < childIds.length; i++) {
      final cid = childIds[i];
      final r = latestResult[cid];
      final row = i + 1;
      _setCell(sheet, row, 0, cid);
      if (r != null) {
        _setCell(sheet, row, 1, _toDouble(r['gm_dq']));
        _setCell(sheet, row, 2, _toDouble(r['fm_dq']));
        _setCell(sheet, row, 3, _toDouble(r['lc_dq']));
        _setCell(sheet, row, 4, _toDouble(r['cog_dq']));
        _setCell(sheet, row, 5, _toDouble(r['se_dq']));
        _setCell(sheet, row, 6, _toDouble(r['composite_dq']));
      } else {
        for (var c = 1; c <= 6; c++) _setCell(sheet, row, c, '');
      }
    }
  }

  /// 7. Risk_Classification
  static void _buildRiskClassification(
      Excel excel,
      List<int> childIds,
      Map<int, Map<String, dynamic>> latestResult,
      Map<int, Map<String, dynamic>> latestNutrition) {
    final sheet = excel['Risk_Classification'];
    final headers = [
      'child_id', 'developmental_status', 'autism_risk',
      'attention_regulation_risk', 'nutrition_linked_risk',
    ];
    _addHeaderRow(sheet, headers);

    for (var i = 0; i < childIds.length; i++) {
      final cid = childIds[i];
      final r = latestResult[cid];
      final n = latestNutrition[cid];
      final row = i + 1;
      _setCell(sheet, row, 0, cid);
      _setCell(sheet, row, 1, r?['overall_risk'] ?? '');
      _setCell(sheet, row, 2, r?['autism_risk'] ?? '');
      _setCell(sheet, row, 3, r?['adhd_risk'] ?? '');
      _setCell(sheet, row, 4, n?['nutrition_risk'] ?? '');
    }
  }

  /// 8. Behaviour_indicators
  static void _buildBehaviourIndicators(
      Excel excel, List<int> childIds, Map<int, Map<String, dynamic>> latestResult) {
    final sheet = excel['Behaviour_indicators'];
    final headers = [
      'child_id', 'behaviour_concerns', 'behaviour_score',
      'behaviour_risk_level',
    ];
    _addHeaderRow(sheet, headers);

    for (var i = 0; i < childIds.length; i++) {
      final cid = childIds[i];
      final r = latestResult[cid];
      final row = i + 1;
      _setCell(sheet, row, 0, cid);
      if (r != null) {
        final risk = r['behavior_risk']?.toString() ?? '';
        _setCell(sheet, row, 1, risk != 'Low' && risk.isNotEmpty);
        _setCell(sheet, row, 2, r['behavior_score'] ?? 0);
        _setCell(sheet, row, 3, risk);
      } else {
        for (var c = 1; c <= 3; c++) _setCell(sheet, row, c, '');
      }
    }
  }

  /// 9. Baseline_Risk_Output
  static void _buildBaselineRiskOutput(
      Excel excel, List<int> childIds, Map<int, Map<String, dynamic>> latestResult) {
    final sheet = excel['Baseline_Risk_Output'];
    final headers = ['child_id', 'baseline_score', 'baseline_category'];
    _addHeaderRow(sheet, headers);

    for (var i = 0; i < childIds.length; i++) {
      final cid = childIds[i];
      final r = latestResult[cid];
      final row = i + 1;
      _setCell(sheet, row, 0, cid);
      _setCell(sheet, row, 1, r?['baseline_score'] ?? '');
      _setCell(sheet, row, 2, r?['baseline_category'] ?? '');
    }
  }

  /// 10. Referral_Action
  static void _buildReferralAction(
      Excel excel, List<int> childIds, Map<int, Map<String, dynamic>> latestReferral) {
    final sheet = excel['Referral_Action'];
    final headers = [
      'child_id', 'referral_triggered', 'referral_type',
      'referral_reason', 'referral_status',
    ];
    _addHeaderRow(sheet, headers);

    for (var i = 0; i < childIds.length; i++) {
      final cid = childIds[i];
      final r = latestReferral[cid];
      final row = i + 1;
      _setCell(sheet, row, 0, cid);
      if (r != null) {
        _setCell(sheet, row, 1, r['referral_triggered'] ?? false);
        _setCell(sheet, row, 2, r['referral_type'] ?? '');
        _setCell(sheet, row, 3, r['referral_reason'] ?? '');
        _setCell(sheet, row, 4, r['referral_status'] ?? '');
      } else {
        _setCell(sheet, row, 1, 'No');
        for (var c = 2; c <= 4; c++) _setCell(sheet, row, c, '');
      }
    }
  }

  /// 11. Intervention_FollowUp
  static void _buildInterventionFollowUp(
      Excel excel, List<int> childIds, Map<int, Map<String, dynamic>> latestFollowup) {
    final sheet = excel['Intervention_FollowUp'];
    final headers = [
      'child_id', 'intervention_plan_generated', 'home_activities_assigned',
      'followup_conducted', 'improvement_status',
    ];
    _addHeaderRow(sheet, headers);

    for (var i = 0; i < childIds.length; i++) {
      final cid = childIds[i];
      final f = latestFollowup[cid];
      final row = i + 1;
      _setCell(sheet, row, 0, cid);
      if (f != null) {
        _setCell(sheet, row, 1, f['intervention_plan_generated'] ?? false);
        _setCell(sheet, row, 2, f['home_activities_assigned'] ?? 0);
        _setCell(sheet, row, 3, f['followup_conducted'] ?? false);
        _setCell(sheet, row, 4, f['improvement_status'] ?? '');
      } else {
        _setCell(sheet, row, 1, 'No');
        _setCell(sheet, row, 2, 0);
        _setCell(sheet, row, 3, 'No');
        _setCell(sheet, row, 4, '');
      }
    }
  }

  /// 12. Outcomes_Impact
  static void _buildOutcomesImpact(
      Excel excel, List<int> childIds, Map<int, Map<String, dynamic>> latestFollowup) {
    final sheet = excel['Outcomes_Impact'];
    final headers = [
      'child_id', 'reduction_in_delay_months', 'domain_improvement',
      'autism_risk_change', 'exit_high_risk',
    ];
    _addHeaderRow(sheet, headers);

    for (var i = 0; i < childIds.length; i++) {
      final cid = childIds[i];
      final f = latestFollowup[cid];
      final row = i + 1;
      _setCell(sheet, row, 0, cid);
      if (f != null) {
        _setCell(sheet, row, 1, f['reduction_in_delay_months'] ?? 0);
        _setCell(sheet, row, 2, f['domain_improvement'] ?? false);
        _setCell(sheet, row, 3, f['autism_risk_change'] ?? 'Same');
        _setCell(sheet, row, 4, f['exit_high_risk'] ?? false);
      } else {
        _setCell(sheet, row, 1, 0);
        _setCell(sheet, row, 2, 'No');
        _setCell(sheet, row, 3, 'Same');
        _setCell(sheet, row, 4, 'No');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static bool _isDqDelay(dynamic dq) {
    final v = _toDouble(dq);
    if (v == null) return false;
    return v < 75.0;
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  /// Try to extract risk level from tool_results map
  static String _mapRiskFromOverall(Map<String, dynamic> toolResults, String tool) {
    final val = toolResults['${tool}_overall'] as String?;
    if (val == null) return 'Low';
    if (val.toUpperCase().contains('HIGH')) return 'High';
    if (val.toUpperCase().contains('MED') || val.toUpperCase().contains('MOD')) return 'Moderate';
    return 'Low';
  }

  static int _computeBaseline(int numDelays, String autism, String adhd, String behavior) {
    int score = numDelays * 5;
    score += autism == 'High' ? 15 : (autism == 'Moderate' ? 8 : 0);
    score += adhd == 'High' ? 8 : (adhd == 'Moderate' ? 4 : 0);
    score += behavior == 'High' ? 7 : 0;
    return score;
  }

  static String _baselineCategory(int score) =>
      score <= 10 ? 'Low' : (score <= 25 ? 'Medium' : 'High');

  // ---------------------------------------------------------------------------
  // Per-tool detail sheets (5 missing tools)
  // ---------------------------------------------------------------------------

  /// 13. RBSK Developmental — 5 domains (motor, cognitive, language, social, adaptive)
  /// Responses: rbsk_m1..m5, rbsk_c1..c5, rbsk_l1..l5, rbsk_s1..s5, rbsk_a1..a5 (values 0/1/2)
  static void _buildRbskDevelopmental(
      Excel excel,
      List<int> childIds,
      Map<int, Map<String, Map<String, dynamic>>> toolResponses) {
    final sheet = excel['RBSK_Developmental'];
    final headers = [
      'child_id', 'Motor', 'Cognitive', 'Language', 'Social', 'Adaptive',
      'Total_Score', 'Max_Score', 'Risk_Level',
    ];
    _addHeaderRow(sheet, headers);

    final domainPrefixes = {
      'motor': 'rbsk_m',
      'cognitive': 'rbsk_c',
      'language': 'rbsk_l',
      'social': 'rbsk_s',
      'adaptive': 'rbsk_a',
    };

    for (var i = 0; i < childIds.length; i++) {
      final cid = childIds[i];
      final resp = toolResponses[cid]?['rbskTool'];
      final row = i + 1;
      _setCell(sheet, row, 0, cid);
      if (resp != null) {
        int total = 0;
        int col = 1;
        for (final entry in domainPrefixes.entries) {
          int domainScore = 0;
          for (var q = 1; q <= 5; q++) {
            final val = resp['${entry.value}$q'];
            domainScore += (val is int ? val : int.tryParse(val?.toString() ?? '') ?? 0);
          }
          total += domainScore;
          _setCell(sheet, row, col++, domainScore);
        }
        _setCell(sheet, row, 6, total);
        _setCell(sheet, row, 7, 50); // 25 questions × max 2
        // Risk: <=8 HIGH, <=16 MEDIUM, else LOW (per domain avg — use total)
        final risk = total <= 20 ? 'HIGH' : (total <= 35 ? 'MEDIUM' : 'LOW');
        _setCell(sheet, row, 8, risk);
      } else {
        for (var c = 1; c <= 8; c++) _setCell(sheet, row, c, '');
      }
    }
  }

  /// 14. ISAA Autism — 6 domains (social:10, emotional:6, communication:7, behavior:8, sensory:5, cognitive:4)
  /// Responses: isaa_s1..s10, isaa_e1..e6, isaa_c1..c7, isaa_b1..b8, isaa_sn1..sn5, isaa_cg1..cg4 (values 1-5)
  static void _buildIsaaAssessment(
      Excel excel,
      List<int> childIds,
      Map<int, Map<String, Map<String, dynamic>>> toolResponses) {
    final sheet = excel['ISAA_Autism'];
    final headers = [
      'child_id', 'Social', 'Emotional', 'Communication', 'Behavior',
      'Sensory', 'Cognitive', 'Total_Score', 'Max_Score', 'Risk_Level',
    ];
    _addHeaderRow(sheet, headers);

    final domains = <String, List<String>>{
      'social': List.generate(10, (i) => 'isaa_s${i + 1}'),
      'emotional': List.generate(6, (i) => 'isaa_e${i + 1}'),
      'communication': List.generate(7, (i) => 'isaa_c${i + 1}'),
      'behavior': List.generate(8, (i) => 'isaa_b${i + 1}'),
      'sensory': List.generate(5, (i) => 'isaa_sn${i + 1}'),
      'cognitive': List.generate(4, (i) => 'isaa_cg${i + 1}'),
    };

    for (var i = 0; i < childIds.length; i++) {
      final cid = childIds[i];
      final resp = toolResponses[cid]?['isaaAutism'];
      final row = i + 1;
      _setCell(sheet, row, 0, cid);
      if (resp != null) {
        int total = 0;
        int col = 1;
        for (final qIds in domains.values) {
          int domainScore = 0;
          for (final qId in qIds) {
            final val = resp[qId];
            domainScore += (val is int ? val : int.tryParse(val?.toString() ?? '') ?? 0);
          }
          total += domainScore;
          _setCell(sheet, row, col++, domainScore);
        }
        _setCell(sheet, row, 7, total);
        _setCell(sheet, row, 8, 200); // 40 items × max 5
        // Risk: <70 LOW, 70-106 MEDIUM, >=107 HIGH
        final risk = total >= 107 ? 'HIGH' : (total >= 70 ? 'MEDIUM' : 'LOW');
        _setCell(sheet, row, 9, risk);
      } else {
        for (var c = 1; c <= 9; c++) _setCell(sheet, row, c, '');
      }
    }
  }

  /// 15. RBSK Behavioral — 10 yes/no items, b8 & b9 are red flags
  /// Responses: rbsk_b1..b10 (values true/false)
  static void _buildRbskBehavioral(
      Excel excel,
      List<int> childIds,
      Map<int, Map<String, Map<String, dynamic>>> toolResponses) {
    final sheet = excel['RBSK_Behavioral'];
    final headers = [
      'child_id', 'Yes_Count', 'Total_Items', 'Red_Flags', 'Risk_Level', 'Referral_Needed',
    ];
    _addHeaderRow(sheet, headers);

    const redFlagIds = {'rbsk_b8', 'rbsk_b9'};

    for (var i = 0; i < childIds.length; i++) {
      final cid = childIds[i];
      final resp = toolResponses[cid]?['rbskBehavioral'];
      final row = i + 1;
      _setCell(sheet, row, 0, cid);
      if (resp != null) {
        int yesCount = 0;
        int redFlags = 0;
        for (var q = 1; q <= 10; q++) {
          final key = 'rbsk_b$q';
          final val = resp[key];
          final isYes = val == true || val == 'true' || val == 1;
          if (isYes) {
            yesCount++;
            if (redFlagIds.contains(key)) redFlags++;
          }
        }
        _setCell(sheet, row, 1, yesCount);
        _setCell(sheet, row, 2, 10);
        _setCell(sheet, row, 3, redFlags);
        final risk = redFlags > 0 ? 'HIGH' : (yesCount >= 3 ? 'MEDIUM' : 'LOW');
        _setCell(sheet, row, 4, risk);
        _setCell(sheet, row, 5, risk == 'HIGH');
      } else {
        for (var c = 1; c <= 5; c++) _setCell(sheet, row, c, '');
      }
    }
  }

  /// 16. RBSK Birth Defects — 6 domains (neural, musculoskeletal, craniofacial, cardiac, sensory, other)
  /// Responses: bd_n1..n2, bd_m1..m3, bd_c1..c3, bd_h1..h3, bd_s1..s3, bd_o1..o3 (true/false)
  static void _buildRbskBirthDefectsTab(
      Excel excel,
      List<int> childIds,
      Map<int, Map<String, Map<String, dynamic>>> toolResponses) {
    final sheet = excel['RBSK_BirthDefects'];
    final headers = [
      'child_id', 'Neural', 'Musculoskeletal', 'Craniofacial', 'Cardiac',
      'Sensory', 'Other', 'Total_Flags', 'Risk_Level', 'Referral_Needed',
    ];
    _addHeaderRow(sheet, headers);

    final domainQs = {
      'neural': ['bd_n1', 'bd_n2'],
      'musculoskeletal': ['bd_m1', 'bd_m2', 'bd_m3'],
      'craniofacial': ['bd_c1', 'bd_c2', 'bd_c3'],
      'cardiac': ['bd_h1', 'bd_h2', 'bd_h3'],
      'sensory': ['bd_s1', 'bd_s2', 'bd_s3'],
      'other': ['bd_o1', 'bd_o2', 'bd_o3'],
    };
    // Red flag question IDs
    const redFlags = {'bd_n1', 'bd_n2', 'bd_c1', 'bd_c2', 'bd_c3', 'bd_h1', 'bd_s1', 'bd_s2'};

    for (var i = 0; i < childIds.length; i++) {
      final cid = childIds[i];
      final resp = toolResponses[cid]?['rbskBirthDefects'];
      final row = i + 1;
      _setCell(sheet, row, 0, cid);
      if (resp != null) {
        int totalYes = 0;
        bool hasRedFlag = false;
        int col = 1;
        for (final qIds in domainQs.values) {
          int count = 0;
          for (final qId in qIds) {
            final val = resp[qId];
            if (val == true || val == 'true' || val == 1) {
              count++;
              totalYes++;
              if (redFlags.contains(qId)) hasRedFlag = true;
            }
          }
          _setCell(sheet, row, col++, count);
        }
        _setCell(sheet, row, 7, totalYes);
        final risk = (hasRedFlag || totalYes >= 3) ? 'HIGH' : (totalYes >= 1 ? 'MEDIUM' : 'LOW');
        _setCell(sheet, row, 8, risk);
        _setCell(sheet, row, 9, risk == 'HIGH');
      } else {
        for (var c = 1; c <= 9; c++) _setCell(sheet, row, c, '');
      }
    }
  }

  /// 17. RBSK Diseases — 6 domains (skin, ent, eye, dental, blood, deficiency)
  /// Responses: ds_sk1..sk3, ds_e1..e3, ds_ey1..ey3, ds_d1..d2, ds_bl1..bl3, ds_df1..df3 (true/false)
  static void _buildRbskDiseasesTab(
      Excel excel,
      List<int> childIds,
      Map<int, Map<String, Map<String, dynamic>>> toolResponses) {
    final sheet = excel['RBSK_Diseases'];
    final headers = [
      'child_id', 'Skin', 'ENT', 'Eye', 'Dental',
      'Blood', 'Deficiency', 'Total_Flags', 'Risk_Level', 'Referral_Needed',
    ];
    _addHeaderRow(sheet, headers);

    final domainQs = {
      'skin': ['ds_sk1', 'ds_sk2', 'ds_sk3'],
      'ent': ['ds_e1', 'ds_e2', 'ds_e3'],
      'eye': ['ds_ey1', 'ds_ey2', 'ds_ey3'],
      'dental': ['ds_d1', 'ds_d2'],
      'blood': ['ds_bl1', 'ds_bl2', 'ds_bl3'],
      'deficiency': ['ds_df1', 'ds_df2', 'ds_df3'],
    };
    // Red flag question IDs
    const redFlags = {'ds_e1', 'ds_ey3', 'ds_bl1', 'ds_bl2', 'ds_df3'};

    for (var i = 0; i < childIds.length; i++) {
      final cid = childIds[i];
      final resp = toolResponses[cid]?['rbskDiseases'];
      final row = i + 1;
      _setCell(sheet, row, 0, cid);
      if (resp != null) {
        int totalYes = 0;
        bool hasRedFlag = false;
        int col = 1;
        for (final qIds in domainQs.values) {
          int count = 0;
          for (final qId in qIds) {
            final val = resp[qId];
            if (val == true || val == 'true' || val == 1) {
              count++;
              totalYes++;
              if (redFlags.contains(qId)) hasRedFlag = true;
            }
          }
          _setCell(sheet, row, col++, count);
        }
        _setCell(sheet, row, 7, totalYes);
        final risk = (hasRedFlag || totalYes >= 4) ? 'HIGH' : (totalYes >= 2 ? 'MEDIUM' : 'LOW');
        _setCell(sheet, row, 8, risk);
        _setCell(sheet, row, 9, risk == 'HIGH');
      } else {
        for (var c = 1; c <= 9; c++) _setCell(sheet, row, c, '');
      }
    }
  }
}
