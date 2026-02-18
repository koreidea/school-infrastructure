import '../config/api_config.dart';

class User {
  final int userId;
  final String mobileNumber;
  final String name;
  final int roleId;
  final String roleName;
  final String? roleCode;
  final int? anganwadiCenterId;
  final String preferredLanguage;
  final bool isActive;
  final DateTime createdAt;
  final String? email;
  final String? profilePhotoUrl;
  final String? supabaseId; // UUID from Supabase users table
  final int? sectorId;
  final int? projectId;
  final int? districtId;
  final int? stateId;

  User({
    required this.userId,
    required this.mobileNumber,
    required this.name,
    required this.roleId,
    required this.roleName,
    this.roleCode,
    this.anganwadiCenterId,
    this.preferredLanguage = 'en',
    required this.isActive,
    required this.createdAt,
    this.email,
    this.profilePhotoUrl,
    this.supabaseId,
    this.sectorId,
    this.projectId,
    this.districtId,
    this.stateId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      mobileNumber: json['mobile_number'],
      name: json['name'],
      roleId: json['role_id'] ?? 0,
      roleName: json['role_name'] ?? '',
      roleCode: json['role_code'],
      anganwadiCenterId: json['anganwadi_center_id'],
      preferredLanguage: json['preferred_language'] ?? 'en',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      email: json['email'],
      profilePhotoUrl: json['profile_photo_url'],
      supabaseId: json['supabase_id'],
      sectorId: json['sector_id'],
      projectId: json['project_id'],
      districtId: json['district_id'],
      stateId: json['state_id'],
    );
  }

  /// Create a User from a Supabase users table row
  factory User.fromSupabase(Map<String, dynamic> row) {
    return User(
      userId: 0, // Not used with Supabase
      mobileNumber: row['phone'] ?? '',
      name: row['name'] ?? '',
      roleId: 0,
      roleName: row['role'] ?? '',
      roleCode: row['role'],
      anganwadiCenterId: row['awc_id'],
      preferredLanguage: row['preferred_language'] ?? 'en',
      isActive: row['is_active'] ?? true,
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'])
          : DateTime.now(),
      email: row['email'],
      profilePhotoUrl: null,
      supabaseId: row['id'],
      sectorId: row['sector_id'],
      projectId: row['project_id'],
      districtId: row['district_id'],
      stateId: row['state_id'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'mobile_number': mobileNumber,
      'name': name,
      'role_id': roleId,
      'role_name': roleName,
      'role_code': roleCode,
      'anganwadi_center_id': anganwadiCenterId,
      'preferred_language': preferredLanguage,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'email': email,
      'profile_photo_url': profilePhotoUrl,
      'supabase_id': supabaseId,
      'sector_id': sectorId,
      'project_id': projectId,
      'district_id': districtId,
      'state_id': stateId,
    };
  }

  User copyWith({
    int? userId,
    String? mobileNumber,
    String? name,
    int? roleId,
    String? roleName,
    String? roleCode,
    int? anganwadiCenterId,
    String? preferredLanguage,
    bool? isActive,
    DateTime? createdAt,
    String? email,
    String? profilePhotoUrl,
    String? supabaseId,
    int? sectorId,
    int? projectId,
    int? districtId,
    int? stateId,
  }) {
    return User(
      userId: userId ?? this.userId,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      name: name ?? this.name,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      roleCode: roleCode ?? this.roleCode,
      anganwadiCenterId: anganwadiCenterId ?? this.anganwadiCenterId,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      email: email ?? this.email,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      supabaseId: supabaseId ?? this.supabaseId,
      sectorId: sectorId ?? this.sectorId,
      projectId: projectId ?? this.projectId,
      districtId: districtId ?? this.districtId,
      stateId: stateId ?? this.stateId,
    );
  }

  bool get isParent =>
      roleCode == AppConstants.roleParent ||
      roleName == 'Parent/Caregiver' ||
      roleName == 'PARENT';

  bool get isAWW =>
      roleCode == AppConstants.roleAWW ||
      roleName == 'Anganwadi Worker' ||
      roleName == 'AWW';

  bool get isSupervisor =>
      roleCode == AppConstants.roleSupervisor ||
      roleName == 'Supervisor' ||
      roleName == 'SUPERVISOR';

  bool get isCDPO => roleCode == AppConstants.roleCDPO || roleName == 'CDPO';
  bool get isDW => roleCode == AppConstants.roleDW || roleName == 'DW';
  bool get isCW => roleCode == AppConstants.roleCW || roleName == 'CW';
  bool get isEO => roleCode == AppConstants.roleEO || roleName == 'EO';
  bool get isSeniorOfficial =>
      roleCode == AppConstants.roleSeniorOfficial ||
      roleName == 'SENIOR_OFFICIAL';

  bool get isAdmin =>
      roleCode == AppConstants.roleAdmin ||
      roleName == 'Admin' ||
      roleName == 'ADMIN';

  /// Whether this user has a staff/administrative role (not a parent)
  bool get isStaff => !isParent && hasRole;

  /// Whether this user can view aggregate/dashboard data
  bool get canViewDashboard => isSupervisor || isCDPO || isDW || isCW || isEO || isSeniorOfficial;

  bool get hasRole => roleCode != null && roleCode!.isNotEmpty;
}

class Child {
  final int childId;
  final String childUniqueId;
  final String name;
  final DateTime dateOfBirth;
  final String gender;
  final int? parentUserId;
  final int? awwUserId;
  final int? anganwadiCenterId;
  final String? photoUrl;
  final DateTime createdAt;
  final int? ageMonths;
  
  Child({
    required this.childId,
    required this.childUniqueId,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    this.parentUserId,
    this.awwUserId,
    this.anganwadiCenterId,
    this.photoUrl,
    required this.createdAt,
    this.ageMonths,
  });
  
  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      childId: json['child_id'],
      childUniqueId: json['child_unique_id'],
      name: json['name'],
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      gender: json['gender'],
      parentUserId: json['parent_user_id'],
      awwUserId: json['aww_user_id'],
      anganwadiCenterId: json['anganwadi_center_id'],
      photoUrl: json['photo_url'],
      createdAt: DateTime.parse(json['created_at']),
      ageMonths: json['age_months'],
    );
  }

  /// Create a Child from the Map format used by children_provider.
  /// Handles both naming conventions (parent_id vs parent_user_id, etc.)
  /// Safely parse a value to int? (handles String, int, and null)
  static int? _toIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  factory Child.fromMap(Map<String, dynamic> map) {
    return Child(
      childId: _toIntOrNull(map['child_id']) ?? 0,
      childUniqueId: map['child_unique_id'] ?? '',
      name: map['name'] ?? '',
      dateOfBirth: map['date_of_birth'] is DateTime
          ? map['date_of_birth']
          : DateTime.parse(map['date_of_birth'] ?? '2000-01-01'),
      gender: map['gender'] ?? 'male',
      parentUserId: _toIntOrNull(map['parent_user_id'] ?? map['parent_id']),
      awwUserId: _toIntOrNull(map['aww_user_id'] ?? map['aww_id']),
      anganwadiCenterId: _toIntOrNull(map['anganwadi_center_id'] ?? map['awc_id']),
      photoUrl: map['photo_url'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      ageMonths: _toIntOrNull(map['age_months']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'child_id': childId,
      'child_unique_id': childUniqueId,
      'name': name,
      'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
      'gender': gender,
      'parent_user_id': parentUserId,
      'aww_user_id': awwUserId,
      'anganwadi_center_id': anganwadiCenterId,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
      'age_months': ageMonths,
    };
  }
  
  int get currentAgeMonths {
    if (ageMonths != null) return ageMonths!;
    return DateTime.now().difference(dateOfBirth).inDays ~/ 30;
  }
  
  String get genderDisplay => gender == 'male' ? 'Male' : 'Female';
}

class ScreeningSession {
  final int sessionId;
  final int childId;
  final int? conductedByUserId;
  final DateTime assessmentDate;
  final int childAgeMonths;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;
  
  ScreeningSession({
    required this.sessionId,
    required this.childId,
    this.conductedByUserId,
    required this.assessmentDate,
    required this.childAgeMonths,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });
  
  factory ScreeningSession.fromJson(Map<String, dynamic> json) {
    return ScreeningSession(
      sessionId: json['session_id'],
      childId: json['child_id'],
      conductedByUserId: json['conducted_by_user_id'],
      assessmentDate: DateTime.parse(json['assessment_date']),
      childAgeMonths: json['child_age_months'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
    );
  }
  
  bool get isCompleted => status == 'completed';
  bool get isInProgress => status == 'in_progress';
}

class AssessmentResult {
  final double? gmDq;
  final double? fmDq;
  final double? lcDq;
  final double? cogDq;
  final double? seDq;
  final double? compositeDq;
  final bool gmDelay;
  final bool fmDelay;
  final bool lcDelay;
  final bool cogDelay;
  final bool seDelay;
  final int numDelays;
  final String? overallRisk;
  final bool referralNeeded;
  final String? interventionPriority;
  final String? nutritionRisk;
  
  AssessmentResult({
    this.gmDq,
    this.fmDq,
    this.lcDq,
    this.cogDq,
    this.seDq,
    this.compositeDq,
    this.gmDelay = false,
    this.fmDelay = false,
    this.lcDelay = false,
    this.cogDelay = false,
    this.seDelay = false,
    this.numDelays = 0,
    this.overallRisk,
    this.referralNeeded = false,
    this.interventionPriority,
    this.nutritionRisk,
  });
  
  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    final assessment = json['assessment'] ?? {};
    final dev = assessment['developmental'] ?? {};
    final risk = assessment['risk'] ?? {};
    final nutrition = assessment['nutrition'] ?? {};
    final baseline = assessment['baseline_risk'] ?? {};
    
    return AssessmentResult(
      gmDq: dev['gm_dq']?.toDouble(),
      fmDq: dev['fm_dq']?.toDouble(),
      lcDq: dev['lc_dq']?.toDouble(),
      cogDq: dev['cog_dq']?.toDouble(),
      seDq: dev['se_dq']?.toDouble(),
      compositeDq: dev['composite_dq']?.toDouble(),
      gmDelay: risk['gm_delay'] ?? false,
      fmDelay: risk['fm_delay'] ?? false,
      lcDelay: risk['lc_delay'] ?? false,
      cogDelay: risk['cog_delay'] ?? false,
      seDelay: risk['se_delay'] ?? false,
      numDelays: risk['num_delays'] ?? 0,
      overallRisk: baseline['overall_risk_category'],
      referralNeeded: baseline['referral_needed'] ?? false,
      interventionPriority: baseline['intervention_priority'],
      nutritionRisk: nutrition['nutrition_risk'],
    );
  }
  
  String getRiskColor() {
    switch (overallRisk) {
      case 'HIGH':
        return '#F44336';
      case 'MEDIUM-HIGH':
        return '#FF9800';
      case 'MEDIUM':
        return '#FFC107';
      default:
        return '#4CAF50';
    }
  }
}
