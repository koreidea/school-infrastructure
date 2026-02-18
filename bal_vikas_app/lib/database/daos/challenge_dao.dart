import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/screening_tables.dart';

part 'challenge_dao.g.dart';

@DriftAccessor(tables: [
  LocalNutritionAssessments,
  LocalEnvironmentAssessments,
  LocalInterventionFollowups,
])
class ChallengeDao extends DatabaseAccessor<AppDatabase>
    with _$ChallengeDaoMixin {
  ChallengeDao(super.db);

  // ---- Nutrition ----

  Future<int> insertNutrition(LocalNutritionAssessmentsCompanion data) {
    return into(localNutritionAssessments).insert(data);
  }

  Future<LocalNutritionAssessment?> getLatestNutritionForChild(int childRemoteId) {
    return (select(localNutritionAssessments)
          ..where((n) => n.childRemoteId.equals(childRemoteId))
          ..orderBy([(n) => OrderingTerm.desc(n.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<LocalNutritionAssessment>> getNutritionHistoryForChild(int childRemoteId) {
    return (select(localNutritionAssessments)
          ..where((n) => n.childRemoteId.equals(childRemoteId))
          ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]))
        .get();
  }

  Future<List<LocalNutritionAssessment>> getAllNutritionAssessments() {
    return select(localNutritionAssessments).get();
  }

  Future<LocalNutritionAssessment?> getNutritionById(int id) {
    return (select(localNutritionAssessments)..where((n) => n.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> markNutritionSynced(int id) {
    return (update(localNutritionAssessments)..where((n) => n.id.equals(id)))
        .write(LocalNutritionAssessmentsCompanion(syncedAt: Value(DateTime.now())));
  }

  // ---- Environment ----

  Future<int> insertEnvironment(LocalEnvironmentAssessmentsCompanion data) {
    return into(localEnvironmentAssessments).insert(data);
  }

  Future<LocalEnvironmentAssessment?> getLatestEnvironmentForChild(int childRemoteId) {
    return (select(localEnvironmentAssessments)
          ..where((e) => e.childRemoteId.equals(childRemoteId))
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<LocalEnvironmentAssessment>> getEnvironmentHistoryForChild(int childRemoteId) {
    return (select(localEnvironmentAssessments)
          ..where((e) => e.childRemoteId.equals(childRemoteId))
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .get();
  }

  Future<LocalEnvironmentAssessment?> getEnvironmentById(int id) {
    return (select(localEnvironmentAssessments)..where((e) => e.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> markEnvironmentSynced(int id) {
    return (update(localEnvironmentAssessments)..where((e) => e.id.equals(id)))
        .write(LocalEnvironmentAssessmentsCompanion(syncedAt: Value(DateTime.now())));
  }

  // ---- Intervention Follow-ups ----

  Future<int> insertFollowup(LocalInterventionFollowupsCompanion data) {
    return into(localInterventionFollowups).insert(data);
  }

  Future<List<LocalInterventionFollowup>> getFollowupsForChild(int childRemoteId) {
    return (select(localInterventionFollowups)
          ..where((f) => f.childRemoteId.equals(childRemoteId))
          ..orderBy([(f) => OrderingTerm.desc(f.createdAt)]))
        .get();
  }

  Future<List<LocalInterventionFollowup>> getAllFollowups() {
    return (select(localInterventionFollowups)
          ..orderBy([(f) => OrderingTerm.desc(f.createdAt)]))
        .get();
  }

  Future<LocalInterventionFollowup?> getFollowupById(int id) {
    return (select(localInterventionFollowups)..where((f) => f.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> markFollowupSynced(int id) {
    return (update(localInterventionFollowups)..where((f) => f.id.equals(id)))
        .write(LocalInterventionFollowupsCompanion(syncedAt: Value(DateTime.now())));
  }

  Future<void> updateFollowup(int id, LocalInterventionFollowupsCompanion data) {
    return (update(localInterventionFollowups)..where((f) => f.id.equals(id)))
        .write(data);
  }

  /// Get aggregated follow-up stats for dashboard
  Future<Map<String, int>> getFollowupStats() async {
    final all = await select(localInterventionFollowups).get();
    int improved = 0, same = 0, worsened = 0, exitedHighRisk = 0, domainImproved = 0;
    for (final f in all) {
      if (f.improvementStatus == 'Improved') improved++;
      if (f.improvementStatus == 'Same') same++;
      if (f.improvementStatus == 'Worsened') worsened++;
      if (f.exitHighRisk) exitedHighRisk++;
      if (f.domainImprovement) domainImproved++;
    }
    return {
      'improved': improved,
      'same': same,
      'worsened': worsened,
      'exited_high_risk': exitedHighRisk,
      'domain_improved': domainImproved,
      'total': all.length,
    };
  }
}
