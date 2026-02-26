import '../models/school.dart';
import '../models/enrolment.dart';
import '../models/demand_plan.dart';
import '../models/infra_assessment.dart';
import '../models/priority_score.dart';
import '../config/api_config.dart';

/// AI-powered priority scoring for school infrastructure needs.
/// Computes a composite score (0-100) based on 4 weighted factors:
/// - Enrolment Pressure (30%): Growth rate, student-classroom ratio
/// - Infrastructure Gap (30%): Missing facilities, demand plan items
/// - CWSN Needs (20%): CWSN-specific gaps
/// - Accessibility (20%): Electrification, drinking water, ramps
class PriorityScoringService {
  // Weights (must sum to 1.0)
  static const double wEnrolment = 0.30;
  static const double wInfraGap = 0.30;
  static const double wCWSN = 0.20;
  static const double wAccessibility = 0.20;

  /// Compute priority score for a single school
  static SchoolPriorityScore computeScore({
    required School school,
    required List<EnrolmentRecord> enrolment,
    required List<DemandPlan> demands,
    InfraAssessment? assessment,
    int scoreYear = 2025,
  }) {
    final enrolmentScore = _computeEnrolmentPressure(school, enrolment, assessment);
    final infraScore = _computeInfraGap(demands, assessment);
    final cwsnScore = _computeCWSNNeed(demands, assessment);
    final accessScore = _computeAccessibility(demands, assessment);

    final composite = (enrolmentScore * wEnrolment +
            infraScore * wInfraGap +
            cwsnScore * wCWSN +
            accessScore * wAccessibility)
        .clamp(0.0, 100.0);

    final level = SchoolPriorityScore.levelFromScore(composite);

    return SchoolPriorityScore(
      schoolId: school.id,
      scoreYear: scoreYear,
      compositeScore: double.parse(composite.toStringAsFixed(1)),
      priorityLevel: level,
      enrolmentPressureScore: double.parse(enrolmentScore.toStringAsFixed(1)),
      infraGapScore: double.parse(infraScore.toStringAsFixed(1)),
      cwsnNeedScore: double.parse(cwsnScore.toStringAsFixed(1)),
      accessibilityScore: double.parse(accessScore.toStringAsFixed(1)),
      scoreBreakdown: {
        'enrolment_weight': wEnrolment,
        'infra_gap_weight': wInfraGap,
        'cwsn_weight': wCWSN,
        'accessibility_weight': wAccessibility,
        'enrolment_details': {
          'growth_rate': _getGrowthRate(enrolment),
          'total_students': _getLatestTotal(enrolment),
        },
        'demand_count': demands.length,
      },
    );
  }

  /// Enrolment Pressure (0-100)
  /// High growth + high student-classroom ratio = high pressure
  static double _computeEnrolmentPressure(
    School school,
    List<EnrolmentRecord> enrolment,
    InfraAssessment? assessment,
  ) {
    double score = 0;

    // Growth rate factor (0-50)
    final growthRate = _getGrowthRate(enrolment);
    if (growthRate > 20) {
      score += 50;
    } else if (growthRate > 10) {
      score += 35;
    } else if (growthRate > 5) {
      score += 20;
    } else if (growthRate > 0) {
      score += 10;
    }

    // Student-classroom ratio factor (0-50)
    if (assessment != null && assessment.existingClassrooms > 0) {
      final latestTotal = _getLatestTotal(enrolment);
      final ratio = latestTotal / assessment.existingClassrooms;
      final norm = school.schoolCategory == 'PS'
          ? AppConstants.normStudentClassroomRatioPrimary
          : AppConstants.normStudentClassroomRatioSecondary;

      if (ratio > norm * 1.5) {
        score += 50;
      } else if (ratio > norm * 1.2) {
        score += 35;
      } else if (ratio > norm) {
        score += 20;
      } else {
        score += 5;
      }
    } else {
      // No assessment data — use enrolment size as proxy
      final total = _getLatestTotal(enrolment);
      if (total > 300) {
        score += 40;
      } else if (total > 150) {
        score += 25;
      } else if (total > 50) {
        score += 15;
      } else {
        score += 5;
      }
    }

    return score.clamp(0, 100);
  }

  /// Infrastructure Gap (0-100)
  /// More demand items + missing facilities = higher gap
  static double _computeInfraGap(
    List<DemandPlan> demands,
    InfraAssessment? assessment,
  ) {
    double score = 0;

    // Demand plan items (0-60): each demand type adds points
    final demandTypes = demands.map((d) => d.infraType).toSet();
    score += (demandTypes.length / 5.0) * 60; // 5 possible types

    // Total physical demand volume (0-40)
    final totalPhysical = demands.fold<int>(0, (s, d) => s + d.physicalCount);
    if (totalPhysical >= 5) {
      score += 40;
    } else if (totalPhysical >= 3) {
      score += 25;
    } else if (totalPhysical >= 1) {
      score += 15;
    }

    // Boost if assessment shows missing facilities
    if (assessment != null) {
      score += assessment.missingFacilitiesCount * 5;
      if (assessment.isCritical) score += 15;
      if (assessment.needsRepair) score += 8;
    }

    return score.clamp(0, 100);
  }

  /// CWSN Need (0-100)
  /// Missing CWSN-specific infrastructure
  static double _computeCWSNNeed(
    List<DemandPlan> demands,
    InfraAssessment? assessment,
  ) {
    double score = 0;

    // Check CWSN-specific demands
    final hasCWSNRoom = demands.any(
        (d) => d.infraType == AppConstants.infraCWSNResourceRoom);
    final hasCWSNToilet = demands.any(
        (d) => d.infraType == AppConstants.infraCWSNToilet);
    final hasRamp = demands.any(
        (d) => d.infraType == AppConstants.infraRamps);

    if (hasCWSNRoom) score += 35;
    if (hasCWSNToilet) score += 35;
    if (hasRamp) score += 30;

    // Cross-check with assessment
    if (assessment != null) {
      if (!assessment.cwsnResourceRoomAvailable && hasCWSNRoom) score += 10;
      if (!assessment.cwsnToiletAvailable && hasCWSNToilet) score += 10;
      if (!assessment.rampAvailable && hasRamp) score += 10;
    }

    return score.clamp(0, 100);
  }

  /// Accessibility (0-100)
  /// Electrification, drinking water, ramp availability
  static double _computeAccessibility(
    List<DemandPlan> demands,
    InfraAssessment? assessment,
  ) {
    double score = 0;

    final hasWaterDemand = demands.any(
        (d) => d.infraType == AppConstants.infraDrinkingWater);
    final hasElectricDemand = demands.any(
        (d) => d.infraType == AppConstants.infraElectrification);
    final hasRampDemand = demands.any(
        (d) => d.infraType == AppConstants.infraRamps);

    if (hasWaterDemand) score += 35;
    if (hasElectricDemand) score += 35;
    if (hasRampDemand) score += 30;

    // Assessment-based scoring
    if (assessment != null) {
      if (!assessment.drinkingWaterAvailable) score += 10;
      if (assessment.electrificationStatus == 'NONE') score += 10;
      if (assessment.electrificationStatus == 'PARTIAL') score += 5;
      if (!assessment.rampAvailable) score += 10;
    }

    return score.clamp(0, 100);
  }

  // ─── Helpers ───

  static double _getGrowthRate(List<EnrolmentRecord> records) {
    final trend = EnrolmentTrend.compute(0, records);
    return trend.growthRate;
  }

  static int _getLatestTotal(List<EnrolmentRecord> records) {
    if (records.isEmpty) return 0;
    final years = records.map((r) => r.academicYear).toSet().toList()..sort();
    final latestYear = years.last;
    return records
        .where((r) => r.academicYear == latestYear)
        .fold<int>(0, (s, r) => s + r.total);
  }
}
