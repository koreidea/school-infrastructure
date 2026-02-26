import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/school.dart';
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

final selectedDistrictProvider =
    NotifierProvider<_DistrictNotifier, int?>(_DistrictNotifier.new);
final selectedMandalProvider =
    NotifierProvider<_MandalNotifier, int?>(_MandalNotifier.new);
final selectedCategoryProvider =
    NotifierProvider<_CategoryNotifier, String?>(_CategoryNotifier.new);
final selectedPriorityProvider =
    NotifierProvider<_PriorityNotifier, String?>(_PriorityNotifier.new);
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

// Filtered schools with search
final filteredSchoolsProvider = Provider<AsyncValue<List<School>>>((ref) {
  final schoolsAsync = ref.watch(schoolsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return schoolsAsync.whenData((schools) {
    if (query.isEmpty) return schools;
    return schools.where((s) {
      return s.schoolName.toLowerCase().contains(query) ||
          (s.districtName?.toLowerCase().contains(query) ?? false) ||
          (s.mandalName?.toLowerCase().contains(query) ?? false) ||
          s.udiseCode.toString().contains(query);
    }).toList();
  });
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
