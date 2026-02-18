import 'dart:convert';
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/screening_config_tables.dart';

part 'screening_config_dao.g.dart';

@DriftAccessor(tables: [
  LocalToolConfigs,
  LocalQuestions,
  LocalResponseOptions,
  LocalScoringRules,
  LocalActivities,
])
class ScreeningConfigDao extends DatabaseAccessor<AppDatabase>
    with _$ScreeningConfigDaoMixin {
  ScreeningConfigDao(super.db);

  // ── Tool Configs ──────────────────────────────────────────────────────

  Future<List<LocalToolConfig>> getAllActiveToolConfigs() {
    return (select(localToolConfigs)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Future<LocalToolConfig?> getToolConfigByType(String toolType) {
    return (select(localToolConfigs)
          ..where((t) => t.toolType.equals(toolType) & t.isActive.equals(true)))
        .getSingleOrNull();
  }

  Future<void> upsertToolConfig(Map<String, dynamic> row) async {
    final remoteId = row['id'] as int;
    final existing = await (select(localToolConfigs)
          ..where((t) => t.remoteId.equals(remoteId)))
        .getSingleOrNull();

    final companion = LocalToolConfigsCompanion(
      remoteId: Value(remoteId),
      toolType: Value(row['tool_type'] as String),
      toolId: Value(row['tool_id'] as String),
      name: Value(row['name'] as String),
      nameTe: Value(row['name_te'] as String),
      description: Value(row['description'] as String? ?? ''),
      descriptionTe: Value(row['description_te'] as String? ?? ''),
      minAgeMonths: Value(row['min_age_months'] as int? ?? 0),
      maxAgeMonths: Value(row['max_age_months'] as int? ?? 72),
      responseFormat: Value(row['response_format'] as String),
      domainsJson: Value(jsonEncode(row['domains'] ?? [])),
      iconName: Value(row['icon_name'] as String?),
      colorHex: Value(row['color_hex'] as String?),
      sortOrder: Value(row['sort_order'] as int? ?? 0),
      isAgeBracketFiltered: Value(row['is_age_bracket_filtered'] as bool? ?? false),
      isActive: Value(row['is_active'] as bool? ?? true),
      version: Value(row['version'] as int? ?? 1),
      lastSyncedAt: Value(DateTime.now()),
    );

    if (existing != null) {
      await (update(localToolConfigs)
            ..where((t) => t.remoteId.equals(remoteId)))
          .write(companion);
    } else {
      await into(localToolConfigs).insert(companion);
    }
  }

  // ── Questions ─────────────────────────────────────────────────────────

  Future<List<LocalQuestion>> getQuestionsForTool(int toolConfigId) {
    return (select(localQuestions)
          ..where((q) => q.toolConfigId.equals(toolConfigId) & q.isActive.equals(true))
          ..orderBy([(q) => OrderingTerm.asc(q.sortOrder)]))
        .get();
  }

  Future<List<LocalQuestion>> getQuestionsForToolType(String toolType) async {
    final config = await getToolConfigByType(toolType);
    if (config == null) return [];
    return getQuestionsForTool(config.id);
  }

  Future<void> upsertQuestion(Map<String, dynamic> row, int localToolConfigId) async {
    final remoteId = row['id'] as int;
    final existing = await (select(localQuestions)
          ..where((q) => q.remoteId.equals(remoteId)))
        .getSingleOrNull();

    final companion = LocalQuestionsCompanion(
      remoteId: Value(remoteId),
      toolConfigId: Value(localToolConfigId),
      code: Value(row['code'] as String),
      textEn: Value(row['text_en'] as String),
      textTe: Value(row['text_te'] as String),
      domain: Value(row['domain'] as String?),
      domainNameEn: Value(row['domain_name_en'] as String?),
      domainNameTe: Value(row['domain_name_te'] as String?),
      category: Value(row['category'] as String?),
      categoryTe: Value(row['category_te'] as String?),
      ageMonths: Value(row['age_months'] as int?),
      isCritical: Value(row['is_critical'] as bool? ?? false),
      isRedFlag: Value(row['is_red_flag'] as bool? ?? false),
      isReverseScored: Value(row['is_reverse_scored'] as bool? ?? false),
      unit: Value(row['unit'] as String?),
      overrideFormat: Value(row['override_format'] as String?),
      sortOrder: Value(row['sort_order'] as int? ?? 0),
      isActive: Value(row['is_active'] as bool? ?? true),
    );

    if (existing != null) {
      await (update(localQuestions)
            ..where((q) => q.remoteId.equals(remoteId)))
          .write(companion);
    } else {
      await into(localQuestions).insert(companion);
    }
  }

  // ── Response Options ──────────────────────────────────────────────────

  Future<List<LocalResponseOption>> getResponseOptionsForTool(int toolConfigId) {
    return (select(localResponseOptions)
          ..where((o) => o.toolConfigId.equals(toolConfigId))
          ..orderBy([(o) => OrderingTerm.asc(o.sortOrder)]))
        .get();
  }

  Future<void> upsertResponseOption(Map<String, dynamic> row, int localToolConfigId) async {
    final remoteId = row['id'] as int;
    final existing = await (select(localResponseOptions)
          ..where((o) => o.remoteId.equals(remoteId)))
        .getSingleOrNull();

    final companion = LocalResponseOptionsCompanion(
      remoteId: Value(remoteId),
      toolConfigId: Value(localToolConfigId),
      questionId: Value(row['question_id'] as int?),
      labelEn: Value(row['label_en'] as String),
      labelTe: Value(row['label_te'] as String),
      valueJson: Value(jsonEncode(row['value'])),
      colorHex: Value(row['color_hex'] as String?),
      sortOrder: Value(row['sort_order'] as int? ?? 0),
    );

    if (existing != null) {
      await (update(localResponseOptions)
            ..where((o) => o.remoteId.equals(remoteId)))
          .write(companion);
    } else {
      await into(localResponseOptions).insert(companion);
    }
  }

  // ── Scoring Rules ─────────────────────────────────────────────────────

  Future<List<LocalScoringRule>> getScoringRulesForTool(int toolConfigId) {
    return (select(localScoringRules)
          ..where((r) => r.toolConfigId.equals(toolConfigId)))
        .get();
  }

  Future<List<LocalScoringRule>> getScoringRulesForToolType(String toolType) async {
    final config = await getToolConfigByType(toolType);
    if (config == null) return [];
    return getScoringRulesForTool(config.id);
  }

  Future<void> upsertScoringRule(Map<String, dynamic> row, int localToolConfigId) async {
    final remoteId = row['id'] as int;
    final existing = await (select(localScoringRules)
          ..where((r) => r.remoteId.equals(remoteId)))
        .getSingleOrNull();

    final companion = LocalScoringRulesCompanion(
      remoteId: Value(remoteId),
      toolConfigId: Value(localToolConfigId),
      ruleType: Value(row['rule_type'] as String),
      domain: Value(row['domain'] as String?),
      parameterName: Value(row['parameter_name'] as String),
      parameterValueJson: Value(jsonEncode(row['parameter_value'])),
      description: Value(row['description'] as String?),
    );

    if (existing != null) {
      await (update(localScoringRules)
            ..where((r) => r.remoteId.equals(remoteId)))
          .write(companion);
    } else {
      await into(localScoringRules).insert(companion);
    }
  }

  // ── Activities ────────────────────────────────────────────────────────

  Future<List<LocalActivity>> getAllActiveActivities() {
    return (select(localActivities)
          ..where((a) => a.isActive.equals(true))
          ..orderBy([(a) => OrderingTerm.asc(a.domain), (a) => OrderingTerm.asc(a.activityCode)]))
        .get();
  }

  Future<List<LocalActivity>> getActivitiesForDomainAndAge(String domain, int ageMonths) {
    return (select(localActivities)
          ..where((a) =>
              a.isActive.equals(true) &
              a.domain.equals(domain) &
              a.minAgeMonths.isSmallerOrEqualValue(ageMonths) &
              a.maxAgeMonths.isBiggerOrEqualValue(ageMonths))
          ..orderBy([(a) => OrderingTerm.asc(a.activityCode)]))
        .get();
  }

  Future<void> upsertActivity(Map<String, dynamic> row) async {
    final remoteId = row['id'] as int;
    final existing = await (select(localActivities)
          ..where((a) => a.remoteId.equals(remoteId)))
        .getSingleOrNull();

    final companion = LocalActivitiesCompanion(
      remoteId: Value(remoteId),
      activityCode: Value(row['activity_code'] as String),
      domain: Value(row['domain'] as String),
      titleEn: Value(row['title_en'] as String),
      titleTe: Value(row['title_te'] as String),
      descriptionEn: Value(row['description_en'] as String),
      descriptionTe: Value(row['description_te'] as String),
      materialsEn: Value(row['materials_en'] as String?),
      materialsTe: Value(row['materials_te'] as String?),
      durationMinutes: Value(row['duration_minutes'] as int? ?? 15),
      minAgeMonths: Value(row['min_age_months'] as int? ?? 0),
      maxAgeMonths: Value(row['max_age_months'] as int? ?? 72),
      riskLevel: Value(row['risk_level'] as String? ?? 'all'),
      hasVideo: Value(row['has_video'] as bool? ?? false),
      isActive: Value(row['is_active'] as bool? ?? true),
      version: Value(row['version'] as int? ?? 1),
      lastSyncedAt: Value(DateTime.now()),
    );

    if (existing != null) {
      await (update(localActivities)
            ..where((a) => a.remoteId.equals(remoteId)))
          .write(companion);
    } else {
      await into(localActivities).insert(companion);
    }
  }

  // ── Bulk Operations ───────────────────────────────────────────────────

  Future<void> clearAllConfigData() async {
    await delete(localScoringRules).go();
    await delete(localResponseOptions).go();
    await delete(localQuestions).go();
    await delete(localToolConfigs).go();
    await delete(localActivities).go();
  }
}
