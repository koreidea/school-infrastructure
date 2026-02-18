import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/api_config.dart';
import '../../../models/user.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dataset_provider.dart';
import '../../../providers/screening_results_storage.dart';
import '../../../services/supabase_service.dart';
import '../../children/child_profile_screen.dart';
import '../../children/child_status_card.dart';
import 'challenge_dashboard_widgets.dart';

/// Screen that shows children filtered by a challenge dashboard metric.
/// Scoped to the current user's jurisdiction (sector/project/district/state).
class ChallengeFilteredChildrenScreen extends ConsumerStatefulWidget {
  /// Filter type determines the Supabase query:
  /// - risk_low, risk_medium, risk_high
  /// - referral_pending, referral_completed, referral_under_treatment
  /// - domain_gm, domain_fm, domain_lc, domain_cog, domain_se
  /// - improvement_improved, improvement_same, improvement_worsened
  /// - exited_high_risk, domain_improved
  final String filterType;
  final String title;
  final bool isTelugu;

  const ChallengeFilteredChildrenScreen({
    super.key,
    required this.filterType,
    required this.title,
    required this.isTelugu,
  });

  @override
  ConsumerState<ChallengeFilteredChildrenScreen> createState() =>
      _ChallengeFilteredChildrenScreenState();
}

class _ChallengeFilteredChildrenScreenState
    extends ConsumerState<ChallengeFilteredChildrenScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _children = [];
  Map<int, SavedScreeningResult> _screeningResults = {};
  Map<int, Map<String, dynamic>> _followupData = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Get the set of child IDs within the current user's scope.
  /// Returns null for SENIOR_OFFICIAL (all children).
  /// Respects dataset override — when active, scopes to the override project via RPC.
  Future<Set<int>?> _getScopeChildIds() async {
    // Check dataset override first — use RPC to bypass RLS
    final datasetOverride = ref.read(activeDatasetProvider);
    if (datasetOverride != null) {
      // AWW with override: scope to their AWC only
      final user = ref.read(currentUserProvider);
      if (user?.isAWW == true && user?.anganwadiCenterId != null) {
        final rows = await SupabaseService.client.rpc(
          'get_children_for_awc_full',
          params: {'p_awc_id': user!.anganwadiCenterId!},
        );
        return (rows as List).map<int>((r) => (r as Map)['id'] as int).toSet();
      }
      // Other roles: full project/district scope
      if (datasetOverride.projectId != null) {
        final childIds = await getChildIdsViaRpc('project', datasetOverride.projectId!);
        return childIds.toSet();
      }
    }

    final user = ref.read(currentUserProvider);
    final role = user?.roleName ?? '';

    if (role == 'SENIOR_OFFICIAL') return null; // all children

    List<int> awcIds = [];

    if (role == 'AWW' && user?.anganwadiCenterId != null) {
      awcIds = [user!.anganwadiCenterId!];
    } else if (role == 'SUPERVISOR' && user?.sectorId != null) {
      final awcs = await SupabaseService.client
          .from('anganwadi_centres')
          .select('id')
          .eq('sector_id', user!.sectorId!)
          .eq('is_active', true);
      awcIds = (awcs as List).map<int>((a) => a['id'] as int).toList();
    } else if ((role == 'CDPO' || role == 'CW' || role == 'EO') && user?.projectId != null) {
      final sectors = await SupabaseService.client
          .from('sectors')
          .select('id')
          .eq('project_id', user!.projectId!);
      final sectorIds = (sectors as List).map<int>((s) => s['id'] as int).toList();
      if (sectorIds.isEmpty) return {};
      final awcs = await SupabaseService.client
          .from('anganwadi_centres')
          .select('id')
          .inFilter('sector_id', sectorIds)
          .eq('is_active', true);
      awcIds = (awcs as List).map<int>((a) => a['id'] as int).toList();
    } else if (role == 'DW' && user?.districtId != null) {
      final projects = await SupabaseService.client
          .from('projects')
          .select('id')
          .eq('district_id', user!.districtId!);
      final projectIds = (projects as List).map<int>((p) => p['id'] as int).toList();
      if (projectIds.isEmpty) return {};
      final sectors = await SupabaseService.client
          .from('sectors')
          .select('id')
          .inFilter('project_id', projectIds);
      final sectorIds = (sectors as List).map<int>((s) => s['id'] as int).toList();
      if (sectorIds.isEmpty) return {};
      final awcs = await SupabaseService.client
          .from('anganwadi_centres')
          .select('id')
          .inFilter('sector_id', sectorIds)
          .eq('is_active', true);
      awcIds = (awcs as List).map<int>((a) => a['id'] as int).toList();
    } else {
      return null; // fallback: no scope
    }

    if (awcIds.isEmpty) return {};
    final children = await SupabaseService.client
        .from('children')
        .select('id')
        .inFilter('awc_id', awcIds)
        .eq('is_active', true);
    return (children as List).map<int>((c) => c['id'] as int).toSet();
  }

  Future<void> _loadData() async {
    try {
      // Get scope first, then filter
      final scopeIds = await _getScopeChildIds();
      final childIds = await _getFilteredChildIds();

      // Intersect with scope (if scope is set)
      List<int> scopedIds;
      if (scopeIds == null) {
        scopedIds = childIds; // SENIOR_OFFICIAL — no scope restriction
      } else {
        scopedIds = childIds.where((id) => scopeIds.contains(id)).toList();
      }

      if (scopedIds.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Fetch children details in batches of 100
      final allChildren = <Map<String, dynamic>>[];
      final uniqueIds = scopedIds.toSet().toList();
      final datasetOverride = ref.read(activeDatasetProvider);
      final isOverride = datasetOverride != null;

      for (int i = 0; i < uniqueIds.length; i += 100) {
        final batch = uniqueIds.sublist(
            i, (i + 100).clamp(0, uniqueIds.length));
        if (isOverride) {
          // Use RPC to bypass RLS for cross-project children
          final rpcRows = await SupabaseService.client.rpc(
            'get_table_for_children',
            params: {'p_table_name': 'children', 'p_child_ids': batch},
          );
          for (final r in (rpcRows as List)) {
            final m = Map<String, dynamic>.from(r as Map);
            m['anganwadi_centres'] = null; // RPC doesn't join AWC data
            allChildren.add(m);
          }
        } else {
          final rows = await SupabaseService.client
              .from('children')
              .select('*, anganwadi_centres(name, centre_code)')
              .inFilter('id', batch)
              .eq('is_active', true)
              .order('name');
          allChildren.addAll(List<Map<String, dynamic>>.from(rows));
        }
      }

      // Fetch screening results and followup data for rich cards
      if (uniqueIds.isNotEmpty) {
        await _loadScreeningAndFollowup(uniqueIds, isOverride);
      }

      if (mounted) {
        setState(() {
          _children = allChildren;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Fetch latest screening results and followup data for given child IDs.
  Future<void> _loadScreeningAndFollowup(List<int> childIds, bool isOverride) async {
    try {
      // Screening results
      final screeningMap = <int, SavedScreeningResult>{};
      for (var i = 0; i < childIds.length; i += 200) {
        final batch = childIds.sublist(i, (i + 200).clamp(0, childIds.length));
        List<Map<String, dynamic>> rows;
        if (isOverride) {
          final rpcRows = await SupabaseService.client.rpc(
            'get_screening_results_for_children',
            params: {'p_child_ids': batch},
          );
          rows = (rpcRows as List)
              .map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r as Map))
              .toList();
        } else {
          final dbRows = await SupabaseService.client
              .from('screening_results')
              .select()
              .inFilter('child_id', batch)
              .order('created_at', ascending: false);
          rows = List<Map<String, dynamic>>.from(dbRows);
        }
        // Keep only latest per child
        for (final r in rows) {
          final cid = r['child_id'] as int;
          if (!screeningMap.containsKey(cid)) {
            screeningMap[cid] = ChildStatusCard.resultFromMap(r);
          }
        }
      }
      _screeningResults = screeningMap;

      // Followup data
      final followupMap = <int, Map<String, dynamic>>{};
      for (var i = 0; i < childIds.length; i += 200) {
        final batch = childIds.sublist(i, (i + 200).clamp(0, childIds.length));
        List<Map<String, dynamic>> rows;
        if (isOverride) {
          final rpcRows = await SupabaseService.client.rpc(
            'get_followups_for_children',
            params: {'p_child_ids': batch},
          );
          rows = (rpcRows as List)
              .map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r as Map))
              .toList();
        } else {
          final dbRows = await SupabaseService.client
              .from('intervention_followups')
              .select()
              .inFilter('child_id', batch)
              .order('created_at', ascending: false);
          rows = List<Map<String, dynamic>>.from(dbRows);
        }
        for (final r in rows) {
          final cid = r['child_id'] as int;
          if (!followupMap.containsKey(cid)) {
            followupMap[cid] = r;
          }
        }
      }
      _followupData = followupMap;
    } catch (_) {
      // Non-critical — cards will just show without tags
    }
  }

  Future<List<int>> _getFilteredChildIds() async {
    final ft = widget.filterType;
    final datasetOverride = ref.read(activeDatasetProvider);
    final isOverride = datasetOverride != null && datasetOverride.projectId != null;

    // When dataset override is active, use RPC to bypass RLS
    if (isOverride) {
      return _getFilteredChildIdsViaRpc(ft, datasetOverride.projectId!);
    }

    // Standard path: direct Supabase queries (RLS allows access)

    // Risk filter: risk_low, risk_medium, risk_high
    if (ft.startsWith('risk_')) {
      final riskLevel = ft.replaceFirst('risk_', '').toUpperCase();
      final rows = await SupabaseService.client
          .from('screening_results')
          .select('child_id')
          .eq('overall_risk', riskLevel)
          .limit(5000);
      return (rows as List)
          .map<int>((r) => r['child_id'] as int)
          .toSet()
          .toList();
    }

    // Referral filter: referral_pending, referral_completed, referral_under_treatment
    if (ft.startsWith('referral_')) {
      final status = ft.replaceFirst('referral_', '');
      final dbStatus = switch (status) {
        'pending' => 'Pending',
        'completed' => 'Completed',
        'under_treatment' => 'Under_Treatment',
        _ => status,
      };
      final rows = await SupabaseService.client
          .from('referrals')
          .select('child_id')
          .eq('referral_status', dbStatus)
          .limit(5000);
      return (rows as List)
          .map<int>((r) => r['child_id'] as int)
          .toSet()
          .toList();
    }

    // Domain delay filter: domain_gm, domain_fm, domain_lc, domain_cog, domain_se
    if (ft.startsWith('domain_') && !ft.contains('improved')) {
      final domain = ft.replaceFirst('domain_', '');
      final col = '${domain}_dq';
      final rows = await SupabaseService.client
          .from('screening_results')
          .select('child_id')
          .lt(col, 85)
          .limit(5000);
      return (rows as List)
          .map<int>((r) => r['child_id'] as int)
          .toSet()
          .toList();
    }

    // Improvement filter: improvement_improved, improvement_same, improvement_worsened
    if (ft.startsWith('improvement_')) {
      final status = ft.replaceFirst('improvement_', '');
      final dbStatus = switch (status) {
        'improved' => 'Improved',
        'same' => 'Same',
        'worsened' => 'Worsened',
        _ => status,
      };
      final rows = await SupabaseService.client
          .from('intervention_followups')
          .select('child_id')
          .eq('improvement_status', dbStatus)
          .limit(5000);
      return (rows as List)
          .map<int>((r) => r['child_id'] as int)
          .toSet()
          .toList();
    }

    // Exited high risk
    if (ft == 'exited_high_risk') {
      final rows = await SupabaseService.client
          .from('intervention_followups')
          .select('child_id')
          .eq('exit_high_risk', true)
          .limit(5000);
      return (rows as List)
          .map<int>((r) => r['child_id'] as int)
          .toSet()
          .toList();
    }

    // Domain improved
    if (ft == 'domain_improved') {
      final rows = await SupabaseService.client
          .from('intervention_followups')
          .select('child_id')
          .eq('domain_improvement', true)
          .limit(5000);
      return (rows as List)
          .map<int>((r) => r['child_id'] as int)
          .toSet()
          .toList();
    }

    return [];
  }

  /// RPC-based filter that bypasses RLS for dataset override.
  /// Fetches all data for scoped children via RPC, then filters in-memory.
  Future<List<int>> _getFilteredChildIdsViaRpc(String ft, int projectId) async {
    // AWW: scope to their AWC's children only
    final user = ref.read(currentUserProvider);
    List<int> childIds;
    if (user?.isAWW == true && user?.anganwadiCenterId != null) {
      final rows = await SupabaseService.client.rpc(
        'get_children_for_awc_full',
        params: {'p_awc_id': user!.anganwadiCenterId!},
      );
      childIds = (rows as List).map<int>((r) => (r as Map)['id'] as int).toList();
    } else {
      childIds = await getChildIdsViaRpc('project', projectId);
    }
    if (childIds.isEmpty) return [];

    // Batch child IDs (200 per batch) for RPC calls
    Future<List<Map<String, dynamic>>> batchedRpc(String rpcName, String paramName, List<int> ids) async {
      final all = <Map<String, dynamic>>[];
      for (var i = 0; i < ids.length; i += 200) {
        final batch = ids.sublist(i, (i + 200).clamp(0, ids.length));
        final rows = await SupabaseService.client.rpc(rpcName, params: {paramName: batch});
        all.addAll((rows as List).map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r as Map)));
      }
      return all;
    }

    // Risk filter: risk_low, risk_medium, risk_high
    if (ft.startsWith('risk_')) {
      final riskLevel = ft.replaceFirst('risk_', '').toUpperCase();
      final rows = await batchedRpc('get_screening_results_for_children', 'p_child_ids', childIds);
      return rows
          .where((r) => r['overall_risk'] == riskLevel)
          .map<int>((r) => r['child_id'] as int)
          .toSet()
          .toList();
    }

    // Referral filter: referral_pending, referral_completed, referral_under_treatment
    if (ft.startsWith('referral_')) {
      final status = ft.replaceFirst('referral_', '');
      final dbStatus = switch (status) {
        'pending' => 'Pending',
        'completed' => 'Completed',
        'under_treatment' => 'Under_Treatment',
        _ => status,
      };
      final rows = await batchedRpc('get_referrals_for_children', 'p_child_ids', childIds);
      return rows
          .where((r) => r['referral_status'] == dbStatus)
          .map<int>((r) => r['child_id'] as int)
          .toSet()
          .toList();
    }

    // Domain delay filter: domain_gm, domain_fm, domain_lc, domain_cog, domain_se
    if (ft.startsWith('domain_') && !ft.contains('improved')) {
      final domain = ft.replaceFirst('domain_', '');
      final col = '${domain}_dq';
      final rows = await batchedRpc('get_screening_results_for_children', 'p_child_ids', childIds);
      return rows
          .where((r) {
            final dq = r[col];
            return dq != null && (dq as num) < 85;
          })
          .map<int>((r) => r['child_id'] as int)
          .toSet()
          .toList();
    }

    // Improvement filter: improvement_improved, improvement_same, improvement_worsened
    if (ft.startsWith('improvement_')) {
      final status = ft.replaceFirst('improvement_', '');
      final dbStatus = switch (status) {
        'improved' => 'Improved',
        'same' => 'Same',
        'worsened' => 'Worsened',
        _ => status,
      };
      final rows = await batchedRpc('get_followups_for_children', 'p_child_ids', childIds);
      return rows
          .where((r) => r['improvement_status'] == dbStatus)
          .map<int>((r) => r['child_id'] as int)
          .toSet()
          .toList();
    }

    // Exited high risk
    if (ft == 'exited_high_risk') {
      final rows = await batchedRpc('get_followups_for_children', 'p_child_ids', childIds);
      return rows
          .where((r) => r['exit_high_risk'] == true)
          .map<int>((r) => r['child_id'] as int)
          .toSet()
          .toList();
    }

    // Domain improved
    if (ft == 'domain_improved') {
      final rows = await batchedRpc('get_followups_for_children', 'p_child_ids', childIds);
      return rows
          .where((r) => r['domain_improvement'] == true)
          .map<int>((r) => r['child_id'] as int)
          .toSet()
          .toList();
    }

    return [];
  }

  int _calculateAgeMonths(String dobStr) {
    final dob = DateTime.parse(dobStr);
    final now = DateTime.now();
    int months = (now.year - dob.year) * 12 + (now.month - dob.month);
    if (now.day < dob.day) months--;
    return months < 0 ? 0 : months;
  }

  @override
  Widget build(BuildContext context) {
    final isTelugu = widget.isTelugu;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _children.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people_outline,
                          size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      Text(
                        isTelugu ? 'పిల్లలు లేరు' : 'No children found',
                        style:
                            const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: AppColors.primaryLight,
                      child: Text(
                        '${_children.length} ${isTelugu ? 'పిల్లలు' : 'children'}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _children.length,
                        itemBuilder: (context, index) {
                          final c = _children[index];
                          final dobStr =
                              c['dob']?.toString() ?? '2000-01-01';
                          final ageMonths = _calculateAgeMonths(dobStr);
                          final gender =
                              c['gender']?.toString() ?? 'male';
                          final childId = c['id'] as int?;

                          // Build childData map matching ChildStatusCard expectations
                          final childMap = {
                            'child_id': childId,
                            'child_unique_id':
                                c['child_unique_id'] ?? '',
                            'name': c['name'] ?? '',
                            'date_of_birth': dobStr,
                            'gender': gender,
                            'age_months': ageMonths,
                            'photo_url': c['photo_url'],
                            'awc_id': c['awc_id'],
                            'parent_id': c['parent_id'],
                            'aww_id': c['aww_id'],
                          };

                          return Padding(
                            padding: EdgeInsets.only(
                                bottom: 8,
                                top: index == 0 ? 8 : 0),
                            child: ChildStatusCard(
                              childData: childMap,
                              result: childId != null
                                  ? _screeningResults[childId]
                                  : null,
                              followup: childId != null
                                  ? _followupData[childId]
                                  : null,
                              isTelugu: isTelugu,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChildProfileScreen(
                                        child:
                                            Child.fromMap(childMap)),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
