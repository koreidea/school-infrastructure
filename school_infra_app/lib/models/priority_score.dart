import '../config/api_config.dart';

class SchoolPriorityScore {
  final int? id;
  final int schoolId;
  final int scoreYear;
  final double compositeScore;
  final String priorityLevel;
  final double enrolmentPressureScore;
  final double infraGapScore;
  final double cwsnNeedScore;
  final double accessibilityScore;
  final Map<String, dynamic>? scoreBreakdown;
  final DateTime? computedAt;

  SchoolPriorityScore({
    this.id,
    required this.schoolId,
    required this.scoreYear,
    required this.compositeScore,
    required this.priorityLevel,
    required this.enrolmentPressureScore,
    required this.infraGapScore,
    required this.cwsnNeedScore,
    required this.accessibilityScore,
    this.scoreBreakdown,
    this.computedAt,
  });

  factory SchoolPriorityScore.fromJson(Map<String, dynamic> json) {
    return SchoolPriorityScore(
      id: json['id'] as int?,
      schoolId: json['school_id'] as int,
      scoreYear: json['score_year'] as int? ?? 2025,
      compositeScore: (json['composite_score'] as num?)?.toDouble() ?? 0,
      priorityLevel: json['priority_level'] as String? ?? 'LOW',
      enrolmentPressureScore:
          (json['enrolment_pressure_score'] as num?)?.toDouble() ?? 0,
      infraGapScore: (json['infra_gap_score'] as num?)?.toDouble() ?? 0,
      cwsnNeedScore: (json['cwsn_need_score'] as num?)?.toDouble() ?? 0,
      accessibilityScore:
          (json['accessibility_score'] as num?)?.toDouble() ?? 0,
      scoreBreakdown: json['score_breakdown'] as Map<String, dynamic>?,
      computedAt: json['computed_at'] != null
          ? DateTime.tryParse(json['computed_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'school_id': schoolId,
        'score_year': scoreYear,
        'composite_score': compositeScore,
        'priority_level': priorityLevel,
        'enrolment_pressure_score': enrolmentPressureScore,
        'infra_gap_score': infraGapScore,
        'cwsn_need_score': cwsnNeedScore,
        'accessibility_score': accessibilityScore,
        'score_breakdown': scoreBreakdown,
        'computed_at': DateTime.now().toIso8601String(),
      };

  String get priorityLabel => AppConstants.priorityLabel(priorityLevel);

  /// Compute priority level from composite score
  static String levelFromScore(double score) {
    if (score > 80) return AppConstants.priorityCritical;
    if (score > 60) return AppConstants.priorityHigh;
    if (score > 40) return AppConstants.priorityMedium;
    return AppConstants.priorityLow;
  }
}

/// Stats for dashboard display
class PriorityDistribution {
  final int critical;
  final int high;
  final int medium;
  final int low;
  final int total;

  PriorityDistribution({
    this.critical = 0,
    this.high = 0,
    this.medium = 0,
    this.low = 0,
  }) : total = critical + high + medium + low;

  factory PriorityDistribution.fromScores(List<SchoolPriorityScore> scores) {
    int c = 0, h = 0, m = 0, l = 0;
    for (final s in scores) {
      switch (s.priorityLevel) {
        case 'CRITICAL':
          c++;
          break;
        case 'HIGH':
          h++;
          break;
        case 'MEDIUM':
          m++;
          break;
        default:
          l++;
      }
    }
    return PriorityDistribution(critical: c, high: h, medium: m, low: l);
  }

  double get criticalPercent => total > 0 ? critical / total * 100 : 0;
  double get highPercent => total > 0 ? high / total * 100 : 0;
  double get mediumPercent => total > 0 ? medium / total * 100 : 0;
  double get lowPercent => total > 0 ? low / total * 100 : 0;
}
