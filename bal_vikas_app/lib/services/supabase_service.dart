import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/api_config.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  /// Get the currently authenticated user's app profile via RPC (bypasses RLS)
  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final authUser = client.auth.currentUser;
    if (authUser == null) return null;

    final response = await client.rpc('get_my_profile');
    if (response == null) return null;
    return Map<String, dynamic>.from(response as Map);
  }

  /// Look up a user by phone number (before auth — used to check if phone exists)
  static Future<Map<String, dynamic>?> getUserByPhone(String phone) async {
    final response = await client
        .from('users')
        .select()
        .eq('phone', phone)
        .maybeSingle();

    return response;
  }

  /// Link the Supabase auth UID to our users table via RPC (bypasses RLS)
  static Future<void> linkAuthUid(String phone) async {
    final authUser = client.auth.currentUser;
    if (authUser == null) return;

    await client.rpc('link_auth_uid', params: {'phone_number': phone});
  }

  /// Get children based on user role and hierarchy
  static Future<List<Map<String, dynamic>>> getChildrenForUser(
      Map<String, dynamic> userProfile) async {
    final role = userProfile['role'] as String;

    switch (role) {
      case 'PARENT':
        return await client
            .from('children')
            .select()
            .eq('parent_id', userProfile['id'])
            .eq('is_active', true)
            .order('name');

      case 'AWW':
        return await client
            .from('children')
            .select()
            .eq('awc_id', userProfile['awc_id'])
            .eq('is_active', true)
            .order('name');

      case 'SUPERVISOR':
        // Get all AWC IDs in this sector
        final awcs = await client
            .from('anganwadi_centres')
            .select('id')
            .eq('sector_id', userProfile['sector_id']);
        final awcIds = (awcs as List).map((a) => a['id']).toList();
        if (awcIds.isEmpty) return [];

        return await client
            .from('children')
            .select()
            .inFilter('awc_id', awcIds)
            .eq('is_active', true)
            .order('name');

      case 'CDPO':
      case 'CW':
      case 'EO':
        // Get all AWC IDs in this project
        final sectors = await client
            .from('sectors')
            .select('id')
            .eq('project_id', userProfile['project_id']);
        final sectorIds = (sectors as List).map((s) => s['id']).toList();
        if (sectorIds.isEmpty) return [];

        final awcs = await client
            .from('anganwadi_centres')
            .select('id')
            .inFilter('sector_id', sectorIds);
        final awcIds = (awcs as List).map((a) => a['id']).toList();
        if (awcIds.isEmpty) return [];

        return await client
            .from('children')
            .select()
            .inFilter('awc_id', awcIds)
            .eq('is_active', true)
            .order('name');

      case 'DW':
        // Get all AWC IDs in this district
        final projects = await client
            .from('projects')
            .select('id')
            .eq('district_id', userProfile['district_id']);
        final projectIds = (projects as List).map((p) => p['id']).toList();
        if (projectIds.isEmpty) return [];

        final sectors = await client
            .from('sectors')
            .select('id')
            .inFilter('project_id', projectIds);
        final sectorIds = (sectors as List).map((s) => s['id']).toList();
        if (sectorIds.isEmpty) return [];

        final awcs = await client
            .from('anganwadi_centres')
            .select('id')
            .inFilter('sector_id', sectorIds);
        final awcIds = (awcs as List).map((a) => a['id']).toList();
        if (awcIds.isEmpty) return [];

        return await client
            .from('children')
            .select()
            .inFilter('awc_id', awcIds)
            .eq('is_active', true)
            .order('name');

      case 'SENIOR_OFFICIAL':
        // Get all children in the state
        final districts = await client
            .from('districts')
            .select('id')
            .eq('state_id', userProfile['state_id']);
        final districtIds = (districts as List).map((d) => d['id']).toList();
        if (districtIds.isEmpty) return [];

        final projects = await client
            .from('projects')
            .select('id')
            .inFilter('district_id', districtIds);
        final projectIds = (projects as List).map((p) => p['id']).toList();
        if (projectIds.isEmpty) return [];

        final sectors = await client
            .from('sectors')
            .select('id')
            .inFilter('project_id', projectIds);
        final sectorIds = (sectors as List).map((s) => s['id']).toList();
        if (sectorIds.isEmpty) return [];

        final awcs = await client
            .from('anganwadi_centres')
            .select('id')
            .inFilter('sector_id', sectorIds);
        final awcIds = (awcs as List).map((a) => a['id']).toList();
        if (awcIds.isEmpty) return [];

        return await client
            .from('children')
            .select()
            .inFilter('awc_id', awcIds)
            .eq('is_active', true)
            .order('name');

      default:
        return [];
    }
  }

  /// Save a screening session to Supabase
  static Future<Map<String, dynamic>> saveScreeningSession({
    required int childId,
    required String conductedBy,
    required String assessmentDate,
    required int childAgeMonths,
    required String status,
    String? deviceSessionId,
  }) async {
    final data = <String, dynamic>{
      'child_id': childId,
      'assessment_date': assessmentDate,
      'child_age_months': childAgeMonths,
      'status': status,
      'device_session_id': deviceSessionId,
    };
    // Only include conducted_by if it's a valid UUID (non-empty)
    if (conductedBy.isNotEmpty) {
      data['conducted_by'] = conductedBy;
    }

    final response = await client.from('screening_sessions')
        .insert(data).select().single();

    return response;
  }

  /// Save screening responses (batch)
  static Future<void> saveScreeningResponses({
    required int sessionId,
    required String toolType,
    required Map<String, dynamic> responses,
  }) async {
    final rows = responses.entries.map((e) => {
      'session_id': sessionId,
      'tool_type': toolType,
      'question_id': e.key,
      'response_value': e.value,
    }).toList();

    if (rows.isNotEmpty) {
      await client.from('screening_responses').insert(rows);
    }
  }

  /// Save screening results
  static Future<void> saveScreeningResult({
    required int sessionId,
    required int childId,
    required String overallRisk,
    String? overallRiskTe,
    required bool referralNeeded,
    double? gmDq,
    double? fmDq,
    double? lcDq,
    double? cogDq,
    double? seDq,
    double? compositeDq,
    Map<String, dynamic>? toolResults,
    List<String>? concerns,
    List<String>? concernsTe,
    int toolsCompleted = 0,
    int toolsSkipped = 0,
  }) async {
    await client.from('screening_results').insert({
      'session_id': sessionId,
      'child_id': childId,
      'overall_risk': overallRisk,
      'overall_risk_te': overallRiskTe,
      'referral_needed': referralNeeded,
      'gm_dq': gmDq,
      'fm_dq': fmDq,
      'lc_dq': lcDq,
      'cog_dq': cogDq,
      'se_dq': seDq,
      'composite_dq': compositeDq,
      'tool_results': toolResults,
      'concerns': concerns,
      'concerns_te': concernsTe,
      'tools_completed': toolsCompleted,
      'tools_skipped': toolsSkipped,
    });

    // Mark session as completed
    await client.from('screening_sessions').update({
      'status': 'completed',
      'completed_at': DateTime.now().toIso8601String(),
      'synced_at': DateTime.now().toIso8601String(),
    }).eq('id', sessionId);
  }

  /// Get screening history for a child
  static Future<List<Map<String, dynamic>>> getScreeningHistory(int childId) async {
    return await client
        .from('screening_results')
        .select('*, screening_sessions!inner(*)')
        .eq('child_id', childId)
        .order('created_at', ascending: false);
  }

  /// Get screening results for multiple children at once
  static Future<List<Map<String, dynamic>>> getScreeningResultsForChildren(List<int> childIds) async {
    if (childIds.isEmpty) return [];
    return await client
        .from('screening_results')
        .select('*, screening_sessions!inner(*)')
        .inFilter('child_id', childIds)
        .order('created_at', ascending: false);
  }

  /// Get AWCs for a supervisor (by sector)
  static Future<List<Map<String, dynamic>>> getAwcsForSector(int sectorId) async {
    return await client
        .from('anganwadi_centres')
        .select()
        .eq('sector_id', sectorId)
        .eq('is_active', true)
        .order('centre_code');
  }

  /// Get children for a sector (Supervisor)
  static Future<List<Map<String, dynamic>>> getChildrenForSector(int sectorId) async {
    final awcs = await client
        .from('anganwadi_centres')
        .select('id')
        .eq('sector_id', sectorId)
        .eq('is_active', true);
    final awcIds = (awcs as List).map((a) => a['id']).toList();
    if (awcIds.isEmpty) return [];

    return await client
        .from('children')
        .select('*, anganwadi_centres!inner(name, centre_code)')
        .inFilter('awc_id', awcIds)
        .eq('is_active', true)
        .order('name');
  }

  /// Get screening results for children in a sector (Supervisor)
  static Future<List<Map<String, dynamic>>> getScreeningResultsForSector(int sectorId) async {
    final awcs = await client
        .from('anganwadi_centres')
        .select('id')
        .eq('sector_id', sectorId)
        .eq('is_active', true);
    final awcIds = (awcs as List).map((a) => a['id']).toList();
    if (awcIds.isEmpty) return [];

    final children = await client
        .from('children')
        .select('id')
        .inFilter('awc_id', awcIds)
        .eq('is_active', true);
    final childIds = (children as List).map((c) => c['id']).toList();
    if (childIds.isEmpty) return [];

    return await client
        .from('screening_results')
        .select('*, screening_sessions!inner(*), children!inner(name, dob, gender, awc_id, child_unique_id)')
        .inFilter('child_id', childIds)
        .order('created_at', ascending: false);
  }

  /// Get AWCs for a project (CDPO/CW/EO)
  static Future<List<Map<String, dynamic>>> getAwcsForProject(int projectId) async {
    final sectors = await client
        .from('sectors')
        .select('id')
        .eq('project_id', projectId);
    final sectorIds = (sectors as List).map((s) => s['id']).toList();
    if (sectorIds.isEmpty) return [];

    return await client
        .from('anganwadi_centres')
        .select('*, sectors!inner(name)')
        .inFilter('sector_id', sectorIds)
        .eq('is_active', true)
        .order('centre_code');
  }

  /// Get sectors for a project
  static Future<List<Map<String, dynamic>>> getSectorsForProject(int projectId) async {
    return await client
        .from('sectors')
        .select()
        .eq('project_id', projectId)
        .order('name');
  }

  /// Get children for a project (all AWCs in all sectors)
  static Future<List<Map<String, dynamic>>> getChildrenForProject(int projectId) async {
    final sectors = await client
        .from('sectors')
        .select('id')
        .eq('project_id', projectId);
    final sectorIds = (sectors as List).map((s) => s['id']).toList();
    if (sectorIds.isEmpty) return [];

    final awcs = await client
        .from('anganwadi_centres')
        .select('id')
        .inFilter('sector_id', sectorIds)
        .eq('is_active', true);
    final awcIds = (awcs as List).map((a) => a['id']).toList();
    if (awcIds.isEmpty) return [];

    return await client
        .from('children')
        .select('*, anganwadi_centres!inner(name, centre_code)')
        .inFilter('awc_id', awcIds)
        .eq('is_active', true)
        .order('name');
  }

  /// Get children for a specific AWC
  static Future<List<Map<String, dynamic>>> getChildrenForAwc(int awcId) async {
    return await client
        .from('children')
        .select()
        .eq('awc_id', awcId)
        .eq('is_active', true)
        .order('name');
  }

  /// Get screening results for children in an AWC
  static Future<List<Map<String, dynamic>>> getScreeningResultsForAwc(int awcId) async {
    final children = await client
        .from('children')
        .select('id')
        .eq('awc_id', awcId)
        .eq('is_active', true);
    final childIds = (children as List).map((c) => c['id']).toList();
    if (childIds.isEmpty) return [];

    return await client
        .from('screening_results')
        .select('*, screening_sessions!inner(*), children!inner(name, dob, gender, awc_id, child_unique_id)')
        .inFilter('child_id', childIds)
        .order('created_at', ascending: false);
  }

  /// Get screening results for children in a project (with child + AWC info)
  static Future<List<Map<String, dynamic>>> getScreeningResultsForProject(int projectId) async {
    final sectors = await client
        .from('sectors')
        .select('id')
        .eq('project_id', projectId);
    final sectorIds = (sectors as List).map((s) => s['id']).toList();
    if (sectorIds.isEmpty) return [];

    final awcs = await client
        .from('anganwadi_centres')
        .select('id')
        .inFilter('sector_id', sectorIds)
        .eq('is_active', true);
    final awcIds = (awcs as List).map((a) => a['id']).toList();
    if (awcIds.isEmpty) return [];

    final children = await client
        .from('children')
        .select('id')
        .inFilter('awc_id', awcIds)
        .eq('is_active', true);
    final childIds = (children as List).map((c) => c['id']).toList();
    if (childIds.isEmpty) return [];

    return await client
        .from('screening_results')
        .select('*, screening_sessions!inner(*), children!inner(name, dob, gender, awc_id, child_unique_id)')
        .inFilter('child_id', childIds)
        .order('created_at', ascending: false);
  }

  /// Get AWCs for a district (DW)
  static Future<List<Map<String, dynamic>>> getAwcsForDistrict(int districtId) async {
    final projects = await client.from('projects').select('id').eq('district_id', districtId);
    final projectIds = (projects as List).map((p) => p['id']).toList();
    if (projectIds.isEmpty) return [];

    final sectors = await client.from('sectors').select('id').inFilter('project_id', projectIds);
    final sectorIds = (sectors as List).map((s) => s['id']).toList();
    if (sectorIds.isEmpty) return [];

    return await client
        .from('anganwadi_centres')
        .select('*, sectors!inner(name)')
        .inFilter('sector_id', sectorIds)
        .eq('is_active', true)
        .order('centre_code');
  }

  /// Get children for a district (DW) — all AWCs in all projects/sectors
  static Future<List<Map<String, dynamic>>> getChildrenForDistrict(int districtId) async {
    final projects = await client.from('projects').select('id').eq('district_id', districtId);
    final projectIds = (projects as List).map((p) => p['id']).toList();
    if (projectIds.isEmpty) return [];

    final sectors = await client.from('sectors').select('id').inFilter('project_id', projectIds);
    final sectorIds = (sectors as List).map((s) => s['id']).toList();
    if (sectorIds.isEmpty) return [];

    final awcs = await client.from('anganwadi_centres').select('id').inFilter('sector_id', sectorIds).eq('is_active', true);
    final awcIds = (awcs as List).map((a) => a['id']).toList();
    if (awcIds.isEmpty) return [];

    return await client
        .from('children')
        .select('*, anganwadi_centres!inner(name, centre_code)')
        .inFilter('awc_id', awcIds)
        .eq('is_active', true)
        .order('name');
  }

  /// Get screening results for children in a district (DW)
  static Future<List<Map<String, dynamic>>> getScreeningResultsForDistrict(int districtId) async {
    final projects = await client.from('projects').select('id').eq('district_id', districtId);
    final projectIds = (projects as List).map((p) => p['id']).toList();
    if (projectIds.isEmpty) return [];

    final sectors = await client.from('sectors').select('id').inFilter('project_id', projectIds);
    final sectorIds = (sectors as List).map((s) => s['id']).toList();
    if (sectorIds.isEmpty) return [];

    final awcs = await client.from('anganwadi_centres').select('id').inFilter('sector_id', sectorIds).eq('is_active', true);
    final awcIds = (awcs as List).map((a) => a['id']).toList();
    if (awcIds.isEmpty) return [];

    final children = await client.from('children').select('id').inFilter('awc_id', awcIds).eq('is_active', true);
    final childIds = (children as List).map((c) => c['id']).toList();
    if (childIds.isEmpty) return [];

    return await client
        .from('screening_results')
        .select('*, screening_sessions!inner(*), children!inner(name, dob, gender, awc_id, child_unique_id)')
        .inFilter('child_id', childIds)
        .order('created_at', ascending: false);
  }

  /// Get AWCs for a state (Senior Official)
  static Future<List<Map<String, dynamic>>> getAwcsForState(int stateId) async {
    final districts = await client.from('districts').select('id').eq('state_id', stateId);
    final districtIds = (districts as List).map((d) => d['id']).toList();
    if (districtIds.isEmpty) return [];

    final projects = await client.from('projects').select('id').inFilter('district_id', districtIds);
    final projectIds = (projects as List).map((p) => p['id']).toList();
    if (projectIds.isEmpty) return [];

    final sectors = await client.from('sectors').select('id').inFilter('project_id', projectIds);
    final sectorIds = (sectors as List).map((s) => s['id']).toList();
    if (sectorIds.isEmpty) return [];

    return await client
        .from('anganwadi_centres')
        .select('*, sectors!inner(name)')
        .inFilter('sector_id', sectorIds)
        .eq('is_active', true)
        .order('centre_code');
  }

  /// Get children for a state (Senior Official) — all children
  static Future<List<Map<String, dynamic>>> getChildrenForState(int stateId) async {
    final districts = await client.from('districts').select('id').eq('state_id', stateId);
    final districtIds = (districts as List).map((d) => d['id']).toList();
    if (districtIds.isEmpty) return [];

    final projects = await client.from('projects').select('id').inFilter('district_id', districtIds);
    final projectIds = (projects as List).map((p) => p['id']).toList();
    if (projectIds.isEmpty) return [];

    final sectors = await client.from('sectors').select('id').inFilter('project_id', projectIds);
    final sectorIds = (sectors as List).map((s) => s['id']).toList();
    if (sectorIds.isEmpty) return [];

    final awcs = await client.from('anganwadi_centres').select('id').inFilter('sector_id', sectorIds).eq('is_active', true);
    final awcIds = (awcs as List).map((a) => a['id']).toList();
    if (awcIds.isEmpty) return [];

    return await client
        .from('children')
        .select('*, anganwadi_centres!inner(name, centre_code)')
        .inFilter('awc_id', awcIds)
        .eq('is_active', true)
        .order('name');
  }

  /// Get screening results for children in a state (Senior Official)
  static Future<List<Map<String, dynamic>>> getScreeningResultsForState(int stateId) async {
    final districts = await client.from('districts').select('id').eq('state_id', stateId);
    final districtIds = (districts as List).map((d) => d['id']).toList();
    if (districtIds.isEmpty) return [];

    final projects = await client.from('projects').select('id').inFilter('district_id', districtIds);
    final projectIds = (projects as List).map((p) => p['id']).toList();
    if (projectIds.isEmpty) return [];

    final sectors = await client.from('sectors').select('id').inFilter('project_id', projectIds);
    final sectorIds = (sectors as List).map((s) => s['id']).toList();
    if (sectorIds.isEmpty) return [];

    final awcs = await client.from('anganwadi_centres').select('id').inFilter('sector_id', sectorIds).eq('is_active', true);
    final awcIds = (awcs as List).map((a) => a['id']).toList();
    if (awcIds.isEmpty) return [];

    final children = await client.from('children').select('id').inFilter('awc_id', awcIds).eq('is_active', true);
    final childIds = (children as List).map((c) => c['id']).toList();
    if (childIds.isEmpty) return [];

    return await client
        .from('screening_results')
        .select('*, screening_sessions!inner(*), children!inner(name, dob, gender, awc_id, child_unique_id)')
        .inFilter('child_id', childIds)
        .order('created_at', ascending: false);
  }

  /// Save a referral to Supabase
  static Future<Map<String, dynamic>> saveReferral({
    required int childId,
    int? screeningResultId,
    required bool referralTriggered,
    String? referralType,
    String? referralReason,
    required String referralStatus,
    String? referredBy,
    String? referredDate,
    String? completedDate,
    String? notes,
  }) async {
    return await client.from('referrals').insert({
      'child_id': childId,
      'screening_result_id': screeningResultId,
      'referral_triggered': referralTriggered,
      'referral_type': referralType,
      'referral_reason': referralReason,
      'referral_status': referralStatus,
      'referred_by_user_id': referredBy,
      'referred_date': referredDate,
      'completed_date': completedDate,
      'notes': notes,
    }).select().single();
  }

  /// Save a nutrition assessment to Supabase
  static Future<Map<String, dynamic>> saveNutritionAssessment({
    required int childId,
    int? sessionId,
    double? heightCm,
    double? weightKg,
    double? muacCm,
    required bool underweight,
    required bool stunting,
    required bool wasting,
    required bool anemia,
    required int nutritionScore,
    required String nutritionRisk,
    String? assessedDate,
  }) async {
    return await client.from('nutrition_assessments').insert({
      'child_id': childId,
      'session_id': sessionId,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'muac_cm': muacCm,
      'underweight': underweight,
      'stunting': stunting,
      'wasting': wasting,
      'anemia': anemia,
      'nutrition_score': nutritionScore,
      'nutrition_risk': nutritionRisk,
      'assessed_date': assessedDate,
    }).select().single();
  }

  /// Save an environment assessment to Supabase
  static Future<Map<String, dynamic>> saveEnvironmentAssessment({
    required int childId,
    int? sessionId,
    int? parentChildInteractionScore,
    int? parentMentalHealthScore,
    int? homeStimulationScore,
    required bool playMaterials,
    required String caregiverEngagement,
    required String languageExposure,
    required bool safeWater,
    required bool toiletFacility,
  }) async {
    return await client.from('environment_assessments').insert({
      'child_id': childId,
      'session_id': sessionId,
      'parent_child_interaction_score': parentChildInteractionScore,
      'parent_mental_health_score': parentMentalHealthScore,
      'home_stimulation_score': homeStimulationScore,
      'play_materials': playMaterials,
      'caregiver_engagement': caregiverEngagement,
      'language_exposure': languageExposure,
      'safe_water': safeWater,
      'toilet_facility': toiletFacility,
    }).select().single();
  }

  /// Save an intervention follow-up to Supabase
  static Future<Map<String, dynamic>> saveFollowup({
    required int childId,
    int? screeningResultId,
    required bool followupConducted,
    String? followupDate,
    String? improvementStatus,
    required int reductionInDelayMonths,
    required bool domainImprovement,
    required bool exitHighRisk,
    String? notes,
    String? createdBy,
  }) async {
    return await client.from('intervention_followups').insert({
      'child_id': childId,
      'screening_result_id': screeningResultId,
      'followup_conducted': followupConducted,
      'followup_date': followupDate,
      'improvement_status': improvementStatus,
      'reduction_in_delay_months': reductionInDelayMonths,
      'domain_improvement': domainImprovement,
      'exit_high_risk': exitHighRisk,
      'notes': notes,
      'created_by_user_id': createdBy,
    }).select().single();
  }

  /// Save a consent record to Supabase
  static Future<Map<String, dynamic>> saveConsent({
    required int childId,
    required String guardianName,
    required String guardianRelation,
    String? guardianPhone,
    required String consentPurpose,
    required bool consentGiven,
    required String consentVersion,
    String? digitalSignatureBase64,
    required String collectedByUserId,
    required String collectedByRole,
    required String languageUsed,
    required String consentTimestamp,
  }) async {
    return await client.from('guardian_consents').insert({
      'child_id': childId,
      'guardian_name': guardianName,
      'guardian_relation': guardianRelation,
      'guardian_phone': guardianPhone,
      'consent_purpose': consentPurpose,
      'consent_given': consentGiven,
      'consent_version': consentVersion,
      'digital_signature_base64': digitalSignatureBase64,
      'collected_by_user_id': collectedByUserId,
      'collected_by_role': collectedByRole,
      'language_used': languageUsed,
      'consent_timestamp': consentTimestamp,
    }).select().single();
  }

  /// Save an audit log entry to Supabase
  static Future<Map<String, dynamic>> saveAuditLog({
    required String userId,
    required String userRole,
    required String action,
    required String entityType,
    int? entityId,
    String? entityName,
    String? detailsJson,
    String? deviceInfo,
    required String timestamp,
  }) async {
    return await client.from('audit_logs').insert({
      'user_id': userId,
      'user_role': userRole,
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'entity_name': entityName,
      'details_json': detailsJson,
      'device_info': deviceInfo,
      'timestamp': timestamp,
    }).select().single();
  }

  /// Get aggregate dashboard stats for administrative roles
  static Future<Map<String, dynamic>> getDashboardStats(
      String scope, int scopeId) async {
    final result = await client.rpc('get_dashboard_stats', params: {
      'p_scope': scope,
      'p_scope_id': scopeId,
    });
    if (result == null) {
      return {'scope': scope, 'total_children': 0, 'sub_units': []};
    }
    return Map<String, dynamic>.from(result as Map);
  }
}
