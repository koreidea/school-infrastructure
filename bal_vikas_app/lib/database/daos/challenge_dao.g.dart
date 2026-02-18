// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_dao.dart';

// ignore_for_file: type=lint
mixin _$ChallengeDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalNutritionAssessmentsTable get localNutritionAssessments =>
      attachedDatabase.localNutritionAssessments;
  $LocalEnvironmentAssessmentsTable get localEnvironmentAssessments =>
      attachedDatabase.localEnvironmentAssessments;
  $LocalInterventionFollowupsTable get localInterventionFollowups =>
      attachedDatabase.localInterventionFollowups;
  ChallengeDaoManager get managers => ChallengeDaoManager(this);
}

class ChallengeDaoManager {
  final _$ChallengeDaoMixin _db;
  ChallengeDaoManager(this._db);
  $$LocalNutritionAssessmentsTableTableManager get localNutritionAssessments =>
      $$LocalNutritionAssessmentsTableTableManager(
          _db.attachedDatabase, _db.localNutritionAssessments);
  $$LocalEnvironmentAssessmentsTableTableManager
      get localEnvironmentAssessments =>
          $$LocalEnvironmentAssessmentsTableTableManager(
              _db.attachedDatabase, _db.localEnvironmentAssessments);
  $$LocalInterventionFollowupsTableTableManager
      get localInterventionFollowups =>
          $$LocalInterventionFollowupsTableTableManager(
              _db.attachedDatabase, _db.localInterventionFollowups);
}
