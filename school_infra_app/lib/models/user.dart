import '../config/api_config.dart';

class AppUser {
  final int id;
  final String? authUid;
  final String name;
  final String? phone;
  final String role;
  final int? districtId;
  final int? mandalId;
  final int? schoolId;
  final String? districtName;
  final String? mandalName;

  AppUser({
    required this.id,
    this.authUid,
    required this.name,
    this.phone,
    required this.role,
    this.districtId,
    this.mandalId,
    this.schoolId,
    this.districtName,
    this.mandalName,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      authUid: json['auth_uid'] as String?,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'STATE_OFFICIAL',
      districtId: json['district_id'] as int?,
      mandalId: json['mandal_id'] as int?,
      schoolId: json['school_id'] as int?,
      districtName: json['district_name'] as String?,
      mandalName: json['mandal_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'auth_uid': authUid,
        'name': name,
        'phone': phone,
        'role': role,
        'district_id': districtId,
        'mandal_id': mandalId,
        'school_id': schoolId,
      };

  bool get isSchoolHM => role == AppConstants.roleSchoolHM;
  bool get isBlockOfficer => role == AppConstants.roleBlockOfficer;
  bool get isDistrictOfficer => role == AppConstants.roleDistrictOfficer;
  bool get isStateOfficial => role == AppConstants.roleStateOfficial;
  bool get isFieldInspector => role == AppConstants.roleFieldInspector;
  bool get isAdmin => role == AppConstants.roleAdmin;

  bool get canValidate =>
      isBlockOfficer || isDistrictOfficer || isStateOfficial || isAdmin;
  bool get canViewAllSchools =>
      isDistrictOfficer || isStateOfficial || isAdmin;
  bool get canViewMap => true;
  bool get canExport => canValidate;
  bool get canInspect => isFieldInspector || isBlockOfficer || isAdmin;
}

class District {
  final int id;
  final String name;
  final String? code;
  final int? stateId;
  final int schoolCount;

  District({
    required this.id,
    required this.name,
    this.code,
    this.stateId,
    this.schoolCount = 0,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] as int,
      name: json['district_name'] as String? ?? '',
      code: json['district_code'] as String?,
      stateId: json['state_id'] as int?,
      schoolCount: json['school_count'] as int? ?? 0,
    );
  }
}

class Mandal {
  final int id;
  final String name;
  final String? code;
  final int districtId;
  final String? districtName;
  final int schoolCount;

  Mandal({
    required this.id,
    required this.name,
    this.code,
    required this.districtId,
    this.districtName,
    this.schoolCount = 0,
  });

  factory Mandal.fromJson(Map<String, dynamic> json) {
    return Mandal(
      id: json['id'] as int,
      name: json['mandal_name'] as String? ?? '',
      code: json['mandal_code'] as String?,
      districtId: json['district_id'] as int,
      districtName: json['district_name'] as String?,
      schoolCount: json['school_count'] as int? ?? 0,
    );
  }
}
