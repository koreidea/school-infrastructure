import 'dart:convert';
import 'dart:developer' as dev;
import 'database_service.dart';
import 'storage_service.dart';

/// Static utility for logging audit events (DPDP compliance).
///
/// Records who accessed, modified, or exported child data.
/// Logs are stored locally in Drift and synced to Supabase.
class AuditService {
  static void _log(String msg) {
    dev.log(msg, name: 'Audit');
  }

  /// Log a data access or modification event.
  static Future<void> log({
    required String action,
    required String entityType,
    int? entityId,
    String? entityName,
    Map<String, dynamic>? details,
  }) async {
    try {
      final user = await StorageService.getUser();
      if (user == null) return;

      final userId = user.supabaseId ?? '${user.userId}';
      final userRole = user.roleCode ?? user.roleName;

      final localId = await DatabaseService.db.dpdpDao.logAction(
        userId: userId,
        userRole: userRole,
        action: action,
        entityType: entityType,
        entityId: entityId,
        entityName: entityName,
        detailsJson: details != null ? jsonEncode(details) : null,
      );

      // Enqueue for sync (low priority — audit logs can sync later)
      await DatabaseService.db.syncQueueDao.enqueue(
        entityType: 'audit_log',
        entityLocalId: localId,
        operation: 'insert',
        priority: 4,
      );

      _log('$action on $entityType${entityId != null ? ' #$entityId' : ''}'
          '${entityName != null ? ' ($entityName)' : ''}');
    } catch (e) {
      _log('Failed to log audit event: $e');
    }
  }
}
