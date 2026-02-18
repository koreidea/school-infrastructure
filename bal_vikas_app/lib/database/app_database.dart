import 'package:drift/drift.dart';

import 'database_connection_web.dart'
    if (dart.library.io) 'database_connection_native.dart' as conn;

import 'tables/children_table.dart';
import 'tables/screening_tables.dart';
import 'tables/sync_queue_table.dart';
import 'tables/screening_config_tables.dart';
import 'tables/dpdp_tables.dart';
import 'daos/children_dao.dart';
import 'daos/screening_dao.dart';
import 'daos/sync_queue_dao.dart';
import 'daos/screening_config_dao.dart';
import 'daos/referral_dao.dart';
import 'daos/challenge_dao.dart';
import 'daos/dpdp_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    LocalChildren,
    LocalScreeningSessions,
    LocalScreeningResponses,
    LocalScreeningResults,
    SyncQueue,
    // v2: screening config tables
    LocalToolConfigs,
    LocalQuestions,
    LocalResponseOptions,
    LocalScoringRules,
    LocalActivities,
    // v3: challenge dashboard tables
    LocalReferrals,
    LocalNutritionAssessments,
    LocalEnvironmentAssessments,
    LocalInterventionFollowups,
    // v4: DPDP compliance tables
    LocalConsents,
    LocalAuditLogs,
    LocalDataGovernanceConfig,
  ],
  daos: [
    ChildrenDao,
    ScreeningDao,
    SyncQueueDao,
    ScreeningConfigDao,
    ReferralDao,
    ChallengeDao,
    DpdpDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(conn.openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(localToolConfigs);
          await m.createTable(localQuestions);
          await m.createTable(localResponseOptions);
          await m.createTable(localScoringRules);
          await m.createTable(localActivities);
        }
        if (from < 3) {
          // Add challenge extension columns to screening results
          await m.addColumn(localScreeningResults, localScreeningResults.assessmentCycle);
          await m.addColumn(localScreeningResults, localScreeningResults.baselineScore);
          await m.addColumn(localScreeningResults, localScreeningResults.baselineCategory);
          await m.addColumn(localScreeningResults, localScreeningResults.numDelays);
          await m.addColumn(localScreeningResults, localScreeningResults.autismRisk);
          await m.addColumn(localScreeningResults, localScreeningResults.adhdRisk);
          await m.addColumn(localScreeningResults, localScreeningResults.behaviorRisk);
          await m.addColumn(localScreeningResults, localScreeningResults.behaviorScore);
          // Create new challenge tables
          await m.createTable(localReferrals);
          await m.createTable(localNutritionAssessments);
          await m.createTable(localEnvironmentAssessments);
          await m.createTable(localInterventionFollowups);
        }
        if (from < 4) {
          // DPDP compliance tables
          await m.createTable(localConsents);
          await m.createTable(localAuditLogs);
          await m.createTable(localDataGovernanceConfig);
        }
        if (from < 5) {
          // Predictive risk scoring columns
          await m.addColumn(localScreeningResults, localScreeningResults.predictedRiskScore);
          await m.addColumn(localScreeningResults, localScreeningResults.predictedRiskCategory);
          await m.addColumn(localScreeningResults, localScreeningResults.riskTrend);
          await m.addColumn(localScreeningResults, localScreeningResults.topRiskFactorsJson);
        }
      },
    );
  }
}

