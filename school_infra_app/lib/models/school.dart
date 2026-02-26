import 'package:flutter/material.dart';
import '../config/api_config.dart';

class School {
  final int id;
  final int udiseCode;
  final String schoolName;
  final int? districtId;
  final int? mandalId;
  final double? latitude;
  final double? longitude;
  final String? schoolManagement;
  final String? schoolCategory;
  final String? districtName;
  final String? mandalName;
  final int? totalEnrolment;
  final String? priorityLevel;
  final double? priorityScore;

  School({
    required this.id,
    required this.udiseCode,
    required this.schoolName,
    this.districtId,
    this.mandalId,
    this.latitude,
    this.longitude,
    this.schoolManagement,
    this.schoolCategory,
    this.districtName,
    this.mandalName,
    this.totalEnrolment,
    this.priorityLevel,
    this.priorityScore,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'] as int,
      udiseCode: (json['udise_code'] is int)
          ? json['udise_code'] as int
          : int.tryParse(json['udise_code'].toString()) ?? 0,
      schoolName: json['school_name'] as String? ?? '',
      districtId: json['district_id'] as int?,
      mandalId: json['mandal_id'] as int?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      schoolManagement: json['school_management'] as String?,
      schoolCategory: json['school_category'] as String?,
      districtName: json['district_name'] as String?,
      mandalName: json['mandal_name'] as String?,
      totalEnrolment: json['total_enrolment'] as int?,
      priorityLevel: json['priority_level'] as String?,
      priorityScore: (json['priority_score'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'udise_code': udiseCode,
        'school_name': schoolName,
        'district_id': districtId,
        'mandal_id': mandalId,
        'latitude': latitude,
        'longitude': longitude,
        'school_management': schoolManagement,
        'school_category': schoolCategory,
      };

  bool get hasLocation => latitude != null && longitude != null;

  String get categoryLabel =>
      AppConstants.categoryLabel(schoolCategory ?? '');
  String get managementLabel =>
      AppConstants.managementLabel(schoolManagement ?? '');

  Color get priorityColor =>
      AppColors.forPriority(priorityLevel ?? 'LOW');
}
