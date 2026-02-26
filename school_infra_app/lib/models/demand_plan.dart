import '../config/api_config.dart';

class DemandPlan {
  final int id;
  final int schoolId;
  final int planYear;
  final String infraType;
  final int physicalCount;
  final double financialAmount;
  final String validationStatus;
  final double? validationScore;
  final List<dynamic>? validationFlags;
  final String? validatedBy;
  final DateTime? validatedAt;
  final String? schoolName;
  final String? districtName;
  final String? mandalName;

  DemandPlan({
    required this.id,
    required this.schoolId,
    required this.planYear,
    required this.infraType,
    required this.physicalCount,
    required this.financialAmount,
    this.validationStatus = 'PENDING',
    this.validationScore,
    this.validationFlags,
    this.validatedBy,
    this.validatedAt,
    this.schoolName,
    this.districtName,
    this.mandalName,
  });

  factory DemandPlan.fromJson(Map<String, dynamic> json) {
    return DemandPlan(
      id: json['id'] as int,
      schoolId: json['school_id'] as int,
      planYear: json['plan_year'] as int? ?? 2025,
      infraType: json['infra_type'] as String,
      physicalCount: json['physical_count'] as int? ?? 0,
      financialAmount: (json['financial_amount'] as num?)?.toDouble() ?? 0,
      validationStatus: json['validation_status'] as String? ?? 'PENDING',
      validationScore: (json['validation_score'] as num?)?.toDouble(),
      validationFlags: json['validation_flags'] as List<dynamic>?,
      validatedBy: json['validated_by']?.toString(),
      validatedAt: json['validated_at'] != null
          ? DateTime.tryParse(json['validated_at'].toString())
          : null,
      schoolName: json['school_name'] as String?,
      districtName: json['district_name'] as String?,
      mandalName: json['mandal_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'school_id': schoolId,
        'plan_year': planYear,
        'infra_type': infraType,
        'physical_count': physicalCount,
        'financial_amount': financialAmount,
        'validation_status': validationStatus,
        'validation_score': validationScore,
        'validation_flags': validationFlags,
      };

  String get infraTypeLabel => AppConstants.infraTypeLabel(infraType);

  double get expectedCost =>
      physicalCount * (AppConstants.unitCosts[infraType] ?? 0);

  double get costDeviation =>
      expectedCost > 0 ? ((financialAmount - expectedCost) / expectedCost) * 100 : 0;

  bool get isCostAnomalous => costDeviation.abs() > 20;

  bool get isPending => validationStatus == AppConstants.validationPending;
  bool get isApproved => validationStatus == AppConstants.validationApproved;
  bool get isFlagged => validationStatus == AppConstants.validationFlagged;
  bool get isRejected => validationStatus == AppConstants.validationRejected;
}

class ValidationResult {
  final String status; // APPROVED, FLAGGED, REJECTED
  final double score; // 0-100 confidence
  final List<String> flags;
  final List<String> reasons;
  final Map<String, dynamic>? details;

  ValidationResult({
    required this.status,
    required this.score,
    this.flags = const [],
    this.reasons = const [],
    this.details,
  });

  factory ValidationResult.fromJson(Map<String, dynamic> json) {
    return ValidationResult(
      status: json['status'] as String,
      score: (json['score'] as num).toDouble(),
      flags: (json['flags'] as List?)?.cast<String>() ?? [],
      reasons: (json['reasons'] as List?)?.cast<String>() ?? [],
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  bool get isApproved => status == 'APPROVED';
  bool get isFlagged => status == 'FLAGGED';
  bool get isRejected => status == 'REJECTED';
}

class DemandSummary {
  final String infraType;
  final int totalSchools;
  final int totalPhysical;
  final double totalFinancial;
  final int approved;
  final int flagged;
  final int rejected;
  final int pending;

  DemandSummary({
    required this.infraType,
    required this.totalSchools,
    required this.totalPhysical,
    required this.totalFinancial,
    this.approved = 0,
    this.flagged = 0,
    this.rejected = 0,
    this.pending = 0,
  });

  String get infraTypeLabel => AppConstants.infraTypeLabel(infraType);
  double get approvalRate =>
      totalSchools > 0 ? approved / totalSchools * 100 : 0;
}
