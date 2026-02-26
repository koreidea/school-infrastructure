import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/demand_plan.dart';

/// HTTP client for Python ML backend
class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.fullBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// Forecast enrolment for a school
  static Future<Map<String, dynamic>> forecastEnrolment(
      int schoolId, {int yearsAhead = 1}) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.forecastEnrolment}/$schoolId',
        queryParameters: {'years_ahead': yearsAhead},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Forecast failed: ${e.message}');
    }
  }

  /// Batch forecast for all schools
  static Future<Map<String, dynamic>> batchForecast({int yearsAhead = 1}) async {
    try {
      final response = await _dio.post(
        ApiConfig.forecastBatch,
        data: {'years_ahead': yearsAhead},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Batch forecast failed: ${e.message}');
    }
  }

  /// Validate demand plans using ML
  static Future<Map<String, dynamic>> validateDemandPlans(
      List<DemandPlan> plans) async {
    try {
      final response = await _dio.post(
        ApiConfig.validateDemandPlan,
        data: {
          'demands': plans.map((p) => <String, dynamic>{
              'school_id': p.schoolId,
              'infra_type': p.infraType,
              'physical_count': p.physicalCount,
              'financial_amount': p.financialAmount,
              'school_category': null,
              'total_enrolment': null,
            }).toList(),
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Validation failed: ${e.message}');
    }
  }

  /// Batch validate all pending demand plans
  static Future<Map<String, dynamic>> batchValidate() async {
    try {
      final response = await _dio.post(ApiConfig.validateBatch);
      return response.data;
    } on DioException catch (e) {
      throw Exception('Batch validation failed: ${e.message}');
    }
  }

  /// Get district analytics
  static Future<Map<String, dynamic>> getDistrictAnalytics(
      int districtId) async {
    try {
      final response =
          await _dio.get('${ApiConfig.analyticsDistrict}/$districtId');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Analytics failed: ${e.message}');
    }
  }

  /// Get state analytics
  static Future<Map<String, dynamic>> getStateAnalytics() async {
    try {
      final response = await _dio.get(ApiConfig.analyticsState);
      return response.data;
    } on DioException catch (e) {
      throw Exception('State analytics failed: ${e.message}');
    }
  }

  /// Health check
  static Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.data['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }
}
