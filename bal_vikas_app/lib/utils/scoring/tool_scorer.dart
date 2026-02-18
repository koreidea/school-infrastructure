import '../../models/screening_tool.dart';
import '../../data/screening_tools_registry.dart';
import '../../providers/admin_global_config_provider.dart';

/// Result from scoring a single tool
class ToolResult {
  final ScreeningToolType toolType;
  final String toolName;
  final String toolNameTe;
  final double totalScore;
  final double maxScore;
  final String riskLevel; // LOW, MEDIUM, HIGH
  final String riskLevelTe;
  final Map<String, double> domainScores;
  final List<String> concerns;
  final List<String> concernsTe;
  final bool referralNeeded;

  const ToolResult({
    required this.toolType,
    required this.toolName,
    required this.toolNameTe,
    required this.totalScore,
    required this.maxScore,
    required this.riskLevel,
    required this.riskLevelTe,
    this.domainScores = const {},
    this.concerns = const [],
    this.concernsTe = const [],
    this.referralNeeded = false,
  });
}

/// Score all completed tools and return results.
/// [allScoringRules] is optional DB-backed overrides keyed by tool type name,
/// e.g. {'cdcMilestones': {'threshold:__overall__:dq_medium': 85, ...}}
Map<ScreeningToolType, ToolResult> scoreAllTools(
  Map<ScreeningToolType, Map<String, dynamic>> allResponses,
  int childAgeMonths, {
  Map<String, Map<String, dynamic>>? allScoringRules,
}) {
  final results = <ScreeningToolType, ToolResult>{};

  for (final entry in allResponses.entries) {
    final type = entry.key;
    final responses = entry.value;
    final config = getToolConfig(type);
    if (config == null) continue;

    final rules = allScoringRules?[type.name];
    final result = _scoreToolByType(type, config, responses, childAgeMonths, rules);
    if (result != null) {
      results[type] = result;
    }
  }

  return results;
}

/// Helper to look up a scoring rule value, falling back to a default.
/// Keys follow the pattern: 'ruleType:domain:parameterName'
T _rule<T>(Map<String, dynamic>? rules, String key, T defaultValue) {
  if (rules == null || !rules.containsKey(key)) return defaultValue;
  final v = rules[key];
  if (v is T) return v;
  // Handle num → int/double coercion
  if (defaultValue is int && v is num) return v.toInt() as T;
  if (defaultValue is double && v is num) return v.toDouble() as T;
  return defaultValue;
}

ToolResult? _scoreToolByType(
  ScreeningToolType type,
  ScreeningToolConfig config,
  Map<String, dynamic> responses,
  int childAgeMonths,
  Map<String, dynamic>? rules,
) {
  switch (type) {
    case ScreeningToolType.cdcMilestones:
      return _scoreCdc(config, responses, childAgeMonths, rules);
    case ScreeningToolType.rbskTool:
      return _scoreRbsk(config, responses, rules);
    case ScreeningToolType.mchatAutism:
      return _scoreMchat(config, responses, rules);
    case ScreeningToolType.isaaAutism:
      return _scoreIsaa(config, responses, rules);
    case ScreeningToolType.adhdScreening:
      return _scoreAdhd(config, responses, rules);
    case ScreeningToolType.rbskBehavioral:
      return _scoreRbskBehavioral(config, responses, rules);
    case ScreeningToolType.sdqBehavioral:
      return _scoreSdq(config, responses, rules);
    case ScreeningToolType.parentChildInteraction:
      return _scoreParentChild(config, responses, rules);
    case ScreeningToolType.parentMentalHealth:
      return _scorePhq9(config, responses, rules);
    case ScreeningToolType.homeStimulation:
      return _scoreHomeStim(config, responses, rules);
    case ScreeningToolType.nutritionAssessment:
      return _scoreNutrition(config, responses, rules);
    case ScreeningToolType.rbskBirthDefects:
      return _scoreRbskBirthDefects(config, responses, rules);
    case ScreeningToolType.rbskDiseases:
      return _scoreRbskDiseases(config, responses, rules);
  }
}

/// Get the two CDC age brackets tested for a given child age.
/// Same logic as the questionnaire screen filter.
Set<int> _getCdcTestedBrackets(int childAgeMonths) {
  const cdcBrackets = [2, 4, 6, 9, 12, 18, 24, 30, 36, 48, 60];

  if (childAgeMonths < cdcBrackets.first) {
    return {cdcBrackets.first};
  }

  int currentIdx = 0;
  for (int i = 0; i < cdcBrackets.length; i++) {
    if (cdcBrackets[i] <= childAgeMonths) {
      currentIdx = i;
    } else {
      break;
    }
  }

  if (cdcBrackets[currentIdx] == childAgeMonths) {
    if (currentIdx > 0) {
      return {cdcBrackets[currentIdx - 1], cdcBrackets[currentIdx]};
    }
    return {cdcBrackets[currentIdx]};
  } else {
    if (currentIdx < cdcBrackets.length - 1) {
      return {cdcBrackets[currentIdx], cdcBrackets[currentIdx + 1]};
    }
    return {cdcBrackets[currentIdx]};
  }
}

/// CDC Milestones: DQ per domain (only evaluates the 2 tested brackets)
ToolResult _scoreCdc(ScreeningToolConfig config, Map<String, dynamic> responses, int childAgeMonths, Map<String, dynamic>? rules) {
  final domains = ['gm', 'fm', 'lc', 'cog', 'se'];
  final domainScores = <String, double>{};
  final concerns = <String>[];
  final concernsTe = <String>[];
  final domainNames = {'gm': 'Gross Motor', 'fm': 'Fine Motor', 'lc': 'Language', 'cog': 'Cognitive', 'se': 'Social-Emotional'};
  final domainNamesTe = {'gm': 'స్థూల చలనం', 'fm': 'సూక్ష్మ చలనం', 'lc': 'భాష', 'cog': 'జ్ఞానాత్మకం', 'se': 'సామాజిక-భావోద్వేగ'};

  // Only score the two brackets that were actually tested
  final testedBrackets = _getCdcTestedBrackets(childAgeMonths);
  final sortedBrackets = testedBrackets.toList()..sort();

  // Since we only test 2 brackets, assume child passes all brackets BELOW the
  // lowest tested bracket. This prevents DQ=0 for children who fail some items
  // in the lower tested bracket but are clearly beyond infancy.
  const cdcBrackets = [2, 4, 6, 9, 12, 18, 24, 30, 36, 48, 60];
  int baseBracket = 0;
  for (final b in cdcBrackets) {
    if (b < sortedBrackets.first) {
      baseBracket = b;
    } else {
      break;
    }
  }

  for (final domain in domains) {
    final domainQuestions = config.questions
        .where((q) => q.domain == domain && testedBrackets.contains(q.ageMonths))
        .toList();
    if (domainQuestions.isEmpty) continue;

    // Start devAge at the bracket before the lowest tested bracket
    int devAge = baseBracket;
    bool passedAnyBracket = false;
    for (final bracket in sortedBrackets) {
      final bracketQs = domainQuestions.where((q) => q.ageMonths == bracket).toList();
      if (bracketQs.isEmpty) {
        // No questions for this domain at this bracket — assume passed
        devAge = bracket;
        passedAnyBracket = true;
        continue;
      }
      final allPassed = bracketQs.every((q) => responses[q.id] == true);
      if (allPassed) {
        devAge = bracket;
        passedAnyBracket = true;
      } else {
        break;
      }
    }

    // If child didn't pass any tested bracket, check if they got ANY answer right.
    // If ALL answers are wrong, don't assume they'd pass earlier brackets.
    if (!passedAnyBracket) {
      final anyCorrect = domainQuestions.any((q) => responses[q.id] == true);
      if (!anyCorrect) {
        devAge = 0;
      }
    }

    final dq = childAgeMonths > 0 ? (devAge / childAgeMonths) * 100 : 0.0;
    domainScores['${domain}_dq'] = double.parse(dq.toStringAsFixed(1));

    final dqMedium = _rule<double>(rules, 'threshold:__overall__:dq_medium', 85);
    if (dq < dqMedium) {
      concerns.add('${domainNames[domain]} delay (DQ: ${dq.toStringAsFixed(0)})');
      concernsTe.add('${domainNamesTe[domain]} ఆలస్యం (DQ: ${dq.toStringAsFixed(0)})');
    }
  }

  final compositeDq = domainScores.values.isNotEmpty
      ? domainScores.values.reduce((a, b) => a + b) / domainScores.values.length
      : 0.0;

  final dqHigh = _rule<double>(rules, 'threshold:__overall__:dq_high', 70);
  final dqMediumOverall = _rule<double>(rules, 'threshold:__overall__:dq_medium', 85);

  String risk = 'LOW';
  String riskTe = 'తక్కువ';
  if (compositeDq < dqHigh) {
    risk = 'HIGH';
    riskTe = 'అధిక';
  } else if (compositeDq < dqMediumOverall) {
    risk = 'MEDIUM';
    riskTe = 'మధ్యస్థ';
  }

  return ToolResult(
    toolType: ScreeningToolType.cdcMilestones,
    toolName: config.name,
    toolNameTe: config.nameTe,
    totalScore: compositeDq,
    maxScore: 100,
    riskLevel: risk,
    riskLevelTe: riskTe,
    domainScores: domainScores,
    concerns: concerns,
    concernsTe: concernsTe,
    referralNeeded: compositeDq < dqHigh,
  );
}

/// RBSK: 3+ "Low Extent" (0) in any domain = refer
ToolResult _scoreRbsk(ScreeningToolConfig config, Map<String, dynamic> responses, Map<String, dynamic>? rules) {
  final domainScores = <String, double>{};
  final concerns = <String>[];
  final concernsTe = <String>[];
  bool referral = false;

  final lowCountThreshold = _rule<int>(rules, 'threshold:__overall__:low_count_referral', 3);
  final mediumRatio = _rule<double>(rules, 'threshold:__overall__:medium_ratio', 0.6);

  for (final domain in config.domains) {
    final domainQs = config.questions.where((q) => q.domain == domain).toList();
    int lowCount = 0;
    double total = 0;
    for (final q in domainQs) {
      final val = responses[q.id] as int? ?? 1;
      total += val;
      if (val == 0) lowCount++;
    }
    domainScores[domain] = total;
    if (lowCount >= lowCountThreshold) {
      referral = true;
      concerns.add('$domain: $lowCount low-extent items');
      concernsTe.add('$domain: $lowCount తక్కువ-స్థాయి అంశాలు');
    }
  }

  final totalScore = domainScores.values.fold(0.0, (a, b) => a + b);
  final maxScore = config.questions.length * 2.0;

  String risk = 'LOW';
  String riskTe = 'తక్కువ';
  if (referral) {
    risk = 'HIGH';
    riskTe = 'అధిక';
  } else if (totalScore < maxScore * mediumRatio) {
    risk = 'MEDIUM';
    riskTe = 'మధ్యస్థ';
  }

  return ToolResult(
    toolType: ScreeningToolType.rbskTool,
    toolName: config.name,
    toolNameTe: config.nameTe,
    totalScore: totalScore,
    maxScore: maxScore,
    riskLevel: risk,
    riskLevelTe: riskTe,
    domainScores: domainScores,
    concerns: concerns,
    concernsTe: concernsTe,
    referralNeeded: referral,
  );
}

/// M-CHAT: Count failures, 0-2=Low, 3-7=Medium, 8+=High
ToolResult _scoreMchat(ScreeningToolConfig config, Map<String, dynamic> responses, Map<String, dynamic>? rules) {
  int failures = 0;
  int criticalFailures = 0;
  final concerns = <String>[];
  final concernsTe = <String>[];

  // Items where "No" = fail (most items), items 11, 18, 20 where "Yes" = fail
  final reverseItems = {'mchat_11', 'mchat_18', 'mchat_20'};

  for (final q in config.questions) {
    final answer = responses[q.id];
    if (answer == null) continue;
    bool failed;
    if (reverseItems.contains(q.id)) {
      failed = answer == true; // Yes = fail for these items
    } else {
      failed = answer == false; // No = fail for most items
    }
    if (failed) {
      failures++;
      if (q.isCritical) criticalFailures++;
    }
  }

  final highThreshold = _rule<int>(rules, 'threshold:__overall__:high_failures', 8);
  final criticalThreshold = _rule<int>(rules, 'threshold:__overall__:critical_count', 3);
  final mediumThreshold = _rule<int>(rules, 'threshold:__overall__:medium_failures', 3);

  String risk = 'LOW';
  String riskTe = 'తక్కువ';
  if (failures >= highThreshold || criticalFailures >= criticalThreshold) {
    risk = 'HIGH';
    riskTe = 'అధిక';
    concerns.add('$failures items failed ($criticalFailures critical)');
    concernsTe.add('$failures అంశాలు విఫలం ($criticalFailures క్లిష్టమైన)');
  } else if (failures >= mediumThreshold) {
    risk = 'MEDIUM';
    riskTe = 'మధ్యస్థ';
    concerns.add('$failures items failed');
    concernsTe.add('$failures అంశాలు విఫలం');
  }

  return ToolResult(
    toolType: ScreeningToolType.mchatAutism,
    toolName: config.name,
    toolNameTe: config.nameTe,
    totalScore: failures.toDouble(),
    maxScore: 20,
    riskLevel: risk,
    riskLevelTe: riskTe,
    concerns: concerns,
    concernsTe: concernsTe,
    referralNeeded: failures >= highThreshold || criticalFailures >= criticalThreshold,
  );
}

/// ISAA: Sum 40 items (1-5), range 40-200. <70=Low, 70-106=Mild, 107+=Moderate+
ToolResult _scoreIsaa(ScreeningToolConfig config, Map<String, dynamic> responses, Map<String, dynamic>? rules) {
  final domainScores = <String, double>{};
  double totalScore = 0;

  for (final domain in config.domains) {
    final domainQs = config.questions.where((q) => q.domain == domain).toList();
    double domainTotal = 0;
    for (final q in domainQs) {
      domainTotal += (responses[q.id] as int? ?? 1).toDouble();
    }
    domainScores[domain] = domainTotal;
    totalScore += domainTotal;
  }

  String risk = 'LOW';
  String riskTe = 'తక్కువ';
  final concerns = <String>[];
  final concernsTe = <String>[];

  final moderateMin = _rule<double>(rules, 'threshold:__overall__:moderate_min', 107);
  final mildMin = _rule<double>(rules, 'threshold:__overall__:mild_min', 70);

  if (totalScore >= moderateMin) {
    risk = 'HIGH';
    riskTe = 'అధిక';
    concerns.add('Score $totalScore indicates moderate-severe autism');
    concernsTe.add('స్కోర్ $totalScore మధ్యస్థ-తీవ్ర ఆటిజంను సూచిస్తుంది');
  } else if (totalScore >= mildMin) {
    risk = 'MEDIUM';
    riskTe = 'మధ్యస్థ';
    concerns.add('Score $totalScore indicates mild autism');
    concernsTe.add('స్కోర్ $totalScore మైల్డ్ ఆటిజంను సూచిస్తుంది');
  }

  return ToolResult(
    toolType: ScreeningToolType.isaaAutism,
    toolName: config.name,
    toolNameTe: config.nameTe,
    totalScore: totalScore,
    maxScore: 200,
    riskLevel: risk,
    riskLevelTe: riskTe,
    domainScores: domainScores,
    concerns: concerns,
    concernsTe: concernsTe,
    referralNeeded: totalScore >= moderateMin,
  );
}

/// ADHD: Count Yes items. <4=Low, 4-5=Medium, 6+=High
ToolResult _scoreAdhd(ScreeningToolConfig config, Map<String, dynamic> responses, Map<String, dynamic>? rules) {
  final domainScores = <String, double>{};
  int totalYes = 0;

  for (final domain in config.domains) {
    final domainQs = config.questions.where((q) => q.domain == domain).toList();
    int count = 0;
    for (final q in domainQs) {
      if (responses[q.id] == true) count++;
    }
    domainScores[domain] = count.toDouble();
    totalYes += count;
  }

  String risk = 'LOW';
  String riskTe = 'తక్కువ';
  final concerns = <String>[];
  final concernsTe = <String>[];

  final highThreshold = _rule<int>(rules, 'threshold:__overall__:high_yes', 6);
  final mediumThreshold = _rule<int>(rules, 'threshold:__overall__:medium_yes', 4);

  if (totalYes >= highThreshold) {
    risk = 'HIGH';
    riskTe = 'అధిక';
    concerns.add('$totalYes ADHD indicators present');
    concernsTe.add('$totalYes ADHD సూచకాలు ఉన్నాయి');
  } else if (totalYes >= mediumThreshold) {
    risk = 'MEDIUM';
    riskTe = 'మధ్యస్థ';
  }

  return ToolResult(
    toolType: ScreeningToolType.adhdScreening,
    toolName: config.name,
    toolNameTe: config.nameTe,
    totalScore: totalYes.toDouble(),
    maxScore: 10,
    riskLevel: risk,
    riskLevelTe: riskTe,
    domainScores: domainScores,
    concerns: concerns,
    concernsTe: concernsTe,
    referralNeeded: totalYes >= highThreshold,
  );
}

/// RBSK Behavioral: Count Yes flags. 0=Low, 1-2=Medium, 3+=High
ToolResult _scoreRbskBehavioral(ScreeningToolConfig config, Map<String, dynamic> responses, Map<String, dynamic>? rules) {
  int yesCount = 0;
  final concerns = <String>[];
  final concernsTe = <String>[];

  for (final q in config.questions) {
    if (responses[q.id] == true) {
      yesCount++;
      if (q.isRedFlag) {
        concerns.add('Red flag: ${q.question}');
        concernsTe.add('ఎరుపు జెండా: ${q.questionTe}');
      }
    }
  }

  final highThreshold = _rule<int>(rules, 'threshold:__overall__:high_yes', 3);
  final mediumThreshold = _rule<int>(rules, 'threshold:__overall__:medium_yes', 1);

  String risk = 'LOW';
  String riskTe = 'తక్కువ';
  if (yesCount >= highThreshold) {
    risk = 'HIGH';
    riskTe = 'అధిక';
  } else if (yesCount >= mediumThreshold) {
    risk = 'MEDIUM';
    riskTe = 'మధ్యస్థ';
  }

  return ToolResult(
    toolType: ScreeningToolType.rbskBehavioral,
    toolName: config.name,
    toolNameTe: config.nameTe,
    totalScore: yesCount.toDouble(),
    maxScore: 10,
    riskLevel: risk,
    riskLevelTe: riskTe,
    concerns: concerns,
    concernsTe: concernsTe,
    referralNeeded: yesCount >= highThreshold,
  );
}

/// SDQ: Sum 4 difficulty subscales (not prosocial), range 0-40. <14=Low, 14-17=Medium, 17+=High
ToolResult _scoreSdq(ScreeningToolConfig config, Map<String, dynamic> responses, Map<String, dynamic>? rules) {
  final domainScores = <String, double>{};
  double difficultyTotal = 0;

  for (final domain in config.domains) {
    if (domain == 'impact') continue; // Skip impact items for total
    final domainQs = config.questions.where((q) => q.domain == domain).toList();
    double domainTotal = 0;
    for (final q in domainQs) {
      int val = responses[q.id] as int? ?? 0;
      if (q.isReverseScored) val = 2 - val; // Reverse: 0->2, 1->1, 2->0
      domainTotal += val;
    }
    domainScores[domain] = domainTotal;
    if (domain != 'prosocial') {
      difficultyTotal += domainTotal;
    }
  }

  String risk = 'LOW';
  String riskTe = 'తక్కువ';
  final concerns = <String>[];
  final concernsTe = <String>[];

  final highThreshold = _rule<double>(rules, 'threshold:__overall__:high_difficulty', 17);
  final mediumThreshold = _rule<double>(rules, 'threshold:__overall__:medium_difficulty', 14);

  if (difficultyTotal >= highThreshold) {
    risk = 'HIGH';
    riskTe = 'అధిక';
    concerns.add('Total difficulties score: ${difficultyTotal.toInt()}');
    concernsTe.add('మొత్తం కష్టాల స్కోర్: ${difficultyTotal.toInt()}');
  } else if (difficultyTotal >= mediumThreshold) {
    risk = 'MEDIUM';
    riskTe = 'మధ్యస్థ';
  }

  return ToolResult(
    toolType: ScreeningToolType.sdqBehavioral,
    toolName: config.name,
    toolNameTe: config.nameTe,
    totalScore: difficultyTotal,
    maxScore: 40,
    riskLevel: risk,
    riskLevelTe: riskTe,
    domainScores: domainScores,
    concerns: concerns,
    concernsTe: concernsTe,
    referralNeeded: difficultyTotal >= highThreshold,
  );
}

/// Parent-Child: Sum Yes, 0-8=High stim, 9-16=Medium, 17-24=Low stim (inverted: more yes = better)
ToolResult _scoreParentChild(ScreeningToolConfig config, Map<String, dynamic> responses, Map<String, dynamic>? rules) {
  final domainScores = <String, double>{};
  int totalYes = 0;

  for (final domain in config.domains) {
    final domainQs = config.questions.where((q) => q.domain == domain).toList();
    int count = 0;
    for (final q in domainQs) {
      if (responses[q.id] == true) count++;
    }
    domainScores[domain] = count.toDouble();
    totalYes += count;
  }

  // Higher score = better interaction
  final highMax = _rule<int>(rules, 'threshold:__overall__:high_max', 8);
  final mediumMax = _rule<int>(rules, 'threshold:__overall__:medium_max', 16);

  String risk = 'LOW';
  String riskTe = 'తక్కువ';
  if (totalYes <= highMax) {
    risk = 'HIGH';
    riskTe = 'అధిక';
  } else if (totalYes <= mediumMax) {
    risk = 'MEDIUM';
    riskTe = 'మధ్యస్థ';
  }

  return ToolResult(
    toolType: ScreeningToolType.parentChildInteraction,
    toolName: config.name,
    toolNameTe: config.nameTe,
    totalScore: totalYes.toDouble(),
    maxScore: 24,
    riskLevel: risk,
    riskLevelTe: riskTe,
    domainScores: domainScores,
  );
}

/// PHQ-9: Sum items 1-9 (0-3 each), range 0-27. <5=Minimal, 5-9=Mild, 10-14=Moderate, 15+=Severe
ToolResult _scorePhq9(ScreeningToolConfig config, Map<String, dynamic> responses, Map<String, dynamic>? rules) {
  double totalScore = 0;
  for (final q in config.questions) {
    if (q.id == 'phq_10') continue; // Skip functional impact item
    totalScore += (responses[q.id] as int? ?? 0).toDouble();
  }

  String risk = 'LOW';
  String riskTe = 'తక్కువ';
  final concerns = <String>[];
  final concernsTe = <String>[];

  final severeMin = _rule<double>(rules, 'threshold:__overall__:severe_min', 15);
  final moderateMin = _rule<double>(rules, 'threshold:__overall__:moderate_min', 10);
  final mildMin = _rule<double>(rules, 'threshold:__overall__:mild_min', 5);

  if (totalScore >= severeMin) {
    risk = 'HIGH';
    riskTe = 'అధిక';
    concerns.add('Severe depression symptoms (score: ${totalScore.toInt()})');
    concernsTe.add('తీవ్ర నిరాశ లక్షణాలు (స్కోర్: ${totalScore.toInt()})');
  } else if (totalScore >= moderateMin) {
    risk = 'MEDIUM';
    riskTe = 'మధ్యస్థ';
    concerns.add('Moderate depression symptoms');
    concernsTe.add('మధ్యస్థ నిరాశ లక్షణాలు');
  } else if (totalScore >= mildMin) {
    risk = 'MEDIUM';
    riskTe = 'మధ్యస్థ';
  }

  // Check for suicidality item
  if ((responses['phq_9'] as int? ?? 0) > 0) {
    concerns.add('Suicidal ideation reported - urgent referral needed');
    concernsTe.add('ఆత్మహత్య ఆలోచన నివేదించబడింది - అత్యవసర రిఫరల్ అవసరం');
  }

  return ToolResult(
    toolType: ScreeningToolType.parentMentalHealth,
    toolName: config.name,
    toolNameTe: config.nameTe,
    totalScore: totalScore,
    maxScore: 27,
    riskLevel: risk,
    riskLevelTe: riskTe,
    concerns: concerns,
    concernsTe: concernsTe,
    referralNeeded: totalScore >= severeMin || (responses['phq_9'] as int? ?? 0) > 0,
  );
}

/// Home Stimulation: Sum Yes, 0-7=Low stim (HIGH risk), 8-15=Medium, 16-22=Good (LOW risk)
ToolResult _scoreHomeStim(ScreeningToolConfig config, Map<String, dynamic> responses, Map<String, dynamic>? rules) {
  final domainScores = <String, double>{};
  int totalYes = 0;

  for (final domain in config.domains) {
    final domainQs = config.questions.where((q) => q.domain == domain).toList();
    int count = 0;
    for (final q in domainQs) {
      if (responses[q.id] == true) count++;
    }
    domainScores[domain] = count.toDouble();
    totalYes += count;
  }

  final highMax = _rule<int>(rules, 'threshold:__overall__:high_max', 7);
  final mediumMax = _rule<int>(rules, 'threshold:__overall__:medium_max', 15);

  String risk = 'LOW';
  String riskTe = 'తక్కువ';
  if (totalYes <= highMax) {
    risk = 'HIGH';
    riskTe = 'అధిక';
  } else if (totalYes <= mediumMax) {
    risk = 'MEDIUM';
    riskTe = 'మధ్యస్థ';
  }

  return ToolResult(
    toolType: ScreeningToolType.homeStimulation,
    toolName: config.name,
    toolNameTe: config.nameTe,
    totalScore: totalYes.toDouble(),
    maxScore: 22,
    riskLevel: risk,
    riskLevelTe: riskTe,
    domainScores: domainScores,
  );
}

/// Nutrition: Count risk factors
ToolResult _scoreNutrition(ScreeningToolConfig config, Map<String, dynamic> responses, Map<String, dynamic>? rules) {
  int riskFactors = 0;
  final concerns = <String>[];
  final concernsTe = <String>[];

  // Check clinical signs (positive = risk)
  final signQuestions = config.questions.where((q) => q.domain == 'signs');
  for (final q in signQuestions) {
    if (responses[q.id] == true) {
      riskFactors++;
      concerns.add(q.question);
      concernsTe.add(q.questionTe);
    }
  }

  // Check dietary deficiencies (No = risk for dietary questions)
  final dietaryQuestions = config.questions.where((q) => q.domain == 'dietary');
  int dietaryNo = 0;
  for (final q in dietaryQuestions) {
    if (responses[q.id] == false) dietaryNo++;
  }
  final dietaryNoThreshold = _rule<int>(rules, 'threshold:dietary:inadequate_count', 3);
  if (dietaryNo >= dietaryNoThreshold) {
    riskFactors++;
    concerns.add('Poor dietary diversity ($dietaryNo inadequate areas)');
    concernsTe.add('తక్కువ ఆహార వైవిధ్యం ($dietaryNo తగినంత ప్రాంతాలు)');
  }

  final highThreshold = _rule<int>(rules, 'threshold:__overall__:high_risk_factors', 3);
  final mediumThreshold = _rule<int>(rules, 'threshold:__overall__:medium_risk_factors', 1);

  String risk = 'LOW';
  String riskTe = 'తక్కువ';
  if (riskFactors >= highThreshold) {
    risk = 'HIGH';
    riskTe = 'అధిక';
  } else if (riskFactors >= mediumThreshold) {
    risk = 'MEDIUM';
    riskTe = 'మధ్యస్థ';
  }

  return ToolResult(
    toolType: ScreeningToolType.nutritionAssessment,
    toolName: config.name,
    toolNameTe: config.nameTe,
    totalScore: riskFactors.toDouble(),
    maxScore: 6,
    riskLevel: risk,
    riskLevelTe: riskTe,
    concerns: concerns,
    concernsTe: concernsTe,
    referralNeeded: riskFactors >= highThreshold,
  );
}

/// RBSK Birth Defects: Count Yes flags per domain. Any red flag = HIGH, 2+ = MEDIUM
ToolResult _scoreRbskBirthDefects(ScreeningToolConfig config, Map<String, dynamic> responses, Map<String, dynamic>? rules) {
  final domainScores = <String, double>{};
  int totalYes = 0;
  int redFlagCount = 0;
  final concerns = <String>[];
  final concernsTe = <String>[];

  for (final domain in config.domains) {
    final domainQs = config.questions.where((q) => q.domain == domain).toList();
    int count = 0;
    for (final q in domainQs) {
      if (responses[q.id] == true) {
        count++;
        totalYes++;
        if (q.isRedFlag) {
          redFlagCount++;
          concerns.add('${q.domainName}: ${q.question}');
          concernsTe.add('${q.domainNameTe}: ${q.questionTe}');
        }
      }
    }
    domainScores[domain] = count.toDouble();
  }

  final highRedFlags = _rule<int>(rules, 'threshold:__overall__:high_red_flags', 1);
  final highTotal = _rule<int>(rules, 'threshold:__overall__:high_total', 3);
  final mediumTotal = _rule<int>(rules, 'threshold:__overall__:medium_total', 1);

  String risk = 'LOW';
  String riskTe = 'తక్కువ';
  if (redFlagCount >= highRedFlags || totalYes >= highTotal) {
    risk = 'HIGH';
    riskTe = 'అధిక';
  } else if (totalYes >= mediumTotal) {
    risk = 'MEDIUM';
    riskTe = 'మధ్యస్థ';
  }

  return ToolResult(
    toolType: ScreeningToolType.rbskBirthDefects,
    toolName: config.name,
    toolNameTe: config.nameTe,
    totalScore: totalYes.toDouble(),
    maxScore: config.questions.length.toDouble(),
    riskLevel: risk,
    riskLevelTe: riskTe,
    domainScores: domainScores,
    concerns: concerns,
    concernsTe: concernsTe,
    referralNeeded: redFlagCount >= highRedFlags || totalYes >= highTotal,
  );
}

/// RBSK Diseases: Count Yes flags per domain. Any red flag = HIGH, 3+ = MEDIUM
ToolResult _scoreRbskDiseases(ScreeningToolConfig config, Map<String, dynamic> responses, Map<String, dynamic>? rules) {
  final domainScores = <String, double>{};
  int totalYes = 0;
  int redFlagCount = 0;
  final concerns = <String>[];
  final concernsTe = <String>[];

  for (final domain in config.domains) {
    final domainQs = config.questions.where((q) => q.domain == domain).toList();
    int count = 0;
    for (final q in domainQs) {
      if (responses[q.id] == true) {
        count++;
        totalYes++;
        if (q.isRedFlag) {
          redFlagCount++;
          concerns.add('${q.domainName}: ${q.question}');
          concernsTe.add('${q.domainNameTe}: ${q.questionTe}');
        }
      }
    }
    domainScores[domain] = count.toDouble();
  }

  final highRedFlags = _rule<int>(rules, 'threshold:__overall__:high_red_flags', 1);
  final highTotal = _rule<int>(rules, 'threshold:__overall__:high_total', 4);
  final mediumTotal = _rule<int>(rules, 'threshold:__overall__:medium_total', 2);

  String risk = 'LOW';
  String riskTe = 'తక్కువ';
  if (redFlagCount >= highRedFlags || totalYes >= highTotal) {
    risk = 'HIGH';
    riskTe = 'అధిక';
  } else if (totalYes >= mediumTotal) {
    risk = 'MEDIUM';
    riskTe = 'మధ్యస్థ';
  }

  return ToolResult(
    toolType: ScreeningToolType.rbskDiseases,
    toolName: config.name,
    toolNameTe: config.nameTe,
    totalScore: totalYes.toDouble(),
    maxScore: config.questions.length.toDouble(),
    riskLevel: risk,
    riskLevelTe: riskTe,
    domainScores: domainScores,
    concerns: concerns,
    concernsTe: concernsTe,
    referralNeeded: redFlagCount >= highRedFlags || totalYes >= highTotal,
  );
}

/// Compute overall composite risk from all tool results.
/// [config] provides admin-configurable thresholds; falls back to hardcoded defaults.
ToolResult computeCompositeRisk(Map<ScreeningToolType, ToolResult> results, {GlobalConfig? config}) {
  int highCount = 0;
  int mediumCount = 0;
  bool anyReferral = false;
  final concerns = <String>[];
  final concernsTe = <String>[];

  for (final result in results.values) {
    if (result.riskLevel == 'HIGH') highCount++;
    if (result.riskLevel == 'MEDIUM') mediumCount++;
    if (result.referralNeeded) anyReferral = true;
    concerns.addAll(result.concerns);
    concernsTe.addAll(result.concernsTe);
  }

  final cHighCount = config?.compositeHighCount ?? 2;
  final cMedHighCount = config?.compositeMediumHighCount ?? 1;
  final cMedCount = config?.compositeMediumCount ?? 2;
  final cHighWeight = config?.compositeHighWeight ?? 3;
  final cMedWeight = config?.compositeMediumWeight ?? 1;

  String risk = 'LOW';
  String riskTe = 'తక్కువ';
  if (highCount >= cHighCount || anyReferral) {
    risk = 'HIGH';
    riskTe = 'అధిక';
  } else if (highCount >= cMedHighCount || mediumCount >= cMedCount) {
    risk = 'MEDIUM';
    riskTe = 'మధ్యస్థ';
  }

  return ToolResult(
    toolType: ScreeningToolType.cdcMilestones, // placeholder
    toolName: 'Overall Assessment',
    toolNameTe: 'మొత్తం అంచనా',
    totalScore: (highCount * cHighWeight + mediumCount * cMedWeight).toDouble(),
    maxScore: results.length * cHighWeight.toDouble(),
    riskLevel: risk,
    riskLevelTe: riskTe,
    concerns: concerns,
    concernsTe: concernsTe,
    referralNeeded: anyReferral,
  );
}
