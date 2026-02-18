import 'package:drift/drift.dart';

/// Local screening sessions
class LocalScreeningSessions extends Table {
  IntColumn get localId => integer().autoIncrement()();
  IntColumn get remoteId => integer().nullable()();
  IntColumn get childLocalId => integer().nullable()();
  IntColumn get childRemoteId => integer().nullable()();
  TextColumn get conductedBy => text()();
  TextColumn get assessmentDate => text()();
  IntColumn get childAgeMonths => integer()();
  TextColumn get status => text().withDefault(const Constant('in_progress'))();
  TextColumn get deviceSessionId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}

/// Tool responses within a session (one row per tool, responses as JSON)
class LocalScreeningResponses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionLocalId => integer()();
  TextColumn get toolType => text()();
  TextColumn get responsesJson => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}

/// Computed screening results
class LocalScreeningResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionLocalId => integer()();
  IntColumn get sessionRemoteId => integer().nullable()();
  IntColumn get childLocalId => integer().nullable()();
  IntColumn get childRemoteId => integer().nullable()();
  TextColumn get overallRisk => text()();
  TextColumn get overallRiskTe => text().withDefault(const Constant(''))();
  BoolColumn get referralNeeded => boolean().withDefault(const Constant(false))();
  RealColumn get gmDq => real().nullable()();
  RealColumn get fmDq => real().nullable()();
  RealColumn get lcDq => real().nullable()();
  RealColumn get cogDq => real().nullable()();
  RealColumn get seDq => real().nullable()();
  RealColumn get compositeDq => real().nullable()();
  TextColumn get toolResultsJson => text().nullable()();
  TextColumn get concernsJson => text().nullable()();
  TextColumn get concernsTeJson => text().nullable()();
  IntColumn get toolsCompleted => integer().withDefault(const Constant(0))();
  IntColumn get toolsSkipped => integer().withDefault(const Constant(0))();
  // Challenge extension fields
  TextColumn get assessmentCycle => text().withDefault(const Constant('Baseline'))();
  IntColumn get baselineScore => integer().withDefault(const Constant(0))();
  TextColumn get baselineCategory => text().withDefault(const Constant('Low'))();
  IntColumn get numDelays => integer().withDefault(const Constant(0))();
  TextColumn get autismRisk => text().withDefault(const Constant('Low'))();
  TextColumn get adhdRisk => text().withDefault(const Constant('Low'))();
  TextColumn get behaviorRisk => text().withDefault(const Constant('Low'))();
  IntColumn get behaviorScore => integer().withDefault(const Constant(0))();
  // Predictive risk scoring fields (v5)
  RealColumn get predictedRiskScore => real().nullable()();
  TextColumn get predictedRiskCategory => text().nullable()();
  TextColumn get riskTrend => text().nullable()();
  TextColumn get topRiskFactorsJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}

/// Referral tracking per child/screening result
class LocalReferrals extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get childRemoteId => integer().nullable()();
  IntColumn get screeningResultLocalId => integer().nullable()();
  IntColumn get screeningResultRemoteId => integer().nullable()();
  BoolColumn get referralTriggered => boolean().withDefault(const Constant(false))();
  TextColumn get referralType => text().nullable()();
  TextColumn get referralReason => text().nullable()();
  TextColumn get referralStatus => text().withDefault(const Constant('Pending'))();
  TextColumn get referredBy => text().nullable()();
  TextColumn get referredDate => text().nullable()();
  TextColumn get completedDate => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}

/// Nutrition assessment per screening session
class LocalNutritionAssessments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get childRemoteId => integer().nullable()();
  IntColumn get sessionLocalId => integer().nullable()();
  RealColumn get heightCm => real().nullable()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get muacCm => real().nullable()();
  BoolColumn get underweight => boolean().withDefault(const Constant(false))();
  BoolColumn get stunting => boolean().withDefault(const Constant(false))();
  BoolColumn get wasting => boolean().withDefault(const Constant(false))();
  BoolColumn get anemia => boolean().withDefault(const Constant(false))();
  IntColumn get nutritionScore => integer().withDefault(const Constant(0))();
  TextColumn get nutritionRisk => text().withDefault(const Constant('Low'))();
  TextColumn get assessedDate => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}

/// Environment / caregiving assessment per screening session
class LocalEnvironmentAssessments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get childRemoteId => integer().nullable()();
  IntColumn get sessionLocalId => integer().nullable()();
  IntColumn get parentChildInteractionScore => integer().nullable()();
  IntColumn get parentMentalHealthScore => integer().nullable()();
  IntColumn get homeStimulationScore => integer().nullable()();
  BoolColumn get playMaterials => boolean().withDefault(const Constant(false))();
  TextColumn get caregiverEngagement => text().withDefault(const Constant('Medium'))();
  TextColumn get languageExposure => text().withDefault(const Constant('Adequate'))();
  BoolColumn get safeWater => boolean().withDefault(const Constant(false))();
  BoolColumn get toiletFacility => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}

/// Intervention follow-up tracking
class LocalInterventionFollowups extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get childRemoteId => integer().nullable()();
  IntColumn get screeningResultLocalId => integer().nullable()();
  BoolColumn get interventionPlanGenerated => boolean().withDefault(const Constant(false))();
  IntColumn get homeActivitiesAssigned => integer().withDefault(const Constant(0))();
  BoolColumn get followupConducted => boolean().withDefault(const Constant(false))();
  TextColumn get followupDate => text().nullable()();
  TextColumn get nextFollowupDate => text().nullable()();
  TextColumn get improvementStatus => text().nullable()();
  IntColumn get reductionInDelayMonths => integer().withDefault(const Constant(0))();
  BoolColumn get domainImprovement => boolean().withDefault(const Constant(false))();
  TextColumn get autismRiskChange => text().withDefault(const Constant('Same'))();
  BoolColumn get exitHighRisk => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}
