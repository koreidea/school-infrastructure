import 'package:drift/drift.dart';

/// Tool configuration (mirrors Supabase screening_tool_configs)
class LocalToolConfigs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get remoteId => integer().nullable()();
  TextColumn get toolType => text()(); // e.g. 'cdcMilestones'
  TextColumn get toolId => text()(); // e.g. 'cdc_milestones'
  TextColumn get name => text()();
  TextColumn get nameTe => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get descriptionTe => text().withDefault(const Constant(''))();
  IntColumn get minAgeMonths => integer().withDefault(const Constant(0))();
  IntColumn get maxAgeMonths => integer().withDefault(const Constant(72))();
  TextColumn get responseFormat => text()(); // yesNo, threePoint, etc.
  TextColumn get domainsJson => text().withDefault(const Constant('[]'))(); // JSON array
  TextColumn get iconName => text().nullable()();
  TextColumn get colorHex => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isAgeBracketFiltered =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
}

/// Questions within a tool (mirrors Supabase screening_questions)
class LocalQuestions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get remoteId => integer().nullable()();
  IntColumn get toolConfigId => integer()(); // FK to LocalToolConfigs.id
  TextColumn get code => text()(); // e.g. 'gm_2_1'
  TextColumn get textEn => text()();
  TextColumn get textTe => text()();
  TextColumn get domain => text().nullable()();
  TextColumn get domainNameEn => text().nullable()();
  TextColumn get domainNameTe => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get categoryTe => text().nullable()();
  IntColumn get ageMonths => integer().nullable()();
  BoolColumn get isCritical =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isRedFlag =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isReverseScored =>
      boolean().withDefault(const Constant(false))();
  TextColumn get unit => text().nullable()();
  TextColumn get overrideFormat => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

/// Response options for questions/tools (mirrors Supabase screening_response_options)
class LocalResponseOptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get remoteId => integer().nullable()();
  IntColumn get toolConfigId => integer()();
  IntColumn get questionId => integer().nullable()();
  TextColumn get labelEn => text()();
  TextColumn get labelTe => text()();
  TextColumn get valueJson => text()(); // JSON value
  TextColumn get colorHex => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Scoring rules for tools (mirrors Supabase screening_scoring_rules)
class LocalScoringRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get remoteId => integer().nullable()();
  IntColumn get toolConfigId => integer()();
  TextColumn get ruleType => text()();
  TextColumn get domain => text().nullable()();
  TextColumn get parameterName => text()();
  TextColumn get parameterValueJson => text()(); // JSON value
  TextColumn get description => text().nullable()();
}

/// Recommended activities (mirrors Supabase screening_activities)
class LocalActivities extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get remoteId => integer().nullable()();
  TextColumn get activityCode => text()();
  TextColumn get domain => text()();
  TextColumn get titleEn => text()();
  TextColumn get titleTe => text()();
  TextColumn get descriptionEn => text()();
  TextColumn get descriptionTe => text()();
  TextColumn get materialsEn => text().nullable()();
  TextColumn get materialsTe => text().nullable()();
  IntColumn get durationMinutes =>
      integer().withDefault(const Constant(15))();
  IntColumn get minAgeMonths => integer().withDefault(const Constant(0))();
  IntColumn get maxAgeMonths => integer().withDefault(const Constant(72))();
  TextColumn get riskLevel =>
      text().withDefault(const Constant('all'))();
  BoolColumn get hasVideo =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
}
