import 'package:drift/drift.dart';

/// Local cache of children from Supabase
class LocalChildren extends Table {
  IntColumn get localId => integer().autoIncrement()();
  IntColumn get remoteId => integer().nullable()();
  TextColumn get childUniqueId => text()();
  TextColumn get name => text()();
  DateTimeColumn get dob => dateTime()();
  TextColumn get gender => text()();
  IntColumn get parentId => integer().nullable()();
  TextColumn get awwId => text().nullable()();
  IntColumn get awcId => integer().nullable()();
  TextColumn get photoUrl => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get localUpdatedAt => dateTime().withDefault(currentDateAndTime)();
}
