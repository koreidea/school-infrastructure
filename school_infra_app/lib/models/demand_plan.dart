import '../config/api_config.dart';

class DemandPlan {
  final int id;
  final int schoolId;
  final int planYear;
  final String infraType;
  final int physicalCount;
  final double financialAmount;
  // Stage 1: AI Validation
  final String validationStatus;
  final double? validationScore;
  final List<dynamic>? validationFlags;
  final String? validatedBy;
  final DateTime? validatedAt;
  // Stage 3: Officer Decision
  final String officerStatus;
  final String? officerName;
  final DateTime? officerReviewedAt;
  final String? officerNotes;
  // Stage 2: Assessment Link
  final int? assessmentId;
  final bool hasAssessment;
  final DateTime? assessmentDate;
  final String? assessmentCondition;
  final String? assessmentBy;
  // Denormalized joins
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
    this.officerStatus = 'PENDING',
    this.officerName,
    this.officerReviewedAt,
    this.officerNotes,
    this.assessmentId,
    this.hasAssessment = false,
    this.assessmentDate,
    this.assessmentCondition,
    this.assessmentBy,
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
      officerStatus: json['officer_status'] as String? ?? 'PENDING',
      officerName: json['officer_name'] as String?,
      officerReviewedAt: json['officer_reviewed_at'] != null
          ? DateTime.tryParse(json['officer_reviewed_at'].toString())
          : null,
      officerNotes: json['officer_notes'] as String?,
      assessmentId: json['assessment_id'] as int?,
      hasAssessment: json['has_assessment'] as bool? ?? false,
      assessmentDate: json['assessment_date'] != null
          ? DateTime.tryParse(json['assessment_date'].toString())
          : null,
      assessmentCondition: json['assessment_condition'] as String?,
      assessmentBy: json['assessment_by'] as String?,
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
        'officer_status': officerStatus,
        'officer_name': officerName,
        'officer_reviewed_at': officerReviewedAt?.toIso8601String(),
        'officer_notes': officerNotes,
        'assessment_id': assessmentId,
        'has_assessment': hasAssessment,
      };

  String get infraTypeLabel => AppConstants.infraTypeLabel(infraType);

  double get expectedCost =>
      physicalCount * (AppConstants.unitCosts[infraType] ?? 0);

  double get costDeviation =>
      expectedCost > 0 ? ((financialAmount - expectedCost) / expectedCost) * 100 : 0;

  bool get isCostAnomalous => costDeviation.abs() > 20;

  // --- Stage 1: AI Validation getters ---
  bool get isAIPending => validationStatus == AppConstants.validationPending;
  bool get isAIApproved => validationStatus == AppConstants.validationApproved;
  bool get isAIFlagged => validationStatus == AppConstants.validationFlagged;
  bool get isAIRejected => validationStatus == AppConstants.validationRejected;
  bool get isAIReviewed => validationStatus != AppConstants.validationPending;

  // --- Stage 3: Officer Decision getters ---
  bool get isOfficerPending => officerStatus == AppConstants.validationPending;
  bool get isOfficerApproved => officerStatus == AppConstants.validationApproved;
  bool get isOfficerFlagged => officerStatus == AppConstants.validationFlagged;
  bool get isOfficerRejected => officerStatus == AppConstants.validationRejected;

  // --- Stage 2: Assessment gate (hard gate) ---
  bool get needsAssessment => !hasAssessment;
  bool get canOfficerApprove => hasAssessment;

  // --- Pipeline stage (for tab filtering & display) ---
  String get pipelineStage {
    if (isAIPending) return 'PENDING';
    if (isOfficerApproved) return 'FINAL_APPROVED';
    if (isOfficerFlagged) return 'FLAGGED';
    if (isOfficerRejected) return 'REJECTED';
    // AI reviewed but officer hasn't decided yet
    if (isAIReviewed && isOfficerPending) return 'AI_REVIEWED';
    return 'PENDING';
  }

  // --- Legacy compatibility (used by overview stats, school profile, etc.) ---
  bool get isPending => isAIPending;
  bool get isApproved => isOfficerApproved;
  bool get isFlagged => isOfficerFlagged;
  bool get isRejected => isOfficerRejected;
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
