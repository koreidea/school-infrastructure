import 'package:flutter/material.dart';

class SupabaseConfig {
  static const String url = 'https://owfioycwviwjteviwkka.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im93ZmlveWN3dml3anRldml3a2thIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA2MzE0ODEsImV4cCI6MjA4NjIwNzQ4MX0.AyO5t28pL0N5tkukmnOdWLqINgy9_0jKXvpLCX3QYr8';
}

class ApiConfig {
  // Change this to your server URL
  static const String baseUrl = 'http://192.168.0.207:8000';
  static const String apiPrefix = '/api';

  static String get fullBaseUrl => '$baseUrl$apiPrefix';
  
  // Auth endpoints
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String profile = '/auth/profile';
  static const String updateRole = '/auth/update-role';
  static const String updateProfile = '/auth/profile';
  
  // Children endpoints
  static const String children = '/children';
  
  // Screening endpoints
  static const String screeningStart = '/screening/start';
  static const String screeningComplete = '/screening/{sessionId}/complete';
  static const String screeningResponses = '/screening/{sessionId}/responses';
  static const String screeningVideo = '/screening/{sessionId}/video';
  static const String screeningDetails = '/screening/{sessionId}';
  static const String childScreenings = '/screening/child/{childId}';
  
  // Questionnaire endpoints
  static const String latestQuestionnaire = '/questionnaires/latest';
  
  // Intervention endpoints
  static const String interventions = '/interventions/activities';
  static const String recommendInterventions = '/interventions/recommend/{childId}';
  
  // Export endpoints
  static const String exportChild = '/export/child/{childId}/excel';
}

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);
  
  // Risk Colors
  static const Color riskLow = Color(0xFF4CAF50);
  static const Color riskMedium = Color(0xFFFFC107);
  static const Color riskHigh = Color(0xFFF44336);
  
  // Accent
  static const Color accent = Color(0xFFFF9800);
  
  // Neutrals
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}

class AppConstants {
  static const String appName = 'Bal Vikas';
  static const String appNameTe = 'బాల్ వికాస్';
  
  // Role codes
  static const String roleParent = 'PARENT';
  static const String roleAWW = 'AWW';
  static const String roleSupervisor = 'SUPERVISOR';
  static const String roleCDPO = 'CDPO';
  static const String roleDW = 'DW';
  static const String roleCW = 'CW';
  static const String roleEO = 'EO';
  static const String roleSeniorOfficial = 'SENIOR_OFFICIAL';
  static const String roleAdmin = 'ADMIN';
  
  // Domain names
  static const Map<String, Map<String, String>> domains = {
    'gm': {
      'en': 'Gross Motor',
      'te': 'స్థూల చలనం',
    },
    'fm': {
      'en': 'Fine Motor',
      'te': 'సూక్ష్మ చలనం',
    },
    'lc': {
      'en': 'Language',
      'te': 'భాష',
    },
    'cog': {
      'en': 'Cognitive',
      'te': 'జ్ఞానాత్మకం',
    },
    'se': {
      'en': 'Social-Emotional',
      'te': 'సామాజిక-భావోద్వేగ',
    },
  };
  
  // Risk levels
  static const Map<String, Map<String, String>> riskLevels = {
    'LOW': {
      'en': 'Low Risk',
      'te': 'తక్కువ ప్రమాదం',
    },
    'MEDIUM': {
      'en': 'Medium Risk',
      'te': 'మధ్యస్థ ప్రమాదం',
    },
    'MEDIUM-HIGH': {
      'en': 'Medium-High Risk',
      'te': 'మధ్యస్థ-అధిక ప్రమాదం',
    },
    'HIGH': {
      'en': 'High Risk',
      'te': 'అధిక ప్రమాదం',
    },
  };
}
