import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../services/supabase_service.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import '../services/prediction_service.dart';
import 'dataset_provider.dart';

// Children list provider - Drift-first, background Supabase refresh
// Watches activeDatasetProvider so it auto-reloads when dataset changes
final childrenProvider = AsyncNotifierProvider<ChildrenNotifier, List<Map<String, dynamic>>>(() {
  return ChildrenNotifier();
});

class ChildrenNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    // Watch dataset changes so provider auto-reloads when user switches datasets
    final activeDataset = ref.watch(activeDatasetProvider);
    return await _loadChildren(datasetOverride: activeDataset);
  }

  /// Calculate age in months from a date of birth string (yyyy-MM-dd)
  static int _calculateAgeMonths(String dobString) {
    final dob = DateTime.parse(dobString);
    final now = DateTime.now();
    int months = (now.year - dob.year) * 12 + (now.month - dob.month);
    if (now.day < dob.day) months--;
    return months < 0 ? 0 : months;
  }

  /// Convert Drift LocalChild row to the Map format the app expects
  static Map<String, dynamic> _localChildToMap(dynamic child) {
    final dobStr = child.dob.toIso8601String().split('T')[0];
    return {
      'child_id': child.remoteId ?? child.localId,
      'local_id': child.localId,
      'child_unique_id': child.childUniqueId,
      'name': child.name,
      'date_of_birth': dobStr,
      'gender': child.gender,
      'age_months': _calculateAgeMonths(dobStr),
      'photo_url': child.photoUrl,
      'parent_id': child.parentId,
      'aww_id': child.awwId,
      'awc_id': child.awcId,
    };
  }

  Future<List<Map<String, dynamic>>> _loadChildren({DatasetConfig? datasetOverride}) async {
    // When a dataset override is active, fetch children for that dataset's scope
    // instead of using the user's own profile scope
    if (datasetOverride != null) {
      try {
        // AWW with dataset override: filter by their specific AWC
        final userProfile = await SupabaseService.getCurrentUserProfile();
        final role = userProfile?['role']?.toString() ?? '';
        final awcId = userProfile?['awc_id'] as int?;

        if (role == 'AWW' && awcId != null) {
          final rows = await SupabaseService.client.rpc(
            'get_children_for_awc_full',
            params: {'p_awc_id': awcId},
          );
          final children = (rows as List)
              .map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r as Map))
              .toList();
          // ignore: avoid_print
          print('[Children] AWW override: AWC $awcId → ${children.length} children');
          return _mapSupabaseChildren(children);
        }

        // Other roles: fetch all children for the dataset's project
        final overrideProjectId = datasetOverride.projectId;
        if (overrideProjectId != null) {
          final rows = await SupabaseService.client.rpc(
            'get_children_for_project_full',
            params: {'p_project_id': overrideProjectId},
          );
          final children = (rows as List)
              .map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r as Map))
              .toList();
          // ignore: avoid_print
          print('[Children] RPC returned ${children.length} children (dataset project=$overrideProjectId)');
          return _mapSupabaseChildren(children);
        }
      } catch (e) {
        // ignore: avoid_print
        print('[Children] Dataset override RPC failed: $e');
        return [];
      }
    }

    // 1. Try Drift local DB first (instant UI) — skip on web
    if (!kIsWeb) {
      try {
        final db = DatabaseService.db;
        final localChildren = await db.childrenDao.getAllChildren();
        // ignore: avoid_print
        print('[Children] _loadChildren: Drift has ${localChildren.length} children');
        if (localChildren.isNotEmpty) {
          // Background refresh from Supabase
          _backgroundRefresh();
          // Return Drift data while background refresh runs
          return localChildren.map(_localChildToMap).toList();
        }
      } catch (_) {}
    }

    // 2. Drift empty — try Supabase directly (first launch)
    try {
      final userProfile = await SupabaseService.getCurrentUserProfile();
      if (userProfile != null) {
        final supabaseChildren = await SupabaseService.getChildrenForUser(userProfile);
        // ignore: avoid_print
        print('[Children] Supabase returned ${supabaseChildren.length} children (role=${userProfile['role']}, awc_id=${userProfile['awc_id']})');

        // Save to Drift for next time (skip on web)
        if (!kIsWeb) {
          try {
            final db = DatabaseService.db;
            for (final row in supabaseChildren) {
              await db.childrenDao.upsertFromRemote(row);
            }
          } catch (_) {}
        }

        return _mapSupabaseChildren(supabaseChildren);
      }
    } catch (_) {
      // Supabase not configured or failed — fall through to legacy
    }

    // 3. Fallback: try old API
    try {
      final apiSvc = ref.read(apiServiceProvider);
      final children = await apiSvc.getChildren();
      return children.map((child) => {
        'child_id': child.childId,
        'child_unique_id': child.childUniqueId,
        'name': child.name,
        'date_of_birth': child.dateOfBirth.toIso8601String().split('T')[0],
        'gender': child.gender,
        'age_months': child.currentAgeMonths,
        'photo_url': child.photoUrl,
        'parent_user_id': child.parentUserId,
        'aww_user_id': child.awwUserId,
        'anganwadi_center_id': child.anganwadiCenterId,
      }).toList();
    } catch (e) {
      // Final fallback to mock data
      final mobileNumber = await StorageService.getUserMobileNumber();
      if (mobileNumber == null) return [];
      return _getMockChildrenForPhoneNumber(mobileNumber);
    }
  }

  /// Map Supabase children rows to the app's expected format
  static List<Map<String, dynamic>> _mapSupabaseChildren(List<Map<String, dynamic>> rows) {
    return rows.map((row) {
      final dobStr = row['dob'] as String;
      return {
        'child_id': row['id'] as int,
        'child_unique_id': row['child_unique_id'] as String,
        'name': row['name'] as String,
        'date_of_birth': dobStr,
        'gender': row['gender'] as String,
        'age_months': _calculateAgeMonths(dobStr),
        'photo_url': row['photo_url'],
        'parent_id': row['parent_id'],
        'aww_id': row['aww_id'],
        'awc_id': row['awc_id'],
      };
    }).toList();
  }


  /// Background pull from Supabase → upsert into Drift → update state
  Future<void> _backgroundRefresh() async {
    try {
      // Skip background refresh when dataset override is active —
      // the override path already returns the correct scoped data,
      // and this refresh would overwrite it with unscoped Drift data.
      final activeDataset = ref.read(activeDatasetProvider);
      if (activeDataset != null) {
        // ignore: avoid_print
        print('[Children] backgroundRefresh: SKIPPED (dataset override active)');
        return;
      }

      final userProfile = await SupabaseService.getCurrentUserProfile();
      if (userProfile == null) {
        // ignore: avoid_print
        print('[Children] backgroundRefresh: no user profile');
        return;
      }

      if (!kIsWeb) {
        await SyncService.pullChildren(userProfile);

        // Re-read from Drift and update state
        final db = DatabaseService.db;
        final localChildren = await db.childrenDao.getAllChildren();
        // ignore: avoid_print
        print('[Children] backgroundRefresh: Drift now has ${localChildren.length} children');
        state = AsyncValue.data(localChildren.map(_localChildToMap).toList());

        // Also pull screening results for these children into Drift
        final childRemoteIds = localChildren
            .where((c) => c.remoteId != null)
            .map((c) => c.remoteId!)
            .toList();
        if (childRemoteIds.isNotEmpty) {
          await SyncService.pullScreeningResults(childRemoteIds);
          // Backfill predictions for newly-pulled results
          final backfilled = await PredictionService.backfillPredictions();
          if (backfilled > 0) {
            // ignore: avoid_print
            print('[Children] backgroundRefresh: backfilled $backfilled predictions');
          }
        }
      } else {
        // On web: refresh directly from Supabase (no Drift)
        final supabaseChildren = await SupabaseService.getChildrenForUser(userProfile);
        state = AsyncValue.data(_mapSupabaseChildren(supabaseChildren));
      }
    } catch (e) {
      // ignore: avoid_print
      print('[Children] backgroundRefresh FAILED: $e');
    }
  }

  List<Map<String, dynamic>> _getMockChildrenForPhoneNumber(String mobileNumber) {
    final last4 = mobileNumber.length >= 4 ? mobileNumber.substring(mobileNumber.length - 4) : mobileNumber;
    final hash = last4.hashCode.abs();

    if (mobileNumber == '9876543210' || mobileNumber == '9999999999') {
      return [
        {
          'child_id': 1,
          'child_unique_id': 'CHILD-ARJUN001',
          'name': 'Arjun',
          'date_of_birth': '2022-08-15',
          'gender': 'male',
          'age_months': _calculateAgeMonths('2022-08-15'),
          'photo_url': null,
          'parent_mobile': mobileNumber,
        },
        {
          'child_id': 2,
          'child_unique_id': 'CHILD-MEERA001',
          'name': 'Meera',
          'date_of_birth': '2020-08-20',
          'gender': 'female',
          'age_months': _calculateAgeMonths('2020-08-20'),
          'photo_url': null,
          'parent_mobile': mobileNumber,
        },
      ];
    }

    final numChildren = (hash % 2) + 1;
    final children = <Map<String, dynamic>>[];

    for (int i = 0; i < numChildren; i++) {
      final dob = '2022-01-01';
      children.add({
        'child_id': hash + i,
        'child_unique_id': 'CHILD-$last4-${i + 1}',
        'name': 'Child ${i + 1}',
        'date_of_birth': dob,
        'gender': (hash + i) % 2 == 0 ? 'male' : 'female',
        'age_months': _calculateAgeMonths(dob),
        'photo_url': null,
        'parent_mobile': mobileNumber,
      });
    }

    return children;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final activeDataset = ref.read(activeDatasetProvider);
      final children = await _loadChildren(datasetOverride: activeDataset);
      state = AsyncValue.data(children);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Force invalidate and reload
  void invalidate() {
    ref.invalidateSelf();
  }

  Future<void> addChild(Map<String, dynamic> childData) async {
    final currentChildren = state.value ?? [];

    // Try to add via Supabase
    try {
      final userProfile = await SupabaseService.getCurrentUserProfile();
      if (userProfile != null && userProfile['role'] == 'AWW') {
        final row = await SupabaseService.client.from('children').insert({
          'child_unique_id': childData['child_unique_id'] ?? 'AP_ECD_${DateTime.now().millisecondsSinceEpoch}',
          'name': childData['name'],
          'dob': childData['date_of_birth'],
          'gender': childData['gender'],
          'awc_id': userProfile['awc_id'],
          'aww_id': userProfile['id'],
          'parent_id': childData['parent_id'],
        }).select().single();

        final dobStr = row['dob'] as String;
        final newChild = {
          'child_id': row['id'] as int,
          'child_unique_id': row['child_unique_id'] as String,
          'name': row['name'] as String,
          'date_of_birth': dobStr,
          'gender': row['gender'] as String,
          'age_months': _calculateAgeMonths(dobStr),
          'photo_url': row['photo_url'],
          'awc_id': row['awc_id'],
        };

        state = AsyncValue.data([...currentChildren, newChild]);
        return;
      }
    } catch (_) {}

    // Fallback: local-only add
    final mobileNumber = await StorageService.getUserMobileNumber();
    final newChild = {
      ...childData,
      'child_id': DateTime.now().millisecondsSinceEpoch,
      'child_unique_id': 'CHILD-${mobileNumber}-${currentChildren.length + 1}',
      'parent_mobile': mobileNumber,
    };

    state = AsyncValue.data([...currentChildren, newChild]);
  }
}

// Selected child - using simple provider pattern with a class
class SelectedChildNotifier extends Notifier<Map<String, dynamic>?> {
  @override
  Map<String, dynamic>? build() => null;

  void set(Map<String, dynamic>? child) => state = child;
}

final selectedChildProvider = NotifierProvider<SelectedChildNotifier, Map<String, dynamic>?>(() {
  return SelectedChildNotifier();
});

// Child detail provider
final childDetailProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, childId) async {
  // When dataset override is active, use RPC to bypass RLS
  final isOverride = ref.watch(activeDatasetProvider) != null;

  try {
    Map<String, dynamic>? row;
    if (isOverride) {
      final rows = await SupabaseService.client.rpc(
        'get_child_by_id',
        params: {'p_child_id': childId},
      );
      if ((rows as List).isNotEmpty) {
        row = Map<String, dynamic>.from(rows[0] as Map);
      }
    } else {
      row = await SupabaseService.client
          .from('children')
          .select()
          .eq('id', childId)
          .maybeSingle();
    }

    if (row != null) {
      final dobStr = row['dob'] as String;
      return {
        'child_id': row['id'] as int,
        'child_unique_id': row['child_unique_id'] as String,
        'name': row['name'] as String,
        'date_of_birth': dobStr,
        'gender': row['gender'] as String,
        'age_months': ChildrenNotifier._calculateAgeMonths(dobStr),
        'photo_url': row['photo_url'],
        'awc_id': row['awc_id'],
        'parent_id': row['parent_id'],
      };
    }
  } catch (_) {}

  // Fallback: look in the already-loaded children list
  final children = ref.read(childrenProvider).value ?? [];
  for (final c in children) {
    if (c['child_id'] == childId) return c;
  }
  return null;
});

// Child screenings provider — fetches from Supabase
// Uses RPC when dataset override is active (to bypass RLS for cross-project data)
final childScreeningsProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, childId) async {
  final isOverride = ref.watch(activeDatasetProvider) != null;

  try {
    if (isOverride) {
      // Use RPC to bypass RLS for ECD Sample / cross-project children
      final rows = await SupabaseService.client.rpc(
        'get_screening_history_for_child',
        params: {'p_child_id': childId},
      );
      return (rows as List).map<Map<String, dynamic>>((r) {
        final m = Map<String, dynamic>.from(r as Map);
        return {
          'session_id': m['session_id'] ?? m['id'],
          'assessment_date': m['assessment_date'] ?? m['created_at'],
          'child_age_months': m['child_age_months'] ?? 0,
          'status': m['session_status'] ?? 'completed',
          'overall_risk': m['overall_risk'],
          'composite_dq': m['composite_dq'],
          'gm_dq': m['gm_dq'],
          'fm_dq': m['fm_dq'],
          'lc_dq': m['lc_dq'],
          'cog_dq': m['cog_dq'],
          'se_dq': m['se_dq'],
          'referral_needed': m['referral_needed'],
          'tools_completed': m['tools_completed'],
          'tools_skipped': m['tools_skipped'],
          'created_at': m['created_at'],
        };
      }).toList();
    }

    // Standard path: direct Supabase query (works when RLS allows access)
    final results = await SupabaseService.getScreeningHistory(childId);
    return results.map((r) {
      final session = r['screening_sessions'] as Map<String, dynamic>?;
      return {
        'session_id': r['session_id'] ?? r['id'],
        'assessment_date': session?['assessment_date'] ?? r['created_at'],
        'child_age_months': session?['child_age_months'] ?? 0,
        'status': session?['status'] ?? 'completed',
        'overall_risk': r['overall_risk'],
        'composite_dq': r['composite_dq'],
        'gm_dq': r['gm_dq'],
        'fm_dq': r['fm_dq'],
        'lc_dq': r['lc_dq'],
        'cog_dq': r['cog_dq'],
        'se_dq': r['se_dq'],
        'referral_needed': r['referral_needed'],
        'tools_completed': r['tools_completed'],
        'tools_skipped': r['tools_skipped'],
        'created_at': r['created_at'],
      };
    }).toList();
  } catch (_) {}

  return [];
});
