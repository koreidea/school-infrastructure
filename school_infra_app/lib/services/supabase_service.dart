import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/api_config.dart';
import '../models/school.dart';
import '../models/enrolment.dart';
import '../models/demand_plan.dart';
import '../models/infra_assessment.dart';
import '../models/priority_score.dart';
import '../models/user.dart';

class SupabaseService {
  static late final SupabaseClient _client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    _client = Supabase.instance.client;
  }

  static SupabaseClient get client => _client;

  // ─── Districts ───
  static Future<List<District>> getDistricts() async {
    final res = await _client
        .from('si_districts')
        .select()
        .order('district_name');
    return (res as List).map((e) => District.fromJson(e)).toList();
  }

  // ─── Mandals ───
  static Future<List<Mandal>> getMandals({int? districtId}) async {
    var query = _client.from('si_mandals').select();
    if (districtId != null) {
      query = query.eq('district_id', districtId);
    }
    final res = await query.order('mandal_name');
    return (res as List).map((e) => Mandal.fromJson(e)).toList();
  }

  // ─── Schools ───
  static Future<List<School>> getSchools({
    int? districtId,
    int? mandalId,
    String? category,
    String? priorityLevel,
    int limit = 500,
  }) async {
    var query = _client.from('si_schools_view').select();
    if (districtId != null) query = query.eq('district_id', districtId);
    if (mandalId != null) query = query.eq('mandal_id', mandalId);
    if (category != null) query = query.eq('school_category', category);
    if (priorityLevel != null) {
      query = query.eq('priority_level', priorityLevel);
    }
    final res = await query.order('school_name').limit(limit);
    return (res as List).map((e) => School.fromJson(e)).toList();
  }

  static Future<School?> getSchool(int id) async {
    final res = await _client
        .from('si_schools_view')
        .select()
        .eq('id', id)
        .maybeSingle();
    return res != null ? School.fromJson(res) : null;
  }

  // ─── Enrolment ───
  static Future<List<EnrolmentRecord>> getEnrolment(int schoolId) async {
    final res = await _client
        .from('si_enrolment_history')
        .select()
        .eq('school_id', schoolId)
        .order('academic_year')
        .order('grade');
    return (res as List).map((e) => EnrolmentRecord.fromJson(e)).toList();
  }

  static Future<List<EnrolmentRecord>> getAllEnrolment() async {
    final res = await _client
        .from('si_enrolment_history')
        .select()
        .order('school_id')
        .order('academic_year');
    return (res as List).map((e) => EnrolmentRecord.fromJson(e)).toList();
  }

  // ─── Demand Plans ───
  static Future<List<DemandPlan>> getDemandPlans({
    int? schoolId,
    int? districtId,
    int? mandalId,
    String? infraType,
    String? validationStatus,
    int limit = 1000,
  }) async {
    var query = _client.from('si_demand_plans_view').select();
    if (schoolId != null) query = query.eq('school_id', schoolId);
    if (districtId != null) query = query.eq('district_id', districtId);
    if (mandalId != null) query = query.eq('mandal_id', mandalId);
    if (infraType != null) query = query.eq('infra_type', infraType);
    if (validationStatus != null) {
      query = query.eq('validation_status', validationStatus);
    }
    final res = await query.order('school_name').limit(limit);
    return (res as List).map((e) => DemandPlan.fromJson(e)).toList();
  }

  static Future<void> updateDemandPlanValidation(
    int planId, {
    required String status,
    required double score,
    List<dynamic>? flags,
    String? validatedBy,
  }) async {
    await _client.from('si_demand_plans').update({
      'validation_status': status,
      'validation_score': score,
      'validation_flags': flags,
      'validated_by': validatedBy,
      'validated_at': DateTime.now().toIso8601String(),
    }).eq('id', planId);
  }

  // ─── Infrastructure Assessments ───
  static Future<InfraAssessment?> getLatestAssessment(int schoolId) async {
    final res = await _client
        .from('si_infra_assessments')
        .select()
        .eq('school_id', schoolId)
        .order('assessment_date', ascending: false)
        .limit(1)
        .maybeSingle();
    return res != null ? InfraAssessment.fromJson(res) : null;
  }

  static Future<void> saveAssessment(InfraAssessment assessment) async {
    await _client.from('si_infra_assessments').insert(assessment.toJson());
  }

  // ─── Priority Scores ───
  static Future<List<SchoolPriorityScore>> getPriorityScores({
    int scoreYear = 2025,
  }) async {
    var query = _client.from('si_school_priority_scores').select();
    query = query.eq('score_year', scoreYear);
    final res = await query.order('composite_score', ascending: false);
    return (res as List)
        .map((e) => SchoolPriorityScore.fromJson(e))
        .toList();
  }

  /// Get priority scores filtered to only schools in the given scope.
  /// Uses school IDs to filter since priority_scores table has no district/mandal.
  static Future<List<SchoolPriorityScore>> getScopedPriorityScores({
    required Set<int> schoolIds,
    int scoreYear = 2025,
  }) async {
    if (schoolIds.isEmpty) return [];
    // Supabase `.in_()` supports up to ~500 items; fetch all and filter in Dart
    final all = await getPriorityScores(scoreYear: scoreYear);
    return all.where((s) => schoolIds.contains(s.schoolId)).toList();
  }

  static Future<void> savePriorityScore(SchoolPriorityScore score) async {
    await _client.from('si_school_priority_scores').upsert(
      score.toJson(),
      onConflict: 'school_id,score_year',
    );
  }

  // ─── Forecasts ───
  static Future<List<EnrolmentForecast>> getForecasts(int schoolId) async {
    final res = await _client
        .from('si_enrolment_forecasts')
        .select()
        .eq('school_id', schoolId)
        .order('forecast_year');
    return (res as List).map((e) => EnrolmentForecast.fromJson(e)).toList();
  }

  static Future<void> saveForecast(Map<String, dynamic> forecast) async {
    await _client.from('si_enrolment_forecasts').insert(forecast);
  }

  // ─── Dashboard Stats ───
  static Future<Map<String, dynamic>> getDashboardStats({
    int? districtId,
    int? mandalId,
    int? schoolId,
  }) async {
    // Get school count (scoped)
    var schoolQuery = _client.from('si_schools').select('id');
    if (schoolId != null) {
      schoolQuery = schoolQuery.eq('id', schoolId);
    } else {
      if (districtId != null) {
        schoolQuery = schoolQuery.eq('district_id', districtId);
      }
      if (mandalId != null) {
        schoolQuery = schoolQuery.eq('mandal_id', mandalId);
      }
    }
    final schools = await schoolQuery;

    // Get demand plan stats (scoped via view)
    var demandQuery = _client
        .from('si_demand_plans_view')
        .select('validation_status');
    if (schoolId != null) {
      demandQuery = demandQuery.eq('school_id', schoolId);
    } else {
      if (districtId != null) {
        demandQuery = demandQuery.eq('district_id', districtId);
      }
      if (mandalId != null) {
        demandQuery = demandQuery.eq('mandal_id', mandalId);
      }
    }
    final demands = await demandQuery;

    int pending = 0, approved = 0, flagged = 0, rejected = 0;
    for (final d in demands) {
      switch (d['validation_status']) {
        case 'PENDING':
          pending++;
          break;
        case 'APPROVED':
          approved++;
          break;
        case 'FLAGGED':
          flagged++;
          break;
        case 'REJECTED':
          rejected++;
          break;
      }
    }

    return {
      'total_schools': (schools as List).length,
      'demand_pending': pending,
      'demand_approved': approved,
      'demand_flagged': flagged,
      'demand_rejected': rejected,
      'total_demands': pending + approved + flagged + rejected,
    };
  }

  // ─── Users ───
  static Future<AppUser?> getCurrentUser() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;

    final res = await _client
        .from('si_users')
        .select()
        .eq('auth_uid', authUser.id)
        .maybeSingle();

    if (res != null) return AppUser.fromJson(res);

    // If no user record exists, create a default one
    return AppUser(
      id: 0,
      authUid: authUser.id,
      name: authUser.userMetadata?['name'] ?? 'User',
      phone: authUser.phone,
      role: AppConstants.roleStateOfficial,
    );
  }
}
