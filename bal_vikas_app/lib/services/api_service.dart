import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'package:intl/intl.dart';

// Riverpod provider for ApiService
final apiServiceProvider = Provider<ApiService>((ref) => apiService);

class ApiService {
  late Dio _dio;
  String? _authToken;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.fullBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        return handler.next(error);
      },
    ));
  }
  
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  void clearAuthToken() {
    _authToken = null;
  }
  
  /// Get the current auth token
  String? get authToken => _authToken;
  
  // Auth APIs
  Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    try {
      final response = await _dio.post(
        ApiConfig.sendOtp,
        data: {'mobile_number': mobileNumber},
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> verifyOtp(String mobileNumber, String otp) async {
    try {
      final response = await _dio.post(
        ApiConfig.verifyOtp,
        data: {
          'mobile_number': mobileNumber,
          'otp': otp,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<User> getProfile() async {
    try {
      final response = await _dio.get(ApiConfig.profile);
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Update user role after selection
  Future<User> updateUserRole(String roleCode) async {
    try {
      final response = await _dio.post(
        ApiConfig.updateRole,
        data: {'role_code': roleCode},
      );
      // Backend returns {message, user} - extract user object
      return User.fromJson(response.data['user']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Update user profile (name, email, photo)
  Future<User> updateProfile({
    required String name,
    String? email,
    File? profileImage,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'name': name,
        if (email != null) 'email': email,
      });

      if (profileImage != null) {
        formData.files.add(
          MapEntry(
            'profile_photo',
            await MultipartFile.fromFile(
              profileImage.path,
              filename: 'profile_photo.jpg',
            ),
          ),
        );
      }

      final response = await _dio.put(
        ApiConfig.updateProfile,
        data: formData,
      );
      // Backend returns {message, user} - extract user object
      return User.fromJson(response.data['user']);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Children APIs
  Future<List<Child>> getChildren() async {
    try {
      final response = await _dio.get(ApiConfig.children);
      return (response.data as List)
          .map((json) => Child.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get child details with all stats
  Future<Map<String, dynamic>> getChildDetails(int childId) async {
    try {
      final response = await _dio.get('${ApiConfig.children}/$childId/details');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Child> getChild(int childId) async {
    try {
      final response = await _dio.get('${ApiConfig.children}/$childId');
      return Child.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Child> createChild(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiConfig.children, data: data);
      return Child.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Screening APIs
  Future<ScreeningSession> startScreening(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiConfig.screeningStart, data: data);
      return ScreeningSession.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> saveResponse(int sessionId, Map<String, dynamic> data) async {
    try {
      await _dio.post(
        ApiConfig.screeningResponses.replaceAll('{sessionId}', sessionId.toString()),
        data: data,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> completeScreening(
    int sessionId,
    Map<String, dynamic> measurements,
  ) async {
    try {
      final response = await _dio.post(
        ApiConfig.screeningComplete.replaceAll('{sessionId}', sessionId.toString()),
        data: measurements,
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getScreeningDetails(int sessionId) async {
    try {
      final response = await _dio.get(
        ApiConfig.screeningDetails.replaceAll('{sessionId}', sessionId.toString()),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<Map<String, dynamic>>> getChildScreenings(int childId) async {
    try {
      final response = await _dio.get(
        ApiConfig.childScreenings.replaceAll('{childId}', childId.toString()),
      );
      return (response.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Questionnaire APIs
  Future<Map<String, dynamic>> getLatestQuestionnaire() async {
    try {
      final response = await _dio.get(ApiConfig.latestQuestionnaire);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Intervention APIs
  Future<List<Map<String, dynamic>>> getRecommendedActivities(int childId) async {
    try {
      final response = await _dio.get(
        ApiConfig.recommendInterventions.replaceAll('{childId}', childId.toString()),
      );
      return (response.data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Export child data to Excel and save to device Downloads folder
  /// 
  /// This method requests storage permissions, downloads the Excel file from backend,
  /// and saves it to the device's Downloads folder with a user-friendly filename.
  /// 
  /// [childId] - The ID of the child to export
  /// [childName] - Optional child name for the filename
  /// 
  /// Returns the saved file path
  Future<String> exportChildExcel(int childId, {String? childName}) async {
    if (kIsWeb) {
      throw UnsupportedError('Excel export is not supported on web');
    }
    try {
      // Step 1: Request storage permissions
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception(
          'Storage permission denied. Please enable storage permission in app settings to save files.'
        );
      }

      // Step 2: Download Excel bytes from backend
      final response = await _dio.post(
        ApiConfig.exportChild.replaceAll('{childId}', childId.toString()),
        options: Options(responseType: ResponseType.bytes),
      );
      
      final bytes = response.data as List<int>;
      
      // Step 3: Generate filename with child name and date
      final fileName = _generateExportFileName(childName);
      
      // Step 4: Get Downloads directory
      final downloadsDir = await _getDownloadsDirectory();
      
      // Step 5: Save file to Downloads
      final filePath = '${downloadsDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);
      
      // Verify file was saved
      if (!await file.exists()) {
        throw Exception('Failed to save file to Downloads folder');
      }
      
      return filePath;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Request storage permissions for Android
  /// 
  /// For Android 10 (API 29) and below: requests WRITE_EXTERNAL_STORAGE
  /// For Android 11+ (API 30+): requests MANAGE_EXTERNAL_STORAGE if available
  Future<bool> _requestStoragePermission() async {
    if (!Platform.isAndroid) {
      // iOS doesn't need explicit permission for app documents
      return true;
    }

    final sdkInt = await _getAndroidSdkInt();

    if (sdkInt != null && sdkInt >= 30) {
      // Android 11+ (API 30+): Try storage permission first, then manage external storage
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        return true;
      }

      // Try manage external storage for broader access
      final manageStatus = await Permission.manageExternalStorage.request();
      return manageStatus.isGranted;
    } else {
      // Android 10 and below: Use legacy storage permission
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }
  
  /// Get Android SDK version
  Future<int?> _getAndroidSdkInt() async {
    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.version.sdkInt;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Get the Downloads directory for saving files
  Future<Directory> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // Try standard Downloads path
      final standardDownloads = Directory('/storage/emulated/0/Download');
      if (await standardDownloads.exists()) {
        return standardDownloads;
      }

      // Try alternative paths
      final alternativePaths = [
        '/storage/emulated/0/Downloads',
        '/sdcard/Download',
        '/sdcard/Downloads',
      ];

      for (final path in alternativePaths) {
        final dir = Directory(path);
        if (await dir.exists()) {
          return dir;
        }
      }

      // Fallback to external storage directory
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final downloadsDir = Directory('${externalDir.parent.path}/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        return downloadsDir;
      }

      // Final fallback: app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      return appDir;
    } else {
      // iOS: Use documents directory
      final docsDir = await getApplicationDocumentsDirectory();
      return docsDir;
    }
  }
  
  /// Generate a user-friendly filename for export
  String _generateExportFileName(String? childName) {
    final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
    final safeChildName = childName?.trim() ?? '';
    
    if (safeChildName.isNotEmpty) {
      // Clean the child name for filename
      final cleanName = safeChildName
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .replaceAll(RegExp(r'\s+'), '_');
      return 'BalVikas_${cleanName}_$dateStr.xlsx';
    }
    
    return 'BalVikas_Report_$dateStr.xlsx';
  }
  
  /// Share the exported Excel file
  Future<void> shareExportedFile(String filePath, {String? childName}) async {
    if (kIsWeb) {
      throw UnsupportedError('File sharing is not supported on web');
    }
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found at: $filePath');
      }
      
      final shareText = childName != null && childName.isNotEmpty
          ? 'Bal Vikas Report: $childName' 
          : 'Bal Vikas Report';
      
      await Share.shareXFiles(
        [XFile(filePath)],
        text: shareText,
        subject: 'Bal Vikas Child Report',
      );
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response?.data;
        if (data is Map && data.containsKey('detail')) {
          return Exception(data['detail']);
        }
        return Exception('Server error: ${error.response?.statusCode}');
      }
      return Exception('Network error: ${error.message}');
    }
    return Exception('Unknown error: $error');
  }
}

// Singleton instance
final apiService = ApiService();
