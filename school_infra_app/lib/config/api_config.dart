import 'package:flutter/material.dart';

class SupabaseConfig {
  // Using same Supabase instance as Bal Vikas (separate tables)
  // For production, create a dedicated Supabase project
  static const String url = 'https://yiihjrxfupuohxzubusv.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlpaWhqcnhmdXB1b2h4enVidXN2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE0MDEyMjEsImV4cCI6MjA4Njk3NzIyMX0.y7WHJnt620c71tACqOTfGi7bQxWvlQdsMd8bhYp0d9o';
}

class ApiConfig {
  static const String baseUrl = 'http://localhost:8000';
  static const String apiPrefix = '/api';
  static String get fullBaseUrl => '$baseUrl$apiPrefix';

  // Forecast endpoints
  static const String forecastEnrolment = '/forecast/enrolment';
  static const String forecastBatch = '/forecast/batch';

  // Validation endpoints
  static const String validateDemandPlan = '/validate/demand-plan';
  static const String validateBatch = '/validate/batch';

  // Analytics endpoints
  static const String analyticsDistrict = '/analytics/district';
  static const String analyticsState = '/analytics/state';
  static const String analyticsSchool = '/analytics/school';
}

class AppColors {
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFFBBDEFB);

  // Priority colors
  static const Color priorityCritical = Color(0xFFD32F2F);
  static const Color priorityHigh = Color(0xFFF57C00);
  static const Color priorityMedium = Color(0xFFFFC107);
  static const Color priorityLow = Color(0xFF4CAF50);

  // Infrastructure type colors
  static const Color infraClassroom = Color(0xFF5C6BC0);
  static const Color infraToilet = Color(0xFF26A69A);
  static const Color infraWater = Color(0xFF42A5F5);
  static const Color infraElectric = Color(0xFFFFCA28);
  static const Color infraRamp = Color(0xFF8D6E63);

  // Validation status colors
  static const Color statusApproved = Color(0xFF4CAF50);
  static const Color statusFlagged = Color(0xFFF57C00);
  static const Color statusRejected = Color(0xFFF44336);
  static const Color statusPending = Color(0xFF9E9E9E);

  static const Color accent = Color(0xFF00897B);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  static Color forPriority(String level) {
    switch (level) {
      case 'CRITICAL':
        return priorityCritical;
      case 'HIGH':
        return priorityHigh;
      case 'MEDIUM':
        return priorityMedium;
      case 'LOW':
        return priorityLow;
      default:
        return statusPending;
    }
  }

  static Color forValidation(String status) {
    switch (status) {
      case 'APPROVED':
        return statusApproved;
      case 'FLAGGED':
        return statusFlagged;
      case 'REJECTED':
        return statusRejected;
      default:
        return statusPending;
    }
  }

  static Color forInfraType(String type) {
    switch (type) {
      case 'CWSN_RESOURCE_ROOM':
        return infraClassroom;
      case 'CWSN_TOILET':
        return infraToilet;
      case 'DRINKING_WATER':
        return infraWater;
      case 'ELECTRIFICATION':
        return infraElectric;
      case 'RAMPS':
        return infraRamp;
      default:
        return Colors.grey;
    }
  }
}

class AppConstants {
  static const String appName = 'Vidya Soudha';
  static const String appNameTe = 'విద్యా సౌధ';
  static const String appTagline = 'AI-Powered School Infrastructure Planning';

  // Roles
  static const String roleSchoolHM = 'SCHOOL_HM';
  static const String roleBlockOfficer = 'BLOCK_OFFICER';
  static const String roleDistrictOfficer = 'DISTRICT_OFFICER';
  static const String roleStateOfficial = 'STATE_OFFICIAL';
  static const String roleFieldInspector = 'FIELD_INSPECTOR';
  static const String roleAdmin = 'ADMIN';

  // Infrastructure types
  static const String infraCWSNResourceRoom = 'CWSN_RESOURCE_ROOM';
  static const String infraCWSNToilet = 'CWSN_TOILET';
  static const String infraDrinkingWater = 'DRINKING_WATER';
  static const String infraElectrification = 'ELECTRIFICATION';
  static const String infraRamps = 'RAMPS';

  static const List<String> allInfraTypes = [
    infraCWSNResourceRoom,
    infraCWSNToilet,
    infraDrinkingWater,
    infraElectrification,
    infraRamps,
  ];

  // Priority levels
  static const String priorityCritical = 'CRITICAL';
  static const String priorityHigh = 'HIGH';
  static const String priorityMedium = 'MEDIUM';
  static const String priorityLow = 'LOW';

  // Validation statuses
  static const String validationPending = 'PENDING';
  static const String validationApproved = 'APPROVED';
  static const String validationFlagged = 'FLAGGED';
  static const String validationRejected = 'REJECTED';

  // Samagra Shiksha norms
  static const double normStudentClassroomRatioPrimary = 30.0;
  static const double normStudentClassroomRatioSecondary = 35.0;
  static const double normStudentToiletRatio = 40.0;

  // Standard unit costs (in Lakhs)
  static const Map<String, double> unitCosts = {
    infraCWSNResourceRoom: 29.3,
    infraCWSNToilet: 4.65,
    infraDrinkingWater: 3.4,
    infraElectrification: 1.75,
    infraRamps: 1.25,
  };

  static String infraTypeLabel(String type) {
    switch (type) {
      case infraCWSNResourceRoom:
        return 'CWSN Resource Room';
      case infraCWSNToilet:
        return 'CWSN Toilet';
      case infraDrinkingWater:
        return 'Drinking Water';
      case infraElectrification:
        return 'Electrification';
      case infraRamps:
        return 'Ramps & Handrails';
      default:
        return type;
    }
  }

  static IconData infraTypeIcon(String type) {
    switch (type) {
      case infraCWSNResourceRoom:
        return Icons.meeting_room;
      case infraCWSNToilet:
        return Icons.wc;
      case infraDrinkingWater:
        return Icons.water_drop;
      case infraElectrification:
        return Icons.electric_bolt;
      case infraRamps:
        return Icons.accessible;
      default:
        return Icons.build;
    }
  }

  static String priorityLabel(String level) {
    switch (level) {
      case priorityCritical:
        return 'Critical';
      case priorityHigh:
        return 'High Priority';
      case priorityMedium:
        return 'Medium Priority';
      case priorityLow:
        return 'Low Priority';
      default:
        return level;
    }
  }

  static String validationLabel(String status) {
    switch (status) {
      case validationApproved:
        return 'Approved';
      case validationFlagged:
        return 'Flagged';
      case validationRejected:
        return 'Rejected';
      case validationPending:
        return 'Pending';
      default:
        return status;
    }
  }

  static String categoryLabel(String cat) {
    switch (cat) {
      case 'PS':
        return 'Primary School';
      case 'UPS':
        return 'Upper Primary';
      case 'HS':
        return 'High School';
      case 'HSS':
        return 'Higher Secondary';
      default:
        return cat;
    }
  }

  static String managementLabel(String mgmt) {
    switch (mgmt) {
      case 'MPP_ZP':
        return 'Mandal/Zilla Parishad';
      case 'GOVT':
        return 'Government';
      case 'AIDED':
        return 'Aided';
      case 'PRIVATE':
        return 'Private';
      default:
        return mgmt;
    }
  }
}
