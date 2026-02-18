import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/children_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dataset_provider.dart';
import '../../providers/screening_results_storage.dart';
import '../../config/api_config.dart';
import '../../models/user.dart';
import '../../services/supabase_service.dart';
import '../../services/connectivity_service.dart';
import 'child_profile_screen.dart';
import 'child_status_card.dart';
import 'add_child_screen.dart';
import 'hierarchy_children_screen.dart';

class ChildListScreen extends ConsumerWidget {
  const ChildListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';
    final role = user?.roleName ?? '';

    // AWW / PARENT: flat list of their children
    // Only AWW (and above) can register children — PARENT cannot
    if (role == 'AWW' || role == 'PARENT' || role.isEmpty) {
      final canAddChild = role == 'AWW';
      return Scaffold(
        body: _FlatChildList(isTelugu: isTelugu),
        floatingActionButton: canAddChild
            ? FloatingActionButton(
                heroTag: 'addChildFlatList',
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddChildScreen(),
                    ),
                  );
                  if (result == true) {
                    ref.invalidate(childrenProvider);
                  }
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
      );
    }

    // Non-AWW roles: hierarchical navigation
    return _buildHierarchyView(context, ref, user, isTelugu, role);
  }

  Widget _buildHierarchyView(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    bool isTelugu,
    String role,
  ) {
    // Check for dataset override — use effective IDs instead of user's own scope
    final datasetOverride = ref.watch(activeDatasetProvider);

    // Determine starting level and scope based on role + dataset override
    String level;
    int? scopeId;
    String title;

    if (role == 'SUPERVISOR') {
      if (datasetOverride != null && datasetOverride.projectId != null) {
        // Dataset override: elevate from sector → project scope (show sectors)
        level = 'sectors';
        scopeId = datasetOverride.projectId;
        title = isTelugu ? 'సెక్టార్లు' : 'Sectors';
      } else {
        level = 'awcs';
        scopeId = user?.sectorId;
        title = isTelugu ? 'AWC కేంద్రాలు' : 'AWC Centers';
      }
    } else if (['CDPO', 'CW', 'EO'].contains(role)) {
      level = 'sectors';
      scopeId = ref.watch(effectiveProjectIdProvider);
      title = isTelugu ? 'సెక్టార్లు' : 'Sectors';
    } else if (role == 'DW') {
      if (datasetOverride != null && datasetOverride.isMultiDistrict) {
        // Multi-district ECD: show all districts from dataset
        level = 'districts_of_project';
        scopeId = datasetOverride.projectId;
        title = isTelugu ? 'జిల్లాలు' : 'Districts';
      } else {
        level = 'projects';
        scopeId = ref.watch(effectiveDistrictIdProvider);
        title = isTelugu ? 'ప్రాజెక్టులు' : 'Projects';
      }
    } else if (role == 'SENIOR_OFFICIAL') {
      if (datasetOverride != null && datasetOverride.isMultiDistrict) {
        // Multi-district ECD: show all districts from dataset
        level = 'districts_of_project';
        scopeId = datasetOverride.projectId;
        title = isTelugu ? 'జిల్లాలు' : 'Districts';
      } else if (datasetOverride != null && datasetOverride.districtId != null) {
        // Single-district override: scope to district level
        level = 'projects';
        scopeId = datasetOverride.districtId;
        title = isTelugu ? 'ప్రాజెక్టులు' : 'Projects';
      } else {
        level = 'districts';
        scopeId = ref.watch(effectiveStateIdProvider);
        title = isTelugu ? 'జిల్లాలు' : 'Districts';
      }
    } else {
      // Unknown role, fall back to flat list
      return Scaffold(body: _FlatChildList(isTelugu: isTelugu));
    }

    if (scopeId == null) {
      return Scaffold(
        body: Center(
          child: Text(
            isTelugu
                ? 'మీ ఖాతాకు ప్రాంతం కేటాయించబడలేదు'
                : 'No area assigned to your account',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // When Senior Official views districts (App Data), exclude sample dataset districts
    final excludeIds = (level == 'districts' && datasetOverride == null)
        ? ref.watch(sampleDatasetDistrictIdsProvider)
        : <int>{};

    return Scaffold(
      body: HierarchyLevelScreen(
        level: level,
        scopeId: scopeId,
        title: title,
        isTelugu: isTelugu,
        showAppBar: false,
        useRpc: datasetOverride != null,
        excludeIds: excludeIds,
      ),
    );
  }
}

/// Flat child list with rich status cards (screening risk, improvement, domain chips).
class _FlatChildList extends ConsumerStatefulWidget {
  final bool isTelugu;
  const _FlatChildList({required this.isTelugu});

  @override
  ConsumerState<_FlatChildList> createState() => _FlatChildListState();
}

class _FlatChildListState extends ConsumerState<_FlatChildList> {
  Map<int, Map<String, dynamic>> _followupData = {};

  @override
  void initState() {
    super.initState();
    _loadFollowupData();
  }

  Future<void> _loadFollowupData() async {
    try {
      final children = ref.read(childrenProvider).value ?? [];
      final childIds = children
          .map((c) => c['child_id'] as int?)
          .whereType<int>()
          .toList();
      if (childIds.isEmpty) return;

      if (!ConnectivityService.isOnline) return;

      final datasetOverride = ref.read(activeDatasetProvider);

      List<dynamic> data;
      if (datasetOverride != null) {
        // Use RPC to bypass RLS for dataset override
        data = await SupabaseService.client.rpc(
          'get_followups_for_children',
          params: {'p_child_ids': childIds},
        );
      } else {
        data = await SupabaseService.client
            .from('intervention_followups')
            .select()
            .inFilter('child_id', childIds)
            .order('created_at', ascending: false);
      }

      final map = <int, Map<String, dynamic>>{};
      for (final row in data) {
        final cid = (row as Map)['child_id'] as int;
        if (!map.containsKey(cid)) {
          map[cid] = Map<String, dynamic>.from(row);
        }
      }

      if (mounted) {
        setState(() {
          _followupData = map;
        });
      }
    } catch (_) {
      // Non-critical — cards will show without improvement tags
    }
  }

  @override
  Widget build(BuildContext context) {
    final childrenAsync = ref.watch(childrenProvider);
    final localResults = ref.watch(screeningResultsStorageProvider);
    final isTelugu = widget.isTelugu;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(childrenProvider);
        ref.invalidate(screeningResultsStorageProvider);
        await _loadFollowupData();
      },
      child: childrenAsync.when(
        data: (children) {
          if (children.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    isTelugu ? 'పిల్లలు లేరు' : 'No children found',
                    style: TextStyle(
                        fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];
              final childId = child['child_id'] as int?;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ChildStatusCard(
                  childData: child,
                  result: childId != null ? localResults[childId] : null,
                  followup: childId != null ? _followupData[childId] : null,
                  isTelugu: isTelugu,
                  onTap: () {
                    ref.read(selectedChildProvider.notifier).set(child);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChildProfileScreen(
                          child: Child.fromMap(child),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
