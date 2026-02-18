import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/api_config.dart';
import '../../providers/auth_provider.dart';

/// In-app API documentation and interoperability reference screen
class ApiInteropScreen extends ConsumerWidget {
  const ApiInteropScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isTelugu
              ? 'API & ఇంటరాపరబిలిటీ'
              : 'API & Interoperability'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: isTelugu ? 'API' : 'API'),
              Tab(text: isTelugu ? 'డేటా మోడల్స్' : 'Data Models'),
              Tab(text: isTelugu ? 'ఇంటర్‌ఆప్' : 'Interop'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ApiTab(isTelugu: isTelugu),
            _DataModelsTab(isTelugu: isTelugu),
            _InteropTab(isTelugu: isTelugu),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Tab 1: API Endpoints
// =============================================================================
class _ApiTab extends StatelessWidget {
  final bool isTelugu;
  const _ApiTab({required this.isTelugu});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Architecture Overview
          Card(
            color: AppColors.primary,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.api, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isTelugu ? 'ద్వంద్వ API ఆర్కిటెక్చర్' : 'Dual API Architecture',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Text(
                    isTelugu
                        ? '1. Supabase PostgREST + RPC (ప్రాథమిక)\n2. FastAPI REST (ఎక్స్‌పోర్ట్, ML, OTP)'
                        : '1. Supabase PostgREST + RPC (Primary)\n2. FastAPI REST (Export, ML, OTP)',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Supabase RPC Functions
          _SectionHeader(
            title: isTelugu ? 'Supabase RPC ఫంక్షన్లు' : 'Supabase RPC Functions',
            icon: Icons.functions,
          ),
          const SizedBox(height: 8),
          _EndpointCard(
            method: 'RPC',
            path: 'get_my_profile',
            description: isTelugu
                ? 'ప్రస్తుత యూజర్ ప్రొఫైల్ (RLS బైపాస్)'
                : 'Current user profile (bypasses RLS)',
          ),
          _EndpointCard(
            method: 'RPC',
            path: 'check_phone_exists',
            description: isTelugu
                ? 'ఫోన్ నంబర్ ఉనికిని తనిఖీ చేయి'
                : 'Check phone number existence',
          ),
          _EndpointCard(
            method: 'RPC',
            path: 'link_auth_uid',
            description: isTelugu
                ? 'Auth UID ను యూజర్స్ టేబుల్‌తో లింక్ చేయి'
                : 'Link auth UID to users table',
          ),
          _EndpointCard(
            method: 'RPC',
            path: 'get_dashboard_stats',
            description: isTelugu
                ? 'స్కోప్-ఆధారిత డ్యాష్‌బోర్డ్ గణాంకాలు'
                : 'Scope-based dashboard statistics',
          ),
          const SizedBox(height: 20),

          // Supabase Table Operations
          _SectionHeader(
            title: isTelugu ? 'టేబుల్ ఆపరేషన్లు' : 'Table Operations',
            icon: Icons.table_chart,
          ),
          const SizedBox(height: 8),
          _EndpointCard(
            method: 'GET',
            path: '/children?awc_id=eq.{id}',
            description: isTelugu ? 'AWC పిల్లలను పొందు' : 'Get AWC children',
          ),
          _EndpointCard(
            method: 'POST',
            path: '/screening_sessions',
            description: isTelugu
                ? 'స్క్రీనింగ్ సెషన్ సృష్టించు'
                : 'Create screening session',
          ),
          _EndpointCard(
            method: 'POST',
            path: '/screening_responses',
            description: isTelugu
                ? 'సాధన ప్రతిస్పందనలు సేవ్ చేయి'
                : 'Save tool responses (batch)',
          ),
          _EndpointCard(
            method: 'POST',
            path: '/screening_results',
            description: isTelugu
                ? 'స్క్రీనింగ్ ఫలితం సేవ్ చేయి'
                : 'Save screening result with DQ scores',
          ),
          _EndpointCard(
            method: 'POST',
            path: '/referrals',
            description: isTelugu ? 'రిఫరల్ సృష్టించు' : 'Create referral',
          ),
          _EndpointCard(
            method: 'POST',
            path: '/nutrition_assessments',
            description: isTelugu
                ? 'పోషకాహార అంచనా సేవ్ చేయి'
                : 'Save nutrition assessment',
          ),
          _EndpointCard(
            method: 'POST',
            path: '/environment_assessments',
            description: isTelugu
                ? 'పర్యావరణ అంచనా సేవ్ చేయి'
                : 'Save environment assessment',
          ),
          _EndpointCard(
            method: 'POST',
            path: '/intervention_followups',
            description: isTelugu
                ? 'ఫాలో-అప్ సేవ్ చేయి'
                : 'Save intervention follow-up',
          ),
          const SizedBox(height: 20),

          // REST API Endpoints
          _SectionHeader(
            title: isTelugu ? 'REST API ఎండ్‌పాయింట్లు' : 'REST API Endpoints',
            icon: Icons.http,
          ),
          const SizedBox(height: 8),
          _EndpointCard(
            method: 'POST',
            path: '/api/auth/send-otp',
            description: isTelugu ? 'OTP పంపు' : 'Send OTP to mobile',
          ),
          _EndpointCard(
            method: 'POST',
            path: '/api/auth/verify-otp',
            description: isTelugu
                ? 'OTP ధృవీకరించు → JWT టోకెన్'
                : 'Verify OTP → JWT token',
          ),
          _EndpointCard(
            method: 'POST',
            path: '/api/export/child/{id}/excel',
            description: isTelugu
                ? 'బాలుడి నివేదిక Excel ఎగుమతి'
                : 'Export child report as Excel',
          ),
          _EndpointCard(
            method: 'GET',
            path: '/api/interventions/recommend/{id}',
            description: isTelugu
                ? 'AI సిఫార్సు కార్యకలాపాలు'
                : 'AI-recommended activities',
          ),
          const SizedBox(height: 20),

          // Auth Flow
          _SectionHeader(
            title: isTelugu ? 'ధృవీకరణ ఫ్లో' : 'Authentication Flow',
            icon: Icons.security,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FlowStep(
                    step: '1',
                    text: isTelugu
                        ? 'ఫోన్ నంబర్ నమోదు → check_phone_exists'
                        : 'Enter phone → check_phone_exists',
                  ),
                  _FlowStep(
                    step: '2',
                    text: isTelugu
                        ? 'Supabase signInWithPassword'
                        : 'Supabase signInWithPassword',
                  ),
                  _FlowStep(
                    step: '3',
                    text: isTelugu
                        ? 'JWT టోకెన్ జారీ → సెషన్ కాష్'
                        : 'JWT token issued → session cached',
                  ),
                  _FlowStep(
                    step: '4',
                    text: isTelugu
                        ? 'get_my_profile → పూర్తి యూజర్ ఆబ్జెక్ట్'
                        : 'get_my_profile → full User object',
                  ),
                  _FlowStep(
                    step: '5',
                    text: isTelugu
                        ? 'బ్యాక్‌గ్రౌండ్: కాన్ఫిగ్‌లు + పిల్లల డేటా పుల్'
                        : 'Background: pull configs + children data',
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // RLS
          _SectionHeader(
            title: isTelugu ? 'రో-లెవల్ సెక్యూరిటీ' : 'Row-Level Security (RLS)',
            icon: Icons.shield,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RoleAccessRow(
                    role: 'AWW',
                    scope: isTelugu ? 'ఒక AWC' : 'Single AWC',
                    color: AppColors.riskLow,
                  ),
                  _RoleAccessRow(
                    role: 'Supervisor',
                    scope: isTelugu ? 'సెక్టార్ AWCలు' : 'Sector AWCs',
                    color: Colors.teal,
                  ),
                  _RoleAccessRow(
                    role: 'CDPO/CW/EO',
                    scope: isTelugu ? 'ప్రాజెక్ట్ సెక్టార్లు' : 'Project sectors',
                    color: Colors.orange,
                  ),
                  _RoleAccessRow(
                    role: 'DW',
                    scope: isTelugu ? 'జిల్లా ప్రాజెక్ట్‌లు' : 'District projects',
                    color: Colors.deepOrange,
                  ),
                  _RoleAccessRow(
                    role: isTelugu ? 'సీనియర్ అధికారి' : 'Senior Official',
                    scope: isTelugu ? 'రాష్ట్ర జిల్లాలు' : 'State districts',
                    color: AppColors.riskHigh,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// =============================================================================
// Tab 2: Data Models
// =============================================================================
class _DataModelsTab extends StatelessWidget {
  final bool isTelugu;
  const _DataModelsTab({required this.isTelugu});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ModelCard(
            name: isTelugu ? 'బాలుడు (Child)' : 'Child',
            icon: Icons.child_care,
            fields: const [
              'id: Int (PK)',
              'child_unique_id: String',
              'name: String',
              'dob: Date',
              'gender: String (male/female)',
              'parent_id: Int? → users',
              'awc_id: Int → anganwadi_centres',
              'is_active: Bool',
            ],
          ),
          _ModelCard(
            name: isTelugu ? 'స్క్రీనింగ్ సెషన్' : 'Screening Session',
            icon: Icons.assignment,
            fields: const [
              'id: Int (PK)',
              'child_id: Int → children',
              'conducted_by: UUID → auth.users',
              'assessment_date: Date',
              'child_age_months: Int',
              'status: String (in_progress/completed)',
              'device_session_id: String?',
            ],
          ),
          _ModelCard(
            name: isTelugu ? 'స్క్రీనింగ్ ఫలితం' : 'Screening Result',
            icon: Icons.analytics,
            fields: const [
              'id: Int (PK)',
              'session_id: Int → screening_sessions',
              'child_id: Int → children',
              'overall_risk: String (LOW/MEDIUM/HIGH)',
              'gm_dq, fm_dq, lc_dq, cog_dq, se_dq: Float?',
              'composite_dq: Float?',
              'referral_needed: Bool',
              'tool_results: JSONB',
              'concerns: Text[]',
              'tools_completed: Int',
            ],
          ),
          _ModelCard(
            name: isTelugu ? 'రిఫరల్' : 'Referral',
            icon: Icons.local_hospital,
            fields: const [
              'id: Int (PK)',
              'child_id: Int → children',
              'screening_result_id: Int?',
              'referral_type: String (DEIC/RBSK/PHC)',
              'referral_reason: String',
              'referral_status: String',
              'referred_date: Date?',
            ],
          ),
          _ModelCard(
            name: isTelugu ? 'పోషకాహార అంచనా' : 'Nutrition Assessment',
            icon: Icons.restaurant,
            fields: const [
              'id: Int (PK)',
              'child_id: Int → children',
              'height_cm, weight_kg, muac_cm: Float?',
              'underweight, stunting, wasting, anemia: Bool',
              'nutrition_score: Int',
              'nutrition_risk: String',
            ],
          ),
          _ModelCard(
            name: isTelugu ? 'పర్యావరణ అంచనా' : 'Environment Assessment',
            icon: Icons.home,
            fields: const [
              'id: Int (PK)',
              'child_id: Int → children',
              'parent_child_interaction_score: Int?',
              'parent_mental_health_score: Int?',
              'home_stimulation_score: Int?',
              'play_materials: Bool',
              'safe_water, toilet_facility: Bool',
            ],
          ),
          _ModelCard(
            name: isTelugu ? 'ICDS సోపానక్రమం' : 'ICDS Hierarchy',
            icon: Icons.account_tree,
            fields: const [
              'states → districts → projects',
              '→ sectors → anganwadi_centres',
              '',
              'Each level has: id, name',
              'FK chain enforces hierarchy',
              'Users scoped to their level',
            ],
          ),

          // Sync Architecture
          const SizedBox(height: 16),
          _SectionHeader(
            title: isTelugu ? 'ఆఫ్‌లైన్ సింక్ ఆర్కిటెక్చర్' : 'Offline Sync Architecture',
            icon: Icons.sync,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTelugu
                        ? 'Drift SQLite (స్థానిక) ↔ Supabase PostgreSQL (క్లౌడ్)'
                        : 'Drift SQLite (local) ↔ Supabase PostgreSQL (cloud)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SyncRow(
                    entity: isTelugu ? 'సెషన్' : 'Session',
                    priority: '0',
                    color: AppColors.riskHigh,
                  ),
                  _SyncRow(
                    entity: isTelugu ? 'ప్రతిస్పందనలు' : 'Responses',
                    priority: '1',
                    color: Colors.orange,
                  ),
                  _SyncRow(
                    entity: isTelugu ? 'ఫలితం' : 'Result',
                    priority: '2',
                    color: AppColors.riskMedium,
                  ),
                  _SyncRow(
                    entity: isTelugu ? 'రిఫరల్/పోషణ/పర్యావరణం' : 'Referral/Nutrition/Env',
                    priority: '3',
                    color: AppColors.riskLow,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// =============================================================================
// Tab 3: Interoperability
// =============================================================================
class _InteropTab extends StatelessWidget {
  final bool isTelugu;
  const _InteropTab({required this.isTelugu});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Export Formats
          _SectionHeader(
            title: isTelugu ? 'ఎగుమతి ఫార్మాట్లు' : 'Export Formats',
            icon: Icons.file_download,
          ),
          const SizedBox(height: 8),
          _InteropCard(
            title: 'HL7 FHIR R4',
            icon: Icons.health_and_safety,
            description: isTelugu
                ? 'అంతర్జాతీయ ఆరోగ్య డేటా ప్రమాణం. పిల్లలు → Patient, స్క్రీనింగ్ → Observation, రిఫరల్ → ServiceRequest.'
                : 'International health data standard. Children → Patient, Screening → Observation, Referral → ServiceRequest.',
            format: 'JSON (FHIR Bundle)',
            mappings: isTelugu
                ? const [
                    'బాలుడు → FHIR Patient రీసోర్స్',
                    'DQ స్కోర్లు → Observation.component',
                    'రిస్క్ → Observation.interpretation',
                    'రిఫరల్ → ServiceRequest రీసోర్స్',
                  ]
                : const [
                    'Child → FHIR Patient resource',
                    'DQ Scores → Observation.component',
                    'Risk Level → Observation.interpretation',
                    'Referral → ServiceRequest resource',
                  ],
          ),
          _InteropCard(
            title: isTelugu ? 'పోషన్ ట్రాకర్' : 'Poshan Tracker',
            icon: Icons.restaurant_menu,
            description: isTelugu
                ? 'భారత ప్రభుత్వ పోషకాహార ట్రాకింగ్ వ్యవస్థ. AWC కోడ్, పోషకాహార కొలతలు, అభివృద్ధి ప్రమాదం.'
                : 'Government nutrition tracking system. AWC code, nutrition metrics, developmental risk mapping.',
            format: 'JSON (Poshan Format)',
            mappings: isTelugu
                ? const [
                    'బాలుడు → Beneficiary (AWC కోడ్‌తో)',
                    'పోషణ → ఎత్తు/బరువు/MUAC',
                    'అభివృద్ధి రిస్క్ → అదనపు ఫీల్డ్',
                    'రిఫరల్ → ఫాలో-అప్ సిఫార్సు',
                  ]
                : const [
                    'Child → Beneficiary (with AWC code)',
                    'Nutrition → Height/Weight/MUAC',
                    'Developmental Risk → Additional field',
                    'Referral → Follow-up recommendation',
                  ],
          ),
          _InteropCard(
            title: 'CSV',
            icon: Icons.table_chart,
            description: isTelugu
                ? 'యూనివర్సల్ స్ప్రెడ్‌షీట్ ఫార్మాట్. ఏ డేటా ఎనాలిసిస్ టూల్‌లోనైనా ఇంపోర్ట్ చేయండి.'
                : 'Universal spreadsheet format. Import into any data analysis tool.',
            format: 'CSV (Comma-Separated Values)',
            mappings: isTelugu
                ? const [
                    '22 కాలమ్‌లు: ID, పేరు, వయసు, DQ, రిస్క్...',
                    'Excel, Google Sheets, R, Python లో ఓపెన్',
                    'బల్క్ డేటా ఎనాలిసిస్ కోసం',
                  ]
                : const [
                    '22 columns: ID, Name, Age, DQ, Risk...',
                    'Opens in Excel, Google Sheets, R, Python',
                    'For bulk data analysis',
                  ],
          ),
          _InteropCard(
            title: 'Excel (XLSX)',
            icon: Icons.grid_on,
            description: isTelugu
                ? 'ఒక్క బాలుడి పూర్తి నివేదిక. ప్రొఫైల్, స్క్రీనింగ్ చరిత్ర, DQ చార్ట్‌లు.'
                : 'Individual child report. Profile, screening history, DQ charts.',
            format: 'XLSX (Excel Workbook)',
            mappings: isTelugu
                ? const [
                    'REST API ద్వారా జనరేట్',
                    'డౌన్‌లోడ్స్‌కు సేవ్, షేర్ చేయగలరు',
                    'CDPO/DW నివేదన కోసం',
                  ]
                : const [
                    'Generated via REST API endpoint',
                    'Saves to Downloads, shareable',
                    'For CDPO/DW reporting',
                  ],
          ),
          const SizedBox(height: 20),

          // Integration Points
          _SectionHeader(
            title: isTelugu
                ? 'బాహ్య వ్యవస్థ ఇంటిగ్రేషన్'
                : 'External System Integration',
            icon: Icons.hub,
          ),
          const SizedBox(height: 8),
          _IntegrationCard(
            system: 'RBSK',
            fullName: 'Rashtriya Bal Swasthya Karyakram',
            description: isTelugu
                ? 'ఆరోగ్య తనిఖీ & రిఫరల్ వ్యవస్థ. హై-రిస్క్ పిల్లలను RBSK/DEIC కేంద్రాలకు రిఫర్ చేయి.'
                : 'Health screening & referral system. Refer high-risk children to RBSK/DEIC centres.',
            status: isTelugu ? 'రిఫరల్ ఆటో-ట్రిగ్గర్' : 'Referral auto-trigger',
            color: AppColors.riskHigh,
          ),
          _IntegrationCard(
            system: isTelugu ? 'పోషన్ ట్రాకర్' : 'Poshan Tracker',
            fullName: 'ICDS Nutrition Monitoring',
            description: isTelugu
                ? 'AWC-స్థాయి పోషకాహార డేటా. బరువు, ఎత్తు, MUAC, పోషకాహార ప్రమాద ఫ్లాగ్‌లు ఎగుమతి.'
                : 'AWC-level nutrition data. Export weight, height, MUAC, nutrition risk flags.',
            status: isTelugu ? 'JSON ఎగుమతి సిద్ధం' : 'JSON export ready',
            color: Colors.orange,
          ),
          _IntegrationCard(
            system: 'DEIC',
            fullName: 'District Early Intervention Centre',
            description: isTelugu
                ? 'అభివృద్ధి ఆలస్య జోక్యం. GDD/Autism రిఫరల్‌లతో పూర్తి స్క్రీనింగ్ డేటా.'
                : 'Developmental delay intervention. Full screening data with GDD/Autism referrals.',
            status: isTelugu ? 'FHIR ServiceRequest' : 'FHIR ServiceRequest',
            color: Colors.deepPurple,
          ),
          _IntegrationCard(
            system: 'NHM',
            fullName: 'National Health Mission',
            description: isTelugu
                ? 'జాతీయ ఆరోగ్య నివేదనల కోసం సమగ్ర డేటా. రాష్ట్ర/జిల్లా అగ్రిగేషన్.'
                : 'Aggregate data for national health reporting. State/District aggregation.',
            status: isTelugu ? 'డ్యాష్‌బోర్డ్ RPC' : 'Dashboard RPC',
            color: AppColors.riskLow,
          ),
          const SizedBox(height: 20),

          // Data Standards
          _SectionHeader(
            title: isTelugu ? 'డేటా ప్రమాణాలు' : 'Data Standards',
            icon: Icons.verified,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StandardRow(
                    standard: 'HL7 FHIR R4',
                    usage: isTelugu
                        ? 'ఆరోగ్య డేటా మార్పిడి'
                        : 'Health data exchange',
                  ),
                  _StandardRow(
                    standard: 'ICD-10',
                    usage: isTelugu
                        ? 'రోగనిర్ణయ కోడింగ్ (రిఫరల్‌లు)'
                        : 'Diagnosis coding (referrals)',
                  ),
                  _StandardRow(
                    standard: 'SNOMED CT',
                    usage: isTelugu
                        ? 'క్లినికల్ పరిభాష'
                        : 'Clinical terminology',
                  ),
                  _StandardRow(
                    standard: 'WHO Z-Scores',
                    usage: isTelugu
                        ? 'పోషకాహార అంచనా'
                        : 'Nutrition assessment',
                  ),
                  _StandardRow(
                    standard: 'JWT/OAuth 2.0',
                    usage: isTelugu
                        ? 'ధృవీకరణ & అధికారం'
                        : 'Authentication & authorization',
                  ),
                  _StandardRow(
                    standard: 'PostgREST',
                    usage: isTelugu
                        ? 'RESTful API (Supabase)'
                        : 'RESTful API layer (Supabase)',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// =============================================================================
// Reusable Widgets
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: AppColors.primary, size: 20),
      const SizedBox(width: 8),
      Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ]);
  }
}

class _EndpointCard extends StatelessWidget {
  final String method;
  final String path;
  final String description;
  const _EndpointCard({
    required this.method,
    required this.path,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final methodColor = switch (method) {
      'GET' => AppColors.riskLow,
      'POST' => AppColors.primary,
      'PUT' || 'PATCH' => Colors.orange,
      'DELETE' => AppColors.riskHigh,
      'RPC' => Colors.deepPurple,
      _ => Colors.grey,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: methodColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              method,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  path,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  final String step;
  final String text;
  final bool isLast;
  const _FlowStep({
    required this.step,
    required this.text,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.primary,
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 16,
                color: AppColors.primaryLight,
              ),
          ]),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(text, style: const TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleAccessRow extends StatelessWidget {
  final String role;
  final String scope;
  final Color color;
  const _RoleAccessRow({
    required this.role,
    required this.scope,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 120,
          child: Text(role,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        const Icon(Icons.arrow_right, size: 16, color: AppColors.textSecondary),
        Expanded(
          child: Text(scope,
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ),
      ]),
    );
  }
}

class _ModelCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final List<String> fields;
  const _ModelCard({
    required this.name,
    required this.icon,
    required this.fields,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(name,
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: fields
                  .map((f) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (f.isNotEmpty)
                              const Text('  \u2022 ',
                                  style: TextStyle(
                                      fontFamily: 'monospace', fontSize: 12)),
                            Expanded(
                              child: Text(f,
                                  style: const TextStyle(
                                      fontFamily: 'monospace', fontSize: 12)),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncRow extends StatelessWidget {
  final String entity;
  final String priority;
  final Color color;
  const _SyncRow({
    required this.entity,
    required this.priority,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'P$priority',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(entity, style: const TextStyle(fontSize: 13)),
        ),
        const Icon(Icons.arrow_forward, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          'Supabase',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ]),
    );
  }
}

class _InteropCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final String format;
  final List<String> mappings;
  const _InteropCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.format,
    required this.mappings,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(format,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 8),
            Text(description,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4)),
            const SizedBox(height: 8),
            ...mappings.map((m) => Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Row(children: [
                    const Icon(Icons.subdirectory_arrow_right,
                        size: 14, color: AppColors.riskLow),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(m, style: const TextStyle(fontSize: 12))),
                  ]),
                )),
          ],
        ),
      ),
    );
  }
}

class _IntegrationCard extends StatelessWidget {
  final String system;
  final String fullName;
  final String description;
  final String status;
  final Color color;
  const _IntegrationCard({
    required this.system,
    required this.fullName,
    required this.description,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              system.length > 4
                  ? system.substring(0, 3).toUpperCase()
                  : system.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fullName,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(description,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(status,
                      style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _StandardRow extends StatelessWidget {
  final String standard;
  final String usage;
  const _StandardRow({required this.standard, required this.usage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        const Icon(Icons.check_circle, size: 16, color: AppColors.riskLow),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: Text(standard,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  fontFamily: 'monospace')),
        ),
        Expanded(
          child: Text(usage,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ),
      ]),
    );
  }
}
