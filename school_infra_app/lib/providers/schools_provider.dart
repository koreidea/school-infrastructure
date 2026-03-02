import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/school.dart';
import '../models/demand_plan.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';
import '../services/offline_cache_service.dart';
import 'auth_provider.dart';

// Filter state notifiers (Riverpod 3.x)
class _DistrictNotifier extends Notifier<int?> {
  @override
  int? build() => null;
  void set(int? value) => state = value;
}

class _MandalNotifier extends Notifier<int?> {
  @override
  int? build() => null;
  void set(int? value) => state = value;
}

class _CategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

class _PriorityNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

class _SearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String value) => state = value;
}

class _InfraTypeNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

class _ManagementFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

final selectedDistrictProvider =
    NotifierProvider<_DistrictNotifier, int?>(_DistrictNotifier.new);
final selectedMandalProvider =
    NotifierProvider<_MandalNotifier, int?>(_MandalNotifier.new);
final selectedCategoryProvider =
    NotifierProvider<_CategoryNotifier, String?>(_CategoryNotifier.new);
final selectedPriorityProvider =
    NotifierProvider<_PriorityNotifier, String?>(_PriorityNotifier.new);
final selectedInfraTypeProvider =
    NotifierProvider<_InfraTypeNotifier, String?>(_InfraTypeNotifier.new);
final selectedManagementProvider =
    NotifierProvider<_ManagementFilterNotifier, String?>(_ManagementFilterNotifier.new);
final searchQueryProvider =
    NotifierProvider<_SearchNotifier, String>(_SearchNotifier.new);

/// Effective district ID accounting for role-based scoping.
/// All non-state roles are locked to their assigned district.
final effectiveDistrictProvider = Provider<int?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final AppUser? user;
  switch (userAsync) {
    case AsyncData(:final value):
      user = value;
    default:
      user = null;
  }

  // All sub-state roles are locked to their district
  if (user != null && user.districtId != null && !user.isStateOfficial) {
    return user.districtId;
  }
  // Otherwise use manually selected filter
  return ref.watch(selectedDistrictProvider);
});

/// Effective mandal ID accounting for role-based scoping.
/// Block officers, field inspectors, and school HMs are locked to their mandal.
final effectiveMandalProvider = Provider<int?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final AppUser? user;
  switch (userAsync) {
    case AsyncData(:final value):
      user = value;
    default:
      user = null;
  }

  // Block officers, field inspectors, and school HMs are locked to their mandal
  if (user != null && user.mandalId != null &&
      (user.isBlockOfficer || user.isFieldInspector || user.isSchoolHM)) {
    return user.mandalId;
  }
  return ref.watch(selectedMandalProvider);
});

/// Effective school ID for School HM role (they see only their school).
final effectiveSchoolIdProvider = Provider<int?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final AppUser? user;
  switch (userAsync) {
    case AsyncData(:final value):
      user = value;
    default:
      user = null;
  }
  if (user != null && user.isSchoolHM && user.schoolId != null) {
    return user.schoolId;
  }
  return null;
});

// Districts list
final districtsProvider = FutureProvider<List<District>>((ref) async {
  return SupabaseService.getDistricts();
});

// Mandals list (filtered by effective district)
final mandalsProvider = FutureProvider<List<Mandal>>((ref) async {
  final districtId = ref.watch(effectiveDistrictProvider);
  return SupabaseService.getMandals(districtId: districtId);
});

// Schools list (filtered with role-based scoping + offline fallback)
final schoolsProvider = FutureProvider<List<School>>((ref) async {
  final districtId = ref.watch(effectiveDistrictProvider);
  final mandalId = ref.watch(effectiveMandalProvider);
  final category = ref.watch(selectedCategoryProvider);
  final priority = ref.watch(selectedPriorityProvider);

  // Check for School HM role — only see their own school
  final userAsync = ref.watch(currentUserProvider);
  final AppUser? user;
  switch (userAsync) {
    case AsyncData(:final value):
      user = value;
    default:
      user = null;
  }

  try {
    List<School> schools;
    if (user != null && user.isSchoolHM && user.schoolId != null) {
      final school = await SupabaseService.getSchool(user.schoolId!);
      schools = school != null ? [school] : [];
    } else {
      schools = await SupabaseService.getSchools(
        districtId: districtId,
        mandalId: mandalId,
        category: category,
        priorityLevel: priority,
      );
    }

    // Cache schools for offline use
    if (schools.isNotEmpty) {
      OfflineCacheService.cacheSchools(schools);
    }
    return schools;
  } catch (e) {
    // Offline fallback: return cached schools
    debugPrint('Supabase fetch failed, using offline cache: $e');
    if (OfflineCacheService.hasSchoolsCache()) {
      return OfflineCacheService.getCachedSchools();
    }
    rethrow;
  }
});

// All schools with role-based scoping only (no priority/category/search filters).
// Used by priorityScoresProvider so pie chart always shows full distribution.
final allSchoolsProvider = FutureProvider<List<School>>((ref) async {
  final districtId = ref.watch(effectiveDistrictProvider);
  final mandalId = ref.watch(effectiveMandalProvider);

  final userAsync = ref.watch(currentUserProvider);
  final AppUser? user;
  switch (userAsync) {
    case AsyncData(:final value):
      user = value;
    default:
      user = null;
  }

  try {
    if (user != null && user.isSchoolHM && user.schoolId != null) {
      final school = await SupabaseService.getSchool(user.schoolId!);
      return school != null ? [school] : [];
    }
    return await SupabaseService.getSchools(
      districtId: districtId,
      mandalId: mandalId,
    );
  } catch (e) {
    if (OfflineCacheService.hasSchoolsCache()) {
      return OfflineCacheService.getCachedSchools();
    }
    rethrow;
  }
});

// Filtered schools with search + infra type demand filter + management filter
final filteredSchoolsProvider = Provider<AsyncValue<List<School>>>((ref) {
  final schoolsAsync = ref.watch(schoolsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final infraType = ref.watch(selectedInfraTypeProvider);
  final management = ref.watch(selectedManagementProvider);

  return schoolsAsync.whenData((schools) {
    var filtered = schools;

    // Filter by management type
    if (management != null) {
      filtered = filtered.where((s) => s.schoolManagement == management).toList();
    }

    // Filter by infra type: only show schools that have a demand plan of this type
    if (infraType != null) {
      final demandsAsync = ref.watch(demandPlansForFilterProvider);
      final List<DemandPlan> demands;
      switch (demandsAsync) {
        case AsyncData(:final value):
          demands = value;
        default:
          demands = [];
      }
      final schoolIdsWithDemand = demands
          .where((d) => d.infraType == infraType)
          .map((d) => d.schoolId)
          .toSet();
      filtered = filtered.where((s) => schoolIdsWithDemand.contains(s.id)).toList();
    }

    // Search filter
    if (query.isNotEmpty) {
      filtered = filtered.where((s) {
        return s.schoolName.toLowerCase().contains(query) ||
            (s.districtName?.toLowerCase().contains(query) ?? false) ||
            (s.mandalName?.toLowerCase().contains(query) ?? false) ||
            s.udiseCode.toString().contains(query);
      }).toList();
    }

    return filtered;
  });
});

// Demand plans for infra type filter (unaffected by school-level filters)
final demandPlansForFilterProvider = FutureProvider<List<DemandPlan>>((ref) async {
  final districtId = ref.watch(effectiveDistrictProvider);
  final mandalId = ref.watch(effectiveMandalProvider);
  final schoolId = ref.watch(effectiveSchoolIdProvider);
  try {
    return await SupabaseService.getDemandPlans(
      schoolId: schoolId,
      districtId: schoolId != null ? null : districtId,
      mandalId: schoolId != null ? null : mandalId,
    );
  } catch (_) {
    if (OfflineCacheService.hasDemandPlansCache()) {
      return OfflineCacheService.getCachedDemandPlans();
    }
    return [];
  }
});

// Single school detail
final schoolDetailProvider =
    FutureProvider.family<School?, int>((ref, schoolId) async {
  return SupabaseService.getSchool(schoolId);
});

/// Whether the current user can change district filter
final canChangeDistrictFilterProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final AppUser? user;
  switch (userAsync) {
    case AsyncData(:final value):
      user = value;
    default:
      user = null;
  }
  if (user == null) return true;
  // State officials and admins can filter freely
  return user.isStateOfficial || user.isAdmin;
});

/// Whether the current user can change mandal filter
final canChangeMandalFilterProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final AppUser? user;
  switch (userAsync) {
    case AsyncData(:final value):
      user = value;
    default:
      user = null;
  }
  if (user == null) return true;
  // State/district officials and admins can filter mandals
  return user.isStateOfficial || user.isDistrictOfficer || user.isAdmin;
});
