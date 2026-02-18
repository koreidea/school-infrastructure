import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../config/api_config.dart';

/// Service for exporting child data to Excel and saving to device Downloads folder
class ExcelExportService {
  static final ExcelExportService _instance = ExcelExportService._internal();
  factory ExcelExportService() => _instance;
  ExcelExportService._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.fullBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Export child data to Excel and save to Downloads folder
  /// 
  /// [childId] - The ID of the child to export
  /// [childName] - Optional child name for the filename
  /// [context] - BuildContext for showing messages
  /// 
  /// Returns a [ExportResult] with file path and status
  Future<ExportResult> exportChildToDownloads(
    int childId, {
    String? childName,
    BuildContext? context,
    bool isTelugu = false,
  }) async {
    if (kIsWeb) {
      return ExportResult(
        success: false,
        errorMessage: isTelugu
            ? 'వెబ్‌లో ఎగుమతి అందుబాటులో లేదు'
            : 'Export not supported on web',
      );
    }
    try {
      // Step 1: Check and request storage permissions
      final permissionResult = await _requestStoragePermissions();
      if (!permissionResult.isGranted) {
        return ExportResult(
          success: false,
          errorMessage: permissionResult.errorMessage ??
              (isTelugu
                  ? 'స్టోరేజ్ అనుమతి అవసరం'
                  : 'Storage permission is required to save files'),
        );
      }

      // Step 2: Get the appropriate downloads directory
      final directory = await _getDownloadsDirectory();
      if (directory == null) {
        return ExportResult(
          success: false,
          errorMessage: isTelugu
              ? 'డౌన్‌లోడ్స్ ఫోల్డర్‌ను కనుగొనలేకపోయాము'
              : 'Could not find Downloads folder',
        );
      }

      // Step 3: Generate filename
      final filename = _generateFilename(childName);

      // Step 4: Download file bytes from backend
      final bytes = await _downloadExcelBytes(childId);

      // Step 5: Save file to Downloads
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      // Step 6: Notify media scanner (Android only) so file appears in Downloads
      if (Platform.isAndroid) {
        await _notifyMediaScanner(filePath);
      }

      // Verify file was saved
      if (!await file.exists()) {
        return ExportResult(
          success: false,
          errorMessage: isTelugu
              ? 'ఫైల్ సేవ్ చేయడంలో విఫలమైంది'
              : 'Failed to save file',
        );
      }

      return ExportResult(
        success: true,
        filePath: filePath,
        fileName: filename,
        message: isTelugu
            ? 'నివేదిక విజయవంతంగా డౌన్‌లోడ్స్‌కు సేవ్ చేయబడింది'
            : 'Report saved to Downloads successfully',
      );
    } on DioException catch (e) {
      String errorMsg;
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('detail')) {
          errorMsg = data['detail'];
        } else {
          errorMsg = isTelugu
              ? 'సర్వర్ లోపం: ${e.response?.statusCode}'
              : 'Server error: ${e.response?.statusCode}';
        }
      } else {
        errorMsg = isTelugu
            ? 'నెట్‌వర్క్ లోపం: ${e.message}'
            : 'Network error: ${e.message}';
      }
      return ExportResult(success: false, errorMessage: errorMsg);
    } catch (e) {
      return ExportResult(
        success: false,
        errorMessage: isTelugu
            ? 'ఎగుమతి విఫలమైంది: $e'
            : 'Export failed: $e',
      );
    }
  }

  /// Request necessary storage permissions based on Android version
  Future<PermissionRequestResult> _requestStoragePermissions() async {
    if (!Platform.isAndroid) {
      // iOS doesn't need explicit permission for app documents
      return PermissionRequestResult(isGranted: true);
    }

    final sdkInt = await _getAndroidSdkInt();

    if (sdkInt != null && sdkInt >= 33) {
      // Android 13+ (API 33+): Use granular media permissions
      // For saving to Downloads, we need to request manage external storage
      // or use the Storage Access Framework
      
      // First, try regular storage permission for app-specific directories
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        return PermissionRequestResult(isGranted: true);
      }

      // If storage permission denied, check if we can use manage external storage
      final manageStatus = await Permission.manageExternalStorage.request();
      if (manageStatus.isGranted) {
        return PermissionRequestResult(isGranted: true);
      }

      // If still denied, check if we should show rationale
      if (await Permission.storage.shouldShowRequestRationale) {
        return PermissionRequestResult(
          isGranted: false,
          errorMessage:
              'Storage permission is needed to save files to Downloads folder',
        );
      }

      return PermissionRequestResult(
        isGranted: false,
        errorMessage:
            'Please enable storage permission in app settings to save files',
      );
    } else if (sdkInt != null && sdkInt >= 30) {
      // Android 11-12 (API 30-32): Request manage external storage for broad access
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        return PermissionRequestResult(isGranted: true);
      }

      // Try manage external storage permission
      final manageStatus = await Permission.manageExternalStorage.request();
      if (manageStatus.isGranted) {
        return PermissionRequestResult(isGranted: true);
      }

      return PermissionRequestResult(
        isGranted: false,
        errorMessage:
            'Storage permission denied. Please enable in app settings.',
      );
    } else {
      // Android 10 and below (API <= 29): Use legacy storage permission
      final status = await Permission.storage.request();
      if (status.isGranted) {
        return PermissionRequestResult(isGranted: true);
      }

      return PermissionRequestResult(
        isGranted: false,
        errorMessage:
            'Storage permission is required to save files to Downloads',
      );
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
      // Default to a safe assumption if we can't determine
      return 29;
    }
  }

  /// Get the appropriate Downloads directory
  Future<Directory?> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // Try multiple approaches to get the Downloads folder

      // Approach 1: Standard Downloads path
      final standardDownloads = Directory('/storage/emulated/0/Download');
      if (await standardDownloads.exists()) {
        return standardDownloads;
      }

      // Approach 2: Try alternative Downloads paths
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

      // Approach 3: Use getExternalStorageDirectory and navigate to Downloads
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        // Try to find Downloads in parent directory
        final parentDir = externalDir.parent;
        final downloadsFromParent = Directory('${parentDir.path}/Download');
        if (await downloadsFromParent.exists()) {
          return downloadsFromParent;
        }

        // Fallback: Create a Downloads folder in external storage root
        final fallbackDownloads = Directory('${parentDir.path}/Download');
        if (!await fallbackDownloads.exists()) {
          try {
            await fallbackDownloads.create(recursive: true);
            return fallbackDownloads;
          } catch (e) {
            // Failed to create, continue to next fallback
          }
        }

        // Last resort: use external storage root
        return parentDir;
      }

      // Approach 4: Use application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final appDownloads = Directory('${appDir.path}/Downloads');
      if (!await appDownloads.exists()) {
        await appDownloads.create(recursive: true);
      }
      return appDownloads;
    } else {
      // iOS: Use documents directory with Downloads subdirectory
      final docsDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${docsDir.path}/Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      return downloadsDir;
    }
  }

  /// Generate a user-friendly filename
  String _generateFilename(String? childName) {
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

  /// Download Excel file bytes from backend
  Future<List<int>> _downloadExcelBytes(int childId) async {
    final response = await _dio.post(
      ApiConfig.exportChild.replaceAll('{childId}', childId.toString()),
      options: Options(
        responseType: ResponseType.bytes,
        headers: _authToken != null
            ? {'Authorization': 'Bearer $_authToken'}
            : null,
      ),
    );

    if (response.data == null) {
      throw Exception('No data received from server');
    }

    return response.data as List<int>;
  }

  /// Notify Android media scanner so file appears in Downloads app
  Future<void> _notifyMediaScanner(String filePath) async {
    try {
      // Create a simple .nomedia file check
      final file = File(filePath);
      if (await file.exists()) {
        // The file exists, it should be visible in file managers
        // For Android 10+, we rely on the file being in the Downloads folder
        // which is automatically scanned
      }
    } catch (e) {
      // Silently ignore scanner errors
    }
  }

  /// Share the exported Excel file
  Future<void> shareExportedFile(
    String filePath, {
    String? childName,
    bool isTelugu = false,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception(
        isTelugu ? 'ఫైల్ కనుగొనబడలేదు' : 'File not found',
      );
    }

    final shareText = childName != null && childName.isNotEmpty
        ? (isTelugu ? 'బాల Vikas నివేదిక: $childName' : 'Bal Vikas Report: $childName')
        : (isTelugu ? 'బాల Vikas నివేదిక' : 'Bal Vikas Report');

    await Share.shareXFiles(
      [XFile(filePath)],
      text: shareText,
      subject: isTelugu ? 'బాల Vikas బాలుడి నివేదిక' : 'Bal Vikas Child Report',
    );
  }

  /// Open the exported file with default application
  Future<OpenResult> openExportedFile(String filePath) async {
    final result = await OpenFile.open(filePath);
    return result;
  }

  /// Show export dialog with loading, success, and error states
  Future<void> showExportDialog({
    required BuildContext context,
    required int childId,
    String? childName,
    bool isTelugu = false,
    VoidCallback? onSuccess,
  }) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(isTelugu
                ? 'నివేదిక ఎగుమతి చేస్తోంది...'
                : 'Exporting report...'),
          ],
        ),
      ),
    );

    // Perform export
    final result = await exportChildToDownloads(
      childId,
      childName: childName,
      context: context,
      isTelugu: isTelugu,
    );

    // Close loading dialog
    if (context.mounted) {
      Navigator.pop(context);
    }

    // Show result dialog
    if (context.mounted) {
      if (result.success) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text(isTelugu ? 'విజయవంతం!' : 'Success!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.message ??
                    (isTelugu
                        ? 'నివేదిక డౌన్‌లోడ్స్‌కు సేవ్ చేయబడింది'
                        : 'Report saved to Downloads')),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTelugu ? 'ఫైల్ పేరు:' : 'File:',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        result.fileName ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isTelugu ? 'స్థానం:' : 'Location:',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        result.filePath ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(isTelugu ? 'మూసివేయి' : 'Close'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await shareExportedFile(
                    result.filePath!,
                    childName: childName,
                    isTelugu: isTelugu,
                  );
                },
                icon: const Icon(Icons.share),
                label: Text(isTelugu ? 'భాగస్వామ్యం చేయి' : 'Share'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final openResult = await openExportedFile(result.filePath!);
                  if (openResult.type != ResultType.done && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isTelugu
                            ? 'ఫైల్ తెరవడం సాధ్యపడలేదు'
                            : 'Could not open file'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.open_in_new),
                label: Text(isTelugu ? 'తెరువు' : 'Open'),
              ),
            ],
          ),
        );

        onSuccess?.call();
      } else {
        // Show error dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red.shade600),
                const SizedBox(width: 8),
                Text(isTelugu ? 'లోపం' : 'Error'),
              ],
            ),
            content: Text(result.errorMessage ??
                (isTelugu ? 'ఎగుమతి విఫలమైంది' : 'Export failed')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(isTelugu ? 'సరే' : 'OK'),
              ),
              if (result.errorMessage?.contains('permission') ?? false)
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await openAppSettings();
                  },
                  child: Text(isTelugu ? 'సెట్టింగ్స్‌కు వెళ్ళండి' : 'Open Settings'),
                ),
            ],
          ),
        );
      }
    }
  }
}

/// Result of an export operation
class ExportResult {
  final bool success;
  final String? filePath;
  final String? fileName;
  final String? message;
  final String? errorMessage;

  ExportResult({
    required this.success,
    this.filePath,
    this.fileName,
    this.message,
    this.errorMessage,
  });
}

/// Result of a permission request
class PermissionRequestResult {
  final bool isGranted;
  final String? errorMessage;

  PermissionRequestResult({
    required this.isGranted,
    this.errorMessage,
  });
}

// Singleton instance
final excelExportService = ExcelExportService();
