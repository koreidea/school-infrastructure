// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screening_config_dao.dart';

// ignore_for_file: type=lint
mixin _$ScreeningConfigDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalToolConfigsTable get localToolConfigs =>
      attachedDatabase.localToolConfigs;
  $LocalQuestionsTable get localQuestions => attachedDatabase.localQuestions;
  $LocalResponseOptionsTable get localResponseOptions =>
      attachedDatabase.localResponseOptions;
  $LocalScoringRulesTable get localScoringRules =>
      attachedDatabase.localScoringRules;
  $LocalActivitiesTable get localActivities => attachedDatabase.localActivities;
  ScreeningConfigDaoManager get managers => ScreeningConfigDaoManager(this);
}

class ScreeningConfigDaoManager {
  final _$ScreeningConfigDaoMixin _db;
  ScreeningConfigDaoManager(this._db);
  $$LocalToolConfigsTableTableManager get localToolConfigs =>
      $$LocalToolConfigsTableTableManager(
          _db.attachedDatabase, _db.localToolConfigs);
  $$LocalQuestionsTableTableManager get localQuestions =>
      $$LocalQuestionsTableTableManager(
          _db.attachedDatabase, _db.localQuestions);
  $$LocalResponseOptionsTableTableManager get localResponseOptions =>
      $$LocalResponseOptionsTableTableManager(
          _db.attachedDatabase, _db.localResponseOptions);
  $$LocalScoringRulesTableTableManager get localScoringRules =>
      $$LocalScoringRulesTableTableManager(
          _db.attachedDatabase, _db.localScoringRules);
  $$LocalActivitiesTableTableManager get localActivities =>
      $$LocalActivitiesTableTableManager(
          _db.attachedDatabase, _db.localActivities);
}
