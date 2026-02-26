import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../services/api_service.dart';
import '../services/priority_scoring_service.dart';
import '../services/demand_validation_service.dart';
import '../services/offline_cache_service.dart';
import '../models/demand_plan.dart';
import '../models/enrolment.dart';
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

// Priority scores (scoped to the schools visible to the current role)
final priorityScoresProvider =
    FutureProvider<List<SchoolPriorityScore>>((ref) async {
  final schools = await ref.watch(schoolsProvider.future);
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
            items.where((d) => d.validationStatus == 'APPROVED').length,
        flagged:
            items.where((d) => d.validationStatus == 'FLAGGED').length,
        rejected:
            items.where((d) => d.validationStatus == 'REJECTED').length,
        pending:
            items.where((d) => d.validationStatus == 'PENDING').length,
      );
    }).toList();
  });
});

// All enrolment (for scoring & validation)
final allEnrolmentProvider =
    FutureProvider<List<EnrolmentRecord>>((ref) async {
  return SupabaseService.getAllEnrolment();
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
      // Fetch enrolment and school demands in parallel (lightweight)
      final futures = await Future.wait([
        SupabaseService.getEnrolment(plan.schoolId),
        SupabaseService.getDemandPlans(schoolId: plan.schoolId),
      ]);
      final enrolment = futures[0] as List<EnrolmentRecord>;
      final schoolDemands = futures[1] as List<DemandPlan>;

      // Use already-loaded demand plans for peer comparison instead of re-fetching
      List<DemandPlan> peerDemands = [];
      try {
        final cached = ref.read(demandPlansProvider).value;
        if (cached != null) {
          peerDemands =
              cached.where((d) => d.schoolId != plan.schoolId).toList();
        }
      } catch (_) {}

      final result = DemandValidationService.validate(
        plan: plan,
        enrolment: enrolment,
        allSchoolDemands: schoolDemands,
        peerDemands: peerDemands,
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

  /// Manually set the validation status of a demand plan (officer override).
  Future<void> manualValidate(
    DemandPlan plan, {
    required String status,
    required String validatedBy,
  }) async {
    state = const AsyncValue.loading();
    try {
      await SupabaseService.updateDemandPlanValidation(
        plan.id,
        status: status,
        score: status == 'APPROVED' ? 100 : status == 'REJECTED' ? 0 : 50,
        flags: status == 'FLAGGED' ? ['MANUAL_FLAG'] : [],
        validatedBy: validatedBy,
      );
      ref.invalidate(demandPlansProvider);
      ref.invalidate(dashboardStatsProvider);
      state = AsyncValue.data(
          '${plan.infraTypeLabel}: manually set to $status');
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> validateAllPending() async {
    state = const AsyncValue.loading();
    try {
      final allDemands = await SupabaseService.getDemandPlans(limit: 5000);
      final pendingDemands =
          allDemands.where((d) => d.isPending).toList();
      final allEnrolment = await SupabaseService.getAllEnrolment();

      final enrolmentBySchool = <int, List<EnrolmentRecord>>{};
      for (final r in allEnrolment) {
        enrolmentBySchool.putIfAbsent(r.schoolId, () => []).add(r);
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
      // Try ML backend first
      final result = await ApiService.forecastEnrolment(schoolId);
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

    final forecasts = <Map<String, dynamic>>[];
    for (int i = 1; i <= 3; i++) {
      final fy1 = baseYear + i;
      final fy2 = (fy1 + 1) % 100;
      final forecastYear = '$fy1-${fy2.toString().padLeft(2, '0')}';
      final predicted =
          (lastTotal * _pow(growthFactor, i)).round().clamp(0, 99999);
      final confidence = (0.90 - (i * 0.10)).clamp(0.3, 0.95);
      forecasts.add({
        'forecast_year': forecastYear,
        'grade': 'ALL',
        'predicted_total': predicted,
        'confidence': confidence,
      });
    }

    return {
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
