import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';

/// Demo user entry for quick-login buttons
class DemoUser {
  final String phone;
  final String email;
  final String name;
  final String role;
  final IconData icon;

  const DemoUser({
    required this.phone,
    required this.email,
    required this.name,
    required this.role,
    required this.icon,
  });
}

/// Pre-configured demo users — one per role
const List<DemoUser> demoUsers = [
  DemoUser(
    phone: '9000000001',
    email: 'state.director@vidyasoudha.gov.in',
    name: 'State Education Director',
    role: AppConstants.roleStateOfficial,
    icon: Icons.account_balance,
  ),
  DemoUser(
    phone: '9000000002',
    email: 'deo@vidyasoudha.gov.in',
    name: 'District Education Officer',
    role: AppConstants.roleDistrictOfficer,
    icon: Icons.location_city,
  ),
  DemoUser(
    phone: '9000000003',
    email: 'meo@vidyasoudha.gov.in',
    name: 'Mandal Education Officer/Inspector',
    role: AppConstants.roleFieldInspector,
    icon: Icons.assignment,
  ),
  DemoUser(
    phone: '9000000005',
    email: 'headmaster@vidyasoudha.gov.in',
    name: 'Head Master',
    role: AppConstants.roleSchoolHM,
    icon: Icons.person,
  ),
];

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

  /// OTP login — match phone/email to a demo user, else return null for role selection.
  /// Demo mode: any OTP is accepted.
  Future<String?> loginWithOtp(String phoneOrEmail, String otp) async {
    final input = phoneOrEmail.trim();
    // Find matching demo user by phone or email
    DemoUser? match;
    for (final u in demoUsers) {
      if (u.phone == input || u.email == input) {
        match = u;
        break;
      }
    }
    if (match != null) {
      await _setDemoUserWithPhone(match.role, input);
      return match.role;
    }
    // Unknown user — caller should show role selection
    return null;
  }

  /// Login as unknown user with a chosen role
  Future<void> loginWithRole(String phoneOrEmail, String role) async {
    await _setDemoUserWithPhone(role, phoneOrEmail.trim());
  }

  /// Internal: sets demo user and attaches phone/email
  Future<void> _setDemoUserWithPhone(String role, String phoneOrEmail) async {
    await setDemoUser(role);
    // Attach the phone/email to the resulting user
    final current = state.value;
    if (current != null) {
      state = AsyncValue.data(AppUser(
        id: current.id,
        name: current.name,
        phone: phoneOrEmail,
        role: current.role,
        districtId: current.districtId,
        mandalId: current.mandalId,
        schoolId: current.schoolId,
        districtName: current.districtName,
        mandalName: current.mandalName,
      ));
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
        return 'Mandal Education Officer/Inspector';
      default:
        return 'Admin User';
    }
  }

  void logout() {
    state = const AsyncValue.data(null);
  }
}
