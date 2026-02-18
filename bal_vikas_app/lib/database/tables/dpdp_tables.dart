import 'package:drift/drift.dart';

/// Guardian consent records per child — DPDP Act 2023 Section 9 compliance.
class LocalConsents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get remoteId => integer().nullable()();
  IntColumn get childRemoteId => integer()();
  TextColumn get guardianName => text()();
  TextColumn get guardianRelation => text()(); // 'mother','father','guardian'
  TextColumn get guardianPhone => text().nullable()();
  TextColumn get consentPurpose =>
      text()(); // 'screening','data_collection','referral'
  BoolColumn get consentGiven =>
      boolean().withDefault(const Constant(true))();
  TextColumn get consentVersion =>
      text().withDefault(const Constant('1.0'))();
  TextColumn get digitalSignatureBase64 =>
      text().nullable()(); // finger-drawn signature as base64 PNG
  TextColumn get collectedByUserId => text()(); // users.id (UUID)
  TextColumn get collectedByRole => text()(); // AWW, SUPERVISOR, etc.
  TextColumn get languageUsed =>
      text().withDefault(const Constant('en'))();
  DateTimeColumn get consentTimestamp =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get revokedAt => dateTime().nullable()();
  TextColumn get revocationReason => text().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}

/// Audit log — tracks who accessed/modified what data.
class LocalAuditLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get remoteId => integer().nullable()();
  TextColumn get userId => text()(); // users.id (UUID)
  TextColumn get userRole => text()();
  TextColumn get action =>
      text()(); // view_child, create_child, start_screening, etc.
  TextColumn get entityType =>
      text()(); // child, screening_session, screening_result, export, consent
  IntColumn get entityId => integer().nullable()();
  TextColumn get auditEntityName => text().nullable()();
  TextColumn get detailsJson => text().nullable()(); // additional context
  TextColumn get deviceInfo => text().nullable()();
  DateTimeColumn get timestamp =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}

/// Key-value governance settings (retention policy, consent version, etc.)
class LocalDataGovernanceConfig extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get configKey => text()();
  TextColumn get configValue => text()();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
