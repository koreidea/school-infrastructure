import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App
      'app_name': 'Vidya Nirmaan',
      'app_tagline': 'AI-Powered School Infrastructure Planning',

      // Navigation
      'nav_overview': 'Overview',
      'nav_schools': 'Schools',
      'nav_map': 'Map',
      'nav_validate': 'Validate',
      'nav_analytics': 'Analytics',

      // Dashboard
      'total_schools': 'Total Schools',
      'pending_demands': 'Pending Demands',
      'approved': 'Approved',
      'flagged': 'Flagged',
      'rejected': 'Rejected',
      'total_investment': 'Total Investment',
      'export_excel': 'Export Excel',
      'switch_role': 'Switch Role',

      // Schools
      'search_schools': 'Search schools...',
      'all_districts': 'All Districts',
      'all_mandals': 'All Mandals',
      'all_schools': 'All Schools',
      'no_schools_found': 'No schools found',
      'students': 'students',
      'clear_filters': 'Clear Filters',
      'filtered': 'Filtered',

      // School Profile
      'school_profile': 'School Profile',
      'school_info': 'School Information',
      'udise_code': 'UDISE Code',
      'district': 'District',
      'mandal': 'Mandal',
      'category': 'Category',
      'management': 'Management',
      'total_enrolment': 'Total Enrolment',
      'priority_level': 'Priority Level',
      'priority_score': 'Priority Score',

      // Enrolment
      'enrolment_trend': 'Enrolment Trend',
      'enrolment_forecast': 'Enrolment Forecast',
      'boys': 'Boys',
      'girls': 'Girls',
      'total': 'Total',
      'year': 'Year',
      'growth_rate': 'Growth Rate',
      'forecast': 'Forecast',

      // Infrastructure
      'infra_demand_plans': 'Infrastructure Demand Plans',
      'cwsn_resource_room': 'CWSN Resource Room',
      'cwsn_toilet': 'CWSN Toilet',
      'drinking_water': 'Drinking Water',
      'electrification': 'Electrification',
      'ramps': 'Ramps & Handrails',
      'units': 'Units',
      'cost': 'Cost',
      'score': 'Score',

      // Validation
      'pending': 'Pending',
      'validate_all_pending': 'Validate All Pending',
      'ai_validate': 'AI Validate',
      'ai_validation': 'AI Validation',
      'validation_status': 'Validation Status',
      'confidence': 'Confidence',
      'findings': 'Findings',
      'passed_all_checks': 'Passed all validation checks',

      // Inspection
      'infrastructure_assessment': 'Infrastructure Assessment',
      'existing_infrastructure': 'Existing Infrastructure',
      'num_classrooms': 'Number of Classrooms',
      'num_toilets': 'Number of Toilets',
      'cwsn_facilities': 'CWSN Facilities',
      'cwsn_resource_room_available': 'CWSN Resource Room Available',
      'cwsn_toilet_available': 'CWSN Toilet Available',
      'ramp_available': 'Ramp Available',
      'basic_amenities': 'Basic Amenities',
      'drinking_water_available': 'Drinking Water Available',
      'electrification_status': 'Electrification Status',
      'overall_condition': 'Overall Condition',
      'condition_rating': 'Condition Rating',
      'notes_observations': 'Notes / Observations',
      'submit_assessment': 'Submit Assessment',
      'assessment_submitted': 'Assessment submitted successfully!',
      'add_photos': 'Add Photos',
      'take_photo': 'Take Photo',
      'from_gallery': 'From Gallery',

      // Inspection — Toilet Breakdown
      'toilet_breakdown': 'Toilet Details',
      'boys_toilets': 'Boys Toilets',
      'girls_toilets': 'Girls Toilets',
      'functional_toilets': 'Functional Toilets',
      'handwash_available': 'Handwash Facility Available',

      // Inspection — Classroom Quality
      'classroom_quality': 'Classrooms & Building',
      'functional_classrooms': 'Functional Classrooms',
      'furniture_adequacy': 'Furniture Adequacy',

      // Inspection — Boundary Wall
      'boundary_wall_section': 'Boundary & Security',
      'boundary_wall': 'Boundary Wall',

      // Inspection — Water Source
      'water_source_section': 'Water Supply',
      'water_source_type': 'Water Source Type',
      'water_purifier_available': 'Water Purifier / RO Available',

      // Inspection — Kitchen / MDM
      'mdm_kitchen_section': 'Mid-Day Meal Kitchen',
      'mdm_kitchen_available': 'MDM Kitchen Available',
      'mdm_kitchen_condition': 'Kitchen Condition',

      // Inspection — Library
      'library_section': 'Library & Learning Resources',
      'library_available': 'Library Available',

      // Inspection — Computer Lab
      'computer_lab_section': 'Computer / ICT Lab',
      'computer_lab_available': 'Computer Lab Available',
      'functional_computers': 'Functional Computers',

      // Inspection — Safety
      'safety_section': 'Safety Equipment',
      'fire_extinguisher_available': 'Fire Extinguisher Available',
      'first_aid_available': 'First Aid Kit Available',

      // Inspection — GPS
      'gps_section': 'GPS Location',
      'gps_captured': 'GPS location captured',
      'gps_not_available': 'GPS not captured yet',
      'gps_capturing': 'Capturing GPS...',
      'capture_gps': 'Capture',
      'gps_auto_note': 'GPS will be auto-captured on submit if not manually triggered',

      // Inspection — Condition Ratings
      'condition_ratings_section': 'Condition Ratings',
      'building_condition': 'Building / Roof Condition',
      'toilet_condition': 'Toilet Condition',
      'electrical_condition': 'Electrical Condition',

      // Priority
      'critical': 'Critical',
      'high_priority': 'High Priority',
      'medium_priority': 'Medium Priority',
      'low_priority': 'Low Priority',
      'critical_desc': 'Score > 80 — Severe infrastructure gaps, high enrolment pressure, urgent CWSN needs. Requires immediate intervention.',
      'high_priority_desc': 'Score 60–80 — Significant deficiencies in infrastructure or accessibility. Needs attention in the next planning cycle.',
      'medium_priority_desc': 'Score 40–60 — Moderate gaps identified. Can be addressed through regular budget allocation.',
      'low_priority_desc': 'Score ≤ 40 — Infrastructure is mostly adequate. Minor improvements may be needed.',
      'priority_info_title': 'How Priority Scores are Calculated',
      'priority_info_body': 'Each school receives an AI-computed composite score (0–100). The final score is a weighted sum of 4 factor scores:',
      'enrolment_pressure_calc': 'Enrolment Pressure (30%)',
      'enrolment_pressure_detail': '• Growth rate factor (0–50 pts): >20% growth → 50, >10% → 35, >5% → 20, >0% → 10\n• Student-classroom ratio (0–50 pts): >1.5× norm → 50, >1.2× norm → 35, >norm → 20\n• If no classroom data, uses enrolment size: >300 → 40, >150 → 25, >50 → 15',
      'infra_gap_calc': 'Infrastructure Gap (30%)',
      'infra_gap_detail': '• Demand types coverage (0–60 pts): (number of infra types demanded / 5) × 60\n• Demand volume (0–40 pts): ≥5 units → 40, ≥3 → 25, ≥1 → 15\n• Bonus from field assessment: +5 per missing facility, +15 if critical, +8 if needs repair',
      'cwsn_calc': 'CWSN Needs (20%)',
      'cwsn_detail': '• CWSN Resource Room demand → +35 pts\n• CWSN Toilet demand → +35 pts\n• Ramp demand → +30 pts\n• Bonus +10 each if field assessment confirms facility is missing',
      'accessibility_calc': 'Accessibility (20%)',
      'accessibility_detail': '• Drinking Water demand → +35 pts\n• Electrification demand → +35 pts\n• Ramp demand → +30 pts\n• Bonus from assessment: +10 if no water, +10 if no electricity, +5 if partial, +10 if no ramp',
      'formula_label': 'Final Score = (Enrolment × 0.3) + (InfraGap × 0.3) + (CWSN × 0.2) + (Access × 0.2)',
      'ai_scoring_title': 'AI Priority Scoring',
      'ai_scoring_desc': 'Analyses all schools and computes a composite priority score (0–100) using enrolment data, infrastructure gaps, CWSN needs, and accessibility factors. Schools are then classified into Critical, High, Medium, or Low priority levels to help officers allocate resources effectively.',

      // Analytics
      'infra_demand_by_type': 'Infrastructure Demand by Type',
      'financial_distribution': 'Financial Distribution',
      'key_metrics': 'Key Metrics',
      'district_wise_schools': 'District-wise School Count',
      'avg_per_school': 'Avg per School',
      'approval_rate': 'Approval Rate',

      // Roles
      'role_state_official': 'State Education Director',
      'role_district_officer': 'District Education Officer',
      'role_block_officer': 'Mandal Education Officer',
      'role_school_hm': 'Head Master',
      'role_field_inspector': 'Mandal Education Officer/Inspector',
      'select_role': 'Select Your Role',

      // Map
      'school_map': 'School Map',
      'map_legend': 'Legend',

      // OTP Login
      'login_title': 'Login with OTP',
      'phone_or_email_hint': 'Enter phone number or email',
      'send_otp': 'Send OTP',
      'enter_otp': 'Enter 6-digit OTP',
      'verify_login': 'Verify & Login',
      'otp_sent_to': 'OTP sent to',
      'demo_otp_hint': 'Demo mode: enter any OTP to login',
      'quick_demo_login': 'Quick Demo Login',
      'tap_to_login_instantly': 'Tap a role to pre-fill credentials',
      'select_your_role': 'Select Your Role',
      'phone_number': 'Phone Number',
      'invalid_phone': 'Enter a valid 10-digit phone number or email',
      'logging_in': 'Logging in...',
      'change_number': 'Change',

      // Navigation (extended)
      'nav_inspect': 'Inspect',

      // Dashboard (extended)
      'backend_online': 'ML Backend Online — AI-Enhanced validation active',
      'backend_offline': 'ML Backend Offline — Using rule-based validation',
      'ai_label': 'AI',
      'rules_label': 'Rules',
      'excel_exported': 'Excel exported successfully',
      'export_failed': 'Export failed',
      'assessments_pending_sync': 'assessment(s) pending sync',
      'field_inspections': 'Field Inspections',
      'no_schools_assigned': 'No schools assigned for inspection',

      // School Profile (extended)
      'field_inspection': 'Field Inspection',
      'export_pdf': 'Export PDF',
      'pdf_exported': 'PDF exported',
      'location': 'Location',
      'coordinates': 'Coordinates',
      'enrolment': 'Enrolment',
      'priority_score_breakdown': 'Priority Score Breakdown',
      'enrolment_pressure': 'Enrolment Pressure',
      'infrastructure_gap': 'Infrastructure Gap',
      'cwsn_needs': 'CWSN Needs',
      'accessibility': 'Accessibility',
      'ai_enhanced': 'AI-Enhanced',
      'rule_based': 'Rule-Based',
      'client_side_extrapolation': 'Client-side linear extrapolation',
      'tap_forecast': 'Tap "Forecast" to predict enrolment for the next 3 years based on historical trends.',
      'running': 'Running...',
      'historical': 'Historical',
      'no_forecast_data': 'No forecast data available',
      'ml_backend_offline': 'ML Backend Offline',
      'start_backend_hint': 'Start the Python server to enable ML-powered forecasting:\n./start_backend.sh',

      // Infrastructure Forecast
      'infra_requirement_forecast': 'Infrastructure Requirement Forecast',
      'projected_needs_subtitle': 'Projected needs based on enrolment forecast + Samagra Shiksha norms',
      'run_forecast_first': 'Run forecast first to see infrastructure projections.',

      // Budget Planner
      'budget_allocation_planner': 'Budget Allocation Planner',
      'budget_strategies_subtitle': '3 allocation strategies based on demand plans & forecasts',
      'no_demand_plans_budget': 'No demand plans available for budget planning.',
      'conservative': 'Conservative',
      'balanced': 'Balanced',
      'growth_oriented': 'Growth-Oriented',

      // Repair & Maintenance
      'repair_maintenance_forecast': 'Repair & Maintenance Forecast',
      'inspection_history': 'Inspection History',
      'no_inspection_data': 'No inspection data available',
      'total_estimated_maintenance': 'Total estimated maintenance',

      // Analytics (extended)
      'infrastructure_analytics': 'Infrastructure Analytics',
      'demand_by_infra_type': 'Demand by Infrastructure Type',
      'financial_allocation': 'Financial Allocation (₹ Lakhs)',
      'district_wise_distribution': 'District-wise School Distribution',
      'validation_status_breakdown': 'Validation Status Breakdown',
      'demographics_analysis': 'Demographics & Attendance Analysis',
      'ai_model_performance': 'AI Model Performance',
      'data_governance': 'Data Governance & Privacy',
      'proportional': 'Proportional',
      'priority_first': 'Priority-First',
      'cwsn_first': 'CWSN-First',
      'budget_cap': 'Budget Cap',
      'production': 'Production',
      'failed_to_load': 'Failed to load',

      // Validation (extended)
      'validating': 'Validating...',
      'approve': 'Approve',
      'flag': 'Flag',
      'reject': 'Reject',
      'running_ai_validation': 'Running AI validation...',
      'validated_by': 'Validated by',
      'not_yet_reviewed': 'Not yet reviewed',

      // HM Dashboard
      'hm_my_school': 'My School',
      'hm_my_requests': 'My Requests',
      'hm_infra_status': 'Infrastructure Status',
      'hm_available': 'Available',
      'hm_missing': 'Missing',
      'hm_no_assessment': 'No field assessment on record yet',
      'hm_raise_request': 'Raise Request',
      'hm_infra_type': 'Infrastructure Type',
      'hm_quantity': 'Quantity',
      'hm_estimated_cost': 'Estimated Cost',
      'hm_plan_year': 'Plan Year',
      'hm_justification': 'Justification / Notes',
      'hm_submit_request': 'Submit Request',
      'hm_request_submitted': 'Request submitted successfully!',
      'hm_request_saved_offline': 'Request saved offline — will sync when connected',
      'hm_duplicate_warning': 'A similar pending request already exists for this type and year. Continue anyway?',
      'hm_cancel_request': 'Cancel Request',
      'hm_cancel_confirm': 'Are you sure you want to cancel this request?',
      'hm_view_full_profile': 'View Full Profile',
      'hm_no_requests': 'No infrastructure requests yet',
      'hm_no_requests_hint': 'Tap + to raise your first request',
      'hm_priority_explanation': 'Your school\'s priority score determines resource allocation',
      'hm_per_unit': 'per unit',
      'hm_enrolment_snapshot': 'Enrolment Snapshot',
      'hm_priority_breakdown': 'Priority Score Breakdown',
      'hm_pending_sync': 'request(s) pending sync',
      'hm_auto_cost': 'Auto-calculated from unit cost × quantity',

      // General
      'loading': 'Loading...',
      'error': 'Error',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'retry': 'Retry',
      'offline_mode': 'Offline Mode',
      'last_synced': 'Last synced',
      'sync_now': 'Sync Now',
    },
    'te': {
      // App
      'app_name': 'విద్యా నిర్మాణ్',
      'app_tagline': 'AI-ఆధారిత పాఠశాల మౌలిక సదుపాయాల ప్రణాళిక',

      // Navigation
      'nav_overview': 'అవలోకనం',
      'nav_schools': 'పాఠశాలలు',
      'nav_map': 'మ్యాప్',
      'nav_validate': 'ధ్రువీకరణ',
      'nav_analytics': 'విశ్లేషణలు',

      // Dashboard
      'total_schools': 'మొత్తం పాఠశాలలు',
      'pending_demands': 'పెండింగ్ డిమాండ్లు',
      'approved': 'ఆమోదించబడింది',
      'flagged': 'ఫ్లాగ్ చేయబడింది',
      'rejected': 'తిరస్కరించబడింది',
      'total_investment': 'మొత్తం పెట్టుబడి',
      'export_excel': 'Excel ఎగుమతి',
      'switch_role': 'పాత్ర మార్చు',

      // Schools
      'search_schools': 'పాఠశాలలు వెతకండి...',
      'all_districts': 'అన్ని జిల్లాలు',
      'all_mandals': 'అన్ని మండలాలు',
      'all_schools': 'అన్ని పాఠశాలలు',
      'no_schools_found': 'పాఠశాలలు కనుగొనబడలేదు',
      'students': 'విద్యార్థులు',
      'clear_filters': 'ఫిల్టర్లు తీసివేయి',
      'filtered': 'ఫిల్టర్ చేయబడింది',

      // School Profile
      'school_profile': 'పాఠశాల ప్రొఫైల్',
      'school_info': 'పాఠశాల సమాచారం',
      'udise_code': 'UDISE కోడ్',
      'district': 'జిల్లా',
      'mandal': 'మండలం',
      'category': 'వర్గం',
      'management': 'నిర్వహణ',
      'total_enrolment': 'మొత్తం నమోదు',
      'priority_level': 'ప్రాధాన్యత స్థాయి',
      'priority_score': 'ప్రాధాన్యత స్కోర్',

      // Enrolment
      'enrolment_trend': 'నమోదు ధోరణి',
      'enrolment_forecast': 'నమోదు అంచనా',
      'boys': 'బాలురు',
      'girls': 'బాలికలు',
      'total': 'మొత్తం',
      'year': 'సంవత్సరం',
      'growth_rate': 'వృద్ధి రేటు',
      'forecast': 'అంచనా',

      // Infrastructure
      'infra_demand_plans': 'మౌలిక సదుపాయాల డిమాండ్ ప్రణాళికలు',
      'cwsn_resource_room': 'CWSN వనరుల గది',
      'cwsn_toilet': 'CWSN మరుగుదొడ్డి',
      'drinking_water': 'తాగునీరు',
      'electrification': 'విద్యుదీకరణ',
      'ramps': 'ర్యాంప్‌లు & హ్యాండ్‌రెయిల్స్',
      'units': 'యూనిట్లు',
      'cost': 'ఖర్చు',
      'score': 'స్కోర్',

      // Validation
      'pending': 'పెండింగ్',
      'validate_all_pending': 'అన్ని పెండింగ్ ధ్రువీకరించు',
      'ai_validate': 'AI ధ్రువీకరణ',
      'ai_validation': 'AI ధ్రువీకరణ',
      'validation_status': 'ధ్రువీకరణ స్థితి',
      'confidence': 'విశ్వాసం',
      'findings': 'నిర్ధారణలు',
      'passed_all_checks': 'అన్ని ధ్రువీకరణ తనిఖీలు ఉత్తీర్ణం',

      // Inspection
      'infrastructure_assessment': 'మౌలిక సదుపాయాల అంచనా',
      'existing_infrastructure': 'ఉన్న మౌలిక సదుపాయాలు',
      'num_classrooms': 'తరగతి గదుల సంఖ్య',
      'num_toilets': 'మరుగుదొడ్ల సంఖ్య',
      'cwsn_facilities': 'CWSN సదుపాయాలు',
      'cwsn_resource_room_available': 'CWSN వనరుల గది అందుబాటులో ఉంది',
      'cwsn_toilet_available': 'CWSN మరుగుదొడ్డి అందుబాటులో ఉంది',
      'ramp_available': 'ర్యాంప్ అందుబాటులో ఉంది',
      'basic_amenities': 'ప్రాథమిక సౌకర్యాలు',
      'drinking_water_available': 'తాగునీరు అందుబాటులో ఉంది',
      'electrification_status': 'విద్యుదీకరణ స్థితి',
      'overall_condition': 'మొత్తం పరిస్థితి',
      'condition_rating': 'పరిస్థితి రేటింగ్',
      'notes_observations': 'గమనికలు / పరిశీలనలు',
      'submit_assessment': 'అంచనా సమర్పించు',
      'assessment_submitted': 'అంచనా విజయవంతంగా సమర్పించబడింది!',
      'add_photos': 'ఫోటోలు జోడించు',
      'take_photo': 'ఫోటో తీయండి',
      'from_gallery': 'గ్యాలరీ నుండి',

      // Inspection — Toilet Breakdown
      'toilet_breakdown': 'మరుగుదొడ్డి వివరాలు',
      'boys_toilets': 'బాలుర మరుగుదొడ్లు',
      'girls_toilets': 'బాలికల మరుగుదొడ్లు',
      'functional_toilets': 'పనిచేసే మరుగుదొడ్లు',
      'handwash_available': 'చేతులు కడుక్కునే సౌకర్యం అందుబాటులో ఉంది',

      // Inspection — Classroom Quality
      'classroom_quality': 'తరగతి గదులు & భవనం',
      'functional_classrooms': 'పనిచేసే తరగతి గదులు',
      'furniture_adequacy': 'ఫర్నిచర్ తగినంత',

      // Inspection — Boundary Wall
      'boundary_wall_section': 'ప్రహరీ గోడ & భద్రత',
      'boundary_wall': 'ప్రహరీ గోడ',

      // Inspection — Water Source
      'water_source_section': 'నీటి సరఫరా',
      'water_source_type': 'నీటి వనరు రకం',
      'water_purifier_available': 'నీటి శుద్ధి యంత్రం / RO అందుబాటులో ఉంది',

      // Inspection — Kitchen / MDM
      'mdm_kitchen_section': 'మధ్యాహ్న భోజన వంటగది',
      'mdm_kitchen_available': 'MDM వంటగది అందుబాటులో ఉంది',
      'mdm_kitchen_condition': 'వంటగది పరిస్థితి',

      // Inspection — Library
      'library_section': 'గ్రంథాలయం & అధ్యయన వనరులు',
      'library_available': 'గ్రంథాలయం అందుబాటులో ఉంది',

      // Inspection — Computer Lab
      'computer_lab_section': 'కంప్యూటర్ / ICT ల్యాబ్',
      'computer_lab_available': 'కంప్యూటర్ ల్యాబ్ అందుబాటులో ఉంది',
      'functional_computers': 'పనిచేసే కంప్యూటర్లు',

      // Inspection — Safety
      'safety_section': 'భద్రతా పరికరాలు',
      'fire_extinguisher_available': 'అగ్నిమాపక యంత్రం అందుబాటులో ఉంది',
      'first_aid_available': 'ప్రథమ చికిత్స కిట్ అందుబాటులో ఉంది',

      // Inspection — GPS
      'gps_section': 'GPS స్థానం',
      'gps_captured': 'GPS స్థానం సేకరించబడింది',
      'gps_not_available': 'GPS ఇంకా సేకరించబడలేదు',
      'gps_capturing': 'GPS సేకరిస్తోంది...',
      'capture_gps': 'సేకరించు',
      'gps_auto_note': 'మాన్యువల్‌గా సేకరించకపోతే సమర్పణ సమయంలో GPS స్వయంచాలకంగా సేకరించబడుతుంది',

      // Inspection — Condition Ratings
      'condition_ratings_section': 'పరిస్థితి రేటింగ్‌లు',
      'building_condition': 'భవనం / పైకప్పు పరిస్థితి',
      'toilet_condition': 'మరుగుదొడ్డి పరిస్థితి',
      'electrical_condition': 'విద్యుత్ పరిస్థితి',

      // Priority
      'critical': 'క్లిష్టమైన',
      'high_priority': 'అధిక ప్రాధాన్యత',
      'medium_priority': 'మధ్యస్థ ప్రాధాన్యత',
      'low_priority': 'తక్కువ ప్రాధాన్యత',
      'critical_desc': 'స్కోరు > 80 — తీవ్రమైన మౌలిక సదుపాయ లోటులు, అధిక నమోదు ఒత్తిడి, అత్యవసర CWSN అవసరాలు. తక్షణ జోక్యం అవసరం.',
      'high_priority_desc': 'స్కోరు 60–80 — మౌలిక సదుపాయాలు లేదా ప్రాప్యతలో గణనీయమైన లోపాలు. తదుపరి ప్రణాళిక చక్రంలో శ్రద్ధ అవసరం.',
      'medium_priority_desc': 'స్కోరు 40–60 — మధ్యస్థ లోటులు గుర్తించబడ్డాయి. సాధారణ బడ్జెట్ కేటాయింపు ద్వారా పరిష్కరించవచ్చు.',
      'low_priority_desc': 'స్కోరు ≤ 40 — మౌలిక సదుపాయాలు చాలా వరకు తగినవి. చిన్న మెరుగుదలలు అవసరం కావచ్చు.',
      'priority_info_title': 'ప్రాధాన్యత స్కోర్లు ఎలా లెక్కించబడతాయి',
      'priority_info_body': 'ప్రతి పాఠశాలకు AI-కంప్యూటెడ్ సమ్మిళిత స్కోరు (0–100) లభిస్తుంది. చివరి స్కోరు 4 కారక స్కోర్ల వెయిటెడ్ మొత్తం:',
      'enrolment_pressure_calc': 'నమోదు ఒత్తిడి (30%)',
      'enrolment_pressure_detail': '• వృద్ధి రేటు (0–50 pts): >20% → 50, >10% → 35, >5% → 20, >0% → 10\n• విద్యార్థి-తరగతి గది నిష్పత్తి (0–50 pts): >1.5× నిబంధన → 50, >1.2× → 35, >నిబంధన → 20\n• తరగతి గది డేటా లేకపోతే, నమోదు పరిమాణం ఉపయోగిస్తుంది: >300 → 40, >150 → 25, >50 → 15',
      'infra_gap_calc': 'మౌలిక సదుపాయ లోటు (30%)',
      'infra_gap_detail': '• డిమాండ్ రకాల కవరేజ్ (0–60 pts): (డిమాండ్ చేసిన రకాలు / 5) × 60\n• డిమాండ్ పరిమాణం (0–40 pts): ≥5 యూనిట్లు → 40, ≥3 → 25, ≥1 → 15\n• ఫీల్డ్ అంచనా బోనస్: తప్పిపోయిన సౌకర్యానికి +5, క్లిష్టమైతే +15, మరమ్మత్తు అవసరమైతే +8',
      'cwsn_calc': 'CWSN అవసరాలు (20%)',
      'cwsn_detail': '• CWSN రిసోర్స్ రూమ్ డిమాండ్ → +35 pts\n• CWSN టాయిలెట్ డిమాండ్ → +35 pts\n• ర్యాంప్ డిమాండ్ → +30 pts\n• ఫీల్డ్ అంచనా సౌకర్యం లేదని నిర్ధారిస్తే +10 బోనస్',
      'accessibility_calc': 'ప్రాప్యత (20%)',
      'accessibility_detail': '• త్రాగునీటి డిమాండ్ → +35 pts\n• విద్యుదీకరణ డిమాండ్ → +35 pts\n• ర్యాంప్ డిమాండ్ → +30 pts\n• అంచనా బోనస్: నీరు లేకపోతే +10, విద్యుత్ లేకపోతే +10, పాక్షికమైతే +5, ర్యాంప్ లేకపోతే +10',
      'formula_label': 'చివరి స్కోరు = (నమోదు × 0.3) + (మౌలిక లోటు × 0.3) + (CWSN × 0.2) + (ప్రాప్యత × 0.2)',
      'ai_scoring_title': 'AI ప్రాధాన్యత స్కోరింగ్',
      'ai_scoring_desc': 'అన్ని పాఠశాలలను విశ్లేషించి నమోదు డేటా, మౌలిక సదుపాయ లోటులు, CWSN అవసరాలు మరియు ప్రాప్యత కారకాలను ఉపయోగించి సమ్మిళిత ప్రాధాన్యత స్కోరు (0–100) లెక్కిస్తుంది. వనరులను సమర్థవంతంగా కేటాయించడంలో అధికారులకు సహాయపడటానికి పాఠశాలలు క్లిష్టమైన, అధిక, మధ్యస్థ లేదా తక్కువ ప్రాధాన్యత స్థాయిలుగా వర్గీకరించబడతాయి.',

      // Analytics
      'infra_demand_by_type': 'రకం వారీగా మౌలిక డిమాండ్',
      'financial_distribution': 'ఆర్థిక పంపిణీ',
      'key_metrics': 'కీలక కొలమానాలు',
      'district_wise_schools': 'జిల్లా వారీగా పాఠశాల లెక్క',
      'avg_per_school': 'పాఠశాలకు సగటు',
      'approval_rate': 'ఆమోద రేటు',

      // Roles
      'role_state_official': 'రాష్ట్ర విద్యా డైరెక్టర్',
      'role_district_officer': 'జిల్లా విద్యాధికారి',
      'role_block_officer': 'మండల విద్యాధికారి',
      'role_school_hm': 'ప్రధానోపాధ్యాయులు',
      'role_field_inspector': 'మండల విద్యాధికారి/తనిఖీదారు',
      'select_role': 'మీ పాత్రను ఎంచుకోండి',

      // Map
      'school_map': 'పాఠశాల మ్యాప్',
      'map_legend': 'సూచన',

      // OTP Login
      'login_title': 'OTP తో లాగిన్',
      'phone_or_email_hint': 'ఫోన్ నంబర్ లేదా ఇమెయిల్ నమోదు చేయండి',
      'send_otp': 'OTP పంపు',
      'enter_otp': '6-అంకెల OTP నమోదు చేయండి',
      'verify_login': 'ధ్రువీకరించి లాగిన్',
      'otp_sent_to': 'OTP పంపబడింది',
      'demo_otp_hint': 'డెమో మోడ్: ఏ OTP అయినా లాగిన్ అవ్వవచ్చు',
      'quick_demo_login': 'క్విక్ డెమో లాగిన్',
      'tap_to_login_instantly': 'క్రెడెన్షియల్స్ ముందుగా నింపడానికి పాత్ర నొక్కండి',
      'select_your_role': 'మీ పాత్రను ఎంచుకోండి',
      'phone_number': 'ఫోన్ నంబర్',
      'invalid_phone': 'చెల్లుబాటు అయ్యే 10-అంకెల ఫోన్ నంబర్ లేదా ఇమెయిల్ నమోదు చేయండి',
      'logging_in': 'లాగిన్ అవుతోంది...',
      'change_number': 'మార్చు',

      // Navigation (extended)
      'nav_inspect': 'తనిఖీ',

      // Dashboard (extended)
      'backend_online': 'ML బ్యాకెండ్ ఆన్‌లైన్ — AI-మెరుగైన ధ్రువీకరణ సక్రియం',
      'backend_offline': 'ML బ్యాకెండ్ ఆఫ్‌లైన్ — నియమ-ఆధారిత ధ్రువీకరణ',
      'ai_label': 'AI',
      'rules_label': 'నియమాలు',
      'excel_exported': 'Excel విజయవంతంగా ఎగుమతి చేయబడింది',
      'export_failed': 'ఎగుమతి విఫలమైంది',
      'assessments_pending_sync': 'అంచనా(లు) సమకాలీకరణ పెండింగ్‌లో ఉన్నాయి',
      'field_inspections': 'క్షేత్ర తనిఖీలు',
      'no_schools_assigned': 'తనిఖీ కోసం పాఠశాలలు కేటాయించబడలేదు',

      // School Profile (extended)
      'field_inspection': 'క్షేత్ర తనిఖీ',
      'export_pdf': 'PDF ఎగుమతి',
      'pdf_exported': 'PDF ఎగుమతి చేయబడింది',
      'location': 'ప్రాంతం',
      'coordinates': 'కోఆర్డినేట్లు',
      'enrolment': 'నమోదు',
      'priority_score_breakdown': 'ప్రాధాన్యత స్కోర్ విశ్లేషణ',
      'enrolment_pressure': 'నమోదు ఒత్తిడి',
      'infrastructure_gap': 'మౌలిక అంతరం',
      'cwsn_needs': 'CWSN అవసరాలు',
      'accessibility': 'ప్రాప్యత',
      'ai_enhanced': 'AI-మెరుగుపరచబడింది',
      'rule_based': 'నియమ-ఆధారితం',
      'client_side_extrapolation': 'క్లయింట్-వైపు సరళ ఎక్స్‌ట్రాపోలేషన్',
      'tap_forecast': 'రాబోయే 3 సంవత్సరాల నమోదును అంచనా వేయడానికి "అంచనా" నొక్కండి.',
      'running': 'నడుస్తోంది...',
      'historical': 'చరిత్ర',
      'no_forecast_data': 'అంచనా డేటా అందుబాటులో లేదు',
      'ml_backend_offline': 'ML బ్యాకెండ్ ఆఫ్‌లైన్',
      'start_backend_hint': 'ML-ఆధారిత అంచనా కోసం Python సర్వర్‌ని ప్రారంభించండి:\n./start_backend.sh',

      // Infrastructure Forecast
      'infra_requirement_forecast': 'మౌలిక అవసరాల అంచనా',
      'projected_needs_subtitle': 'నమోదు అంచనా + సమగ్ర శిక్ష నిబంధనల ఆధారంగా అంచనా',
      'run_forecast_first': 'మౌలిక అంచనాలు చూడటానికి ముందు అంచనా అమలు చేయండి.',

      // Budget Planner
      'budget_allocation_planner': 'బడ్జెట్ కేటాయింపు ప్లానర్',
      'budget_strategies_subtitle': 'డిమాండ్ ప్లాన్‌లు & అంచనాల ఆధారంగా 3 కేటాయింపు వ్యూహాలు',
      'no_demand_plans_budget': 'బడ్జెట్ ప్లానింగ్ కోసం డిమాండ్ ప్లాన్‌లు అందుబాటులో లేవు.',
      'conservative': 'సంప్రదాయ',
      'balanced': 'సమతుల్య',
      'growth_oriented': 'వృద్ధి-ఆధారిత',

      // Repair & Maintenance
      'repair_maintenance_forecast': 'మరమ్మత్తు & నిర్వహణ అంచనా',
      'inspection_history': 'తనిఖీ చరిత్ర',
      'no_inspection_data': 'తనిఖీ డేటా అందుబాటులో లేదు',
      'total_estimated_maintenance': 'మొత్తం అంచనా నిర్వహణ',

      // Analytics (extended)
      'infrastructure_analytics': 'మౌలిక సదుపాయాల విశ్లేషణలు',
      'demand_by_infra_type': 'రకం వారీగా మౌలిక డిమాండ్',
      'financial_allocation': 'ఆర్థిక కేటాయింపు (₹ లక్షలు)',
      'district_wise_distribution': 'జిల్లా వారీగా పాఠశాల పంపిణీ',
      'validation_status_breakdown': 'ధ్రువీకరణ స్థితి విభజన',
      'demographics_analysis': 'జనాభా & హాజరు విశ్లేషణ',
      'ai_model_performance': 'AI మోడల్ పనితీరు',
      'data_governance': 'డేటా పాలన & గోప్యత',
      'proportional': 'అనుపాత',
      'priority_first': 'ప్రాధాన్యత-ముందు',
      'cwsn_first': 'CWSN-ముందు',
      'budget_cap': 'బడ్జెట్ పరిమితి',
      'production': 'ఉత్పత్తి',
      'failed_to_load': 'లోడ్ చేయడం విఫలమైంది',

      // Validation (extended)
      'validating': 'ధ్రువీకరిస్తోంది...',
      'approve': 'ఆమోదించు',
      'flag': 'ఫ్లాగ్',
      'reject': 'తిరస్కరించు',
      'running_ai_validation': 'AI ధ్రువీకరణ అమలవుతోంది...',
      'validated_by': 'ధ్రువీకరించినది',
      'not_yet_reviewed': 'ఇంకా సమీక్షించబడలేదు',

      // HM Dashboard
      'hm_my_school': 'నా పాఠశాల',
      'hm_my_requests': 'నా అభ్యర్థనలు',
      'hm_infra_status': 'మౌలిక సదుపాయాల స్థితి',
      'hm_available': 'అందుబాటులో ఉంది',
      'hm_missing': 'లేదు',
      'hm_no_assessment': 'ఇంకా క్షేత్ర అంచనా నమోదు కాలేదు',
      'hm_raise_request': 'అభ్యర్థన చేయండి',
      'hm_infra_type': 'మౌలిక సదుపాయ రకం',
      'hm_quantity': 'పరిమాణం',
      'hm_estimated_cost': 'అంచనా ఖర్చు',
      'hm_plan_year': 'ప్రణాళిక సంవత్సరం',
      'hm_justification': 'సమర్థన / గమనికలు',
      'hm_submit_request': 'అభ్యర్థన సమర్పించు',
      'hm_request_submitted': 'అభ్యర్థన విజయవంతంగా సమర్పించబడింది!',
      'hm_request_saved_offline': 'అభ్యర్థన ఆఫ్‌లైన్‌లో సేవ్ చేయబడింది — కనెక్ట్ అయినప్పుడు సమకాలీకరించబడుతుంది',
      'hm_duplicate_warning': 'ఈ రకం మరియు సంవత్సరానికి ఇప్పటికే ఇలాంటి పెండింగ్ అభ్యర్థన ఉంది. కొనసాగించాలా?',
      'hm_cancel_request': 'అభ్యర్థన రద్దు',
      'hm_cancel_confirm': 'మీరు ఈ అభ్యర్థనను రద్దు చేయాలనుకుంటున్నారా?',
      'hm_view_full_profile': 'పూర్తి ప్రొఫైల్ చూడండి',
      'hm_no_requests': 'ఇంకా మౌలిక సదుపాయ అభ్యర్థనలు లేవు',
      'hm_no_requests_hint': 'మీ మొదటి అభ్యర్థనను చేయడానికి + నొక్కండి',
      'hm_priority_explanation': 'మీ పాఠశాల ప్రాధాన్యత స్కోరు వనరుల కేటాయింపును నిర్ణయిస్తుంది',
      'hm_per_unit': 'యూనిట్‌కు',
      'hm_enrolment_snapshot': 'నమోదు స్నాప్‌షాట్',
      'hm_priority_breakdown': 'ప్రాధాన్యత స్కోర్ విశ్లేషణ',
      'hm_pending_sync': 'అభ్యర్థన(లు) సమకాలీకరణ పెండింగ్',
      'hm_auto_cost': 'యూనిట్ ఖర్చు × పరిమాణం నుండి స్వయంచాలకంగా లెక్కించబడింది',

      // General
      'loading': 'లోడ్ అవుతోంది...',
      'error': 'లోపం',
      'ok': 'సరే',
      'cancel': 'రద్దు',
      'save': 'సేవ్',
      'delete': 'తొలగించు',
      'retry': 'మళ్ళీ ప్రయత్నించు',
      'offline_mode': 'ఆఫ్‌లైన్ మోడ్',
      'last_synced': 'చివరిగా సమకాలీకరించబడింది',
      'sync_now': 'ఇప్పుడు సమకాలీకరించు',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  // Convenience getters for common strings
  String get appName => translate('app_name');
  String get appTagline => translate('app_tagline');
  String get navOverview => translate('nav_overview');
  String get navSchools => translate('nav_schools');
  String get navMap => translate('nav_map');
  String get navValidate => translate('nav_validate');
  String get navAnalytics => translate('nav_analytics');
  String get searchSchools => translate('search_schools');
  String get allDistricts => translate('all_districts');
  String get allMandals => translate('all_mandals');
  String get noSchoolsFound => translate('no_schools_found');
  String get clearFilters => translate('clear_filters');
  String get submitAssessment => translate('submit_assessment');
  String get addPhotos => translate('add_photos');
  String get takePhoto => translate('take_photo');
  String get fromGallery => translate('from_gallery');
  String get loading => translate('loading');
  String get offlineMode => translate('offline_mode');
  String get syncNow => translate('sync_now');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'te'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
