import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _languageKey = 'preferred_language';
  static const String _mobileNumberKey = 'mobile_number';
  static const String _activeDatasetIdKey = 'active_dataset_id';
  
  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
  
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  static Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
  
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
  
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }
  
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
  
  static Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }
  
  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }
  
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  
  // Mobile number storage for phone-specific data
  static Future<void> saveMobileNumber(String mobileNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mobileNumberKey, mobileNumber);
  }
  
  static Future<String?> getUserMobileNumber() async {
    final prefs = await SharedPreferences.getInstance();
    // Try to get from user data first, then from direct storage
    final user = await getUser();
    if (user != null) {
      return user.mobileNumber;
    }
    return prefs.getString(_mobileNumberKey);
  }

  // Active dataset selection persistence
  static Future<void> saveActiveDatasetId(int? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_activeDatasetIdKey);
    } else {
      await prefs.setInt(_activeDatasetIdKey, id);
    }
  }

  static Future<int?> getActiveDatasetId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_activeDatasetIdKey);
  }
}
