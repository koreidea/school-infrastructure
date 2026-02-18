import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../database/app_database.dart';
import '../providers/admin_global_config_provider.dart';
import '../providers/screening_results_storage.dart';
import '../utils/ml/feature_extractor.dart';
import 'database_service.dart';

/// Output of a predictive risk assessment.
class PredictiveScore {
  final double score; // 0-100
  final String category; // 'Low', 'Medium', 'High', 'Very High'
  final String categoryTe;
  final String trend; // 'Improving', 'Stable', 'Worsening', 'New'
  final String trendTe;
  final List<String> topFactors;
  final List<String> topFactorsTe;

  const PredictiveScore({
    required this.score,
    required this.category,
    required this.categoryTe,
    required this.trend,
    required this.trendTe,
    required this.topFactors,
    required this.topFactorsTe,
  });

  Map<String, dynamic> toJson() => {
        'score': score,
        'category': category,
        'trend': trend,
        'topFactors': topFactors,
        'topFactorsTe': topFactorsTe,
      };
}

/// Abstract interface for risk predictors.
/// Swap implementations to move from formula-based to ML-based prediction.
abstract class RiskPredictor {
  PredictiveScore predict(Map<String, double> features, {GlobalConfig? config});
}

/// Formula-based predictor using research-backed clinical weights.
///
/// Weight sources:
///   - Developmental (40%): Lancet 2016 ECD Series
///   - Multi-domain penalty (15%): Sameroff cumulative risk model
///   - Condition risks (20%): DSM-5 PPV ratios
///   - Environment (15%): WHO Nurturing Care Framework
///   - Trajectory (10%): JAMA 2024 Israeli surveillance study
class FormulaPredictor implements RiskPredictor {
  @override
  PredictiveScore predict(Map<String, double> features, {GlobalConfig? config}) {
    double score = 0;
    final contributions = <String, double>{};

    // ── DEVELOPMENTAL COMPONENT (max ~40 pts) ──
    final compositeDq = features['compositeDq'] ?? 100;
    final devWeight = config?.predDevWeight ?? 0.40;
    final devPts = (100 - compositeDq) * devWeight;
    score += devPts;
    if (devPts > 2) contributions['developmental'] = devPts;

    // ── MULTI-DOMAIN PENALTY (max 15 pts) ──
    final numDelays = features['numDelays'] ?? 0;
    final delayMax = config?.predDelayMax ?? 15.0;
    final delayPts = (numDelays / 5) * delayMax;
    score += delayPts;
    if (delayPts > 1) contributions['multiDomainDelay'] = delayPts;

    // ── CONDITION RISKS (max ~20 pts) ──
    final autismWeight = config?.predAutismWeight ?? 0.08;
    final adhdWeight = config?.predAdhdWeight ?? 0.06;
    final behaviorWeight = config?.predBehaviorWeight ?? 0.06;
    final autismPts = (features['autismRisk'] ?? 0) * autismWeight;
    final adhdPts = (features['adhdRisk'] ?? 0) * adhdWeight;
    final behaviorPts = (features['behaviorRisk'] ?? 0) * behaviorWeight;
    score += autismPts + adhdPts + behaviorPts;
    if (autismPts > 1) contributions['autismRisk'] = autismPts;
    if (adhdPts > 1) contributions['adhdRisk'] = adhdPts;
    if (behaviorPts > 1) contributions['behaviorRisk'] = behaviorPts;

    // ── ENVIRONMENT (max ~15 pts) ──
    final phq9Weight = config?.predPhq9Weight ?? 0.05;
    final homeStimWeight = config?.predHomestimWeight ?? 0.05;
    final nutritionWeight = config?.predNutritionWeight ?? 0.05;

    final phq9 = features['phq9Score'] ?? 0;
    final phq9Pts = (phq9 / 27) * 100 * phq9Weight;
    score += phq9Pts;
    if (phq9Pts > 1) contributions['parentMentalHealth'] = phq9Pts;

    final homeStimRisk = features['homeStimRisk'] ?? 0;
    final homeStimPts = homeStimRisk * homeStimWeight;
    score += homeStimPts;
    if (homeStimPts > 1) contributions['homeStimulation'] = homeStimPts;

    final nutritionRisk = features['nutritionRisk'] ?? 0;
    final nutritionPts = nutritionRisk * nutritionWeight;
    score += nutritionPts;
    if (nutritionPts > 1) contributions['nutrition'] = nutritionPts;

    // ── TRAJECTORY (max 10 pts — only if 2+ screenings) ──
    final trajSevere = config?.predTrajSevere ?? 10.0;
    final trajModerate = config?.predTrajModerate ?? 7.0;
    final trajMild = config?.predTrajMild ?? 4.0;
    final trajStable = config?.predTrajStable ?? 2.0;

    final screeningCount = features['screeningCount'] ?? 1;
    if (screeningCount >= 2) {
      final dqDelta = features['compositeDqDelta'] ?? 0;
      double trajPts;
      if (dqDelta < -10) {
        trajPts = trajSevere;
      } else if (dqDelta < -5) {
        trajPts = trajModerate;
      } else if (dqDelta < 0) {
        trajPts = trajMild;
      } else if (dqDelta == 0) {
        trajPts = trajStable;
      } else {
        trajPts = 0;
      }
      score += trajPts;
      if (trajPts > 1) contributions['decliningScores'] = trajPts;
    }

    // ── CROSS-DOMAIN PATTERNS (bonus) ──
    final patternLangSocial = config?.predPatternLangSocial ?? 3.0;
    final patternToxicEnv = config?.predPatternToxicEnv ?? 3.0;
    final patternYoungDelays = config?.predPatternYoungDelays ?? 2.0;

    if (features['languagePlusSocialDelay'] == 1) {
      score += patternLangSocial;
      contributions['languageSocialPattern'] = patternLangSocial;
    }
    if (features['toxicEnvironment'] == 1) {
      score += patternToxicEnv;
      contributions['toxicEnvironment'] = patternToxicEnv;
    }
    if (features['youngWithManyDelays'] == 1) {
      score += patternYoungDelays;
      contributions['youngMultipleDelays'] = patternYoungDelays;
    }

    // Clamp to 0-100
    score = score.clamp(0, 100);

    // Determine category
    final category = _scoreToCategory(score, config: config);
    final categoryTe = _categoryToTelugu(category);

    // Determine trend
    final trend = _determineTrend(features, config: config);
    final trendTe = _trendToTelugu(trend);

    // Get top 3 contributing factors
    final sortedContribs = contributions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topKeys = sortedContribs.take(3).map((e) => e.key).toList();
    final topFactors = topKeys.map((k) => _factorToEnglish(k, features)).toList();
    final topFactorsTe = topKeys.map((k) => _factorToTelugu(k, features)).toList();

    return PredictiveScore(
      score: double.parse(score.toStringAsFixed(1)),
      category: category,
      categoryTe: categoryTe,
      trend: trend,
      trendTe: trendTe,
      topFactors: topFactors,
      topFactorsTe: topFactorsTe,
    );
  }

  static String _scoreToCategory(double score, {GlobalConfig? config}) {
    final catLow = config?.predCatLow ?? 25.0;
    final catMedium = config?.predCatMedium ?? 50.0;
    final catHigh = config?.predCatHigh ?? 75.0;
    if (score <= catLow) return 'Low';
    if (score <= catMedium) return 'Medium';
    if (score <= catHigh) return 'High';
    return 'Very High';
  }

  static String _categoryToTelugu(String category) {
    switch (category) {
      case 'Low':
        return 'తక్కువ';
      case 'Medium':
        return 'మధ్యస్థం';
      case 'High':
        return 'అధికం';
      case 'Very High':
        return 'చాలా అధికం';
      default:
        return category;
    }
  }

  static String _determineTrend(Map<String, double> features, {GlobalConfig? config}) {
    final screeningCount = features['screeningCount'] ?? 1;
    if (screeningCount < 2) return 'New';
    final delta = features['compositeDqDelta'] ?? 0;
    final improvingThreshold = config?.predTrendImproving ?? 5.0;
    final worseningThreshold = config?.predTrendWorsening ?? -5.0;
    if (delta > improvingThreshold) return 'Improving';
    if (delta < worseningThreshold) return 'Worsening';
    return 'Stable';
  }

  static String _trendToTelugu(String trend) {
    switch (trend) {
      case 'Improving':
        return 'మెరుగవుతోంది';
      case 'Stable':
        return 'స్థిరంగా';
      case 'Worsening':
        return 'క్షీణిస్తోంది';
      case 'New':
        return 'కొత్తది';
      default:
        return trend;
    }
  }

  static String _factorToEnglish(String key, Map<String, double> features) {
    switch (key) {
      case 'developmental':
        return 'Low developmental score (DQ=${features['compositeDq']?.toStringAsFixed(0)})';
      case 'multiDomainDelay':
        return '${features['numDelays']?.toInt()} domain delays detected';
      case 'autismRisk':
        return 'Autism screening risk (${_riskLabel(features['autismRisk'])})';
      case 'adhdRisk':
        return 'ADHD screening risk (${_riskLabel(features['adhdRisk'])})';
      case 'behaviorRisk':
        return 'Behavioral concerns (${_riskLabel(features['behaviorRisk'])})';
      case 'parentMentalHealth':
        return 'Parent mental health concern (PHQ-9=${features['phq9Score']?.toInt()})';
      case 'homeStimulation':
        return 'Low home stimulation';
      case 'nutrition':
        return 'Nutritional risk factors';
      case 'decliningScores':
        return 'Declining scores (${features['compositeDqDelta']?.toStringAsFixed(0)} DQ change)';
      case 'languageSocialPattern':
        return 'Language + Social delay pattern';
      case 'toxicEnvironment':
        return 'Parent depression + low stimulation';
      case 'youngMultipleDelays':
        return 'Multiple delays at young age';
      default:
        return key;
    }
  }

  static String _factorToTelugu(String key, Map<String, double> features) {
    switch (key) {
      case 'developmental':
        return 'తక్కువ అభివృద్ధి స్కోర్ (DQ=${features['compositeDq']?.toStringAsFixed(0)})';
      case 'multiDomainDelay':
        return '${features['numDelays']?.toInt()} డొమైన్ ఆలస్యాలు';
      case 'autismRisk':
        return 'ఆటిజం స్క్రీనింగ్ ప్రమాదం';
      case 'adhdRisk':
        return 'ADHD స్క్రీనింగ్ ప్రమాదం';
      case 'behaviorRisk':
        return 'ప్రవర్తన సమస్యలు';
      case 'parentMentalHealth':
        return 'తల్లిదండ్రుల మానసిక ఆరోగ్యం (PHQ-9=${features['phq9Score']?.toInt()})';
      case 'homeStimulation':
        return 'తక్కువ ఇంటి ఉద్దీపన';
      case 'nutrition':
        return 'పోషకాహార ప్రమాద కారకాలు';
      case 'decliningScores':
        return 'స్కోర్లు తగ్గుతున్నాయి (${features['compositeDqDelta']?.toStringAsFixed(0)} DQ మార్పు)';
      case 'languageSocialPattern':
        return 'భాష + సామాజిక ఆలస్యం';
      case 'toxicEnvironment':
        return 'తల్లి మానసిక ఒత్తిడి + తక్కువ ఉద్దీపన';
      case 'youngMultipleDelays':
        return 'చిన్న వయసులో బహుళ ఆలస్యాలు';
      default:
        return key;
    }
  }

  static String _riskLabel(double? val) {
    if (val == null) return 'Low';
    if (val >= 100) return 'High';
    if (val >= 50) return 'Moderate';
    return 'Low';
  }
}

/// Stub for future TFLite-based predictor.
/// Drop a .tflite model in assets/ml/ and implement this class.
class TFLitePredictor implements RiskPredictor {
  @override
  PredictiveScore predict(Map<String, double> features, {GlobalConfig? config}) {
    throw UnimplementedError(
        'TFLite predictor not yet available. Use FormulaPredictor.');
  }
}

/// Main prediction service — orchestrates feature extraction + prediction.
class PredictionService {
  static final RiskPredictor _predictor = FormulaPredictor();

  PredictionService._();

  /// Run predictive risk scoring for a child's screening result.
  ///
  /// [current] — the just-completed screening result
  /// [childAgeMonths] — the child's age
  /// [childRemoteId] — used to fetch previous results from Drift
  static Future<PredictiveScore> predictRisk({
    required SavedScreeningResult current,
    required int childAgeMonths,
    required int childRemoteId,
    GlobalConfig? config,
  }) async {
    // Fetch previous results from Drift for temporal features (skip on web)
    List<LocalScreeningResult> previousResults = [];
    if (DatabaseService.isAvailable) {
      try {
        final db = DatabaseService.db;
        final allResults = await db.screeningDao.getAllResults();
        previousResults = allResults
            .where((r) => r.childRemoteId == childRemoteId)
            .toList()
          ..sort((a, b) => b.id.compareTo(a.id));
      } catch (_) {
        // No previous results available
      }
    }

    // Extract features
    final features = FeatureExtractor.extract(
      current: current,
      childAgeMonths: childAgeMonths,
      previousResults: previousResults,
      config: config,
    );

    // Run prediction
    return _predictor.predict(features, config: config);
  }

  /// Backfill predictions for all existing results that don't have them yet.
  /// Called once on app startup to populate predictions for pre-existing data.
  static Future<int> backfillPredictions() async {
    if (kIsWeb) return 0; // No Drift on web — nothing to backfill

    int backfilledCount = 0;
    try {
      final db = DatabaseService.db;
      final allResults = await db.screeningDao.getAllResults();
      if (allResults.isEmpty) return 0;

      // Only process results missing predictions
      final unpredicted = allResults.where((r) => r.predictedRiskScore == null).toList();
      if (unpredicted.isEmpty) return 0;

      // Build child age lookup: childRemoteId → ageMonths
      // Try from session table first, fallback to DOB calculation
      final childAgeMap = <int, int>{};
      final allChildren = await db.childrenDao.getAllChildren();
      final now = DateTime.now();
      for (final child in allChildren) {
        if (child.remoteId != null) {
          final ageMonths = ((now.difference(child.dob).inDays) / 30.44).floor();
          childAgeMap[child.remoteId!] = ageMonths.clamp(0, 72);
        }
      }

      // Group all results by childRemoteId for temporal features
      final resultsByChild = <int, List<LocalScreeningResult>>{};
      for (final r in allResults) {
        if (r.childRemoteId == null) continue;
        resultsByChild.putIfAbsent(r.childRemoteId!, () => []).add(r);
      }
      // Sort each child's results by id DESC (most recent first)
      for (final list in resultsByChild.values) {
        list.sort((a, b) => b.id.compareTo(a.id));
      }

      // Process each unpredicted result
      for (final r in unpredicted) {
        if (r.childRemoteId == null) continue;
        final childId = r.childRemoteId!;
        final childAgeMonths = childAgeMap[childId] ?? 36; // fallback

        // Convert Drift row to SavedScreeningResult
        final saved = _driftToSaved(childId, r);

        // Get all results for this child (for temporal features)
        final childResults = resultsByChild[childId] ?? [];

        // Extract features & predict
        final features = FeatureExtractor.extract(
          current: saved,
          childAgeMonths: childAgeMonths,
          previousResults: childResults,
        );
        final prediction = _predictor.predict(features);

        // Update Drift row
        await db.screeningDao.updatePrediction(
          resultLocalId: r.id,
          predictedRiskScore: prediction.score,
          predictedRiskCategory: prediction.category,
          riskTrend: prediction.trend,
          topRiskFactorsJson: jsonEncode(prediction.topFactors),
        );
        backfilledCount++;
      }

      // ignore: avoid_print
      print('[PredictionService] Backfilled $backfilledCount / ${unpredicted.length} results');
    } catch (e) {
      // ignore: avoid_print
      print('[PredictionService] Backfill error: $e');
    }
    return backfilledCount;
  }

  /// Validate the prediction model against all existing screening results.
  ///
  /// Compares predicted risk category (from FormulaPredictor) against
  /// the actual `overall_risk` (ground truth from tool-based DQ scoring).
  /// Returns a [ModelValidationResult] with confusion matrix and metrics.
  static Future<ModelValidationResult> validateModel({GlobalConfig? config}) async {
    final categories = ['LOW', 'MEDIUM', 'HIGH'];
    // confusion[actual][predicted] = count
    final confusion = <String, Map<String, int>>{};
    for (final a in categories) {
      confusion[a] = {for (final p in categories) p: 0};
    }

    int total = 0;
    int correct = 0;
    final perCategoryTP = <String, int>{for (final c in categories) c: 0};
    final perCategoryFP = <String, int>{for (final c in categories) c: 0};
    final perCategoryFN = <String, int>{for (final c in categories) c: 0};

    try {
      final db = DatabaseService.db;
      final allResults = await db.screeningDao.getAllResults();
      if (allResults.isEmpty) return ModelValidationResult.empty();

      final allChildren = await db.childrenDao.getAllChildren();
      final now = DateTime.now();
      final childAgeMap = <int, int>{};
      for (final child in allChildren) {
        if (child.remoteId != null) {
          final ageMonths = ((now.difference(child.dob).inDays) / 30.44).floor();
          childAgeMap[child.remoteId!] = ageMonths.clamp(0, 72);
        }
      }

      // Group results by child for temporal features
      final resultsByChild = <int, List<LocalScreeningResult>>{};
      for (final r in allResults) {
        if (r.childRemoteId == null) continue;
        resultsByChild.putIfAbsent(r.childRemoteId!, () => []).add(r);
      }
      for (final list in resultsByChild.values) {
        list.sort((a, b) => b.id.compareTo(a.id));
      }

      // Validate each result
      for (final r in allResults) {
        if (r.childRemoteId == null) continue;
        final childId = r.childRemoteId!;
        final childAgeMonths = childAgeMap[childId] ?? 36;

        final saved = _driftToSaved(childId, r);
        final childResults = resultsByChild[childId] ?? [];

        final features = FeatureExtractor.extract(
          current: saved,
          childAgeMonths: childAgeMonths,
          previousResults: childResults,
          config: config,
        );
        final prediction = _predictor.predict(features, config: config);

        // Normalize: predictor returns 'Low'/'Medium'/'High'/'Very High'
        // ground truth is 'LOW'/'MEDIUM'/'HIGH'
        final actualRisk = r.overallRisk.toUpperCase();
        String predictedRisk = prediction.category.toUpperCase();
        // Merge 'VERY HIGH' into 'HIGH' for comparison
        if (predictedRisk == 'VERY HIGH') predictedRisk = 'HIGH';

        if (!categories.contains(actualRisk)) continue;

        total++;
        confusion[actualRisk]![predictedRisk] =
            (confusion[actualRisk]![predictedRisk] ?? 0) + 1;

        if (actualRisk == predictedRisk) {
          correct++;
          perCategoryTP[actualRisk] = perCategoryTP[actualRisk]! + 1;
        } else {
          perCategoryFN[actualRisk] = perCategoryFN[actualRisk]! + 1;
          perCategoryFP[predictedRisk] = perCategoryFP[predictedRisk]! + 1;
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[PredictionService] Validation error: $e');
    }

    if (total == 0) return ModelValidationResult.empty();

    final accuracy = correct / total;

    // Per-category sensitivity (recall) and precision
    final perCategorySensitivity = <String, double>{};
    final perCategoryPrecision = <String, double>{};
    for (final c in categories) {
      final tp = perCategoryTP[c]!;
      final fn = perCategoryFN[c]!;
      final fp = perCategoryFP[c]!;
      perCategorySensitivity[c] = (tp + fn) > 0 ? tp / (tp + fn) : 1.0;
      perCategoryPrecision[c] = (tp + fp) > 0 ? tp / (tp + fp) : 1.0;
    }

    // At-risk detection: sensitivity for HIGH+MEDIUM combined (catching any risk)
    final atRiskTP = perCategoryTP['HIGH']! + perCategoryTP['MEDIUM']!;
    final atRiskFN = perCategoryFN['HIGH']! + perCategoryFN['MEDIUM']!;
    final atRiskSensitivity = (atRiskTP + atRiskFN) > 0
        ? atRiskTP / (atRiskTP + atRiskFN)
        : 1.0;

    // Specificity for LOW (correctly identified healthy children)
    final lowTP = perCategoryTP['LOW']!;
    final lowFP = perCategoryFP['LOW']!;
    final specificity = (lowTP + lowFP) > 0 ? lowTP / (lowTP + lowFP) : 1.0;

    return ModelValidationResult(
      total: total,
      correct: correct,
      accuracy: accuracy,
      sensitivity: atRiskSensitivity,
      specificity: specificity,
      confusionMatrix: confusion,
      perCategorySensitivity: perCategorySensitivity,
      perCategoryPrecision: perCategoryPrecision,
      categories: categories,
    );
  }

  /// Validate the prediction model against Supabase screening results.
  ///
  /// Used when a dataset override is active (e.g. ECD Sample Data) where data
  /// lives only on Supabase, not in the local Drift database.
  /// [screeningResults] — list of Supabase screening result maps
  /// [children] — list of Supabase children maps (need dob for age)
  static Future<ModelValidationResult> validateModelFromSupabase({
    required List<Map<String, dynamic>> screeningResults,
    required List<Map<String, dynamic>> children,
    GlobalConfig? config,
  }) async {
    final categories = ['LOW', 'MEDIUM', 'HIGH'];
    final confusion = <String, Map<String, int>>{};
    for (final a in categories) {
      confusion[a] = {for (final p in categories) p: 0};
    }

    int total = 0;
    int correct = 0;
    final perCategoryTP = <String, int>{for (final c in categories) c: 0};
    final perCategoryFP = <String, int>{for (final c in categories) c: 0};
    final perCategoryFN = <String, int>{for (final c in categories) c: 0};

    try {
      if (screeningResults.isEmpty) return ModelValidationResult.empty();

      // Build child age map from children data
      final now = DateTime.now();
      final childAgeMap = <int, int>{};
      for (final child in children) {
        final id = child['id'] as int?;
        final dobStr = child['dob']?.toString();
        if (id != null && dobStr != null) {
          try {
            final dob = DateTime.parse(dobStr);
            final ageMonths = ((now.difference(dob).inDays) / 30.44).floor();
            childAgeMap[id] = ageMonths.clamp(0, 72);
          } catch (_) {}
        }
      }

      // Group results by child for temporal features
      final resultsByChild = <int, List<Map<String, dynamic>>>{};
      for (final r in screeningResults) {
        final childId = r['child_id'] as int?;
        if (childId == null) continue;
        resultsByChild.putIfAbsent(childId, () => []).add(r);
      }
      // Sort each child's results by id DESC (most recent first)
      for (final list in resultsByChild.values) {
        list.sort((a, b) => ((b['id'] as int?) ?? 0).compareTo((a['id'] as int?) ?? 0));
      }

      // Validate each result
      for (final r in screeningResults) {
        final childId = r['child_id'] as int?;
        if (childId == null) continue;
        final childAgeMonths = childAgeMap[childId] ?? 36;

        final saved = _supabaseToSaved(childId, r);
        final childResults = resultsByChild[childId] ?? [];

        // Convert previous results to SavedScreeningResult list for temporal features
        // FeatureExtractor needs List<LocalScreeningResult> for previousResults,
        // but we don't have Drift objects. We'll use the simplified extraction path
        // with only the current result (screeningCount=1, no temporal features).
        // This is acceptable because ECD sample data typically has 1 screening per child.
        final features = FeatureExtractor.extractFromSupabase(
          current: saved,
          childAgeMonths: childAgeMonths,
          previousResults: childResults,
          config: config,
        );
        final prediction = _predictor.predict(features, config: config);

        final actualRisk = (r['overall_risk']?.toString() ?? '').toUpperCase();
        String predictedRisk = prediction.category.toUpperCase();
        if (predictedRisk == 'VERY HIGH') predictedRisk = 'HIGH';

        if (!categories.contains(actualRisk)) continue;

        total++;
        confusion[actualRisk]![predictedRisk] =
            (confusion[actualRisk]![predictedRisk] ?? 0) + 1;

        if (actualRisk == predictedRisk) {
          correct++;
          perCategoryTP[actualRisk] = perCategoryTP[actualRisk]! + 1;
        } else {
          perCategoryFN[actualRisk] = perCategoryFN[actualRisk]! + 1;
          perCategoryFP[predictedRisk] = perCategoryFP[predictedRisk]! + 1;
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[PredictionService] Supabase validation error: $e');
    }

    if (total == 0) return ModelValidationResult.empty();

    final accuracy = correct / total;

    final perCategorySensitivity = <String, double>{};
    final perCategoryPrecision = <String, double>{};
    for (final c in categories) {
      final tp = perCategoryTP[c]!;
      final fn = perCategoryFN[c]!;
      final fp = perCategoryFP[c]!;
      perCategorySensitivity[c] = (tp + fn) > 0 ? tp / (tp + fn) : 1.0;
      perCategoryPrecision[c] = (tp + fp) > 0 ? tp / (tp + fp) : 1.0;
    }

    final atRiskTP = perCategoryTP['HIGH']! + perCategoryTP['MEDIUM']!;
    final atRiskFN = perCategoryFN['HIGH']! + perCategoryFN['MEDIUM']!;
    final atRiskSensitivity = (atRiskTP + atRiskFN) > 0
        ? atRiskTP / (atRiskTP + atRiskFN)
        : 1.0;

    final lowTP = perCategoryTP['LOW']!;
    final lowFP = perCategoryFP['LOW']!;
    final specificity = (lowTP + lowFP) > 0 ? lowTP / (lowTP + lowFP) : 1.0;

    return ModelValidationResult(
      total: total,
      correct: correct,
      accuracy: accuracy,
      sensitivity: atRiskSensitivity,
      specificity: specificity,
      confusionMatrix: confusion,
      perCategorySensitivity: perCategorySensitivity,
      perCategoryPrecision: perCategoryPrecision,
      categories: categories,
    );
  }

  /// Helper: convert a Supabase screening result map to SavedScreeningResult
  static SavedScreeningResult _supabaseToSaved(int childId, Map<String, dynamic> r, {double delayThreshold = 85}) {
    final domainDqs = <String, double>{};
    final domainDelays = <String, bool>{};

    final gmDq = (r['gm_dq'] as num?)?.toDouble();
    final fmDq = (r['fm_dq'] as num?)?.toDouble();
    final lcDq = (r['lc_dq'] as num?)?.toDouble();
    final cogDq = (r['cog_dq'] as num?)?.toDouble();
    final seDq = (r['se_dq'] as num?)?.toDouble();

    if (gmDq != null) { domainDqs['gm_dq'] = gmDq; domainDelays['gm_delay'] = gmDq < delayThreshold; }
    if (fmDq != null) { domainDqs['fm_dq'] = fmDq; domainDelays['fm_delay'] = fmDq < delayThreshold; }
    if (lcDq != null) { domainDqs['lc_dq'] = lcDq; domainDelays['lc_delay'] = lcDq < delayThreshold; }
    if (cogDq != null) { domainDqs['cog_dq'] = cogDq; domainDelays['cog_delay'] = cogDq < delayThreshold; }
    if (seDq != null) { domainDqs['se_dq'] = seDq; domainDelays['se_delay'] = seDq < delayThreshold; }

    DateTime createdAt;
    try {
      createdAt = DateTime.parse(r['created_at']?.toString() ?? '');
    } catch (_) {
      createdAt = DateTime.now();
    }

    return SavedScreeningResult(
      childId: childId,
      date: createdAt,
      overallRisk: r['overall_risk']?.toString() ?? 'LOW',
      overallRiskTe: '',
      referralNeeded: r['referral_needed'] == true,
      domainDqScores: domainDqs,
      domainDelays: domainDelays,
      concerns: const [],
      concernsTe: const [],
      toolsCompleted: (r['tools_completed'] as num?)?.toInt() ?? 0,
      toolsSkipped: (r['tools_skipped'] as num?)?.toInt() ?? 0,
      assessmentCycle: r['assessment_cycle']?.toString() ?? 'Baseline',
      baselineScore: (r['baseline_score'] as num?)?.toInt() ?? 0,
      baselineCategory: r['baseline_category']?.toString() ?? 'Low',
      numDelays: (r['num_delays'] as num?)?.toInt() ?? 0,
      autismRisk: r['autism_risk']?.toString() ?? 'Low',
      adhdRisk: r['adhd_risk']?.toString() ?? 'Low',
      behaviorRisk: r['behavior_risk']?.toString() ?? 'Low',
      behaviorScore: (r['behavior_score'] as num?)?.toInt() ?? 0,
    );
  }

  /// Helper: convert a Drift result row to SavedScreeningResult for prediction
  static SavedScreeningResult _driftToSaved(int childId, LocalScreeningResult r, {double delayThreshold = 85}) {
    final domainDqs = <String, double>{};
    final domainDelays = <String, bool>{};
    if (r.gmDq != null) { domainDqs['gm_dq'] = r.gmDq!; domainDelays['gm_delay'] = r.gmDq! < delayThreshold; }
    if (r.fmDq != null) { domainDqs['fm_dq'] = r.fmDq!; domainDelays['fm_delay'] = r.fmDq! < delayThreshold; }
    if (r.lcDq != null) { domainDqs['lc_dq'] = r.lcDq!; domainDelays['lc_delay'] = r.lcDq! < delayThreshold; }
    if (r.cogDq != null) { domainDqs['cog_dq'] = r.cogDq!; domainDelays['cog_delay'] = r.cogDq! < delayThreshold; }
    if (r.seDq != null) { domainDqs['se_dq'] = r.seDq!; domainDelays['se_delay'] = r.seDq! < delayThreshold; }

    final concerns = r.concernsJson != null
        ? (jsonDecode(r.concernsJson!) as List).cast<String>()
        : <String>[];
    final concernsTe = r.concernsTeJson != null
        ? (jsonDecode(r.concernsTeJson!) as List).cast<String>()
        : <String>[];

    return SavedScreeningResult(
      childId: childId,
      date: r.createdAt,
      overallRisk: r.overallRisk,
      overallRiskTe: r.overallRiskTe,
      referralNeeded: r.referralNeeded,
      domainDqScores: domainDqs,
      domainDelays: domainDelays,
      concerns: concerns,
      concernsTe: concernsTe,
      toolsCompleted: r.toolsCompleted,
      toolsSkipped: r.toolsSkipped,
      assessmentCycle: r.assessmentCycle,
      baselineScore: r.baselineScore,
      baselineCategory: r.baselineCategory,
      numDelays: r.numDelays,
      autismRisk: r.autismRisk,
      adhdRisk: r.adhdRisk,
      behaviorRisk: r.behaviorRisk,
      behaviorScore: r.behaviorScore,
    );
  }
}

/// Result of model validation containing accuracy metrics and confusion matrix.
class ModelValidationResult {
  final int total;
  final int correct;
  final double accuracy;
  final double sensitivity; // At-risk detection rate (HIGH+MEDIUM recall)
  final double specificity; // Healthy correctly identified (LOW precision)
  final Map<String, Map<String, int>> confusionMatrix; // actual → predicted → count
  final Map<String, double> perCategorySensitivity;
  final Map<String, double> perCategoryPrecision;
  final List<String> categories;

  const ModelValidationResult({
    required this.total,
    required this.correct,
    required this.accuracy,
    required this.sensitivity,
    required this.specificity,
    required this.confusionMatrix,
    required this.perCategorySensitivity,
    required this.perCategoryPrecision,
    required this.categories,
  });

  factory ModelValidationResult.empty() => ModelValidationResult(
        total: 0,
        correct: 0,
        accuracy: 0,
        sensitivity: 0,
        specificity: 0,
        confusionMatrix: const {},
        perCategorySensitivity: const {},
        perCategoryPrecision: const {},
        categories: const [],
      );

  bool get isEmpty => total == 0;

  double get f1Score {
    if (sensitivity + specificityAsPrec == 0) return 0;
    return 2 * (sensitivity * specificityAsPrec) / (sensitivity + specificityAsPrec);
  }

  double get specificityAsPrec => specificity;
}
