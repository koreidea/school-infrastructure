import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/api_config.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/children_provider.dart';
import '../../../providers/dataset_provider.dart';
import '../../../services/connectivity_service.dart';
import '../../../services/database_service.dart';
import '../../../services/supabase_service.dart';
import 'challenge_filtered_children_screen.dart';

// ============================================================
// PROVIDERS for challenge dashboard data
// ============================================================

/// Helper: get child IDs based on current user role.
/// Each role only sees children within their jurisdiction.
/// AWW → children from their AWC.
/// SUPERVISOR → children from AWCs in their sector.
/// CDPO → children from AWCs in sectors in their project.
/// DW → children from AWCs in their district's projects.
/// SENIOR_OFFICIAL → null (all children).
Future<List<int>?> _getChildIdsForRole(Ref ref) async {
  // When a dataset override is active, use the override scope
  final datasetOverride = ref.watch(activeDatasetProvider);
  // ignore: avoid_print
  print('[CHALLENGE] _getChildIdsForRole: datasetOverride=$datasetOverride');
  if (datasetOverride != null) {
    // AWW with dataset override: scope to their AWC's children only
    final user = ref.watch(currentUserProvider);
    if (user?.isAWW == true && user?.anganwadiCenterId != null) {
      final children = ref.watch(childrenProvider).value ?? [];
      final ids = <int>[];
      for (final c in children) {
        final cid = c['child_id'];
        if (cid is int) ids.add(cid);
      }
      // ignore: avoid_print
      print('[CHALLENGE] _getChildIdsForRole: AWW override awcId=${user?.anganwadiCenterId} → ${ids.length} children');
      return ids.isEmpty ? null : ids;
    }

    if (datasetOverride.isMultiDistrict) {
      // Multi-district ECD: get children from ALL districts in the dataset
      final allIds = <int>[];
      for (final distId in datasetOverride.districtIds!) {
        allIds.addAll(await getChildIdsViaRpc('district', distId));
      }
      // ignore: avoid_print
      print('[CHALLENGE] _getChildIdsForRole: multi-district ECD → ${allIds.length} children');
      return allIds;
    } else if (datasetOverride.projectId != null) {
      // Single-project/district override
      final ids = await getChildIdsViaRpc('project', datasetOverride.projectId!);
      // ignore: avoid_print
      print('[CHALLENGE] _getChildIdsForRole: dataset override projectId=${datasetOverride.projectId} → ${ids.length} children');
      return ids;
    }
  }

  final user = ref.watch(currentUserProvider);
  final role = user?.roleName ?? '';
  // ignore: avoid_print
  print('[CHALLENGE] _getChildIdsForRole: role=$role projectId=${user?.projectId} sectorId=${user?.sectorId}');

  if (role == 'AWW') {
    final children = ref.watch(childrenProvider).value ?? [];
    final ids = <int>[];
    for (final c in children) {
      final cid = c['child_id'];
      if (cid is int) ids.add(cid);
    }
    return ids.isEmpty ? null : ids;
  }

  if (role == 'SUPERVISOR' && user?.sectorId != null) {
    return getChildIdsForScope('sector', user!.sectorId!);
  }

  if ((role == 'CDPO' || role == 'CW' || role == 'EO') && user?.projectId != null) {
    final ids = await getChildIdsForScope('project', user!.projectId!);
    // ignore: avoid_print
    print('[CHALLENGE] _getChildIdsForRole: CDPO projectId=${user.projectId} → ${ids.length} children');
    return ids;
  }

  if (role == 'DW' && user?.districtId != null) {
    return getChildIdsForScope('district', user!.districtId!);
  }

  // SENIOR_OFFICIAL with no override: exclude sample district data
  if (role == 'SENIOR_OFFICIAL' && user?.stateId != null) {
    final sampleIds = ref.read(sampleDatasetDistrictIdsProvider);
    if (sampleIds.isEmpty) return null; // No sample data exists, safe to query all
    // Get children from non-sample districts only
    return await getChildIdsExcludingDistricts(user!.stateId!, sampleIds);
  }

  return null;
}

/// Fetch child IDs via RPC (bypasses RLS). Used when dataset override is active
/// because the logged-in user's RLS scope may not include the overridden project.
Future<List<int>> getChildIdsViaRpc(String scope, int scopeId) async {
  try {
    final String rpcName;
    final Map<String, dynamic> params;
    if (scope == 'district') {
      rpcName = 'get_children_for_district';
      params = {'p_district_id': scopeId};
    } else {
      rpcName = 'get_children_for_project';
      params = {'p_project_id': scopeId};
    }
    final rows = await SupabaseService.client.rpc(rpcName, params: params);
    final ids = (rows as List).map<int>((r) => r['child_id'] as int).toList();
    // ignore: avoid_print
    print('[RPC] $rpcName($scopeId) → ${ids.length} children');
    return ids;
  } catch (e) {
    // ignore: avoid_print
    print('[RPC] ERROR: $e');
    return [];
  }
}

/// Fetch child IDs scoped to a hierarchy level. Public for use by scoped screens.
Future<List<int>> getChildIdsForScope(String scope, int scopeId) async {
  try {
    List<int> awcIds = [];
    // ignore: avoid_print
    print('[SCOPE] getChildIdsForScope: scope=$scope, scopeId=$scopeId');

    if (scope == 'sector') {
      final awcs = await SupabaseService.client
          .from('anganwadi_centres')
          .select('id')
          .eq('sector_id', scopeId)
          .eq('is_active', true);
      awcIds = (awcs as List).map<int>((a) => a['id'] as int).toList();
    } else if (scope == 'project') {
      final sectors = await SupabaseService.client
          .from('sectors')
          .select('id')
          .eq('project_id', scopeId);
      final sectorIds = (sectors as List).map<int>((s) => s['id'] as int).toList();
      // ignore: avoid_print
      print('[SCOPE] project=$scopeId → sectors=$sectorIds');
      if (sectorIds.isEmpty) return [];
      final awcs = await SupabaseService.client
          .from('anganwadi_centres')
          .select('id')
          .inFilter('sector_id', sectorIds)
          .eq('is_active', true);
      awcIds = (awcs as List).map<int>((a) => a['id'] as int).toList();
      // ignore: avoid_print
      print('[SCOPE] sectors=$sectorIds → awcIds count=${awcIds.length}');
    } else if (scope == 'district') {
      final projects = await SupabaseService.client
          .from('projects')
          .select('id')
          .eq('district_id', scopeId);
      final projectIds = (projects as List).map<int>((p) => p['id'] as int).toList();
      if (projectIds.isEmpty) return [];
      final sectors = await SupabaseService.client
          .from('sectors')
          .select('id')
          .inFilter('project_id', projectIds);
      final sectorIds = (sectors as List).map<int>((s) => s['id'] as int).toList();
      if (sectorIds.isEmpty) return [];
      final awcs = await SupabaseService.client
          .from('anganwadi_centres')
          .select('id')
          .inFilter('sector_id', sectorIds)
          .eq('is_active', true);
      awcIds = (awcs as List).map<int>((a) => a['id'] as int).toList();
    }

    if (awcIds.isEmpty) return [];
    // ignore: avoid_print
    print('[SCOPE] Querying children for ${awcIds.length} AWCs...');
    // Batch AWC IDs to avoid URL length limits (199 AWCs is borderline)
    final allChildIds = <int>[];
    for (var i = 0; i < awcIds.length; i += 50) {
      final batch = awcIds.sublist(i, (i + 50).clamp(0, awcIds.length));
      final children = await SupabaseService.client
          .from('children')
          .select('id')
          .inFilter('awc_id', batch)
          .eq('is_active', true);
      for (final c in (children as List)) {
        allChildIds.add(c['id'] as int);
      }
    }
    // ignore: avoid_print
    print('[SCOPE] Found ${allChildIds.length} children across ${awcIds.length} AWCs');
    return allChildIds;
  } catch (e) {
    // ignore: avoid_print
    print('[SCOPE] ERROR fetching children: $e');
    return [];
  }
}

/// Get children for a state, excluding specific district IDs (e.g., sample data).
/// Used by SENIOR_OFFICIAL with App Data to exclude ECD sample districts.
Future<List<int>> getChildIdsExcludingDistricts(int stateId, Set<int> excludeDistrictIds) async {
  try {
    // 1. Get all districts for the state, excluding sample ones
    final districts = await SupabaseService.client
        .from('districts')
        .select('id')
        .eq('state_id', stateId);
    final districtIds = (districts as List)
        .map<int>((d) => d['id'] as int)
        .where((id) => !excludeDistrictIds.contains(id))
        .toList();
    if (districtIds.isEmpty) return [];

    // 2. Get all projects in those districts
    final projects = await SupabaseService.client
        .from('projects')
        .select('id')
        .inFilter('district_id', districtIds);
    final projectIds = (projects as List).map<int>((p) => p['id'] as int).toList();
    if (projectIds.isEmpty) return [];

    // 3. Get all sectors in those projects
    final sectors = await SupabaseService.client
        .from('sectors')
        .select('id')
        .inFilter('project_id', projectIds);
    final sectorIds = (sectors as List).map<int>((s) => s['id'] as int).toList();
    if (sectorIds.isEmpty) return [];

    // 4. Get all AWCs in those sectors
    final allAwcIds = <int>[];
    for (var i = 0; i < sectorIds.length; i += 50) {
      final batch = sectorIds.sublist(i, (i + 50).clamp(0, sectorIds.length));
      final awcs = await SupabaseService.client
          .from('anganwadi_centres')
          .select('id')
          .inFilter('sector_id', batch)
          .eq('is_active', true);
      for (final a in (awcs as List)) {
        allAwcIds.add(a['id'] as int);
      }
    }
    if (allAwcIds.isEmpty) return [];

    // 5. Get all children in those AWCs
    final allChildIds = <int>[];
    for (var i = 0; i < allAwcIds.length; i += 50) {
      final batch = allAwcIds.sublist(i, (i + 50).clamp(0, allAwcIds.length));
      final children = await SupabaseService.client
          .from('children')
          .select('id')
          .inFilter('awc_id', batch)
          .eq('is_active', true);
      for (final c in (children as List)) {
        allChildIds.add(c['id'] as int);
      }
    }
    // ignore: avoid_print
    print('[SCOPE] getChildIdsExcludingDistricts: state=$stateId, excluded=${excludeDistrictIds.length} districts → ${allChildIds.length} children');
    return allChildIds;
  } catch (e) {
    // ignore: avoid_print
    print('[SCOPE] ERROR in getChildIdsExcludingDistricts: $e');
    return [];
  }
}

/// Batch size for inFilter queries to avoid Supabase URL length limits.
/// With ~200 IDs the URL stays well within the ~8KB limit.
const int _batchSize = 200;

/// Helper: run a Supabase query in batches when the ID list is large.
/// Splits [ids] into chunks of [_batchSize] and runs the [queryFn] for each,
/// concatenating all results.
Future<List<Map<String, dynamic>>> _batchedInFilterQuery(
  List<int> ids,
  Future<List<dynamic>> Function(List<int> batchIds) queryFn,
) async {
  if (ids.isEmpty) return [];
  final allResults = <Map<String, dynamic>>[];
  for (var i = 0; i < ids.length; i += _batchSize) {
    final batch = ids.sublist(i, (i + _batchSize).clamp(0, ids.length));
    final rows = await queryFn(batch);
    for (final r in rows) {
      allResults.add(Map<String, dynamic>.from(r as Map));
    }
  }
  return allResults;
}

/// Fetch screening results from Supabase, optionally filtered by child IDs.
/// Uses batching when child IDs exceed [_batchSize] to avoid URL length limits.
Future<List<Map<String, dynamic>>> _fetchScreeningResults(List<int>? childIds, {bool useRpc = false}) async {
  if (childIds != null) {
    // When dataset override is active, use RPC to bypass RLS
    if (useRpc) {
      final rows = await SupabaseService.client.rpc(
        'get_screening_results_for_children',
        params: {'p_child_ids': childIds},
      );
      return (rows as List).map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r as Map)).toList();
    }
    if (childIds.length <= _batchSize) {
      return await SupabaseService.getScreeningResultsForChildren(childIds);
    }
    // Batch the query for large ID lists
    return _batchedInFilterQuery(childIds, (batchIds) async {
      return await SupabaseService.client
          .from('screening_results')
          .select('*, screening_sessions!inner(*)')
          .inFilter('child_id', batchIds)
          .order('created_at', ascending: false);
    });
  }
  // All results — for supervisor/CDPO/DW/state dashboards
  return await SupabaseService.client
      .from('screening_results')
      .select('*, screening_sessions!inner(*)')
      .order('created_at', ascending: false)
      .limit(5000);
}

/// Risk stratification stats — hybrid Supabase + Drift approach
final riskStratificationProvider = FutureProvider<Map<String, int>>((ref) async {
  try {
    final isOverride = ref.watch(activeDatasetProvider) != null;
    final childIds = await _getChildIdsForRole(ref);
    // ignore: avoid_print
    print('[RISK-STRAT] childIds count=${childIds?.length}, online=${ConnectivityService.isOnline}, useRpc=$isOverride');

    // Latest result per child: child_id → result map
    final latestByChild = <int, Map<String, dynamic>>{};
    bool supabaseSucceeded = false;

    // Source 1: Supabase (primary, when online)
    if (ConnectivityService.isOnline) {
      try {
        final remoteResults = await _fetchScreeningResults(childIds, useRpc: isOverride);
        supabaseSucceeded = true; // Query succeeded, even if empty
        // ignore: avoid_print
        print('[RISK-STRAT] Supabase returned ${remoteResults.length} results');
        for (final r in remoteResults) {
          final cid = r['child_id'] as int?;
          if (cid != null && !latestByChild.containsKey(cid)) {
            latestByChild[cid] = r;
          }
        }
      } catch (e) {
        // ignore: avoid_print
        print('[RISK-STRAT] Supabase FAILED: $e');
      }
    }

    // Source 2: Drift local DB (fallback ONLY when Supabase was not reachable)
    // Do NOT use Drift when Supabase succeeded — empty result means no data exists.
    if (!supabaseSucceeded && !kIsWeb) {
      try {
        final childIdSet = childIds?.toSet();
        final db = DatabaseService.db;
        final localResults = await db.screeningDao.getAllResults();
        localResults.sort((a, b) => b.id.compareTo(a.id));
        for (final r in localResults) {
          final cid = r.childRemoteId;
          if (cid == null) continue;
          // Filter by scope: only include results for children in our scope
          if (childIdSet != null && !childIdSet.contains(cid)) continue;
          if (!latestByChild.containsKey(cid)) {
            latestByChild[cid] = {
              'baseline_category': r.baselineCategory,
              'num_delays': r.numDelays,
              'assessment_cycle': r.assessmentCycle,
              'overall_risk': r.overallRisk,
              'gm_dq': r.gmDq,
              'fm_dq': r.fmDq,
              'lc_dq': r.lcDq,
              'cog_dq': r.cogDq,
              'se_dq': r.seDq,
            };
          }
        }
      } catch (_) {}
    }

    int low = 0, medium = 0, high = 0;
    final delayCounts = <int, int>{0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    int gmDelay = 0, fmDelay = 0, lcDelay = 0, cogDelay = 0, seDelay = 0;
    int baselineCount = 0, followupCount = 0, rescreenCount = 0;

    for (final r in latestByChild.values) {
      // Use overall_risk to match drill-down filter logic
      final category = _riskToCategory(r['overall_risk'] as String?);
      switch (category) {
        case 'Low':
          low++;
        case 'Medium':
          medium++;
        case 'High':
          high++;
      }

      final nd = (r['num_delays'] as num?)?.toInt() ?? 0;
      if (nd >= 0 && nd <= 5) {
        delayCounts[nd] = (delayCounts[nd] ?? 0) + 1;
      }

      // Domain delays from DQ scores
      final gmDq = (r['gm_dq'] as num?)?.toDouble();
      final fmDq = (r['fm_dq'] as num?)?.toDouble();
      final lcDq = (r['lc_dq'] as num?)?.toDouble();
      final cogDq = (r['cog_dq'] as num?)?.toDouble();
      final seDq = (r['se_dq'] as num?)?.toDouble();
      if (gmDq != null && gmDq < 85) gmDelay++;
      if (fmDq != null && fmDq < 85) fmDelay++;
      if (lcDq != null && lcDq < 85) lcDelay++;
      if (cogDq != null && cogDq < 85) cogDelay++;
      if (seDq != null && seDq < 85) seDelay++;

      final cycle = r['assessment_cycle'] as String? ?? 'Baseline';
      switch (cycle) {
        case 'Baseline':
          baselineCount++;
        case 'Follow-up':
          followupCount++;
        case 'Re-screen':
          rescreenCount++;
      }
    }

    // ignore: avoid_print
    print('[RISK-STRAT] FINAL: latestByChild=${latestByChild.length}, low=$low, med=$medium, high=$high, supabaseOK=$supabaseSucceeded');
    return {
      'low': low,
      'medium': medium,
      'high': high,
      'delay_0': delayCounts[0]!,
      'delay_1': delayCounts[1]!,
      'delay_2': delayCounts[2]!,
      'delay_3': delayCounts[3]!,
      'delay_4': delayCounts[4]!,
      'delay_5': delayCounts[5]!,
      'gm_delay': gmDelay,
      'fm_delay': fmDelay,
      'lc_delay': lcDelay,
      'cog_delay': cogDelay,
      'se_delay': seDelay,
      'baseline': baselineCount,
      'followup': followupCount,
      'rescreen': rescreenCount,
    };
  } catch (e) {
    // ignore: avoid_print
    print('[RISK-STRAT] TOP-LEVEL ERROR: $e');
    return {};
  }
});

/// Map overall_risk (LOW/MEDIUM/HIGH) to baseline_category (Low/Medium/High)
String _riskToCategory(String? risk) {
  switch (risk?.toUpperCase()) {
    case 'HIGH':
      return 'High';
    case 'MEDIUM':
      return 'Medium';
    default:
      return 'Low';
  }
}

/// Referral status counts — hybrid Supabase + Drift
/// Counts UNIQUE CHILDREN per status (not referral rows).
final referralStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final counts = <String, int>{'Pending': 0, 'Completed': 0, 'Under_Treatment': 0};
  try {
    final isOverride = ref.watch(activeDatasetProvider) != null;
    bool supabaseSucceeded = false;
    if (ConnectivityService.isOnline) {
      try {
        final childIds = await _getChildIdsForRole(ref);
        List<Map<String, dynamic>> rows;
        if (childIds != null) {
          if (isOverride) {
            // Use RPC to bypass RLS for dataset override
            final rpcRows = await SupabaseService.client.rpc(
              'get_referrals_for_children',
              params: {'p_child_ids': childIds},
            );
            rows = (rpcRows as List).map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r as Map)).toList();
          } else {
            rows = await _batchedInFilterQuery(childIds, (batchIds) async {
              return await SupabaseService.client
                  .from('referrals')
                  .select('referral_status, child_id')
                  .inFilter('child_id', batchIds);
            });
          }
        } else {
          final rawRows = await SupabaseService.client
              .from('referrals')
              .select('referral_status, child_id')
              .limit(5000);
          rows = (rawRows as List).map((r) => Map<String, dynamic>.from(r as Map)).toList();
        }
        supabaseSucceeded = true;
        // ignore: avoid_print
        print('[REFERRAL] Supabase returned ${rows.length} referral rows, childIds count=${childIds?.length}');
        // Count unique children per status
        final childrenPerStatus = <String, Set<int>>{
          'Pending': {}, 'Completed': {}, 'Under_Treatment': {},
        };
        for (final r in rows) {
          final status = r['referral_status'] as String? ?? 'Pending';
          final childId = r['child_id'] as int?;
          if (childId != null) {
            childrenPerStatus.putIfAbsent(status, () => {}).add(childId);
          }
        }
        final result = {
          'Pending': childrenPerStatus['Pending']?.length ?? 0,
          'Completed': childrenPerStatus['Completed']?.length ?? 0,
          'Under_Treatment': childrenPerStatus['Under_Treatment']?.length ?? 0,
        };
        // ignore: avoid_print
        print('[REFERRAL] FINAL: $result');
        return result;
      } catch (e) {
        // ignore: avoid_print
        print('[REFERRAL] Supabase FAILED: $e');
      }
    }

    // Drift fallback — only when Supabase was NOT reachable
    if (!supabaseSucceeded && !kIsWeb) {
      // ignore: avoid_print
      print('[REFERRAL] Using Drift fallback');
      final db = DatabaseService.db;
      return await db.referralDao.getReferralStatusCounts();
    }
  } catch (e) {
    // ignore: avoid_print
    print('[REFERRAL] TOP-LEVEL ERROR: $e');
  }
  return counts;
});

/// Follow-up stats — hybrid Supabase + Drift
/// Counts UNIQUE CHILDREN per improvement status (not follow-up rows).
final followupStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  try {
    final isOverride = ref.watch(activeDatasetProvider) != null;
    bool supabaseSucceeded = false;
    if (ConnectivityService.isOnline) {
      try {
        final childIds = await _getChildIdsForRole(ref);
        List<Map<String, dynamic>> rows;
        if (childIds != null) {
          if (isOverride) {
            // Use RPC to bypass RLS for dataset override
            final rpcRows = await SupabaseService.client.rpc(
              'get_followups_for_children',
              params: {'p_child_ids': childIds},
            );
            rows = (rpcRows as List).map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r as Map)).toList();
          } else {
            rows = await _batchedInFilterQuery(childIds, (batchIds) async {
              return await SupabaseService.client
                  .from('intervention_followups')
                  .select('child_id, improvement_status, domain_improvement, exit_high_risk')
                  .inFilter('child_id', batchIds);
            });
          }
        } else {
          final rawRows = await SupabaseService.client
              .from('intervention_followups')
              .select('child_id, improvement_status, domain_improvement, exit_high_risk')
              .limit(5000);
          rows = (rawRows as List).map((r) => Map<String, dynamic>.from(r as Map)).toList();
        }
        supabaseSucceeded = true;
        // Count unique children per category
        final improvedChildren = <int>{};
        final sameChildren = <int>{};
        final worsenedChildren = <int>{};
        final exitedChildren = <int>{};
        final domainImprovedChildren = <int>{};
        for (final f in rows) {
          final childId = f['child_id'] as int?;
          if (childId == null) continue;
          if (f['improvement_status'] == 'Improved') improvedChildren.add(childId);
          if (f['improvement_status'] == 'Same') sameChildren.add(childId);
          if (f['improvement_status'] == 'Worsened') worsenedChildren.add(childId);
          if (f['exit_high_risk'] == true) exitedChildren.add(childId);
          if (f['domain_improvement'] == true) domainImprovedChildren.add(childId);
        }
        return {
          'improved': improvedChildren.length,
          'same': sameChildren.length,
          'worsened': worsenedChildren.length,
          'exited_high_risk': exitedChildren.length,
          'domain_improved': domainImprovedChildren.length,
          'total': {...improvedChildren, ...sameChildren, ...worsenedChildren}.length,
        };
      } catch (_) {}
    }

    // Drift fallback — only when Supabase was NOT reachable
    if (!supabaseSucceeded && !kIsWeb) {
      final db = DatabaseService.db;
      return await db.challengeDao.getFollowupStats();
    }
  } catch (_) {
    // fall through
  }
  return {};
});

// ============================================================
// SCOPED PROVIDERS (for drill-down dashboards)
// Key format: "scope:id" e.g. "district:5", "sector:12"
// ============================================================

/// Parse scope key string into (scope, id) pair
(String, int) _parseScopeKey(String key) {
  final parts = key.split(':');
  return (parts[0], int.parse(parts[1]));
}

/// Scoped risk stratification — fetches data for a specific hierarchy scope
final scopedRiskStratificationProvider =
    FutureProvider.family<Map<String, int>, String>((ref, scopeKey) async {
  try {
    final isOverride = ref.watch(activeDatasetProvider) != null;
    final (scope, id) = _parseScopeKey(scopeKey);
    final childIds = isOverride
        ? await getChildIdsViaRpc(scope, id)
        : await getChildIdsForScope(scope, id);
    if (childIds.isEmpty) return {};

    final results = await _fetchScreeningResults(childIds, useRpc: isOverride);
    final latestByChild = <int, Map<String, dynamic>>{};
    for (final r in results) {
      final cid = r['child_id'] as int?;
      if (cid != null && !latestByChild.containsKey(cid)) {
        latestByChild[cid] = r;
      }
    }

    int low = 0, medium = 0, high = 0;
    final delayCounts = <int, int>{0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    int gmDelay = 0, fmDelay = 0, lcDelay = 0, cogDelay = 0, seDelay = 0;
    int baselineCount = 0, followupCount = 0, rescreenCount = 0;

    for (final r in latestByChild.values) {
      final category = _riskToCategory(r['overall_risk'] as String?);
      switch (category) {
        case 'Low': low++;
        case 'Medium': medium++;
        case 'High': high++;
      }
      final nd = (r['num_delays'] as num?)?.toInt() ?? 0;
      if (nd >= 0 && nd <= 5) delayCounts[nd] = (delayCounts[nd] ?? 0) + 1;
      final gmDq = (r['gm_dq'] as num?)?.toDouble();
      final fmDq = (r['fm_dq'] as num?)?.toDouble();
      final lcDq = (r['lc_dq'] as num?)?.toDouble();
      final cogDq = (r['cog_dq'] as num?)?.toDouble();
      final seDq = (r['se_dq'] as num?)?.toDouble();
      if (gmDq != null && gmDq < 85) gmDelay++;
      if (fmDq != null && fmDq < 85) fmDelay++;
      if (lcDq != null && lcDq < 85) lcDelay++;
      if (cogDq != null && cogDq < 85) cogDelay++;
      if (seDq != null && seDq < 85) seDelay++;
      final cycle = r['assessment_cycle'] as String? ?? 'Baseline';
      switch (cycle) {
        case 'Baseline': baselineCount++;
        case 'Follow-up': followupCount++;
        case 'Re-screen': rescreenCount++;
      }
    }
    return {
      'low': low, 'medium': medium, 'high': high,
      'delay_0': delayCounts[0]!, 'delay_1': delayCounts[1]!, 'delay_2': delayCounts[2]!,
      'delay_3': delayCounts[3]!, 'delay_4': delayCounts[4]!, 'delay_5': delayCounts[5]!,
      'gm_delay': gmDelay, 'fm_delay': fmDelay, 'lc_delay': lcDelay,
      'cog_delay': cogDelay, 'se_delay': seDelay,
      'baseline': baselineCount, 'followup': followupCount, 'rescreen': rescreenCount,
    };
  } catch (_) { return {}; }
});

/// Scoped referral stats
final scopedReferralStatsProvider =
    FutureProvider.family<Map<String, int>, String>((ref, scopeKey) async {
  final counts = <String, int>{'Pending': 0, 'Completed': 0, 'Under_Treatment': 0};
  try {
    final isOverride = ref.watch(activeDatasetProvider) != null;
    final (scope, id) = _parseScopeKey(scopeKey);
    final childIds = isOverride
        ? await getChildIdsViaRpc(scope, id)
        : await getChildIdsForScope(scope, id);
    if (childIds.isEmpty) return counts;

    List<Map<String, dynamic>> rows;
    if (isOverride) {
      final rpcRows = await SupabaseService.client.rpc(
        'get_referrals_for_children',
        params: {'p_child_ids': childIds},
      );
      rows = (rpcRows as List).map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r as Map)).toList();
    } else {
      rows = await _batchedInFilterQuery(childIds, (batchIds) async {
        return await SupabaseService.client
            .from('referrals')
            .select('referral_status, child_id')
            .inFilter('child_id', batchIds);
      });
    }
    final childrenPerStatus = <String, Set<int>>{'Pending': {}, 'Completed': {}, 'Under_Treatment': {}};
    for (final r in rows) {
      final status = r['referral_status'] as String? ?? 'Pending';
      final childId = r['child_id'] as int?;
      if (childId != null) childrenPerStatus.putIfAbsent(status, () => {}).add(childId);
    }
    return {
      'Pending': childrenPerStatus['Pending']?.length ?? 0,
      'Completed': childrenPerStatus['Completed']?.length ?? 0,
      'Under_Treatment': childrenPerStatus['Under_Treatment']?.length ?? 0,
    };
  } catch (_) { return counts; }
});

/// Scoped follow-up stats
final scopedFollowupStatsProvider =
    FutureProvider.family<Map<String, int>, String>((ref, scopeKey) async {
  try {
    final isOverride = ref.watch(activeDatasetProvider) != null;
    final (scope, id) = _parseScopeKey(scopeKey);
    final childIds = isOverride
        ? await getChildIdsViaRpc(scope, id)
        : await getChildIdsForScope(scope, id);
    if (childIds.isEmpty) return {};

    List<Map<String, dynamic>> rows;
    if (isOverride) {
      final rpcRows = await SupabaseService.client.rpc(
        'get_followups_for_children',
        params: {'p_child_ids': childIds},
      );
      rows = (rpcRows as List).map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r as Map)).toList();
    } else {
      rows = await _batchedInFilterQuery(childIds, (batchIds) async {
        return await SupabaseService.client
            .from('intervention_followups')
            .select('child_id, improvement_status, domain_improvement, exit_high_risk')
            .inFilter('child_id', batchIds);
      });
    }
    final improvedChildren = <int>{};
    final sameChildren = <int>{};
    final worsenedChildren = <int>{};
    final exitedChildren = <int>{};
    final domainImprovedChildren = <int>{};
    for (final f in rows) {
      final childId = f['child_id'] as int?;
      if (childId == null) continue;
      if (f['improvement_status'] == 'Improved') improvedChildren.add(childId);
      if (f['improvement_status'] == 'Same') sameChildren.add(childId);
      if (f['improvement_status'] == 'Worsened') worsenedChildren.add(childId);
      if (f['exit_high_risk'] == true) exitedChildren.add(childId);
      if (f['domain_improvement'] == true) domainImprovedChildren.add(childId);
    }
    return {
      'improved': improvedChildren.length, 'same': sameChildren.length,
      'worsened': worsenedChildren.length, 'exited_high_risk': exitedChildren.length,
      'domain_improved': domainImprovedChildren.length,
      'total': {...improvedChildren, ...sameChildren, ...worsenedChildren}.length,
    };
  } catch (_) { return {}; }
});

// ============================================================
// WIDGETS
// ============================================================

/// Navigate to filtered children screen
void _navigateToFilter(BuildContext context, String filterType, String title, bool isTelugu) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChallengeFilteredChildrenScreen(
        filterType: filterType,
        title: title,
        isTelugu: isTelugu,
      ),
    ),
  );
}

/// Risk Stratification Section — Low / Medium / High cards + domain delay chart
class RiskStratificationSection extends ConsumerWidget {
  final bool isTelugu;
  final String? scopeLevel;
  final int? scopeId;
  const RiskStratificationSection({super.key, required this.isTelugu, this.scopeLevel, this.scopeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = (scopeLevel != null && scopeId != null)
        ? ref.watch(scopedRiskStratificationProvider('$scopeLevel:$scopeId'))
        : ref.watch(riskStratificationProvider);

    return statsAsync.when(
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      )),
      error: (_, __) => const SizedBox.shrink(),
      data: (stats) {
        final low = stats['low'] ?? 0;
        final medium = stats['medium'] ?? 0;
        final high = stats['high'] ?? 0;
        final total = low + medium + high;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTelugu ? 'రిస్క్ వర్గీకరణ' : 'Risk Stratification',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Risk category cards — tappable to drill down
            Row(
              children: [
                _RiskCard(
                  label: isTelugu ? 'తక్కువ' : 'Low',
                  count: low,
                  color: AppColors.riskLow,
                  total: total,
                  onTap: () => _navigateToFilter(context, 'risk_low',
                      isTelugu ? 'తక్కువ ప్రమాద పిల్లలు' : 'Low Risk Children', isTelugu),
                ),
                const SizedBox(width: 8),
                _RiskCard(
                  label: isTelugu ? 'మధ్యస్థ' : 'Medium',
                  count: medium,
                  color: AppColors.riskMedium,
                  total: total,
                  onTap: () => _navigateToFilter(context, 'risk_medium',
                      isTelugu ? 'మధ్యస్థ ప్రమాద పిల్లలు' : 'Medium Risk Children', isTelugu),
                ),
                const SizedBox(width: 8),
                _RiskCard(
                  label: isTelugu ? 'అధిక' : 'High',
                  count: high,
                  color: AppColors.riskHigh,
                  total: total,
                  onTap: () => _navigateToFilter(context, 'risk_high',
                      isTelugu ? 'అధిక ప్రమాద పిల్లలు' : 'High Risk Children', isTelugu),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Assessment cycle breakdown
            Row(
              children: [
                _CycleChip(
                  label: isTelugu ? 'బేస్‌లైన్' : 'Baseline',
                  count: stats['baseline'] ?? 0,
                ),
                const SizedBox(width: 8),
                _CycleChip(
                  label: isTelugu ? 'ఫాలో-అప్' : 'Follow-up',
                  count: stats['followup'] ?? 0,
                ),
                const SizedBox(width: 8),
                _CycleChip(
                  label: isTelugu ? 'రీ-స్క్రీన్' : 'Re-screen',
                  count: stats['rescreen'] ?? 0,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Domain delay burden bar chart
            Text(
              isTelugu ? 'డొమైన్ ఆలస్యం' : 'Domain Delay Burden',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: _DomainDelayBarChart(
                gmDelay: stats['gm_delay'] ?? 0,
                fmDelay: stats['fm_delay'] ?? 0,
                lcDelay: stats['lc_delay'] ?? 0,
                cogDelay: stats['cog_delay'] ?? 0,
                seDelay: stats['se_delay'] ?? 0,
                isTelugu: isTelugu,
                onBarTap: (barIndex) {
                  final domainKeys = ['gm', 'fm', 'lc', 'cog', 'se'];
                  final domainLabels = isTelugu
                      ? ['స్థూల మోటార్', 'సూక్ష్మ మోటార్', 'భాష', 'జ్ఞాన', 'సామాజిక']
                      : ['Gross Motor', 'Fine Motor', 'Language', 'Cognitive', 'Social-Emotional'];
                  if (barIndex >= 0 && barIndex < domainKeys.length) {
                    _navigateToFilter(
                      context,
                      'domain_${domainKeys[barIndex]}',
                      '${domainLabels[barIndex]} ${isTelugu ? 'ఆలస్యం' : 'Delay'}',
                      isTelugu,
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _RiskCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final int total;
  final VoidCallback? onTap;

  const _RiskCard({
    required this.label,
    required this.count,
    required this.color,
    required this.total,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (count / total * 100).round() : 0;
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(label,
                    style: TextStyle(fontSize: 12, color: color)),
                Text('$pct%',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CycleChip extends StatelessWidget {
  final String label;
  final int count;
  const _CycleChip({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text('$count',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _DomainDelayBarChart extends StatelessWidget {
  final int gmDelay, fmDelay, lcDelay, cogDelay, seDelay;
  final bool isTelugu;
  final void Function(int barIndex)? onBarTap;

  const _DomainDelayBarChart({
    required this.gmDelay,
    required this.fmDelay,
    required this.lcDelay,
    required this.cogDelay,
    required this.seDelay,
    required this.isTelugu,
    this.onBarTap,
  });

  @override
  Widget build(BuildContext context) {
    final labels = isTelugu
        ? ['స్థూల', 'సూక్ష్మ', 'భాష', 'జ్ఞాన', 'సామా']
        : ['GM', 'FM', 'LC', 'COG', 'SE'];
    final values = [gmDelay, fmDelay, lcDelay, cogDelay, seDelay];
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];
    final maxVal =
        values.reduce((a, b) => a > b ? a : b).toDouble().clamp(1, double.infinity);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal + 2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.grey.shade800,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final domainNames = isTelugu
                  ? ['స్థూల చలనం', 'సూక్ష్మ చలనం', 'భాష', 'జ్ఞాన', 'సామాజిక']
                  : ['Gross Motor', 'Fine Motor', 'Language', 'Cognitive', 'Social-Emotional'];
              final name = groupIndex < domainNames.length ? domainNames[groupIndex] : '';
              return BarTooltipItem(
                '$name\n${rod.toY.toInt()} ${isTelugu ? 'ఆలస్యాలు' : 'delays'}',
                const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              );
            },
          ),
          touchCallback: (event, response) {
            if (event.isInterestedForInteractions &&
                response != null &&
                response.spot != null &&
                onBarTap != null) {
              onBarTap!(response.spot!.touchedBarGroupIndex);
            }
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= labels.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(labels[idx],
                      style: const TextStyle(fontSize: 11)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                if (value == value.roundToDouble()) {
                  return Text('${value.toInt()}',
                      style: const TextStyle(fontSize: 10));
                }
                return const SizedBox();
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxVal / 4).ceilToDouble().clamp(1, double.infinity),
        ),
        barGroups: List.generate(values.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i].toDouble(),
                color: colors[i],
                width: 24,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxVal + 2,
                  color: colors[i].withValues(alpha: 0.08),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// Referral Board Section — Pending / Completed / Under Treatment
class ReferralBoardSection extends ConsumerWidget {
  final bool isTelugu;
  final String? scopeLevel;
  final int? scopeId;
  const ReferralBoardSection({super.key, required this.isTelugu, this.scopeLevel, this.scopeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = (scopeLevel != null && scopeId != null)
        ? ref.watch(scopedReferralStatsProvider('$scopeLevel:$scopeId'))
        : ref.watch(referralStatsProvider);

    return statsAsync.when(
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      )),
      error: (_, __) => const SizedBox.shrink(),
      data: (stats) {
        final pending = stats['Pending'] ?? 0;
        final completed = stats['Completed'] ?? 0;
        final underTreatment = stats['Under_Treatment'] ?? 0;
        final total = pending + completed + underTreatment;

        final completionRate =
            total > 0 ? (completed / total * 100).round() : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTelugu ? 'రిఫరల్ బోర్డ్' : 'Referral Board',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ReferralStatusCard(
                  label: isTelugu ? 'పెండింగ్' : 'Pending',
                  count: pending,
                  color: Colors.orange,
                  icon: Icons.pending_actions,
                  onTap: () => _navigateToFilter(context, 'referral_pending',
                      isTelugu ? 'పెండింగ్ రిఫరల్ పిల్లలు' : 'Pending Referrals', isTelugu),
                ),
                const SizedBox(width: 8),
                _ReferralStatusCard(
                  label: isTelugu ? 'పూర్తయింది' : 'Completed',
                  count: completed,
                  color: AppColors.riskLow,
                  icon: Icons.check_circle_outline,
                  onTap: () => _navigateToFilter(context, 'referral_completed',
                      isTelugu ? 'పూర్తయిన రిఫరల్ పిల్లలు' : 'Completed Referrals', isTelugu),
                ),
                const SizedBox(width: 8),
                _ReferralStatusCard(
                  label: isTelugu ? 'చికిత్సలో' : 'Treatment',
                  count: underTreatment,
                  color: Colors.blue,
                  icon: Icons.medical_services_outlined,
                  onTap: () => _navigateToFilter(context, 'referral_under_treatment',
                      isTelugu ? 'చికిత్సలో ఉన్న పిల్లలు' : 'Under Treatment', isTelugu),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isTelugu ? 'పూర్తి రేటు' : 'Completion Rate',
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    '$completionRate%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.riskLow,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _ReferralStatusCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const _ReferralStatusCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 4),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(label,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Follow-up & Outcomes Section
class FollowupOutcomesSection extends ConsumerWidget {
  final bool isTelugu;
  final String? scopeLevel;
  final int? scopeId;
  const FollowupOutcomesSection({super.key, required this.isTelugu, this.scopeLevel, this.scopeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = (scopeLevel != null && scopeId != null)
        ? ref.watch(scopedFollowupStatsProvider('$scopeLevel:$scopeId'))
        : ref.watch(followupStatsProvider);

    return statsAsync.when(
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      )),
      error: (_, __) => const SizedBox.shrink(),
      data: (stats) {
        final improved = stats['improved'] ?? 0;
        final same = stats['same'] ?? 0;
        final worsened = stats['worsened'] ?? 0;
        final exitedHighRisk = stats['exited_high_risk'] ?? 0;
        final domainImproved = stats['domain_improved'] ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTelugu ? 'ఫాలో-అప్ & ఫలితాలు' : 'Follow-up & Outcomes',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Improvement status bar chart — tappable bars
            SizedBox(
              height: 160,
              child: _ImprovementChart(
                improved: improved,
                same: same,
                worsened: worsened,
                isTelugu: isTelugu,
                onBarTap: (barIndex) {
                  final filters = ['improvement_improved', 'improvement_same', 'improvement_worsened'];
                  final labels = isTelugu
                      ? ['మెరుగుపడిన పిల్లలు', 'అదే స్థితి పిల్లలు', 'తీవ్రమైన పిల్లలు']
                      : ['Improved Children', 'Same Status Children', 'Worsened Children'];
                  if (barIndex >= 0 && barIndex < filters.length) {
                    _navigateToFilter(context, filters[barIndex], labels[barIndex], isTelugu);
                  }
                },
              ),
            ),
            const SizedBox(height: 12),

            // Outcome KPIs — tappable
            Row(
              children: [
                _OutcomeKpi(
                  label: isTelugu ? 'హై రిస్క్ నుండి బయట' : 'Exited High Risk',
                  value: '$exitedHighRisk',
                  icon: Icons.trending_down,
                  color: AppColors.riskLow,
                  onTap: () => _navigateToFilter(context, 'exited_high_risk',
                      isTelugu ? 'హై రిస్క్ నుండి బయటపడిన పిల్లలు' : 'Exited High Risk', isTelugu),
                ),
                const SizedBox(width: 8),
                _OutcomeKpi(
                  label: isTelugu ? 'డొమైన్ మెరుగుదల' : 'Domain Improved',
                  value: '$domainImproved',
                  icon: Icons.trending_up,
                  color: Colors.blue,
                  onTap: () => _navigateToFilter(context, 'domain_improved',
                      isTelugu ? 'డొమైన్ మెరుగుపడిన పిల్లలు' : 'Domain Improved Children', isTelugu),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _ImprovementChart extends StatelessWidget {
  final int improved, same, worsened;
  final bool isTelugu;
  final void Function(int barIndex)? onBarTap;

  const _ImprovementChart({
    required this.improved,
    required this.same,
    required this.worsened,
    required this.isTelugu,
    this.onBarTap,
  });

  @override
  Widget build(BuildContext context) {
    final labels = isTelugu
        ? ['మెరుగు', 'అదే', 'తీవ్రం']
        : ['Improved', 'Same', 'Worsened'];
    final values = [improved, same, worsened];
    final colors = [AppColors.riskLow, Colors.amber, AppColors.riskHigh];
    final maxVal =
        values.reduce((a, b) => a > b ? a : b).toDouble().clamp(1, double.infinity);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal + 2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.grey.shade800,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final name = groupIndex < labels.length ? labels[groupIndex] : '';
              return BarTooltipItem(
                '$name\n${rod.toY.toInt()} ${isTelugu ? 'పిల్లలు' : 'children'}',
                const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              );
            },
          ),
          touchCallback: (event, response) {
            if (event.isInterestedForInteractions &&
                response != null &&
                response.spot != null &&
                onBarTap != null) {
              onBarTap!(response.spot!.touchedBarGroupIndex);
            }
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= labels.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(labels[idx],
                      style: const TextStyle(fontSize: 11)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                if (value == value.roundToDouble()) {
                  return Text('${value.toInt()}',
                      style: const TextStyle(fontSize: 10));
                }
                return const SizedBox();
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(values.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i].toDouble(),
                color: colors[i],
                width: 36,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxVal + 2,
                  color: colors[i].withValues(alpha: 0.08),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _OutcomeKpi extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _OutcomeKpi({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(value,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: color)),
                      Text(label,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
