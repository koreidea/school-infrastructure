import '../models/demand_plan.dart';
import '../models/enrolment.dart';
import '../config/api_config.dart';

/// Rule-based demand plan validation against Samagra Shiksha norms.
/// Checks: unit cost, enrolment-demand correlation, duplicates, peer comparison.
class DemandValidationService {
  /// Validate a single demand plan
  static ValidationResult validate({
    required DemandPlan plan,
    required List<EnrolmentRecord> enrolment,
    required List<DemandPlan> allSchoolDemands,
    required List<DemandPlan> peerDemands,
    String? schoolCategory,
  }) {
    final flags = <String>[];
    final reasons = <String>[];
    double score = 100; // Start at 100, deduct for issues

    // 1. Unit cost validation
    final expectedCost =
        plan.physicalCount * (AppConstants.unitCosts[plan.infraType] ?? 0);
    if (expectedCost > 0) {
      final deviation =
          ((plan.financialAmount - expectedCost) / expectedCost) * 100;
      if (deviation.abs() > 20) {
        flags.add('COST_ANOMALY');
        reasons.add(
            'Financial amount deviates ${deviation.toStringAsFixed(0)}% from standard unit cost (expected: ₹${expectedCost.toStringAsFixed(2)}L)');
        score -= 25;
      } else if (deviation.abs() > 10) {
        flags.add('COST_WARNING');
        reasons.add(
            'Financial amount deviates ${deviation.toStringAsFixed(0)}% from standard');
        score -= 10;
      }
    }

    // 2. Duplicate detection
    final duplicates = allSchoolDemands.where((d) =>
        d.id != plan.id &&
        d.infraType == plan.infraType &&
        d.planYear == plan.planYear);
    if (duplicates.isNotEmpty) {
      flags.add('DUPLICATE');
      reasons.add(
          'Duplicate demand found for ${plan.infraTypeLabel} in year ${plan.planYear}');
      score -= 30;
    }

    // 3. Enrolment-demand correlation
    if (enrolment.isNotEmpty) {
      final trend = EnrolmentTrend.compute(plan.schoolId, enrolment);
      final latestEnrolment = trend.yearWise.isNotEmpty
          ? trend.yearWise.last.totalStudents
          : 0;

      // Check if demand makes sense for school size
      if (latestEnrolment < 20 && plan.physicalCount > 2) {
        flags.add('OVER_DEMAND');
        reasons.add(
            'School has only $latestEnrolment students but requests ${plan.physicalCount} units');
        score -= 20;
      }

      // Check if declining enrolment but requesting expansion
      if (trend.trend == 'DECLINING' && plan.physicalCount > 1) {
        flags.add('DECLINING_ENROLMENT');
        reasons.add(
            'Enrolment declining (${trend.growthRate.toStringAsFixed(1)}%) but expansion requested');
        score -= 15;
      }
    }

    // 4. Peer comparison (flag outliers)
    if (peerDemands.isNotEmpty) {
      final sameTypePeers =
          peerDemands.where((d) => d.infraType == plan.infraType).toList();
      if (sameTypePeers.length >= 3) {
        final avgPhysical = sameTypePeers.fold<int>(
                0, (s, d) => s + d.physicalCount) /
            sameTypePeers.length;
        if (plan.physicalCount > avgPhysical * 3) {
          flags.add('PEER_OUTLIER');
          reasons.add(
              'Physical count (${plan.physicalCount}) is ${(plan.physicalCount / avgPhysical).toStringAsFixed(1)}x the peer average');
          score -= 15;
        }
      }
    }

    // 5. Zero-value checks
    if (plan.physicalCount <= 0) {
      flags.add('ZERO_PHYSICAL');
      reasons.add('Physical count is zero or negative');
      score -= 40;
    }
    if (plan.financialAmount <= 0 && plan.physicalCount > 0) {
      flags.add('ZERO_FINANCIAL');
      reasons.add('Financial amount is zero for non-zero physical count');
      score -= 20;
    }

    // Determine status
    score = score.clamp(0, 100);
    String status;
    if (score >= 80) {
      status = AppConstants.validationApproved;
    } else if (score >= 50) {
      status = AppConstants.validationFlagged;
    } else {
      status = AppConstants.validationRejected;
    }

    // If no issues at all, give a clean approval
    if (flags.isEmpty) {
      reasons.add('All validation checks passed');
      score = 100;
      status = AppConstants.validationApproved;
    }

    return ValidationResult(
      status: status,
      score: score,
      flags: flags,
      reasons: reasons,
      details: {
        'expected_cost': expectedCost,
        'actual_cost': plan.financialAmount,
        'cost_deviation_pct':
            expectedCost > 0 ? ((plan.financialAmount - expectedCost) / expectedCost * 100) : 0,
        'checks_performed': 5,
        'checks_passed': 5 - flags.length,
      },
    );
  }

  /// Batch validate all demand plans for a set of schools
  static Map<int, ValidationResult> batchValidate({
    required List<DemandPlan> allPlans,
    required Map<int, List<EnrolmentRecord>> enrolmentBySchool,
    required Map<int, String?> schoolCategories,
  }) {
    final results = <int, ValidationResult>{};

    for (final plan in allPlans) {
      final schoolDemands =
          allPlans.where((d) => d.schoolId == plan.schoolId).toList();
      final peerDemands =
          allPlans.where((d) => d.schoolId != plan.schoolId).toList();
      final enrolment = enrolmentBySchool[plan.schoolId] ?? [];
      final category = schoolCategories[plan.schoolId];

      results[plan.id] = validate(
        plan: plan,
        enrolment: enrolment,
        allSchoolDemands: schoolDemands,
        peerDemands: peerDemands,
        schoolCategory: category,
      );
    }

    return results;
  }
}
