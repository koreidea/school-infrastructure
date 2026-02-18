// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dpdp_dao.dart';

// ignore_for_file: type=lint
mixin _$DpdpDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalConsentsTable get localConsents => attachedDatabase.localConsents;
  $LocalAuditLogsTable get localAuditLogs => attachedDatabase.localAuditLogs;
  $LocalDataGovernanceConfigTable get localDataGovernanceConfig =>
      attachedDatabase.localDataGovernanceConfig;
  DpdpDaoManager get managers => DpdpDaoManager(this);
}

class DpdpDaoManager {
  final _$DpdpDaoMixin _db;
  DpdpDaoManager(this._db);
  $$LocalConsentsTableTableManager get localConsents =>
      $$LocalConsentsTableTableManager(_db.attachedDatabase, _db.localConsents);
  $$LocalAuditLogsTableTableManager get localAuditLogs =>
      $$LocalAuditLogsTableTableManager(
          _db.attachedDatabase, _db.localAuditLogs);
  $$LocalDataGovernanceConfigTableTableManager get localDataGovernanceConfig =>
      $$LocalDataGovernanceConfigTableTableManager(
          _db.attachedDatabase, _db.localDataGovernanceConfig);
}
