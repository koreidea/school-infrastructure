import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../services/api_service.dart';
import '../services/priority_scoring_service.dart';
import '../services/demand_validation_service.dart';
import '../services/offline_cache_service.dart';
import '../models/demand_plan.dart';
import '../models/enrolment.dart';
import '../models/infra_assessment.dart';
import '../models/priority_score.dart';
import 'schools_provider.dart';

// Dashboard stats (scoped to effective district/mandal/school based on role)
final dashboardStatsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final schoolId = ref.watch(effectiveSchoolIdProvider);
  final districtId = ref.watch(effectiveDistrictProvider);
  final mandalId = ref.watch(effectiveMandalProvider);
  return SupabaseService.getDashboardStats(
    schoolId: schoolId,
    districtId: schoolId != null ? null : districtId,
    mandalId: schoolId != null ? null : mandalId,
  );
});

// Demand plans provider (scoped + offline fallback)
final demandPlansProvider = FutureProvider<List<DemandPlan>>((ref) async {
  final schoolId = ref.watch(effectiveSchoolIdProvider);
  final districtId = ref.watch(effectiveDistrictProvider);
  final mandalId = ref.watch(effectiveMandalProvider);
  try {
    final demands = await SupabaseService.getDemandPlans(
      schoolId: schoolId,
      districtId: schoolId != null ? null : districtId,
      mandalId: schoolId != null ? null : mandalId,
    );
    if (demands.isNotEmpty) {
      OfflineCacheService.cacheDemandPlans(demands);
    }
    return demands;
  } catch (e) {
    debugPrint('Demand plans fetch failed, using offline cache: $e');
    if (OfflineCacheService.hasDemandPlansCache()) {
      return OfflineCacheService.getCachedDemandPlans();
    }
    rethrow;
  }
});

// Priority scores (scoped to ALL schools for current role, ignoring priority/category filters)
final priorityScoresProvider =
    FutureProvider<List<SchoolPriorityScore>>((ref) async {
  final schools = await ref.watch(allSchoolsProvider.future);
  final schoolIds = schools.map((s) => s.id).toSet();
  // If no scoping (state official), fetch all; otherwise filter
  if (schoolIds.length >= 300) {
    return SupabaseService.getPriorityScores();
  }
  return SupabaseService.getScopedPriorityScores(schoolIds: schoolIds);
});

// Priority distribution
final priorityDistributionProvider =
    Provider<AsyncValue<PriorityDistribution>>((ref) {
  return ref.watch(priorityScoresProvider).whenData(
        (scores) => PriorityDistribution.fromScores(scores),
      );
});

// Single school priority score (for profile detail view)
final schoolPriorityScoreProvider =
    FutureProvider.family<SchoolPriorityScore?, int>((ref, schoolId) async {
  final allScores = await ref.watch(priorityScoresProvider.future);
  final matches = allScores.where((s) => s.schoolId == schoolId);
  return matches.isNotEmpty ? matches.first : null;
});

// School enrolment provider (for a specific school)
final schoolEnrolmentProvider =
    FutureProvider.family<List<EnrolmentRecord>, int>((ref, schoolId) async {
  return SupabaseService.getEnrolment(schoolId);
});

// School demand plans provider (for a specific school)
final schoolDemandPlansProvider =
    FutureProvider.family<List<DemandPlan>, int>((ref, schoolId) async {
  return SupabaseService.getDemandPlans(schoolId: schoolId);
});

// Demand summary by infra type
final demandSummaryProvider =
    Provider<AsyncValue<List<DemandSummary>>>((ref) {
  return ref.watch(demandPlansProvider).whenData((plans) {
    final byType = <String, List<DemandPlan>>{};
    for (final p in plans) {
      byType.putIfAbsent(p.infraType, () => []).add(p);
    }
    return byType.entries.map((e) {
      final items = e.value;
      return DemandSummary(
        infraType: e.key,
        totalSchools: items.map((d) => d.schoolId).toSet().length,
        totalPhysical: items.fold(0, (s, d) => s + d.physicalCount),
        totalFinancial:
            items.fold(0.0, (s, d) => s + d.financialAmount),
        approved:
            items.where((d) => d.pipelineStage == 'FINAL_APPROVED').length,
        flagged:
            items.where((d) => d.pipelineStage == 'FLAGGED').length,
        rejected:
            items.where((d) => d.pipelineStage == 'REJECTED').length,
        pending: items
            .where((d) =>
                d.pipelineStage == 'PENDING' ||
                d.pipelineStage == 'AI_REVIEWED')
            .length,
      );
    }).toList();
  });
});

// All enrolment (for scoring & validation)
final allEnrolmentProvider =
    FutureProvider<List<EnrolmentRecord>>((ref) async {
  return SupabaseService.getAllEnrolment();
});

// Role-scoped enrolment (filtered by schools the user can see)
final scopedEnrolmentProvider =
    FutureProvider<List<EnrolmentRecord>>((ref) async {
  final allEnrolment = await ref.watch(allEnrolmentProvider.future);
  final schools = await ref.watch(allSchoolsProvider.future);
  final schoolIds = schools.map((s) => s.id).toSet();

  // If state official sees all schools, return everything
  if (schoolIds.length >= 300) {
    return allEnrolment;
  }

  // Filter enrolment to only schools the user can see
  return allEnrolment
      .where((r) => schoolIds.contains(r.schoolId))
      .toList();
});

// All assessments with school info (role-scoped)
final scopedAssessmentsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final districtId = ref.watch(effectiveDistrictProvider);
  final mandalId = ref.watch(effectiveMandalProvider);
  final allRows = await SupabaseService.getAllAssessmentsWithSchool();

  // State official sees all
  if (districtId == null && mandalId == null) return allRows;

  return allRows.where((r) {
    if (mandalId != null) return r['school_mandal_id'] == mandalId;
    if (districtId != null) return r['school_district_id'] == districtId;
    return true;
  }).toList();
});

// District school counts (for analytics)
final districtSchoolCountsProvider =
    Provider<AsyncValue<Map<String, int>>>((ref) {
  return ref.watch(schoolsProvider).whenData((schools) {
    final counts = <String, int>{};
    for (final s in schools) {
      final name = s.districtName ?? 'Unknown';
      counts[name] = (counts[name] ?? 0) + 1;
    }
    return counts;
  });
});

/// Compute & save priority scores for all schools
class ComputePriorityScoresNotifier extends Notifier<AsyncValue<String?>> {
  @override
  AsyncValue<String?> build() => const AsyncValue.data(null);

  Future<void> computeAll() async {
    state = const AsyncValue.loading();
    try {
      // Fetch all schools
      final schools = await SupabaseService.getSchools(limit: 1000);
      // Fetch all enrolment
      final allEnrolment = await SupabaseService.getAllEnrolment();
      // Fetch all demand plans
      final allDemands = await SupabaseService.getDemandPlans(limit: 5000);

      // Group by school
      final enrolmentBySchool = <int, List<EnrolmentRecord>>{};
      for (final r in allEnrolment) {
        enrolmentBySchool.putIfAbsent(r.schoolId, () => []).add(r);
      }
      final demandsBySchool = <int, List<DemandPlan>>{};
      for (final d in allDemands) {
        demandsBySchool.putIfAbsent(d.schoolId, () => []).add(d);
      }

      int computed = 0;
      for (final school in schools) {
        final enrolment = enrolmentBySchool[school.id] ?? [];
        final demands = demandsBySchool[school.id] ?? [];

        final score = PriorityScoringService.computeScore(
          school: school,
          enrolment: enrolment,
          demands: demands,
        );

        await SupabaseService.savePriorityScore(score);
        computed++;
      }

      // Invalidate dependent providers
      ref.invalidate(priorityScoresProvider);
      ref.invalidate(dashboardStatsProvider);

      state = AsyncValue.data('Computed scores for $computed schools');
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final computePriorityScoresProvider =
    NotifierProvider<ComputePriorityScoresNotifier, AsyncValue<String?>>(
  ComputePriorityScoresNotifier.new,
);

/// Validate a single demand plan and write back to Supabase
class ValidateDemandNotifier extends Notifier<AsyncValue<String?>> {
  @override
  AsyncValue<String?> build() => const AsyncValue.data(null);

  Future<ValidationResult?> validateSingle(DemandPlan plan) async {
    state = const AsyncValue.loading();
    try {
      // Fetch enrolment, school demands, and latest inspection in parallel
      final futures = await Future.wait([
        SupabaseService.getEnrolment(plan.schoolId),
        SupabaseService.getDemandPlans(schoolId: plan.schoolId),
        SupabaseService.getLatestAssessment(plan.schoolId),
      ]);
      final enrolment = futures[0] as List<EnrolmentRecord>;
      final schoolDemands = futures[1] as List<DemandPlan>;
      final assessment = futures[2] as InfraAssessment?;

      // Use already-loaded demand plans for peer comparison instead of re-fetching
      List<DemandPlan> peerDemands = [];
      try {
        final cached = ref.read(demandPlansProvider).value;
        if (cached != null) {
          peerDemands =
              cached.where((d) => d.schoolId != plan.schoolId).toList();
        }
      } catch (_) {}

      // Build existingInfra map from latest inspection data
      Map<String, bool>? existingInfra;
      if (assessment != null) {
        existingInfra = {
          'has_cwsn_room': assessment.cwsnResourceRoomAvailable,
          'has_cwsn_toilet': assessment.cwsnToiletAvailable,
          'has_drinking_water': assessment.drinkingWaterAvailable,
          'has_electrification': assessment.electrificationStatus == 'FULL',
          'has_ramp': assessment.rampAvailable,
        };
      }

      final result = DemandValidationService.validate(
        plan: plan,
        enrolment: enrolment,
        allSchoolDemands: schoolDemands,
        peerDemands: peerDemands,
        existingInfra: existingInfra,
      );

      // Write back to Supabase
      await SupabaseService.updateDemandPlanValidation(
        plan.id,
        status: result.status,
        score: result.score,
        flags: result.flags,
        validatedBy: 'AI_VALIDATOR',
      );

      ref.invalidate(demandPlansProvider);
      state = AsyncValue.data(
          '${plan.infraTypeLabel}: ${result.status} (${result.score.toStringAsFixed(0)}%)');
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Officer decision on a demand plan (Stage 3 of pipeline).
  /// Hard gate: if status is APPROVED, requires field assessment.
  /// Returns false if hard gate blocks approval.
  Future<bool> officerDecision(
    DemandPlan plan, {
    required String status,
    required String officerName,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      // HARD GATE: If approving, require field assessment
      if (status == 'APPROVED' && !plan.hasAssessment) {
        // Try to auto-link latest assessment for the school
        final assessmentId =
            await SupabaseService.getLatestAssessmentId(plan.schoolId);
        if (assessmentId == null) {
          state = const AsyncValue.data(
              'Cannot approve: field assessment required');
          return false; // hard gate blocks approval
        }
        // Auto-link assessment before approving
        await SupabaseService.linkAssessmentToDemand(plan.id, assessmentId);
      }

      await SupabaseService.updateOfficerDecision(
        plan.id,
        status: status,
        officerName: officerName,
        notes: notes,
      );
      ref.invalidate(demandPlansProvider);
      ref.invalidate(dashboardStatsProvider);
      state = AsyncValue.data(
          '${plan.infraTypeLabel}: officer $status by $officerName');
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> validateAllPending() async {
    state = const AsyncValue.loading();
    try {
      // Try backend batch validation first
      try {
        final result = await ApiService.batchValidate();
        ref.invalidate(demandPlansProvider);
        ref.invalidate(dashboardStatsProvider);
        state = AsyncValue.data('Backend batch validation complete: ${result['validated'] ?? 'done'}');
        return;
      } catch (_) {
        debugPrint('Backend batch validation unavailable, using client-side');
      }

      // Fallback: client-side validation
      final allDemands = await SupabaseService.getDemandPlans(limit: 5000);
      final pendingDemands =
          allDemands.where((d) => d.isPending).toList();
      final allEnrolment = await SupabaseService.getAllEnrolment();

      final enrolmentBySchool = <int, List<EnrolmentRecord>>{};
      for (final r in allEnrolment) {
        enrolmentBySchool.putIfAbsent(r.schoolId, () => []).add(r);
      }

      // Fetch all inspections for existingInfra checks
      final existingInfraBySchool = <int, Map<String, bool>>{};
      for (final plan in pendingDemands) {
        if (!existingInfraBySchool.containsKey(plan.schoolId)) {
          try {
            final assessment = await SupabaseService.getLatestAssessment(plan.schoolId);
            if (assessment != null) {
              existingInfraBySchool[plan.schoolId] = {
                'has_cwsn_room': assessment.cwsnResourceRoomAvailable,
                'has_cwsn_toilet': assessment.cwsnToiletAvailable,
                'has_drinking_water': assessment.drinkingWaterAvailable,
                'has_electrification': assessment.electrificationStatus == 'FULL',
                'has_ramp': assessment.rampAvailable,
              };
            }
          } catch (_) {}
        }
      }

      int approved = 0, flagged = 0, rejected = 0;
      for (final plan in pendingDemands) {
        final schoolDemands =
            allDemands.where((d) => d.schoolId == plan.schoolId).toList();
        final peerDemands =
            allDemands.where((d) => d.schoolId != plan.schoolId).toList();
        final enrolment = enrolmentBySchool[plan.schoolId] ?? [];

        final result = DemandValidationService.validate(
          plan: plan,
          enrolment: enrolment,
          allSchoolDemands: schoolDemands,
          peerDemands: peerDemands,
          existingInfra: existingInfraBySchool[plan.schoolId],
        );

        await SupabaseService.updateDemandPlanValidation(
          plan.id,
          status: result.status,
          score: result.score,
          flags: result.flags,
          validatedBy: 'AI_VALIDATOR',
        );

        if (result.isApproved) {
          approved++;
        } else if (result.isFlagged) {
          flagged++;
        } else {
          rejected++;
        }
      }

      ref.invalidate(demandPlansProvider);
      ref.invalidate(dashboardStatsProvider);
      state = AsyncValue.data(
          'Validated ${pendingDemands.length}: $approved approved, $flagged flagged, $rejected rejected');
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final validateDemandProvider =
    NotifierProvider<ValidateDemandNotifier, AsyncValue<String?>>(
  ValidateDemandNotifier.new,
);

/// Enrolment forecast — tries Python ML backend, falls back to client-side
class ForecastNotifier extends Notifier<AsyncValue<Map<String, dynamic>?>> {
  @override
  AsyncValue<Map<String, dynamic>?> build() => const AsyncValue.data(null);

  Future<void> forecastSchool(int schoolId) async {
    state = const AsyncValue.loading();
    try {
      // Try ML backend first (3 years)
      final result = await ApiService.forecastEnrolment(schoolId, yearsAhead: 3);
      // Tag with model source + school so UI can verify
      result['model'] = 'backend_ml';
      result['school_id'] = schoolId;
      state = AsyncValue.data(result);
    } catch (_) {
      // Fallback: client-side linear extrapolation
      try {
        final records = await SupabaseService.getEnrolment(schoolId);
        final result = _clientForecast(schoolId, records);
        state = AsyncValue.data(result);
      } catch (e2, st2) {
        state = AsyncValue.error(e2, st2);
      }
    }
  }

  Map<String, dynamic> _clientForecast(
      int schoolId, List<EnrolmentRecord> records) {
    final trend = EnrolmentTrend.compute(schoolId, records);
    final summaries = trend.yearWise;

    if (summaries.isEmpty) {
      return {
        'school_id': schoolId,
        'overall_trend': 'STABLE',
        'growth_rate': 0.0,
        'forecasts': <Map<String, dynamic>>[],
        'model': 'client_linear',
      };
    }

    final lastYear = summaries.last;
    final lastTotal = lastYear.totalStudents;
    final annualGrowthRate = summaries.length >= 2
        ? trend.growthRate / (summaries.length - 1)
        : 0.0;
    final growthFactor = 1 + (annualGrowthRate / 100);

    // Parse last academic year to generate forecast years
    final lastYearStr = lastYear.academicYear; // e.g. "2024-25"
    final yearParts = lastYearStr.split('-');
    final baseYear = int.tryParse(yearParts.first) ?? 2024;

    // Confidence = dataQuality × horizonDecay × volatilityFactor
    // dataQuality: how much historical data we have
    //   2 years → 0.75, 3 → 0.82, 4 → 0.88, 5+ → 0.93
    // horizonDecay: further predictions are less reliable
    //   Year 1 → 1.0, Year 2 → 0.92, Year 3 → 0.82
    final dataYears = summaries.length;
    final dataQuality = dataYears >= 5
        ? 0.93
        : dataYears >= 4
            ? 0.88
            : dataYears >= 3
                ? 0.82
                : 0.75;
    // Penalize if growth is volatile (large year-to-year swings)
    double volatilityPenalty = 1.0;
    if (dataYears >= 3) {
      final changes = <double>[];
      for (int j = 1; j < summaries.length; j++) {
        final prev = summaries[j - 1].totalStudents;
        final curr = summaries[j].totalStudents;
        if (prev > 0) changes.add((curr - prev).abs() / prev);
      }
      final avgChange = changes.fold<double>(0, (s, c) => s + c) / changes.length;
      // High volatility (>25% avg change) reduces confidence
      if (avgChange > 0.25) volatilityPenalty = 0.85;
      else if (avgChange > 0.15) volatilityPenalty = 0.92;
    }

    final forecasts = <Map<String, dynamic>>[];
    const horizonDecay = [1.0, 0.92, 0.82]; // Year 1, 2, 3
    for (int i = 1; i <= 3; i++) {
      final fy1 = baseYear + i;
      final fy2 = (fy1 + 1) % 100;
      final forecastYear = '$fy1-${fy2.toString().padLeft(2, '0')}';
      final predicted =
          (lastTotal * _pow(growthFactor, i)).round().clamp(0, 99999);
      final confidence =
          (dataQuality * horizonDecay[i - 1] * volatilityPenalty)
              .clamp(0.20, 0.95);
      forecasts.add({
        'forecast_year': forecastYear,
        'grade': 'ALL',
        'predicted_total': predicted,
        'confidence': double.parse(confidence.toStringAsFixed(2)),
      });
    }

    return {
      'school_id': schoolId,
      'overall_trend': trend.trend,
      'growth_rate': annualGrowthRate,
      'forecasts': forecasts,
      'model': 'client_linear',
    };
  }

  double _pow(double base, int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}

final forecastProvider =
    NotifierProvider<ForecastNotifier, AsyncValue<Map<String, dynamic>?>>(
  ForecastNotifier.new,
);

// ── Pre-computed forecast per school (loaded from Supabase) ────────
/// Loads pre-computed forecasts for a specific school from the database.
/// Returns the same map format as ForecastNotifier so UI can use it directly.
final precomputedForecastProvider =
    FutureProvider.family<Map<String, dynamic>?, int>((ref, schoolId) async {
  final savedForecasts = await SupabaseService.getForecasts(schoolId);
  if (savedForecasts.isEmpty) return null;

  // Compute growth rate from enrolment for the trend info
  final records = await SupabaseService.getEnrolment(schoolId);
  final trend = EnrolmentTrend.compute(schoolId, records);
  final annualGrowthRate = trend.yearWise.length >= 2
      ? trend.growthRate / (trend.yearWise.length - 1)
      : 0.0;

  return {
    'overall_trend': trend.trend,
    'growth_rate': annualGrowthRate,
    'forecasts': savedForecasts
        .where((f) => (f.grade ?? 'ALL') == 'ALL')
        .map((f) => {
              'forecast_year': f.forecastYear,
              'grade': f.grade ?? 'ALL',
              'predicted_total': f.predictedTotal,
              'confidence': f.confidence,
              'model_used': f.modelUsed,
            })
        .toList(),
    'model': savedForecasts.first.modelUsed ?? 'client_linear',
  };
});

// ── All-school growth rates (for budget allocator) ─────────────────
/// Pre-computed annual growth rates for all schools.
/// Returns Map<schoolId, annualGrowthRate%>.
final allSchoolGrowthRatesProvider =
    FutureProvider<Map<int, double>>((ref) async {
  final allEnrolment = await ref.watch(allEnrolmentProvider.future);

  // Group enrolment by school
  final enrolmentBySchool = <int, List<EnrolmentRecord>>{};
  for (final r in allEnrolment) {
    enrolmentBySchool.putIfAbsent(r.schoolId, () => []).add(r);
  }

  final growthRates = <int, double>{};
  for (final entry in enrolmentBySchool.entries) {
    final trend = EnrolmentTrend.compute(entry.key, entry.value);
    final summaries = trend.yearWise;
    if (summaries.length >= 2) {
      growthRates[entry.key] = trend.growthRate / (summaries.length - 1);
    } else {
      growthRates[entry.key] = 0.0;
    }
  }

  return growthRates;
});

// ── Batch Forecast Computation ─────────────────────────────────────
/// Computes 3-year enrolment forecasts for ALL schools and saves to Supabase.
class BatchForecastNotifier extends Notifier<AsyncValue<String?>> {
  @override
  AsyncValue<String?> build() => const AsyncValue.data(null);

  Future<void> computeAllForecasts() async {
    state = const AsyncValue.loading();
    try {
      final schools = await SupabaseService.getSchools(limit: 1000);
      final allEnrolment = await SupabaseService.getAllEnrolment();

      // Group enrolment by school
      final enrolmentBySchool = <int, List<EnrolmentRecord>>{};
      for (final r in allEnrolment) {
        enrolmentBySchool.putIfAbsent(r.schoolId, () => []).add(r);
      }

      int computed = 0;
      for (final school in schools) {
        final records = enrolmentBySchool[school.id] ?? [];
        if (records.isEmpty) continue;

        final trend = EnrolmentTrend.compute(school.id, records);
        final summaries = trend.yearWise;
        if (summaries.isEmpty) continue;

        final lastYear = summaries.last;
        final lastTotal = lastYear.totalStudents;
        final annualGrowthRate = summaries.length >= 2
            ? trend.growthRate / (summaries.length - 1)
            : 0.0;
        final growthFactor = 1 + (annualGrowthRate / 100);

        // Parse last academic year
        final yearParts = lastYear.academicYear.split('-');
        final baseYear = int.tryParse(yearParts.first) ?? 2024;

        // Confidence = dataQuality × horizonDecay × volatilityFactor
        final dataYears = summaries.length;
        final dataQuality = dataYears >= 5
            ? 0.93
            : dataYears >= 4
                ? 0.88
                : dataYears >= 3
                    ? 0.82
                    : 0.75;
        double volatilityPenalty = 1.0;
        if (dataYears >= 3) {
          final changes = <double>[];
          for (int j = 1; j < summaries.length; j++) {
            final prev = summaries[j - 1].totalStudents;
            final curr = summaries[j].totalStudents;
            if (prev > 0) changes.add((curr - prev).abs() / prev);
          }
          final avgChange =
              changes.fold<double>(0, (s, c) => s + c) / changes.length;
          if (avgChange > 0.25) {
            volatilityPenalty = 0.85;
          } else if (avgChange > 0.15) {
            volatilityPenalty = 0.92;
          }
        }

        const horizonDecay = [1.0, 0.92, 0.82];
        final forecasts = <Map<String, dynamic>>[];
        for (int i = 1; i <= 3; i++) {
          final fy1 = baseYear + i;
          final fy2 = (fy1 + 1) % 100;
          final forecastYear = '$fy1-${fy2.toString().padLeft(2, '0')}';
          final predicted =
              (lastTotal * _pow(growthFactor, i)).round().clamp(0, 99999);
          final confidence =
              (dataQuality * horizonDecay[i - 1] * volatilityPenalty)
                  .clamp(0.20, 0.95);
          forecasts.add({
            'school_id': school.id,
            'forecast_year': forecastYear,
            'grade': 'ALL',
            'predicted_total': predicted,
            'confidence': double.parse(confidence.toStringAsFixed(2)),
            'model_used': 'client_linear',
          });
        }

        // Save to Supabase (delete old, insert new)
        await SupabaseService.saveBatchForecasts(school.id, forecasts);
        computed++;
      }

      state = AsyncValue.data('Forecasts computed for $computed schools');
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  double _pow(double base, int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}

final batchForecastProvider =
    NotifierProvider<BatchForecastNotifier, AsyncValue<String?>>(
  BatchForecastNotifier.new,
);

// ── HM: Latest Assessment for a school ─────────────────────────────
final hmLatestAssessmentProvider =
    FutureProvider.family<InfraAssessment?, int>((ref, schoolId) async {
  return SupabaseService.getLatestAssessment(schoolId);
});

// ── HM: Create / Cancel Demand Plans ───────────────────────────────
class CreateDemandNotifier extends Notifier<AsyncValue<String?>> {
  @override
  AsyncValue<String?> build() => const AsyncValue.data(null);

  /// Create a new demand plan. Falls back to offline queue if no network.
  Future<bool> createDemandPlan({
    required int schoolId,
    required int planYear,
    required String infraType,
    required int physicalCount,
    required double financialAmount,
    String? justification,
  }) async {
    state = const AsyncValue.loading();
    try {
      await SupabaseService.createDemandPlan(
        schoolId: schoolId,
        planYear: planYear,
        infraType: infraType,
        physicalCount: physicalCount,
        financialAmount: financialAmount,
        justification: justification,
      );
      ref.invalidate(demandPlansProvider);
      ref.invalidate(dashboardStatsProvider);
      state = const AsyncValue.data('Request submitted successfully');
      return true;
    } catch (e) {
      // Fallback: queue offline
      try {
        await OfflineCacheService.queueDemandPlan({
          'school_id': schoolId,
          'plan_year': planYear,
          'infra_type': infraType,
          'physical_count': physicalCount,
          'financial_amount': financialAmount,
          'justification': justification,
        });
        state = const AsyncValue.data('Request saved offline — will sync when connected');
        return true;
      } catch (e2, st2) {
        state = AsyncValue.error(e2, st2);
        return false;
      }
    }
  }

  /// Cancel a pending demand plan.
  Future<bool> cancelDemandPlan(int planId) async {
    state = const AsyncValue.loading();
    try {
      await SupabaseService.cancelDemandPlan(planId);
      ref.invalidate(demandPlansProvider);
      ref.invalidate(dashboardStatsProvider);
      state = const AsyncValue.data('Request cancelled');
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final createDemandProvider =
    NotifierProvider<CreateDemandNotifier, AsyncValue<String?>>(
  CreateDemandNotifier.new,
);
