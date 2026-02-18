// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screening_dao.dart';

// ignore_for_file: type=lint
mixin _$ScreeningDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalScreeningSessionsTable get localScreeningSessions =>
      attachedDatabase.localScreeningSessions;
  $LocalScreeningResponsesTable get localScreeningResponses =>
      attachedDatabase.localScreeningResponses;
  $LocalScreeningResultsTable get localScreeningResults =>
      attachedDatabase.localScreeningResults;
  ScreeningDaoManager get managers => ScreeningDaoManager(this);
}

class ScreeningDaoManager {
  final _$ScreeningDaoMixin _db;
  ScreeningDaoManager(this._db);
  $$LocalScreeningSessionsTableTableManager get localScreeningSessions =>
      $$LocalScreeningSessionsTableTableManager(
          _db.attachedDatabase, _db.localScreeningSessions);
  $$LocalScreeningResponsesTableTableManager get localScreeningResponses =>
      $$LocalScreeningResponsesTableTableManager(
          _db.attachedDatabase, _db.localScreeningResponses);
  $$LocalScreeningResultsTableTableManager get localScreeningResults =>
      $$LocalScreeningResultsTableTableManager(
          _db.attachedDatabase, _db.localScreeningResults);
}
