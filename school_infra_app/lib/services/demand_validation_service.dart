import '../models/demand_plan.dart';
import '../models/enrolment.dart';
import '../config/api_config.dart';

/// Individual rule check result for explainable AI
class RuleCheckResult {
  final String ruleName;
  final String ruleDescription;
  final bool passed;
  final String detail;
  final double scorePenalty;

  RuleCheckResult({
    required this.ruleName,
    required this.ruleDescription,
    required this.passed,
    required this.detail,
    this.scorePenalty = 0,
  });

  Map<String, dynamic> toJson() => {
    'rule': ruleName,
    'description': ruleDescription,
    'passed': passed,
    'detail': detail,
    'penalty': scorePenalty,
  };
}

/// Rule-based demand plan validation against Samagra Shiksha norms.
/// Checks: unit cost, enrolment-demand correlation, duplicates, peer comparison,
/// zero-value, and infrastructure already existing.
class DemandValidationService {
  /// Validate a single demand plan with detailed per-rule breakdown
  static ValidationResult validate({
    required DemandPlan plan,
    required List<EnrolmentRecord> enrolment,
    required List<DemandPlan> allSchoolDemands,
    required List<DemandPlan> peerDemands,
    String? schoolCategory,
    Map<String, bool>? existingInfra,
  }) {
    final flags = <String>[];
    final reasons = <String>[];
    final ruleChecks = <RuleCheckResult>[];
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
            'Financial amount deviates ${deviation.toStringAsFixed(0)}% from standard unit cost (expected: \u20B9${expectedCost.toStringAsFixed(2)}L)');
        ruleChecks.add(RuleCheckResult(
          ruleName: 'Unit Cost Check',
          ruleDescription: 'Validates financial amount against Samagra Shiksha standard unit costs',
          passed: false,
          detail: 'Deviation of ${deviation.toStringAsFixed(0)}% from standard (expected \u20B9${expectedCost.toStringAsFixed(2)}L, actual \u20B9${plan.financialAmount.toStringAsFixed(2)}L)',
          scorePenalty: 25,
        ));
        score -= 25;
      } else if (deviation.abs() > 10) {
        flags.add('COST_WARNING');
        reasons.add(
            'Financial amount deviates ${deviation.toStringAsFixed(0)}% from standard');
        ruleChecks.add(RuleCheckResult(
          ruleName: 'Unit Cost Check',
          ruleDescription: 'Validates financial amount against Samagra Shiksha standard unit costs',
          passed: false,
          detail: 'Minor deviation of ${deviation.toStringAsFixed(0)}% from standard',
          scorePenalty: 10,
        ));
        score -= 10;
      } else {
        ruleChecks.add(RuleCheckResult(
          ruleName: 'Unit Cost Check',
          ruleDescription: 'Validates financial amount against Samagra Shiksha standard unit costs',
          passed: true,
          detail: 'Cost within acceptable range (${deviation.toStringAsFixed(1)}% deviation)',
        ));
      }
    } else {
      ruleChecks.add(RuleCheckResult(
        ruleName: 'Unit Cost Check',
        ruleDescription: 'Validates financial amount against Samagra Shiksha standard unit costs',
        passed: true,
        detail: 'No standard cost available for comparison',
      ));
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
      ruleChecks.add(RuleCheckResult(
        ruleName: 'Duplicate Check',
        ruleDescription: 'Detects duplicate infrastructure requests for same type and year',
        passed: false,
        detail: '${duplicates.length} duplicate(s) found for ${plan.infraTypeLabel} in ${plan.planYear}',
        scorePenalty: 30,
      ));
      score -= 30;
    } else {
      ruleChecks.add(RuleCheckResult(
        ruleName: 'Duplicate Check',
        ruleDescription: 'Detects duplicate infrastructure requests for same type and year',
        passed: true,
        detail: 'No duplicates found',
      ));
    }

    // 3. Enrolment-demand correlation
    if (enrolment.isNotEmpty) {
      final trend = EnrolmentTrend.compute(plan.schoolId, enrolment);
      final latestEnrolment = trend.yearWise.isNotEmpty
          ? trend.yearWise.last.totalStudents
          : 0;

      if (latestEnrolment < 20 && plan.physicalCount > 2) {
        flags.add('OVER_DEMAND');
        reasons.add(
            'School has only $latestEnrolment students but requests ${plan.physicalCount} units');
        ruleChecks.add(RuleCheckResult(
          ruleName: 'Enrolment Correlation',
          ruleDescription: 'Checks if demand proportional to school enrolment size',
          passed: false,
          detail: 'Only $latestEnrolment students but requesting ${plan.physicalCount} units (over-demand)',
          scorePenalty: 20,
        ));
        score -= 20;
      } else if (trend.trend == 'DECLINING' && plan.physicalCount > 1) {
        flags.add('DECLINING_ENROLMENT');
        reasons.add(
            'Enrolment declining (${trend.growthRate.toStringAsFixed(1)}%) but expansion requested');
        ruleChecks.add(RuleCheckResult(
          ruleName: 'Enrolment Correlation',
          ruleDescription: 'Checks if demand proportional to school enrolment size',
          passed: false,
          detail: 'Enrolment declining at ${trend.growthRate.toStringAsFixed(1)}% but expansion requested',
          scorePenalty: 15,
        ));
        score -= 15;
      } else {
        ruleChecks.add(RuleCheckResult(
          ruleName: 'Enrolment Correlation',
          ruleDescription: 'Checks if demand proportional to school enrolment size',
          passed: true,
          detail: 'Demand consistent with enrolment of $latestEnrolment students (${trend.trend})',
        ));
      }
    } else {
      ruleChecks.add(RuleCheckResult(
        ruleName: 'Enrolment Correlation',
        ruleDescription: 'Checks if demand proportional to school enrolment size',
        passed: true,
        detail: 'No enrolment data available for correlation',
      ));
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
          ruleChecks.add(RuleCheckResult(
            ruleName: 'Peer Comparison',
            ruleDescription: 'Compares demand against similar schools in the region',
            passed: false,
            detail: 'Count ${plan.physicalCount} is ${(plan.physicalCount / avgPhysical).toStringAsFixed(1)}x peer avg (${avgPhysical.toStringAsFixed(1)})',
            scorePenalty: 15,
          ));
          score -= 15;
        } else {
          ruleChecks.add(RuleCheckResult(
            ruleName: 'Peer Comparison',
            ruleDescription: 'Compares demand against similar schools in the region',
            passed: true,
            detail: 'Within peer range (avg: ${avgPhysical.toStringAsFixed(1)} units)',
          ));
        }
      } else {
        ruleChecks.add(RuleCheckResult(
          ruleName: 'Peer Comparison',
          ruleDescription: 'Compares demand against similar schools in the region',
          passed: true,
          detail: 'Insufficient peers for comparison (<3 schools)',
        ));
      }
    } else {
      ruleChecks.add(RuleCheckResult(
        ruleName: 'Peer Comparison',
        ruleDescription: 'Compares demand against similar schools in the region',
        passed: true,
        detail: 'No peer data available',
      ));
    }

    // 5. Zero-value checks
    if (plan.physicalCount <= 0) {
      flags.add('ZERO_PHYSICAL');
      reasons.add('Physical count is zero or negative');
      ruleChecks.add(RuleCheckResult(
        ruleName: 'Zero-Value Check',
        ruleDescription: 'Ensures demand has valid physical and financial values',
        passed: false,
        detail: 'Physical count is ${plan.physicalCount} (must be > 0)',
        scorePenalty: 40,
      ));
      score -= 40;
    } else if (plan.financialAmount <= 0 && plan.physicalCount > 0) {
      flags.add('ZERO_FINANCIAL');
      reasons.add('Financial amount is zero for non-zero physical count');
      ruleChecks.add(RuleCheckResult(
        ruleName: 'Zero-Value Check',
        ruleDescription: 'Ensures demand has valid physical and financial values',
        passed: false,
        detail: 'Financial amount is \u20B90 but ${plan.physicalCount} units requested',
        scorePenalty: 20,
      ));
      score -= 20;
    } else {
      ruleChecks.add(RuleCheckResult(
        ruleName: 'Zero-Value Check',
        ruleDescription: 'Ensures demand has valid physical and financial values',
        passed: true,
        detail: '${plan.physicalCount} units, \u20B9${plan.financialAmount.toStringAsFixed(2)}L',
      ));
    }

    // 6. Infrastructure Already Existing check (NEW - PS5 requirement)
    if (existingInfra != null) {
      final key = _infraToExistingKey(plan.infraType);
      if (key != null && existingInfra[key] == true) {
        flags.add('ALREADY_EXISTS');
        reasons.add(
            '${plan.infraTypeLabel} already exists at this school per last inspection');
        ruleChecks.add(RuleCheckResult(
          ruleName: 'Existing Infrastructure',
          ruleDescription: 'Checks if requested infrastructure already exists at the school',
          passed: false,
          detail: '${plan.infraTypeLabel} already available per field inspection data',
          scorePenalty: 20,
        ));
        score -= 20;
      } else {
        ruleChecks.add(RuleCheckResult(
          ruleName: 'Existing Infrastructure',
          ruleDescription: 'Checks if requested infrastructure already exists at the school',
          passed: true,
          detail: 'Infrastructure not yet available at school',
        ));
      }
    } else {
      ruleChecks.add(RuleCheckResult(
        ruleName: 'Existing Infrastructure',
        ruleDescription: 'Checks if requested infrastructure already exists at the school',
        passed: true,
        detail: 'No inspection data available',
      ));
    }

    // 7. Over-reporting / Non-compliance pattern detection
    // Check if this school has excessive demands across ALL infra types
    final schoolAllDemands = allSchoolDemands.where((d) => d.id != plan.id).toList();
    if (schoolAllDemands.length >= 4) {
      // School requesting nearly all infra types — pattern of over-reporting
      final distinctTypes = schoolAllDemands.map((d) => d.infraType).toSet();
      if (distinctTypes.length >= 4) {
        final totalFinancial = schoolAllDemands.fold<double>(0, (s, d) => s + d.financialAmount) + plan.financialAmount;
        // If total demand > 50 Lakhs for a single school, flag as over-reporting
        if (totalFinancial > 50) {
          flags.add('OVER_REPORTING');
          reasons.add(
              'School requests ${distinctTypes.length + 1} infra types totalling ₹${totalFinancial.toStringAsFixed(1)}L — possible over-reporting');
          ruleChecks.add(RuleCheckResult(
            ruleName: 'Over-Reporting Check',
            ruleDescription: 'Detects schools requesting excessive infrastructure across multiple types',
            passed: false,
            detail: '${distinctTypes.length + 1} infra types, ₹${totalFinancial.toStringAsFixed(1)}L total — exceeds per-school threshold',
            scorePenalty: 15,
          ));
          score -= 15;
        } else {
          ruleChecks.add(RuleCheckResult(
            ruleName: 'Over-Reporting Check',
            ruleDescription: 'Detects schools requesting excessive infrastructure across multiple types',
            passed: true,
            detail: '${distinctTypes.length + 1} infra types, ₹${totalFinancial.toStringAsFixed(1)}L total — within limits',
          ));
        }
      } else {
        ruleChecks.add(RuleCheckResult(
          ruleName: 'Over-Reporting Check',
          ruleDescription: 'Detects schools requesting excessive infrastructure across multiple types',
          passed: true,
          detail: '${distinctTypes.length + 1} infra types requested — normal range',
        ));
      }
    } else {
      ruleChecks.add(RuleCheckResult(
        ruleName: 'Over-Reporting Check',
        ruleDescription: 'Detects schools requesting excessive infrastructure across multiple types',
        passed: true,
        detail: 'Only ${schoolAllDemands.length + 1} demand(s) — no over-reporting pattern',
      ));
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

    final checksPerformed = ruleChecks.length;
    final checksPassed = ruleChecks.where((r) => r.passed).length;

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
        'checks_performed': checksPerformed,
        'checks_passed': checksPassed,
        'rule_checks': ruleChecks.map((r) => r.toJson()).toList(),
      },
    );
  }

  /// Map infra type to existing infrastructure field name
  static String? _infraToExistingKey(String infraType) {
    switch (infraType) {
      case 'CWSN_RESOURCE_ROOM':
        return 'has_cwsn_room';
      case 'CWSN_TOILET':
        return 'has_cwsn_toilet';
      case 'DRINKING_WATER':
        return 'has_drinking_water';
      case 'ELECTRIFICATION':
        return 'has_electrification';
      case 'RAMPS':
        return 'has_ramp';
      default:
        return null;
    }
  }

  /// Batch validate all demand plans for a set of schools
  static Map<int, ValidationResult> batchValidate({
    required List<DemandPlan> allPlans,
    required Map<int, List<EnrolmentRecord>> enrolmentBySchool,
    required Map<int, String?> schoolCategories,
    Map<int, Map<String, bool>>? existingInfraBySchool,
  }) {
    final results = <int, ValidationResult>{};

    for (final plan in allPlans) {
      final schoolDemands =
          allPlans.where((d) => d.schoolId == plan.schoolId).toList();
      final peerDemands =
          allPlans.where((d) => d.schoolId != plan.schoolId).toList();
      final enrolment = enrolmentBySchool[plan.schoolId] ?? [];
      final category = schoolCategories[plan.schoolId];
      final existingInfra = existingInfraBySchool?[plan.schoolId];

      results[plan.id] = validate(
        plan: plan,
        enrolment: enrolment,
        allSchoolDemands: schoolDemands,
        peerDemands: peerDemands,
        schoolCategory: category,
        existingInfra: existingInfra,
      );
    }

    return results;
  }
}
