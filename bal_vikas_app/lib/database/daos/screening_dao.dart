import 'dart:convert';
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/screening_tables.dart';

part 'screening_dao.g.dart';

@DriftAccessor(
    tables: [LocalScreeningSessions, LocalScreeningResponses, LocalScreeningResults])
class ScreeningDao extends DatabaseAccessor<AppDatabase>
    with _$ScreeningDaoMixin {
  ScreeningDao(super.db);

  // ---- Sessions ----

  Future<int> createSession(LocalScreeningSessionsCompanion session) {
    return into(localScreeningSessions).insert(session);
  }

  Future<LocalScreeningSession?> getSessionByLocalId(int localId) {
    return (select(localScreeningSessions)
          ..where((s) => s.localId.equals(localId)))
        .getSingleOrNull();
  }

  Future<void> markSessionCompleted(int localId) {
    return (update(localScreeningSessions)
          ..where((s) => s.localId.equals(localId)))
        .write(LocalScreeningSessionsCompanion(
      status: const Value('completed'),
      completedAt: Value(DateTime.now()),
    ));
  }

  Future<void> markSessionSynced(int localId, int remoteId) {
    return (update(localScreeningSessions)
          ..where((s) => s.localId.equals(localId)))
        .write(LocalScreeningSessionsCompanion(
      remoteId: Value(remoteId),
      syncedAt: Value(DateTime.now()),
    ));
  }

  Future<List<LocalScreeningSession>> getUnsyncedSessions() {
    return (select(localScreeningSessions)
          ..where(
              (s) => s.syncedAt.isNull() & s.status.equals('completed')))
        .get();
  }

  // ---- Responses ----

  Future<int> saveToolResponses({
    required int sessionLocalId,
    required String toolType,
    required Map<String, dynamic> responses,
  }) {
    return into(localScreeningResponses).insert(
      LocalScreeningResponsesCompanion.insert(
        sessionLocalId: sessionLocalId,
        toolType: toolType,
        responsesJson: jsonEncode(responses),
      ),
    );
  }

  Future<List<LocalScreeningResponse>> getResponsesForSession(
      int sessionLocalId) {
    return (select(localScreeningResponses)
          ..where((r) => r.sessionLocalId.equals(sessionLocalId)))
        .get();
  }

  Future<void> markResponsesSynced(int id) {
    return (update(localScreeningResponses)..where((r) => r.id.equals(id)))
        .write(
            LocalScreeningResponsesCompanion(syncedAt: Value(DateTime.now())));
  }

  // ---- Results ----

  Future<int> saveResult(LocalScreeningResultsCompanion result) {
    return into(localScreeningResults).insert(result);
  }

  Future<LocalScreeningResult?> getResultForSession(int sessionLocalId) {
    return (select(localScreeningResults)
          ..where((r) => r.sessionLocalId.equals(sessionLocalId)))
        .getSingleOrNull();
  }

  Future<LocalScreeningResult?> getResultByLocalId(int id) {
    return (select(localScreeningResults)..where((r) => r.id.equals(id)))
        .getSingleOrNull();
  }

  Future<LocalScreeningResult?> getLatestResultForChild(int childLocalId) {
    return (select(localScreeningResults)
          ..where((r) => r.childLocalId.equals(childLocalId))
          ..orderBy([(r) => OrderingTerm.desc(r.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<LocalScreeningResult>> getResultsForChild(int childLocalId) {
    return (select(localScreeningResults)
          ..where((r) => r.childLocalId.equals(childLocalId))
          ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]))
        .get();
  }

  /// Get the latest screening result for a child by their remote (Supabase) ID
  Future<LocalScreeningResult?> getLatestResultForChildByRemoteId(int childRemoteId) {
    return (select(localScreeningResults)
          ..where((r) => r.childRemoteId.equals(childRemoteId))
          ..orderBy([(r) => OrderingTerm.desc(r.id)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> markResultSynced(int id, int remoteSessionId) {
    return (update(localScreeningResults)..where((r) => r.id.equals(id)))
        .write(LocalScreeningResultsCompanion(
      sessionRemoteId: Value(remoteSessionId),
      syncedAt: Value(DateTime.now()),
    ));
  }

  // ---- Stats for dashboard ----

  /// Get all completed sessions
  Future<List<LocalScreeningSession>> getCompletedSessions() {
    return (select(localScreeningSessions)
          ..where((s) => s.status.equals('completed')))
        .get();
  }

  /// Get sessions completed today
  Future<List<LocalScreeningSession>> getSessionsCompletedToday() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return (select(localScreeningSessions)
          ..where((s) =>
              s.status.equals('completed') &
              s.assessmentDate.equals(today)))
        .get();
  }

  /// Get sessions completed this month (assessmentDate starts with 'YYYY-MM')
  Future<List<LocalScreeningSession>> getSessionsCompletedThisMonth() async {
    final now = DateTime.now();
    final monthPrefix = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final all = await (select(localScreeningSessions)
          ..where((s) => s.status.equals('completed')))
        .get();
    return all.where((s) => s.assessmentDate.startsWith(monthPrefix)).toList();
  }

  /// Get all screening results
  Future<List<LocalScreeningResult>> getAllResults() {
    return select(localScreeningResults).get();
  }

  /// Get set of child remote IDs that have been screened
  Future<Set<int>> getScreenedChildRemoteIds() async {
    final sessions = await (select(localScreeningSessions)
          ..where((s) => s.status.equals('completed')))
        .get();
    return sessions
        .where((s) => s.childRemoteId != null)
        .map((s) => s.childRemoteId!)
        .toSet();
  }

  /// Get high-risk results
  Future<List<LocalScreeningResult>> getHighRiskResults() {
    return (select(localScreeningResults)
          ..where((r) => r.overallRisk.equals('HIGH')))
        .get();
  }

  /// Get early warning children: currently LOW/MEDIUM but predicted HIGH or Very High (score > 50)
  Future<List<LocalScreeningResult>> getEarlyWarningResults() {
    return (select(localScreeningResults)
          ..where((r) =>
              r.overallRisk.isIn(['LOW', 'MEDIUM']) &
              r.predictedRiskScore.isBiggerThanValue(50))
          ..orderBy([(r) => OrderingTerm.desc(r.predictedRiskScore)]))
        .get();
  }

  /// Upsert a screening result from Supabase remote data.
  /// Skips if a result with the same sessionRemoteId already exists.
  Future<int?> upsertResultFromRemote(Map<String, dynamic> row) async {
    final sessionRemoteId = row['session_id'] as int?;
    if (sessionRemoteId == null) return null;

    // Check if already exists
    final existing = await (select(localScreeningResults)
          ..where((r) => r.sessionRemoteId.equals(sessionRemoteId))
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) return existing.id;

    final risk = row['overall_risk'] as String? ?? 'LOW';
    return into(localScreeningResults).insert(
      LocalScreeningResultsCompanion.insert(
        sessionLocalId: 0, // no local session for pulled results
        sessionRemoteId: Value(sessionRemoteId),
        childRemoteId: Value(row['child_id'] as int?),
        overallRisk: risk,
        overallRiskTe: Value(row['overall_risk_te'] as String? ?? ''),
        referralNeeded: Value(risk == 'HIGH'),
        gmDq: Value((row['gm_dq'] as num?)?.toDouble()),
        fmDq: Value((row['fm_dq'] as num?)?.toDouble()),
        lcDq: Value((row['lc_dq'] as num?)?.toDouble()),
        cogDq: Value((row['cog_dq'] as num?)?.toDouble()),
        seDq: Value((row['se_dq'] as num?)?.toDouble()),
        compositeDq: Value((row['composite_dq'] as num?)?.toDouble()),
        toolsCompleted: Value((row['tools_completed'] as int?) ?? 0),
        toolsSkipped: Value((row['tools_skipped'] as int?) ?? 0),
        assessmentCycle: Value(row['assessment_cycle'] as String? ?? 'Baseline'),
        baselineScore: Value((row['baseline_score'] as int?) ?? 0),
        baselineCategory: Value(row['baseline_category'] as String? ?? 'Low'),
        numDelays: Value((row['num_delays'] as int?) ?? 0),
        autismRisk: Value(row['autism_risk'] as String? ?? 'Low'),
        adhdRisk: Value(row['adhd_risk'] as String? ?? 'Low'),
        behaviorRisk: Value(row['behavior_risk'] as String? ?? 'Low'),
        behaviorScore: Value((row['behavior_score'] as int?) ?? 0),
      ),
    );
  }

  /// Update prediction fields on an existing result row
  Future<void> updatePrediction({
    required int resultLocalId,
    required double predictedRiskScore,
    required String predictedRiskCategory,
    required String riskTrend,
    required String topRiskFactorsJson,
  }) {
    return (update(localScreeningResults)
          ..where((r) => r.id.equals(resultLocalId)))
        .write(LocalScreeningResultsCompanion(
      predictedRiskScore: Value(predictedRiskScore),
      predictedRiskCategory: Value(predictedRiskCategory),
      riskTrend: Value(riskTrend),
      topRiskFactorsJson: Value(topRiskFactorsJson),
    ));
  }
}
