import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Interoperability service for exporting data in standard formats
/// (FHIR, Poshan Tracker, CSV) and providing integration points
/// with external government health systems.
class InteroperabilityService {
  static final InteroperabilityService _instance =
      InteroperabilityService._internal();
  factory InteroperabilityService() => _instance;
  InteroperabilityService._internal();

  // ---------------------------------------------------------------------------
  // FHIR R4 Mapping
  // ---------------------------------------------------------------------------

  /// Convert a child record to a FHIR R4 Patient resource JSON
  static Map<String, dynamic> childToFhirPatient(Map<String, dynamic> child) {
    final dob = child['dob'] ?? child['date_of_birth'] ?? '';
    final gender = (child['gender'] ?? 'unknown').toString().toLowerCase();

    return {
      'resourceType': 'Patient',
      'id': child['child_unique_id'] ?? 'BV-${child['id']}',
      'meta': {
        'profile': [
          'http://hl7.org/fhir/StructureDefinition/Patient',
        ],
        'source': 'BalVikas-ECD-Platform',
      },
      'identifier': [
        {
          'system': 'https://balvikas.gov.in/child-id',
          'value': child['child_unique_id'] ?? '',
        },
      ],
      'active': child['is_active'] ?? true,
      'name': [
        {
          'use': 'official',
          'text': child['name'] ?? '',
        },
      ],
      'gender': gender == 'male'
          ? 'male'
          : gender == 'female'
              ? 'female'
              : 'unknown',
      'birthDate': dob.toString().split('T')[0],
      'managingOrganization': {
        'reference': 'Organization/AWC-${child['awc_id'] ?? ''}',
        'display': 'Anganwadi Centre ${child['awc_id'] ?? ''}',
      },
    };
  }

  /// Convert a screening result to a FHIR R4 Observation resource JSON
  static Map<String, dynamic> screeningToFhirObservation(
      Map<String, dynamic> result, Map<String, dynamic> child) {
    final components = <Map<String, dynamic>>[];

    // Add DQ scores as components
    for (final domain in ['gm', 'fm', 'lc', 'cog', 'se']) {
      final dqKey = '${domain}_dq';
      final dqValue = result[dqKey];
      if (dqValue != null) {
        components.add({
          'code': {
            'coding': [
              {
                'system': 'https://balvikas.gov.in/dq-domain',
                'code': domain.toUpperCase(),
                'display': _domainDisplayName(domain),
              },
            ],
          },
          'valueQuantity': {
            'value': dqValue,
            'unit': 'DQ',
            'system': 'https://balvikas.gov.in/units',
          },
        });
      }
    }

    // Add composite DQ
    if (result['composite_dq'] != null) {
      components.add({
        'code': {
          'coding': [
            {
              'system': 'https://balvikas.gov.in/dq-domain',
              'code': 'COMPOSITE',
              'display': 'Composite DQ',
            },
          ],
        },
        'valueQuantity': {
          'value': result['composite_dq'],
          'unit': 'DQ',
          'system': 'https://balvikas.gov.in/units',
        },
      });
    }

    return {
      'resourceType': 'Observation',
      'id': 'screening-${result['id'] ?? result['session_id']}',
      'meta': {
        'profile': [
          'http://hl7.org/fhir/StructureDefinition/Observation',
        ],
        'source': 'BalVikas-ECD-Platform',
      },
      'status': 'final',
      'category': [
        {
          'coding': [
            {
              'system':
                  'http://terminology.hl7.org/CodeSystem/observation-category',
              'code': 'survey',
              'display': 'Survey',
            },
          ],
        },
      ],
      'code': {
        'coding': [
          {
            'system': 'https://balvikas.gov.in/screening',
            'code': 'ECD_SCREENING',
            'display': 'Early Childhood Development Screening',
          },
        ],
      },
      'subject': {
        'reference':
            'Patient/${child['child_unique_id'] ?? 'BV-${child['id']}'}',
        'display': child['name'] ?? '',
      },
      'effectiveDateTime': result['assessment_date'] ??
          result['created_at'] ??
          DateTime.now().toIso8601String(),
      'valueCodeableConcept': {
        'coding': [
          {
            'system': 'https://balvikas.gov.in/risk-level',
            'code': result['overall_risk'] ?? 'UNKNOWN',
            'display': _riskDisplayName(result['overall_risk'] ?? ''),
          },
        ],
      },
      'interpretation': [
        {
          'coding': [
            {
              'system':
                  'http://terminology.hl7.org/CodeSystem/v3-ObservationInterpretation',
              'code': _fhirInterpretationCode(result['overall_risk'] ?? ''),
              'display': _riskDisplayName(result['overall_risk'] ?? ''),
            },
          ],
        },
      ],
      'component': components,
    };
  }

  /// Convert a referral to a FHIR R4 ServiceRequest resource JSON
  static Map<String, dynamic> referralToFhirServiceRequest(
      Map<String, dynamic> referral, Map<String, dynamic> child) {
    return {
      'resourceType': 'ServiceRequest',
      'id': 'referral-${referral['id']}',
      'meta': {
        'source': 'BalVikas-ECD-Platform',
      },
      'status': _fhirRequestStatus(referral['referral_status'] ?? 'Pending'),
      'intent': 'order',
      'priority': referral['referral_type'] == 'DEIC' ? 'urgent' : 'routine',
      'code': {
        'coding': [
          {
            'system': 'https://balvikas.gov.in/referral-type',
            'code': referral['referral_type'] ?? '',
            'display':
                _referralTypeDisplay(referral['referral_type'] ?? ''),
          },
        ],
      },
      'subject': {
        'reference':
            'Patient/${child['child_unique_id'] ?? 'BV-${child['id']}'}',
        'display': child['name'] ?? '',
      },
      'reasonCode': [
        {
          'coding': [
            {
              'system': 'https://balvikas.gov.in/referral-reason',
              'code': referral['referral_reason'] ?? '',
              'display': referral['referral_reason'] ?? '',
            },
          ],
        },
      ],
      'authoredOn': referral['referred_date'] ??
          DateTime.now().toIso8601String().split('T')[0],
      'note': referral['notes'] != null
          ? [
              {'text': referral['notes']}
            ]
          : [],
    };
  }

  // ---------------------------------------------------------------------------
  // Poshan Tracker Format
  // ---------------------------------------------------------------------------

  /// Convert child + screening data to Poshan Tracker-compatible format
  static Map<String, dynamic> toPoshanTrackerFormat(
      Map<String, dynamic> child, Map<String, dynamic>? latestResult) {
    final dob = child['dob'] ?? child['date_of_birth'] ?? '';
    final ageMonths = _calculateAgeMonths(dob.toString());

    final data = <String, dynamic>{
      // Beneficiary identification
      'beneficiary_id': child['child_unique_id'] ?? '',
      'beneficiary_name': child['name'] ?? '',
      'date_of_birth': dob.toString().split('T')[0],
      'gender': child['gender'] ?? '',
      'age_months': ageMonths,
      'awc_code': child['centre_code'] ?? child['awc_id']?.toString() ?? '',
      'registration_date':
          (child['created_at'] ?? DateTime.now().toIso8601String())
              .toString()
              .split('T')[0],

      // Growth monitoring (from nutrition assessment if available)
      'height_cm': latestResult?['height_cm'],
      'weight_kg': latestResult?['weight_kg'],
      'muac_cm': latestResult?['muac_cm'],

      // Nutrition flags
      'underweight': latestResult?['underweight'] ?? false,
      'stunting': latestResult?['stunting'] ?? false,
      'wasting': latestResult?['wasting'] ?? false,
      'anemia': latestResult?['anemia'] ?? false,

      // Developmental screening
      'screening_date': latestResult?['assessment_date'],
      'developmental_risk': latestResult?['overall_risk'],
      'composite_dq': latestResult?['composite_dq'],
      'referral_needed': latestResult?['referral_needed'] ?? false,

      // Source system
      'source_system': 'BalVikas-ECD',
      'export_timestamp': DateTime.now().toIso8601String(),
    };

    return data;
  }

  // ---------------------------------------------------------------------------
  // CSV Export
  // ---------------------------------------------------------------------------

  /// Export children + screening data as CSV string
  static String exportChildrenToCsv(
      List<Map<String, dynamic>> children,
      Map<int, Map<String, dynamic>> latestResults) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln(
        'Child ID,Name,DOB,Gender,Age (Months),AWC Code,'
        'Screening Date,Overall Risk,Composite DQ,'
        'GM DQ,FM DQ,LC DQ,COG DQ,SE DQ,'
        'Referral Needed,Referral Type,'
        'Height (cm),Weight (kg),MUAC (cm),'
        'Underweight,Stunting,Wasting');

    for (final child in children) {
      final childId =
          child['id'] ?? child['child_id'] ?? child['remote_id'] ?? 0;
      final result = latestResults[childId];
      final dob = child['dob'] ?? child['date_of_birth'] ?? '';

      buffer.writeln([
        _csvEscape(child['child_unique_id'] ?? ''),
        _csvEscape(child['name'] ?? ''),
        dob.toString().split('T')[0],
        child['gender'] ?? '',
        _calculateAgeMonths(dob.toString()),
        _csvEscape(child['centre_code'] ?? child['awc_id']?.toString() ?? ''),
        result?['assessment_date'] ?? '',
        result?['overall_risk'] ?? '',
        result?['composite_dq']?.toString() ?? '',
        result?['gm_dq']?.toString() ?? '',
        result?['fm_dq']?.toString() ?? '',
        result?['lc_dq']?.toString() ?? '',
        result?['cog_dq']?.toString() ?? '',
        result?['se_dq']?.toString() ?? '',
        result?['referral_needed']?.toString() ?? 'false',
        result?['referral_type'] ?? '',
        result?['height_cm']?.toString() ?? '',
        result?['weight_kg']?.toString() ?? '',
        result?['muac_cm']?.toString() ?? '',
        result?['underweight']?.toString() ?? '',
        result?['stunting']?.toString() ?? '',
        result?['wasting']?.toString() ?? '',
      ].join(','));
    }

    return buffer.toString();
  }

  // ---------------------------------------------------------------------------
  // FHIR Bundle Export
  // ---------------------------------------------------------------------------

  /// Create a FHIR Bundle containing all children and their screenings
  static Map<String, dynamic> createFhirBundle(
      List<Map<String, dynamic>> children,
      Map<int, List<Map<String, dynamic>>> screeningResults) {
    final entries = <Map<String, dynamic>>[];

    for (final child in children) {
      // Add Patient resource
      entries.add({
        'fullUrl':
            'urn:uuid:patient-${child['child_unique_id'] ?? child['id']}',
        'resource': childToFhirPatient(child),
        'request': {
          'method': 'PUT',
          'url':
              'Patient/${child['child_unique_id'] ?? 'BV-${child['id']}'}',
        },
      });

      // Add Observation resources for each screening
      final childId = child['id'] ?? child['child_id'] ?? 0;
      final results = screeningResults[childId] ?? [];
      for (final result in results) {
        entries.add({
          'fullUrl':
              'urn:uuid:observation-${result['id'] ?? result['session_id']}',
          'resource': screeningToFhirObservation(result, child),
          'request': {
            'method': 'PUT',
            'url':
                'Observation/screening-${result['id'] ?? result['session_id']}',
          },
        });
      }
    }

    return {
      'resourceType': 'Bundle',
      'type': 'transaction',
      'meta': {
        'source': 'BalVikas-ECD-Platform',
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      'total': entries.length,
      'entry': entries,
    };
  }

  // ---------------------------------------------------------------------------
  // File Export & Sharing
  // ---------------------------------------------------------------------------

  /// Export data to a file and return the file path
  static Future<String> exportToFile({
    required String content,
    required String filename,
    required String format,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('File export not supported on web');
    }
    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${dir.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fullFilename = '${filename}_$dateStr.$format';
    final file = File('${exportDir.path}/$fullFilename');
    await file.writeAsString(content, flush: true);
    return file.path;
  }

  /// Export children data as CSV file and share
  static Future<String> exportAndShareCsv({
    required List<Map<String, dynamic>> children,
    required Map<int, Map<String, dynamic>> latestResults,
    String filename = 'BalVikas_Export',
  }) async {
    final csv = exportChildrenToCsv(children, latestResults);
    final path =
        await exportToFile(content: csv, filename: filename, format: 'csv');
    await Share.shareXFiles([XFile(path)],
        text: 'Bal Vikas ECD Data Export',
        subject: 'Bal Vikas Children Data');
    return path;
  }

  /// Export FHIR Bundle as JSON file and share
  static Future<String> exportAndShareFhir({
    required List<Map<String, dynamic>> children,
    required Map<int, List<Map<String, dynamic>>> screeningResults,
    String filename = 'BalVikas_FHIR',
  }) async {
    final bundle = createFhirBundle(children, screeningResults);
    final json = const JsonEncoder.withIndent('  ').convert(bundle);
    final path =
        await exportToFile(content: json, filename: filename, format: 'json');
    await Share.shareXFiles([XFile(path)],
        text: 'Bal Vikas ECD FHIR Bundle',
        subject: 'Bal Vikas FHIR Export');
    return path;
  }

  /// Export Poshan Tracker format data and share
  static Future<String> exportAndSharePoshanTracker({
    required List<Map<String, dynamic>> children,
    required Map<int, Map<String, dynamic>> latestResults,
    String filename = 'BalVikas_Poshan',
  }) async {
    final records = <Map<String, dynamic>>[];
    for (final child in children) {
      final childId = child['id'] ?? child['child_id'] ?? 0;
      records.add(toPoshanTrackerFormat(child, latestResults[childId]));
    }
    final json = const JsonEncoder.withIndent('  ').convert({
      'source': 'BalVikas-ECD-Platform',
      'export_date': DateTime.now().toIso8601String(),
      'record_count': records.length,
      'beneficiaries': records,
    });
    final path = await exportToFile(
        content: json, filename: filename, format: 'json');
    await Share.shareXFiles([XFile(path)],
        text: 'Bal Vikas Poshan Tracker Export',
        subject: 'Poshan Tracker Data');
    return path;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static String _domainDisplayName(String code) {
    switch (code) {
      case 'gm':
        return 'Gross Motor';
      case 'fm':
        return 'Fine Motor';
      case 'lc':
        return 'Language & Communication';
      case 'cog':
        return 'Cognitive';
      case 'se':
        return 'Social-Emotional';
      default:
        return code.toUpperCase();
    }
  }

  static String _riskDisplayName(String risk) {
    switch (risk) {
      case 'LOW':
        return 'Low Risk';
      case 'MEDIUM':
        return 'Medium Risk';
      case 'MEDIUM-HIGH':
        return 'Medium-High Risk';
      case 'HIGH':
        return 'High Risk';
      default:
        return 'Unknown';
    }
  }

  static String _fhirInterpretationCode(String risk) {
    switch (risk) {
      case 'LOW':
        return 'N'; // Normal
      case 'MEDIUM':
        return 'L'; // Low abnormal
      case 'MEDIUM-HIGH':
        return 'H'; // High abnormal
      case 'HIGH':
        return 'HH'; // Critical high
      default:
        return 'N';
    }
  }

  static String _fhirRequestStatus(String status) {
    switch (status) {
      case 'Pending':
        return 'active';
      case 'In Progress':
        return 'active';
      case 'Completed':
        return 'completed';
      default:
        return 'active';
    }
  }

  static String _referralTypeDisplay(String type) {
    switch (type) {
      case 'DEIC':
        return 'District Early Intervention Centre';
      case 'RBSK':
        return 'Rashtriya Bal Swasthya Karyakram';
      case 'PHC':
        return 'Primary Health Centre';
      case 'AWW_INTERVENTION':
        return 'Anganwadi Worker Intervention';
      default:
        return type;
    }
  }

  static int _calculateAgeMonths(String dobStr) {
    try {
      final dob = DateTime.parse(dobStr.split('T')[0]);
      final now = DateTime.now();
      return (now.year - dob.year) * 12 + (now.month - dob.month);
    } catch (_) {
      return 0;
    }
  }

  static String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
