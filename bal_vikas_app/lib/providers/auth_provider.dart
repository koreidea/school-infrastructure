import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart' as app;
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import 'children_provider.dart';

// Auth state using modern Riverpod 3 syntax
final authProvider = AsyncNotifierProvider<AuthNotifier, app.User?>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<app.User?> {
  @override
  Future<app.User?> build() async {
    // Check if we have a Supabase session
    final supabaseSession = SupabaseService.client.auth.currentSession;
    if (supabaseSession != null) {
      try {
        final profile = await SupabaseService.getCurrentUserProfile();
        if (profile != null) {
          final user = app.User.fromSupabase(profile);
          await StorageService.saveUser(user);
          return user;
        }
      } catch (_) {}
    }

    // Fallback: check local storage for cached user
    final savedUser = await StorageService.getUser();
    if (savedUser != null) return savedUser;

    // Legacy: check old API token
    final token = await StorageService.getAuthToken();
    if (token != null) {
      apiService.setAuthToken(token);
      try {
        return await apiService.getProfile();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Pilot mode: verify phone exists in database (no real OTP sent)
  /// When Twilio is configured later, switch back to signInWithOtp
  Future<void> sendOtp(String mobileNumber) async {
    final cleanPhone = mobileNumber.replaceAll('+91', '').replaceAll('+', '');

    // Check if this phone number exists (uses RPC function, works before login)
    final exists = await SupabaseService.client
        .rpc('check_phone_exists', params: {'phone_number': cleanPhone});
    if (exists != true) {
      throw Exception('Phone number not registered. Contact administrator.');
    }

    // In pilot mode, no real OTP is sent — the user enters "123456"
    print('[Auth] Phone $cleanPhone found in database');
  }

  /// Pilot mode: sign in using email/password (phone@balvikas.pilot / pilot123456)
  /// When Twilio is configured later, switch back to verifyOTP
  Future<void> verifyOtp(String mobileNumber, String otp) async {
    state = const AsyncValue.loading();
    try {
      final cleanPhone = mobileNumber.replaceAll('+91', '').replaceAll('+', '').trim();

      // Pilot mode: accept any OTP (auth is via email/password behind the scenes)
      final email = '$cleanPhone@balvikas.pilot';
      print('[Auth] Attempting login for: $email');

      // Try sign in first (existing auth user)
      try {
        final response = await SupabaseService.client.auth.signInWithPassword(
          email: email,
          password: 'pilot123456',
        );
        if (response.session == null) throw Exception('No session');
        print('[Auth] Sign-in successful');
      } catch (signInError) {
        print('[Auth] Sign-in failed ($signInError), creating account...');
        // Auto-create auth user via Supabase signUp API
        final signUpResponse = await SupabaseService.client.auth.signUp(
          email: email,
          password: 'pilot123456',
        );
        if (signUpResponse.session == null) {
          // signUp may not return a session if email confirmation is required
          // Try signing in immediately after signup
          final retryResponse = await SupabaseService.client.auth.signInWithPassword(
            email: email,
            password: 'pilot123456',
          );
          if (retryResponse.session == null) {
            throw Exception(
              'Could not authenticate. Make sure "Confirm email" is OFF '
              'in Supabase Dashboard → Authentication → Providers → Email.',
            );
          }
        }
        print('[Auth] Account created and signed in');
      }

      // Link auth UID to our users table
      await SupabaseService.linkAuthUid(cleanPhone);

      // Clear stale children cache from previous user sessions
      if (!kIsWeb) {
        try {
          await DatabaseService.db.childrenDao.deleteAllChildren();
        } catch (_) {}
      }
      ref.invalidate(childrenProvider);

      print('[Auth] Fetching user profile...');
      final profile = await SupabaseService.getCurrentUserProfile();
      if (profile == null) {
        throw Exception('User profile not found. Contact administrator.');
      }

      final user = app.User.fromSupabase(profile);
      print('[Auth] Logged in as: ${user.name} (${user.roleCode})');

      await StorageService.saveUser(user);
      await StorageService.saveMobileNumber(cleanPhone);

      state = AsyncValue.data(user);

      // Background sync: screening configs + children (skip on web — no Drift)
      if (!kIsWeb) {
        SyncService.pullScreeningConfigs();
        final userProfile = await SupabaseService.getCurrentUserProfile();
        if (userProfile != null) {
          SyncService.pullChildren(userProfile);
        }
      }
    } catch (e, st) {
      print('[Auth] verifyOtp error: $e');
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    // Clear Drift children cache so next user doesn't see stale data
    if (!kIsWeb) {
      try {
        await DatabaseService.db.childrenDao.deleteAllChildren();
      } catch (_) {}
    }
    ref.invalidate(childrenProvider);

    try {
      await SupabaseService.client.auth.signOut();
    } catch (_) {}
    await StorageService.clearAuthToken();
    await StorageService.clearUser();
    apiService.clearAuthToken();
    state = const AsyncValue.data(null);
  }

  Future<void> refreshProfile() async {
    try {
      final profile = await SupabaseService.getCurrentUserProfile();
      if (profile != null) {
        final user = app.User.fromSupabase(profile);
        await StorageService.saveUser(user);
        state = AsyncValue.data(user);
      }
    } catch (e) {
      // Ignore refresh errors
    }
  }

  /// Update user role after selection during registration
  Future<void> updateUserRole(String roleCode) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    try {
      // Try Supabase first
      if (currentUser.supabaseId != null) {
        await SupabaseService.client
            .from('users')
            .update({'role': roleCode})
            .eq('id', currentUser.supabaseId!);

        final updatedUser = currentUser.copyWith(
          roleCode: roleCode,
          roleName: roleCode,
        );
        await StorageService.saveUser(updatedUser);
        state = AsyncValue.data(updatedUser);
      } else {
        // Fallback to old API
        final updatedUser = await apiService.updateUserRole(roleCode);
        await StorageService.saveUser(updatedUser);
        state = AsyncValue.data(updatedUser);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Check if current user needs role selection
  bool get needsRoleSelection {
    final user = state.value;
    return user != null && !user.hasRole;
  }

  /// Update user profile data
  Future<void> updateUser(app.User updatedUser) async {
    await StorageService.saveUser(updatedUser);
    state = AsyncValue.data(updatedUser);
  }
}

// Current user provider
final currentUserProvider = Provider<app.User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.value;
});

// Provider to check if user needs role selection
final needsRoleSelectionProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  final user = authState.value;
  return user != null && !user.hasRole;
});

// Auth token provider - to access current token for services
final authTokenProvider = Provider<String?>((ref) {
  // Check Supabase session first
  final session = SupabaseService.client.auth.currentSession;
  if (session != null) return session.accessToken;
  // Fallback to old api service
  return apiService.authToken;
});

// Supabase user profile provider — raw map from users table
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return await SupabaseService.getCurrentUserProfile();
});

// Language provider
final languageProvider = NotifierProvider<LanguageNotifier, String>(() {
  return LanguageNotifier();
});

class LanguageNotifier extends Notifier<String> {
  @override
  String build() {
    _loadLanguage();
    return 'en';
  }

  Future<void> _loadLanguage() async {
    final lang = await StorageService.getLanguage();
    state = lang;
  }

  Future<void> setLanguage(String language) async {
    await StorageService.saveLanguage(language);
    state = language;
  }

  String getLocalizedText(Map<String, String> textMap) {
    return textMap[state] ?? textMap['en'] ?? '';
  }
}
