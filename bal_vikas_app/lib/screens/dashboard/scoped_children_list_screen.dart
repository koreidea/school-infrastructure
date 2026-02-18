import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../models/user.dart';
import '../../providers/screening_results_storage.dart';
import '../../services/supabase_service.dart';
import '../children/child_profile_screen.dart';
import '../children/child_status_card.dart';

/// Unified filtered children list screen that works at any hierarchy scope level.
/// Replaces _SOChildrenListScreen, _DWChildrenListScreen, _ChildrenListScreen (CDPO),
/// and _SvChildrenListScreen with a single reusable implementation.
class ScopedChildrenListScreen extends StatefulWidget {
  final String scopeLevel; // 'state', 'district', 'project', 'sector', 'awc'
  final int scopeId;
  final String title;
  final String filter; // 'all', 'high_risk', 'screened', 'pending', 'referral'
  final bool useRpc; // When true, use RPC to bypass RLS (for dataset override)

  const ScopedChildrenListScreen({
    super.key,
    required this.scopeLevel,
    required this.scopeId,
    required this.title,
    required this.filter,
    this.useRpc = false,
  });

  @override
  State<ScopedChildrenListScreen> createState() => _ScopedChildrenListScreenState();
}

class _ScopedChildrenListScreenState extends State<ScopedChildrenListScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _filteredChildren = [];
  Map<int, SavedScreeningResult> _screeningResults = {};
  Map<int, Map<String, dynamic>> _followupData = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Fetch children and screening results based on scope level
      final children = await _getChildrenForScope();
      final results = await _getScreeningResultsForScope();

      // Build risk/referral maps AND full screening result objects
      final riskMap = <int, String>{};
      final referralMap = <int, bool>{};
      final screeningMap = <int, SavedScreeningResult>{};
      for (final r in results) {
        final childId = r['child_id'] as int?;
        if (childId != null && !riskMap.containsKey(childId)) {
          riskMap[childId] = r['overall_risk'] as String? ?? 'LOW';
          referralMap[childId] = r['referral_needed'] as bool? ?? false;
          screeningMap[childId] = ChildStatusCard.resultFromMap(r);
        }
      }

      // Annotate children with risk data
      final annotated = children.map((c) {
        final childId = c['id'] as int;
        final awcData = c['anganwadi_centres'] as Map?;
        return {
          ...c,
          '_risk': riskMap[childId],
          '_referral': referralMap[childId] ?? false,
          '_awc_name': awcData?['name']?.toString() ?? awcData?['centre_code']?.toString() ?? '',
        };
      }).toList();

      // Apply filter
      List<Map<String, dynamic>> filtered;
      switch (widget.filter) {
        case 'high_risk':
          filtered = annotated.where((c) => c['_risk'] == 'HIGH').toList();
        case 'screened':
          filtered = annotated.where((c) => c['_risk'] != null).toList();
        case 'pending':
          filtered = annotated.where((c) => c['_risk'] == null).toList();
        case 'referral':
          filtered = annotated.where((c) => c['_referral'] == true).toList();
        default:
          filtered = annotated;
      }

      // Load followup data
      final childIds = filtered.map((c) => c['id'] as int).toList();
      final followupMap = await _loadFollowupData(childIds);

      if (mounted) {
        setState(() {
          _filteredChildren = filtered;
          _screeningResults = screeningMap;
          _followupData = followupMap;
          _isLoading = false;
        });
      }
    } catch (e, st) {
      print('[ScopedChildrenList] ERROR loading data: $e\n$st');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<Map<int, Map<String, dynamic>>> _loadFollowupData(List<int> childIds) async {
    if (childIds.isEmpty) return {};
    try {
      final followupMap = <int, Map<String, dynamic>>{};
      for (var i = 0; i < childIds.length; i += 200) {
        final batch = childIds.sublist(i, (i + 200).clamp(0, childIds.length));
        List<Map<String, dynamic>> rows;
        if (widget.useRpc) {
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
      return followupMap;
    } catch (_) {
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> _getChildrenForScope() async {
    // Use RPC to bypass RLS when dataset override is active
    if (widget.useRpc) {
      final rows = await SupabaseService.client.rpc(
        'get_children_for_scope',
        params: {'p_scope': widget.scopeLevel, 'p_scope_id': widget.scopeId},
      );
      return (rows as List).map<Map<String, dynamic>>((r) {
        final m = Map<String, dynamic>.from(r as Map);
        // Add empty anganwadi_centres stub so annotated code doesn't break
        m['anganwadi_centres'] = null;
        return m;
      }).toList();
    }
    switch (widget.scopeLevel) {
      case 'state':
        return await SupabaseService.getChildrenForState(widget.scopeId);
      case 'district':
        return await SupabaseService.getChildrenForDistrict(widget.scopeId);
      case 'project':
        return await SupabaseService.getChildrenForProject(widget.scopeId);
      case 'sector':
        return await SupabaseService.getChildrenForSector(widget.scopeId);
      case 'awc':
        return await SupabaseService.getChildrenForAwc(widget.scopeId);
      default:
        return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getScreeningResultsForScope() async {
    // Use RPC to bypass RLS when dataset override is active
    if (widget.useRpc) {
      // Get child IDs first, then use screening RPC
      final childRows = await SupabaseService.client.rpc(
        'get_children_for_scope',
        params: {'p_scope': widget.scopeLevel, 'p_scope_id': widget.scopeId},
      );
      final childIds = (childRows as List).map<int>((r) => r['id'] as int).toList();
      print('[ScopedChildrenList] RPC children: ${childIds.length}');
      if (childIds.isEmpty) return [];
      // Batch child IDs to avoid URL length limits (200 per batch)
      final allResults = <Map<String, dynamic>>[];
      for (var i = 0; i < childIds.length; i += 200) {
        final batch = childIds.sublist(i, i + 200 > childIds.length ? childIds.length : i + 200);
        final resultRows = await SupabaseService.client.rpc(
          'get_screening_results_for_children',
          params: {'p_child_ids': batch},
        );
        allResults.addAll((resultRows as List).map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r as Map)));
      }
      print('[ScopedChildrenList] RPC screening results: ${allResults.length}');
      return allResults;
    }
    switch (widget.scopeLevel) {
      case 'state':
        return await SupabaseService.getScreeningResultsForState(widget.scopeId);
      case 'district':
        return await SupabaseService.getScreeningResultsForDistrict(widget.scopeId);
      case 'project':
        return await SupabaseService.getScreeningResultsForProject(widget.scopeId);
      case 'sector':
        return await SupabaseService.getScreeningResultsForSector(widget.scopeId);
      case 'awc':
        return await SupabaseService.getScreeningResultsForAwc(widget.scopeId);
      default:
        return [];
    }
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
    final isTelugu = Localizations.localeOf(context).languageCode == 'te';
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.primaryLight,
                child: Row(children: [
                  Text(
                    '${_filteredChildren.length} ${isTelugu ? 'పిల్లలు' : 'children'}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ]),
              ),
              Expanded(
                child: _filteredChildren.isEmpty
                    ? Center(
                        child: Text(
                          isTelugu ? 'పిల్లలు లేరు' : 'No children found',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredChildren.length,
                        itemBuilder: (context, index) {
                          final c = _filteredChildren[index];
                          final dobStr = c['dob']?.toString() ?? '2000-01-01';
                          final ageMonths = _calculateAgeMonths(dobStr);
                          final childId = c['id'] as int?;

                          final childMap = {
                            'child_id': childId,
                            'child_unique_id': c['child_unique_id'] ?? '',
                            'name': c['name'] ?? '',
                            'date_of_birth': dobStr,
                            'gender': c['gender'] ?? 'male',
                            'age_months': ageMonths,
                            'photo_url': c['photo_url'],
                            'awc_id': c['awc_id'],
                            'parent_id': c['parent_id'],
                            'aww_id': c['aww_id'],
                          };

                          return Padding(
                            padding: EdgeInsets.only(
                                bottom: 8, top: index == 0 ? 8 : 0),
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
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => ChildProfileScreen(child: Child.fromMap(childMap)),
                                ));
                              },
                            ),
                          );
                        },
                      ),
              ),
            ]),
    );
  }
}
