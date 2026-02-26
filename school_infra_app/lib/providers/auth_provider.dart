import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';

final currentUserProvider =
    NotifierProvider<CurrentUserNotifier, AsyncValue<AppUser?>>(
  CurrentUserNotifier.new,
);

class CurrentUserNotifier extends Notifier<AsyncValue<AppUser?>> {
  @override
  AsyncValue<AppUser?> build() => const AsyncValue.data(null);

  Future<void> loadUser() async {
    state = const AsyncValue.loading();
    try {
      final user = await SupabaseService.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Set demo user with real district/mandal/school IDs from the database.
  Future<void> setDemoUser(String role) async {
    state = const AsyncValue.loading();
    try {
      int? districtId;
      int? mandalId;
      int? schoolId;
      String? districtName;
      String? mandalName;

      if (role != 'STATE_OFFICIAL') {
        // Fetch first district
        final districts = await SupabaseService.getDistricts();
        if (districts.isNotEmpty) {
          final district = districts.first;
          districtId = district.id;
          districtName = district.name;

          if (role == 'BLOCK_OFFICER' || role == 'FIELD_INSPECTOR' || role == 'SCHOOL_HM') {
            // Pick the mandal with the most schools for a meaningful demo
            final mandals = await SupabaseService.getMandals(districtId: districtId);
            if (mandals.isNotEmpty) {
              // Try to find a mandal with multiple schools
              Mandal? bestMandal;
              int bestCount = 0;
              for (final m in mandals) {
                final schools = await SupabaseService.getSchools(
                  districtId: districtId,
                  mandalId: m.id,
                  limit: 20,
                );
                if (schools.length > bestCount) {
                  bestCount = schools.length;
                  bestMandal = m;
                }
                // Stop searching if we found a mandal with 5+ schools
                if (bestCount >= 5) break;
              }
              final mandal = bestMandal ?? mandals.first;
              mandalId = mandal.id;
              mandalName = mandal.name;
            }
          }

          if (role == 'SCHOOL_HM') {
            // Fetch first school in this mandal
            final schools = await SupabaseService.getSchools(
              districtId: districtId,
              mandalId: mandalId,
              limit: 1,
            );
            if (schools.isNotEmpty) {
              schoolId = schools.first.id;
            }
          }
        }
      }

      state = AsyncValue.data(AppUser(
        id: 0,
        name: _demoName(role),
        role: role,
        districtId: districtId,
        mandalId: mandalId,
        schoolId: schoolId,
        districtName: districtName,
        mandalName: mandalName,
      ));
    } catch (e) {
      debugPrint('Demo user setup failed: $e');
      // Fallback: create user without scoping
      state = AsyncValue.data(AppUser(
        id: 0,
        name: _demoName(role),
        role: role,
      ));
    }
  }

  String _demoName(String role) {
    switch (role) {
      case 'STATE_OFFICIAL':
        return 'State Education Director';
      case 'DISTRICT_OFFICER':
        return 'District Education Officer';
      case 'BLOCK_OFFICER':
        return 'Mandal Education Officer';
      case 'SCHOOL_HM':
        return 'Head Master';
      case 'FIELD_INSPECTOR':
        return 'Field Inspector';
      default:
        return 'Admin User';
    }
  }

  void logout() {
    state = const AsyncValue.data(null);
  }
}
