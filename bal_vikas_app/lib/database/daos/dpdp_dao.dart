import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/dpdp_tables.dart';

part 'dpdp_dao.g.dart';

@DriftAccessor(tables: [LocalConsents, LocalAuditLogs, LocalDataGovernanceConfig])
class DpdpDao extends DatabaseAccessor<AppDatabase> with _$DpdpDaoMixin {
  DpdpDao(super.db);

  // ---- Consent Management ----

  Future<int> insertConsent(LocalConsentsCompanion consent) {
    return into(localConsents).insert(consent);
  }

  /// Get the most recent active (non-revoked) consent for a child.
  Future<LocalConsent?> getActiveConsentForChild(int childRemoteId) {
    return (select(localConsents)
          ..where((c) => c.childRemoteId.equals(childRemoteId))
          ..where((c) => c.revokedAt.isNull())
          ..where((c) => c.consentGiven.equals(true))
          ..orderBy([(c) => OrderingTerm.desc(c.consentTimestamp)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get all consents (including revoked) for a child.
  Future<List<LocalConsent>> getAllConsentsForChild(int childRemoteId) {
    return (select(localConsents)
          ..where((c) => c.childRemoteId.equals(childRemoteId))
          ..orderBy([(c) => OrderingTerm.desc(c.consentTimestamp)]))
        .get();
  }

  /// Revoke a consent by setting revokedAt and reason.
  Future<void> revokeConsent(int consentId, String reason) {
    return (update(localConsents)..where((c) => c.id.equals(consentId))).write(
      LocalConsentsCompanion(
        revokedAt: Value(DateTime.now()),
        revocationReason: Value(reason),
      ),
    );
  }

  /// Count of distinct children who have at least one active consent.
  Future<int> getConsentedChildrenCount() async {
    final query = selectOnly(localConsents, distinct: true)
      ..where(localConsents.revokedAt.isNull() &
          localConsents.consentGiven.equals(true))
      ..addColumns([localConsents.childRemoteId]);
    final results = await query.get();
    return results.length;
  }

  /// Get all unsynced consents for background sync.
  Future<List<LocalConsent>> getUnsyncedConsents() {
    return (select(localConsents)..where((c) => c.syncedAt.isNull())).get();
  }

  /// Mark a consent as synced with the remote ID.
  Future<void> markConsentSynced(int id, int remoteId) {
    return (update(localConsents)..where((c) => c.id.equals(id))).write(
      LocalConsentsCompanion(
        remoteId: Value(remoteId),
        syncedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Get a consent by its local ID.
  Future<LocalConsent?> getConsentById(int id) {
    return (select(localConsents)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  // ---- Audit Logging ----

  /// Insert an audit log entry. Returns the local ID.
  Future<int> logAction({
    required String userId,
    required String userRole,
    required String action,
    required String entityType,
    int? entityId,
    String? entityName,
    String? detailsJson,
    String? deviceInfo,
  }) {
    return into(localAuditLogs).insert(LocalAuditLogsCompanion.insert(
      userId: userId,
      userRole: userRole,
      action: action,
      entityType: entityType,
      entityId: Value(entityId),
      auditEntityName: Value(entityName),
      detailsJson: Value(detailsJson),
      deviceInfo: Value(deviceInfo),
    ));
  }

  /// Get recent audit logs, ordered by timestamp descending.
  Future<List<LocalAuditLog>> getRecentLogs({int limit = 50}) {
    return (select(localAuditLogs)
          ..orderBy([(l) => OrderingTerm.desc(l.timestamp)])
          ..limit(limit))
        .get();
  }

  /// Get logs for a specific entity.
  Future<List<LocalAuditLog>> getLogsForEntity(
      String entityType, int entityId) {
    return (select(localAuditLogs)
          ..where((l) =>
              l.entityType.equals(entityType) & l.entityId.equals(entityId))
          ..orderBy([(l) => OrderingTerm.desc(l.timestamp)]))
        .get();
  }

  /// Get logs for a specific user.
  Future<List<LocalAuditLog>> getLogsForUser(String userId, {int limit = 50}) {
    return (select(localAuditLogs)
          ..where((l) => l.userId.equals(userId))
          ..orderBy([(l) => OrderingTerm.desc(l.timestamp)])
          ..limit(limit))
        .get();
  }

  /// Count of actions grouped by action type (for governance dashboard).
  Future<Map<String, int>> getActionCounts() async {
    final all = await select(localAuditLogs).get();
    final counts = <String, int>{};
    for (final log in all) {
      counts[log.action] = (counts[log.action] ?? 0) + 1;
    }
    return counts;
  }

  /// Get unsynced audit logs.
  Future<List<LocalAuditLog>> getUnsyncedLogs() {
    return (select(localAuditLogs)..where((l) => l.syncedAt.isNull())).get();
  }

  /// Mark an audit log as synced.
  Future<void> markLogSynced(int id, int remoteId) {
    return (update(localAuditLogs)..where((l) => l.id.equals(id))).write(
      LocalAuditLogsCompanion(
        remoteId: Value(remoteId),
        syncedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Get an audit log by its local ID.
  Future<LocalAuditLog?> getLogById(int id) {
    return (select(localAuditLogs)..where((l) => l.id.equals(id)))
        .getSingleOrNull();
  }

  // ---- Governance Config ----

  /// Get a config value by key.
  Future<String?> getConfigValue(String key) async {
    final row = await (select(localDataGovernanceConfig)
          ..where((c) => c.configKey.equals(key)))
        .getSingleOrNull();
    return row?.configValue;
  }

  /// Set a config value (upsert by key).
  Future<void> setConfigValue(String key, String value) async {
    final existing = await (select(localDataGovernanceConfig)
          ..where((c) => c.configKey.equals(key)))
        .getSingleOrNull();
    if (existing != null) {
      await (update(localDataGovernanceConfig)
            ..where((c) => c.configKey.equals(key)))
          .write(LocalDataGovernanceConfigCompanion(
        configValue: Value(value),
        updatedAt: Value(DateTime.now()),
      ));
    } else {
      await into(localDataGovernanceConfig)
          .insert(LocalDataGovernanceConfigCompanion.insert(
        configKey: key,
        configValue: value,
      ));
    }
  }
}
