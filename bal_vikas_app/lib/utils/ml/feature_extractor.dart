import 'dart:convert';
import '../../database/app_database.dart';
import '../../providers/admin_global_config_provider.dart';
import '../../providers/screening_results_storage.dart';

/// Extracts ML-ready features from screening results for predictive risk scoring.
///
/// Static features come from the current screening result.
/// Temporal features (deltas, trends) come from comparing with previous results.
class FeatureExtractor {
  FeatureExtractor._();

  /// Extract all features from the current result and optional history.
  /// Returns a normalized feature map suitable for the predictor.
  static Map<String, double> extract({
    required SavedScreeningResult current,
    required int childAgeMonths,
    List<LocalScreeningResult> previousResults = const [],
    GlobalConfig? config,
  }) {
    final features = <String, double>{};

    // ── Static features (current screening) ──
    final dqScores = current.domainDqScores;
    features['gmDq'] = dqScores['gm_dq'] ?? 100;
    features['fmDq'] = dqScores['fm_dq'] ?? 100;
    features['lcDq'] = dqScores['lc_dq'] ?? 100;
    features['cogDq'] = dqScores['cog_dq'] ?? 100;
    features['seDq'] = dqScores['se_dq'] ?? 100;

    // Composite DQ — average of available domains
    final dqValues = dqScores.values.where((v) => v > 0).toList();
    features['compositeDq'] = dqValues.isNotEmpty
        ? dqValues.reduce((a, b) => a + b) / dqValues.length
        : 100;

    features['numDelays'] = current.numDelays.toDouble();
    features['autismRisk'] = _riskToNumeric(current.autismRisk);
    features['adhdRisk'] = _riskToNumeric(current.adhdRisk);
    features['behaviorRisk'] = _riskToNumeric(current.behaviorRisk);
    features['behaviorScore'] = current.behaviorScore.toDouble();
    features['referralNeeded'] = current.referralNeeded ? 1 : 0;
    features['toolsCompleted'] = current.toolsCompleted.toDouble();
    features['toolsSkipped'] = current.toolsSkipped.toDouble();
    features['childAgeMonths'] = childAgeMonths.toDouble();

    // ── Tool-specific scores (parsed from toolResultsJson of latest Drift result) ──
    _extractToolSpecificScores(features, previousResults, current, config: config);

    // ── Temporal features (requires previous screening) ──
    final prevResult = _getMostRecentPrevious(previousResults);
    if (prevResult != null) {
      features['screeningCount'] = (previousResults.length + 1).toDouble();

      final prevCompositeDq = prevResult.compositeDq ?? 100;
      features['compositeDqDelta'] = features['compositeDq']! - prevCompositeDq;
      features['gmDqDelta'] = (dqScores['gm_dq'] ?? 100) - (prevResult.gmDq ?? 100);
      features['fmDqDelta'] = (dqScores['fm_dq'] ?? 100) - (prevResult.fmDq ?? 100);
      features['lcDqDelta'] = (dqScores['lc_dq'] ?? 100) - (prevResult.lcDq ?? 100);
      features['cogDqDelta'] = (dqScores['cog_dq'] ?? 100) - (prevResult.cogDq ?? 100);
      features['seDqDelta'] = (dqScores['se_dq'] ?? 100) - (prevResult.seDq ?? 100);

      // Risk direction: worsened=1, same=0, improved=-1
      final currentRank = _overallRiskRank(current.overallRisk);
      final prevRank = _overallRiskRank(prevResult.overallRisk);
      features['riskChanged'] = (currentRank - prevRank).toDouble();

      // Days since last screening
      final daysDiff = current.date.difference(prevResult.createdAt).inDays;
      features['daysSinceLastScreening'] = daysDiff.toDouble().clamp(0, 365);

      // Count of newly delayed domains (were OK, now delayed)
      features['newDelaysCount'] = _countNewDelays(current, prevResult, config: config);
    } else {
      features['screeningCount'] = 1;
      features['compositeDqDelta'] = 0;
      features['gmDqDelta'] = 0;
      features['fmDqDelta'] = 0;
      features['lcDqDelta'] = 0;
      features['cogDqDelta'] = 0;
      features['seDqDelta'] = 0;
      features['riskChanged'] = 0;
      features['daysSinceLastScreening'] = 0;
      features['newDelaysCount'] = 0;
    }

    // ── Cross-domain patterns (configurable thresholds) ──
    final langSocialDq = config?.featLangSocialDq ?? 80.0;
    final toxicPhq9 = config?.featToxicPhq9 ?? 10.0;
    final toxicHomestim = config?.featToxicHomestim ?? 80.0;
    final youngDelaysCount = config?.featYoungDelaysCount ?? 3.0;
    final youngAgeMax = config?.featYoungAgeMax ?? 24.0;

    features['languagePlusSocialDelay'] =
        (features['lcDq']! < langSocialDq && features['seDq']! < langSocialDq) ? 1 : 0;
    features['toxicEnvironment'] =
        (features['phq9Score']! >= toxicPhq9 && features['homeStimRisk']! >= toxicHomestim) ? 1 : 0;
    features['youngWithManyDelays'] =
        (features['numDelays']! >= youngDelaysCount && childAgeMonths < youngAgeMax) ? 1 : 0;

    return features;
  }

  /// Extract features from Supabase screening results (used when data lives only on Supabase).
  /// [current] — SavedScreeningResult built from Supabase map
  /// [previousResults] — all Supabase result maps for this child, sorted by id DESC
  static Map<String, double> extractFromSupabase({
    required SavedScreeningResult current,
    required int childAgeMonths,
    List<Map<String, dynamic>> previousResults = const [],
    GlobalConfig? config,
  }) {
    final features = <String, double>{};

    // ── Static features (same as Drift path) ──
    final dqScores = current.domainDqScores;
    features['gmDq'] = dqScores['gm_dq'] ?? 100;
    features['fmDq'] = dqScores['fm_dq'] ?? 100;
    features['lcDq'] = dqScores['lc_dq'] ?? 100;
    features['cogDq'] = dqScores['cog_dq'] ?? 100;
    features['seDq'] = dqScores['se_dq'] ?? 100;

    final dqValues = dqScores.values.where((v) => v > 0).toList();
    features['compositeDq'] = dqValues.isNotEmpty
        ? dqValues.reduce((a, b) => a + b) / dqValues.length
        : 100;

    features['numDelays'] = current.numDelays.toDouble();
    features['autismRisk'] = _riskToNumeric(current.autismRisk);
    features['adhdRisk'] = _riskToNumeric(current.adhdRisk);
    features['behaviorRisk'] = _riskToNumeric(current.behaviorRisk);
    features['behaviorScore'] = current.behaviorScore.toDouble();
    features['referralNeeded'] = current.referralNeeded ? 1 : 0;
    features['toolsCompleted'] = current.toolsCompleted.toDouble();
    features['toolsSkipped'] = current.toolsSkipped.toDouble();
    features['childAgeMonths'] = childAgeMonths.toDouble();

    // ── Tool-specific scores from Supabase tool_results JSON ──
    features['phq9Score'] = 0;
    features['homeStimScore'] = 0;
    features['homeStimRisk'] = 0;
    features['nutritionScore'] = 0;
    features['nutritionRisk'] = 0;
    features['parentChildScore'] = 0;
    features['mchatFailures'] = 0;

    // Try to extract from the current result's tool_results if available
    if (previousResults.isNotEmpty) {
      final currentMap = previousResults.first;
      if (currentMap['tool_results'] != null) {
        _extractToolScoresFromJson(features, currentMap['tool_results'], config: config);
      }
    }

    // ── Temporal features (from Supabase maps) ──
    // previousResults contains ALL results for this child sorted by id DESC
    // Find the "previous" result (not the current one)
    Map<String, dynamic>? prevMap;
    if (previousResults.length >= 2) {
      // First is most recent (likely current), second is previous
      prevMap = previousResults[1];
    }

    if (prevMap != null) {
      features['screeningCount'] = previousResults.length.toDouble();

      final prevCompositeDq = (prevMap['composite_dq'] as num?)?.toDouble() ?? 100;
      features['compositeDqDelta'] = features['compositeDq']! - prevCompositeDq;
      features['gmDqDelta'] = (dqScores['gm_dq'] ?? 100) - ((prevMap['gm_dq'] as num?)?.toDouble() ?? 100);
      features['fmDqDelta'] = (dqScores['fm_dq'] ?? 100) - ((prevMap['fm_dq'] as num?)?.toDouble() ?? 100);
      features['lcDqDelta'] = (dqScores['lc_dq'] ?? 100) - ((prevMap['lc_dq'] as num?)?.toDouble() ?? 100);
      features['cogDqDelta'] = (dqScores['cog_dq'] ?? 100) - ((prevMap['cog_dq'] as num?)?.toDouble() ?? 100);
      features['seDqDelta'] = (dqScores['se_dq'] ?? 100) - ((prevMap['se_dq'] as num?)?.toDouble() ?? 100);

      // Risk direction
      final currentRank = _overallRiskRank(current.overallRisk);
      final prevRank = _overallRiskRank(prevMap['overall_risk']?.toString() ?? 'LOW');
      features['riskChanged'] = (currentRank - prevRank).toDouble();

      // Days since last screening
      try {
        final prevDate = DateTime.parse(prevMap['created_at']?.toString() ?? '');
        final daysDiff = current.date.difference(prevDate).inDays;
        features['daysSinceLastScreening'] = daysDiff.toDouble().clamp(0, 365);
      } catch (_) {
        features['daysSinceLastScreening'] = 0;
      }

      features['newDelaysCount'] = _countNewDelaysFromMap(current, prevMap, config: config);
    } else {
      features['screeningCount'] = 1;
      features['compositeDqDelta'] = 0;
      features['gmDqDelta'] = 0;
      features['fmDqDelta'] = 0;
      features['lcDqDelta'] = 0;
      features['cogDqDelta'] = 0;
      features['seDqDelta'] = 0;
      features['riskChanged'] = 0;
      features['daysSinceLastScreening'] = 0;
      features['newDelaysCount'] = 0;
    }

    // ── Cross-domain patterns ──
    final langSocialDq = config?.featLangSocialDq ?? 80.0;
    final toxicPhq9 = config?.featToxicPhq9 ?? 10.0;
    final toxicHomestim = config?.featToxicHomestim ?? 80.0;
    final youngDelaysCount = config?.featYoungDelaysCount ?? 3.0;
    final youngAgeMax = config?.featYoungAgeMax ?? 24.0;

    features['languagePlusSocialDelay'] =
        (features['lcDq']! < langSocialDq && features['seDq']! < langSocialDq) ? 1 : 0;
    features['toxicEnvironment'] =
        (features['phq9Score']! >= toxicPhq9 && features['homeStimRisk']! >= toxicHomestim) ? 1 : 0;
    features['youngWithManyDelays'] =
        (features['numDelays']! >= youngDelaysCount && childAgeMonths < youngAgeMax) ? 1 : 0;

    return features;
  }

  /// Extract tool-specific scores from Supabase tool_results JSONB
  static void _extractToolScoresFromJson(
    Map<String, double> features,
    dynamic toolResultsRaw, {
    GlobalConfig? config,
  }) {
    try {
      Map<String, dynamic> toolResults;
      if (toolResultsRaw is String) {
        toolResults = jsonDecode(toolResultsRaw) as Map<String, dynamic>;
      } else if (toolResultsRaw is Map) {
        toolResults = Map<String, dynamic>.from(toolResultsRaw);
      } else {
        return;
      }

      final toolResponses = toolResults['tool_responses'] as Map<String, dynamic>? ?? {};

      // PHQ-9
      final phq9 = toolResponses['phq9'] as Map<String, dynamic>?;
      if (phq9 != null) {
        double phq9Sum = 0;
        for (int i = 1; i <= 9; i++) {
          final val = phq9['phq9_$i'];
          if (val is num) phq9Sum += val;
          if (val is String) phq9Sum += (val == 'Yes' || val == 'yes') ? 1 : 0;
        }
        features['phq9Score'] = phq9Sum;
      }

      // Home Stimulation
      final homeStim = toolResponses['homeStimulation'] as Map<String, dynamic>?;
      if (homeStim != null) {
        int yesCount = 0;
        for (final v in homeStim.values) {
          if (v == 'Yes' || v == 'yes' || v == true) yesCount++;
        }
        features['homeStimScore'] = yesCount.toDouble();
        final hsHigh = config?.featHomestimHigh ?? 7.0;
        final hsMedium = config?.featHomestimMedium ?? 15.0;
        features['homeStimRisk'] = yesCount <= hsHigh ? 100 : (yesCount <= hsMedium ? 50 : 0);
      }

      // Nutrition
      final nutrition = toolResponses['nutritionAssessment'] as Map<String, dynamic>?;
      if (nutrition != null) {
        int riskFactors = 0;
        for (final entry in nutrition.entries) {
          if (entry.key.startsWith('nutr_clinical_') && (entry.value == 'Yes' || entry.value == true)) {
            riskFactors++;
          }
          if (entry.key.startsWith('nutr_diet_') && (entry.value == 'No' || entry.value == false)) {
            riskFactors++;
          }
        }
        features['nutritionScore'] = riskFactors.toDouble();
        final nutHigh = config?.featNutritionHigh ?? 3.0;
        final nutMedium = config?.featNutritionMedium ?? 1.0;
        features['nutritionRisk'] = riskFactors >= nutHigh ? 100 : (riskFactors >= nutMedium ? 50 : 0);
      }

      // M-CHAT failures
      final mchat = toolResponses['mchat'] as Map<String, dynamic>?;
      if (mchat != null) {
        int failures = 0;
        final reverseItems = {'mchat_11', 'mchat_18', 'mchat_20'};
        for (final entry in mchat.entries) {
          final isReverse = reverseItems.contains(entry.key);
          final isYes = entry.value == 'Yes' || entry.value == 'yes' || entry.value == true;
          if (isReverse && isYes) failures++;
          if (!isReverse && !isYes) failures++;
        }
        features['mchatFailures'] = failures.toDouble();
      }
    } catch (_) {
      // Parse failure — keep defaults
    }
  }

  /// Count newly delayed domains from Supabase map (previous result)
  static double _countNewDelaysFromMap(
      SavedScreeningResult current, Map<String, dynamic> previous, {GlobalConfig? config}) {
    int count = 0;
    final delayThreshold = config?.delayDqThreshold ?? 85.0;
    final domains = ['gm', 'fm', 'lc', 'cog', 'se'];
    final prevDqs = {
      'gm': (previous['gm_dq'] as num?)?.toDouble(),
      'fm': (previous['fm_dq'] as num?)?.toDouble(),
      'lc': (previous['lc_dq'] as num?)?.toDouble(),
      'cog': (previous['cog_dq'] as num?)?.toDouble(),
      'se': (previous['se_dq'] as num?)?.toDouble(),
    };

    for (final d in domains) {
      final wasOk = (prevDqs[d] ?? 100) >= delayThreshold;
      final isDelayed = current.domainDelays['${d}_delay'] == true;
      if (wasOk && isDelayed) count++;
    }
    return count.toDouble();
  }

  /// Map risk string (Low/Moderate/High) to numeric value.
  static double _riskToNumeric(String risk) {
    switch (risk) {
      case 'High':
        return 100;
      case 'Moderate':
        return 50;
      default:
        return 0;
    }
  }

  static int _overallRiskRank(String risk) {
    switch (risk) {
      case 'HIGH':
        return 2;
      case 'MEDIUM':
        return 1;
      default:
        return 0;
    }
  }

  /// Get the most recent previous result (not the current one).
  static LocalScreeningResult? _getMostRecentPrevious(
      List<LocalScreeningResult> previousResults) {
    if (previousResults.isEmpty) return null;
    // previousResults are ordered by createdAt DESC; first is most recent
    return previousResults.first;
  }

  /// Parse tool-specific scores from the Drift results or from the current SavedScreeningResult.
  static void _extractToolSpecificScores(
    Map<String, double> features,
    List<LocalScreeningResult> previousResults,
    SavedScreeningResult current, {
    GlobalConfig? config,
  }) {
    // Defaults
    features['phq9Score'] = 0;
    features['homeStimScore'] = 0;
    features['homeStimRisk'] = 0;
    features['nutritionScore'] = 0;
    features['nutritionRisk'] = 0;
    features['parentChildScore'] = 0;
    features['mchatFailures'] = 0;

    // Try to parse from the latest Drift result's toolResultsJson
    // (previousResults contains all results including current if loaded from Drift)
    // We also check the current result's concerns for fallback signals
    LocalScreeningResult? latestDrift;
    if (previousResults.isNotEmpty) {
      latestDrift = previousResults.first;
    }

    if (latestDrift?.toolResultsJson != null) {
      try {
        final toolResults = jsonDecode(latestDrift!.toolResultsJson!) as Map<String, dynamic>;
        final toolResponses = toolResults['tool_responses'] as Map<String, dynamic>? ?? {};

        // PHQ-9: Sum items 1-9 (each 0-3)
        final phq9 = toolResponses['phq9'] as Map<String, dynamic>?;
        if (phq9 != null) {
          double phq9Sum = 0;
          for (int i = 1; i <= 9; i++) {
            final val = phq9['phq9_$i'];
            if (val is num) phq9Sum += val;
            if (val is String) phq9Sum += (val == 'Yes' || val == 'yes') ? 1 : 0;
          }
          features['phq9Score'] = phq9Sum;
        }

        // Home Stimulation: count 'Yes' answers (higher = better)
        final homeStim = toolResponses['homeStimulation'] as Map<String, dynamic>?;
        if (homeStim != null) {
          int yesCount = 0;
          for (final v in homeStim.values) {
            if (v == 'Yes' || v == 'yes' || v == true) yesCount++;
          }
          features['homeStimScore'] = yesCount.toDouble();
          // Risk: <=high = HIGH(100), <=medium = MEDIUM(50), >medium = LOW(0)
          final hsHigh = config?.featHomestimHigh ?? 7.0;
          final hsMedium = config?.featHomestimMedium ?? 15.0;
          features['homeStimRisk'] = yesCount <= hsHigh ? 100 : (yesCount <= hsMedium ? 50 : 0);
        }

        // Nutrition: count risk factors
        final nutrition = toolResponses['nutritionAssessment'] as Map<String, dynamic>?;
        if (nutrition != null) {
          int riskFactors = 0;
          for (final entry in nutrition.entries) {
            // Clinical signs: Yes = risk; Dietary: No = risk
            if (entry.key.startsWith('nutr_clinical_') && (entry.value == 'Yes' || entry.value == true)) {
              riskFactors++;
            }
            if (entry.key.startsWith('nutr_diet_') && (entry.value == 'No' || entry.value == false)) {
              riskFactors++;
            }
          }
          features['nutritionScore'] = riskFactors.toDouble();
          final nutHigh = config?.featNutritionHigh ?? 3.0;
          final nutMedium = config?.featNutritionMedium ?? 1.0;
          features['nutritionRisk'] = riskFactors >= nutHigh ? 100 : (riskFactors >= nutMedium ? 50 : 0);
        }

        // Parent-Child Interaction: count 'Yes' answers (higher = better)
        final pci = toolResponses['parentChildInteraction'] as Map<String, dynamic>?;
        if (pci != null) {
          int yesCount = 0;
          for (final v in pci.values) {
            if (v == 'Yes' || v == 'yes' || v == true) yesCount++;
          }
          features['parentChildScore'] = yesCount.toDouble();
        }

        // M-CHAT: count failures
        final mchat = toolResponses['mchat'] as Map<String, dynamic>?;
        if (mchat != null) {
          int failures = 0;
          final reverseItems = {'mchat_11', 'mchat_18', 'mchat_20'};
          for (final entry in mchat.entries) {
            final isReverse = reverseItems.contains(entry.key);
            final isYes = entry.value == 'Yes' || entry.value == 'yes' || entry.value == true;
            // Normal: No = fail; Reverse: Yes = fail
            if (isReverse && isYes) failures++;
            if (!isReverse && !isYes) failures++;
          }
          features['mchatFailures'] = failures.toDouble();
        }
      } catch (_) {
        // Parse failure — keep defaults
      }
    }
  }

  /// Count domains that are newly delayed (OK in previous, delayed now).
  static double _countNewDelays(
      SavedScreeningResult current, LocalScreeningResult previous, {GlobalConfig? config}) {
    int count = 0;
    final delayThreshold = config?.delayDqThreshold ?? 85.0;
    final domains = ['gm', 'fm', 'lc', 'cog', 'se'];
    final prevDqs = {
      'gm': previous.gmDq,
      'fm': previous.fmDq,
      'lc': previous.lcDq,
      'cog': previous.cogDq,
      'se': previous.seDq,
    };

    for (final d in domains) {
      final wasOk = (prevDqs[d] ?? 100) >= delayThreshold;
      final isDelayed = current.domainDelays['${d}_delay'] == true;
      if (wasOk && isDelayed) count++;
    }
    return count.toDouble();
  }
}
