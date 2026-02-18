import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../models/user.dart';
import '../../providers/screening_results_storage.dart';
import '../../services/supabase_service.dart';
import '../../utils/telugu_transliterator.dart';
import 'child_profile_screen.dart';
import 'child_status_card.dart';
import 'add_child_screen.dart';

/// Generic hierarchy navigation screen for drilling down through
/// the ICDS hierarchy: State → District → Project → Sector → AWC → Children.
///
/// Used in the Children tab for non-AWW roles and in dashboard drill-downs.
/// When [useRpc] is true, all queries use SECURITY DEFINER RPC functions
/// to bypass RLS (needed for cross-project dataset browsing).
///
/// Special levels for ECD Sample data:
/// - 'districts_of_project': shows districts linked to a project (scope = project_id)
/// - 'sectors_of_district': shows sectors under all projects in a district (scope = district_id)
class HierarchyLevelScreen extends StatefulWidget {
  /// Level determines what to show and query:
  /// 'districts', 'projects', 'sectors', 'awcs', 'children'
  /// 'districts_of_project', 'sectors_of_district' (ECD Sample special levels)
  final String level;

  /// Parent scope ID (e.g., state_id for districts, district_id for projects)
  final int scopeId;

  /// Title shown in the AppBar
  final String title;

  final bool isTelugu;

  /// Whether to show AppBar (false when embedded in ChildListScreen)
  final bool showAppBar;

  /// Whether to use RPC functions (bypasses RLS for cross-project browsing)
  final bool useRpc;

  /// IDs to exclude from results (e.g., sample dataset district IDs)
  final Set<int> excludeIds;

  const HierarchyLevelScreen({
    super.key,
    required this.level,
    required this.scopeId,
    required this.title,
    required this.isTelugu,
    this.showAppBar = true,
    this.useRpc = false,
    this.excludeIds = const {},
  });

  @override
  State<HierarchyLevelScreen> createState() => _HierarchyLevelScreenState();
}

class _HierarchyLevelScreenState extends State<HierarchyLevelScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _items = [];
  // For children level: full screening results + followup data
  Map<int, SavedScreeningResult> _screeningResults = {};
  Map<int, Map<String, dynamic>> _followupData = {};

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      List<Map<String, dynamic>> items;

      if (_isVirtualLevel(widget.level)) {
        // Virtual levels (ECD Sample): always use direct queries
        items = await _loadItemsDirect();
      } else if (widget.useRpc && widget.level != 'children') {
        // RPC path for standard hierarchy levels (districts/projects/sectors/awcs)
        items = await _loadHierarchyViaRpc(widget.level, widget.scopeId);
      } else if (widget.useRpc && widget.level == 'children') {
        // RPC path for children
        items = await _loadChildrenViaRpc(widget.scopeId);
      } else {
        // Standard direct query path
        items = await _loadItemsDirect();
      }

      // Filter out excluded IDs (e.g., sample dataset districts)
      if (widget.excludeIds.isNotEmpty) {
        items = items.where((item) {
          final id = item['id'];
          return id == null || !widget.excludeIds.contains(id);
        }).toList();
      }

      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('[Hierarchy] Error loading items: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Load hierarchy items via RPC (bypasses RLS)
  Future<List<Map<String, dynamic>>> _loadHierarchyViaRpc(String level, int scopeId) async {
    final rpcRows = await SupabaseService.client.rpc(
      'get_hierarchy_items',
      params: {'p_level': level, 'p_scope_id': scopeId},
    );
    return (rpcRows as List)
        .map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r as Map))
        .toList();
  }

  bool _isVirtualLevel(String level) =>
      level == 'districts_of_project' || level == 'sectors_of_district';

  /// Load children + screening results via RPC (bypasses RLS)
  Future<List<Map<String, dynamic>>> _loadChildrenViaRpc(int awcId) async {
    final rpcRows = await SupabaseService.client.rpc(
      'get_children_for_scope',
      params: {'p_scope': 'awc', 'p_scope_id': awcId},
    );
    final items = (rpcRows as List)
        .map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r as Map))
        .toList();

    // Also fetch screening results + followups via RPC
    if (items.isNotEmpty) {
      final childIds = items.map((c) => c['id'] as int).toList();
      await _loadScreeningAndFollowup(childIds, true);
    }

    return items;
  }

  /// Standard direct query path (when RLS allows access)
  Future<List<Map<String, dynamic>>> _loadItemsDirect() async {
    List<Map<String, dynamic>> items;
    switch (widget.level) {
      case 'districts':
        items = List<Map<String, dynamic>>.from(
          await SupabaseService.client
              .from('districts')
              .select()
              .eq('state_id', widget.scopeId)
              .order('name'),
        );
        break;
      case 'projects':
        items = List<Map<String, dynamic>>.from(
          await SupabaseService.client
              .from('projects')
              .select()
              .eq('district_id', widget.scopeId)
              .order('name'),
        );
        break;
      case 'districts_of_project':
        // ECD Sample: show all districts linked to the dataset.
        // scopeId here is the project_id from the dataset.
        // 1. Check datasets table for district_ids array
        // 2. Fallback: single district from the project's district_id
        List<int> districtIds = [];
        try {
          final dsRow = await SupabaseService.client
              .from('datasets')
              .select('district_ids')
              .eq('project_id', widget.scopeId)
              .maybeSingle();
          if (dsRow != null && dsRow['district_ids'] is List) {
            districtIds = (dsRow['district_ids'] as List)
                .map<int>((e) => e as int)
                .toList();
          }
        } catch (_) {}

        if (districtIds.isEmpty) {
          // Fallback: single district from the project
          final proj = await SupabaseService.client
              .from('projects')
              .select('district_id')
              .eq('id', widget.scopeId)
              .maybeSingle();
          if (proj != null && proj['district_id'] != null) {
            districtIds = [proj['district_id'] as int];
          }
        }

        if (districtIds.isNotEmpty) {
          items = List<Map<String, dynamic>>.from(
            await SupabaseService.client
                .from('districts')
                .select()
                .inFilter('id', districtIds)
                .order('name'),
          );
        } else {
          items = [];
        }
        break;
      case 'sectors_of_district':
        // ECD Sample: show sectors under all projects in a district
        final projects = await SupabaseService.client
            .from('projects')
            .select('id')
            .eq('district_id', widget.scopeId);
        final projectIds = (projects as List).map<int>((p) => p['id'] as int).toList();
        if (projectIds.isNotEmpty) {
          items = List<Map<String, dynamic>>.from(
            await SupabaseService.client
                .from('sectors')
                .select()
                .inFilter('project_id', projectIds)
                .order('name'),
          );
        } else {
          items = [];
        }
        break;
      case 'sectors':
        items = List<Map<String, dynamic>>.from(
          await SupabaseService.client
              .from('sectors')
              .select()
              .eq('project_id', widget.scopeId)
              .order('name'),
        );
        break;
      case 'awcs':
        items = List<Map<String, dynamic>>.from(
          await SupabaseService.client
              .from('anganwadi_centres')
              .select()
              .eq('sector_id', widget.scopeId)
              .eq('is_active', true)
              .order('centre_code'),
        );
        break;
      case 'children':
        items = List<Map<String, dynamic>>.from(
          await SupabaseService.client
              .from('children')
              .select()
              .eq('awc_id', widget.scopeId)
              .eq('is_active', true)
              .order('name'),
        );
        // Also fetch screening results + followups for rich cards
        if (items.isNotEmpty) {
          final childIds = items.map((c) => c['id'] as int).toList();
          await _loadScreeningAndFollowup(childIds, false);
        }
        break;
      default:
        items = [];
    }
    return items;
  }

  /// Fetch full screening results + followup data for child IDs.
  Future<void> _loadScreeningAndFollowup(List<int> childIds, bool useRpc) async {
    // Screening results
    try {
      final screeningMap = <int, SavedScreeningResult>{};
      for (var i = 0; i < childIds.length; i += 200) {
        final batch = childIds.sublist(i, (i + 200).clamp(0, childIds.length));
        List<Map<String, dynamic>> rows;
        if (useRpc) {
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
        for (final r in rows) {
          final cid = r['child_id'] as int;
          if (!screeningMap.containsKey(cid)) {
            screeningMap[cid] = ChildStatusCard.resultFromMap(r);
          }
        }
      }
      _screeningResults = screeningMap;
    } catch (_) {}

    // Followup data
    try {
      final followupMap = <int, Map<String, dynamic>>{};
      for (var i = 0; i < childIds.length; i += 200) {
        final batch = childIds.sublist(i, (i + 200).clamp(0, childIds.length));
        List<Map<String, dynamic>> rows;
        if (useRpc) {
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
    } catch (_) {}
  }

  String _nextLevel() => switch (widget.level) {
        'districts' => 'projects',
        'projects' => widget.useRpc ? 'districts_of_project' : 'sectors',
        'districts_of_project' => 'sectors_of_district',
        'sectors_of_district' => 'awcs',
        'sectors' => 'awcs',
        'awcs' => 'children',
        _ => '',
      };

  IconData _levelIcon() => switch (widget.level) {
        'districts' || 'districts_of_project' => Icons.map,
        'projects' => Icons.business,
        'sectors' || 'sectors_of_district' => Icons.location_city,
        'awcs' => Icons.location_on,
        'children' => Icons.child_care,
        _ => Icons.list,
      };

  String _levelLabel() => switch (widget.level) {
        'districts' || 'districts_of_project' => widget.isTelugu ? 'జిల్లాలు' : 'Districts',
        'projects' => widget.isTelugu ? 'ప్రాజెక్టులు' : 'Projects',
        'sectors' || 'sectors_of_district' => widget.isTelugu ? 'సెక్టార్లు' : 'Sectors',
        'awcs' => widget.isTelugu ? 'AWC కేంద్రాలు' : 'AWC Centers',
        'children' => widget.isTelugu ? 'పిల్లలు' : 'Children',
        _ => '',
      };

  int _calculateAgeMonths(String dobStr) {
    final dob = DateTime.parse(dobStr);
    final now = DateTime.now();
    int months = (now.year - dob.year) * 12 + (now.month - dob.month);
    if (now.day < dob.day) months--;
    return months < 0 ? 0 : months;
  }

  @override
  Widget build(BuildContext context) {
    final body = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _items.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_levelIcon(),
                        size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: 12),
                    Text(
                      '${_levelLabel()} ${widget.isTelugu ? 'లేవు' : 'not found'}',
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
                      '${_items.length} ${_levelLabel()}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: widget.level == 'children'
                        ? _buildChildrenList()
                        : _buildUnitList(),
                  ),
                ],
              );

    final fab = widget.level == 'children'
        ? FloatingActionButton(
            heroTag: 'addChildHierarchy',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddChildScreen(),
                ),
              );
              if (result == true) {
                _loadItems(); // Refresh children list
              }
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          )
        : null;

    if (!widget.showAppBar) {
      return Scaffold(
        body: body,
        floatingActionButton: fab,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: body,
      floatingActionButton: fab,
    );
  }

  Widget _buildUnitList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final name = item['name']?.toString() ??
            item['centre_code']?.toString() ??
            '';
        final code = item['code']?.toString() ??
            item['centre_code']?.toString() ??
            '';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              final nextLvl = _nextLevel();
              if (nextLvl.isNotEmpty) {
                final nextTitle =
                    widget.isTelugu ? toTelugu(name) : name;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HierarchyLevelScreen(
                      level: nextLvl,
                      scopeId: item['id'] as int,
                      title: nextTitle,
                      isTelugu: widget.isTelugu,
                      useRpc: widget.useRpc, // propagate RPC flag
                    ),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(_levelIcon(), color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isTelugu ? toTelugu(name) : name,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        if (code.isNotEmpty && code != name)
                          Text(code,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChildrenList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final c = _items[index];
        final dobStr = c['dob']?.toString() ?? '2000-01-01';
        final ageMonths = _calculateAgeMonths(dobStr);
        final gender = c['gender']?.toString() ?? 'male';
        final childId = c['id'] as int?;

        final childMap = {
          'child_id': childId,
          'child_unique_id': c['child_unique_id'] ?? '',
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
          padding: const EdgeInsets.only(bottom: 8),
          child: ChildStatusCard(
            childData: childMap,
            result: childId != null ? _screeningResults[childId] : null,
            followup: childId != null ? _followupData[childId] : null,
            isTelugu: widget.isTelugu,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ChildProfileScreen(child: Child.fromMap(childMap)),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
