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
      'app_name': 'Vidya Soudha',
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

      // Priority
      'critical': 'Critical',
      'high_priority': 'High Priority',
      'medium_priority': 'Medium Priority',
      'low_priority': 'Low Priority',

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
      'role_field_inspector': 'Field Inspector',
      'select_role': 'Select Your Role',

      // Map
      'school_map': 'School Map',
      'map_legend': 'Legend',

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
      'app_name': 'విద్యా సౌధ',
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

      // Priority
      'critical': 'క్లిష్టమైన',
      'high_priority': 'అధిక ప్రాధాన్యత',
      'medium_priority': 'మధ్యస్థ ప్రాధాన్యత',
      'low_priority': 'తక్కువ ప్రాధాన్యత',

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
      'role_field_inspector': 'క్షేత్ర తనిఖీదారు',
      'select_role': 'మీ పాత్రను ఎంచుకోండి',

      // Map
      'school_map': 'పాఠశాల మ్యాప్',
      'map_legend': 'సూచన',

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
