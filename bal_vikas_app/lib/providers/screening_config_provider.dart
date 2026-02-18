import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/screening_tool.dart';
import '../data/screening_tools_registry.dart';
import '../services/database_service.dart';
import '../utils/icon_color_mapper.dart';

/// Provides screening tool configs from Drift DB, falling back to hardcoded data
final screeningToolConfigsProvider =
    FutureProvider<List<ScreeningToolConfig>>((ref) async {
  // On web, skip Drift — use hardcoded fallback directly
  if (kIsWeb) return allScreeningTools;

  try {
    final db = DatabaseService.db;
    final dbConfigs = await db.screeningConfigDao.getAllActiveToolConfigs();

    if (dbConfigs.isEmpty) {
      return allScreeningTools;
    }

    final result = <ScreeningToolConfig>[];
    final dbToolTypes = <ScreeningToolType>{};
    for (final config in dbConfigs) {
      final questions = await db.screeningConfigDao.getQuestionsForTool(config.id);
      final options = await db.screeningConfigDao.getResponseOptionsForTool(config.id);

      // Convert DB response options to model ResponseOption
      final responseOptionsList = options.map((o) {
        final value = jsonDecode(o.valueJson);
        return ResponseOption(
          value: value is int ? value : (value as num).toInt(),
          label: o.labelEn,
          labelTe: o.labelTe,
          color: mapColorHex(o.colorHex),
        );
      }).toList();

      // Convert DB questions to model ScreeningQuestion
      final questionsList = questions.map((q) {
        return ScreeningQuestion(
          id: q.code,
          question: q.textEn,
          questionTe: q.textTe,
          domain: q.domain ?? '',
          domainName: q.domainNameEn,
          domainNameTe: q.domainNameTe,
          category: q.category,
          categoryTe: q.categoryTe,
          ageMonths: q.ageMonths,
          isCritical: q.isCritical,
          isRedFlag: q.isRedFlag,
          isReverseScored: q.isReverseScored,
          unit: q.unit,
          overrideFormat: q.overrideFormat != null
              ? _parseResponseFormat(q.overrideFormat!)
              : null,
          responseOptions: responseOptionsList.isNotEmpty ? responseOptionsList : null,
        );
      }).toList();

      // Parse domains from JSON
      final domains = (jsonDecode(config.domainsJson) as List).cast<String>();

      // Map tool_type string to enum
      final toolType = _parseToolType(config.toolType);
      if (toolType == null) continue;

      dbToolTypes.add(toolType);
      result.add(ScreeningToolConfig(
        type: toolType,
        id: config.toolId,
        name: config.name,
        nameTe: config.nameTe,
        description: config.description,
        descriptionTe: config.descriptionTe,
        minAgeMonths: config.minAgeMonths,
        maxAgeMonths: config.maxAgeMonths,
        responseFormat: _parseResponseFormat(config.responseFormat),
        domains: domains,
        icon: mapIconName(config.iconName),
        color: mapColorHex(config.colorHex),
        order: config.sortOrder,
        isAgeBracketFiltered: config.isAgeBracketFiltered,
        questions: questionsList,
      ));
    }

    // Merge: add hardcoded tools not present in DB
    for (final tool in allScreeningTools) {
      if (!dbToolTypes.contains(tool.type)) {
        result.add(tool);
      }
    }

    return result;
  } catch (_) {
    return allScreeningTools;
  }
});

/// Provides tools filtered by age, from DB with hardcoded fallback
final toolsForAgeProvider =
    FutureProvider.family<List<ScreeningToolConfig>, int>((ref, ageMonths) async {
  final allTools = await ref.watch(screeningToolConfigsProvider.future);
  return allTools
      .where((t) => ageMonths >= t.minAgeMonths && ageMonths <= t.maxAgeMonths)
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));
});

/// Provides scoring rules for a tool type from Drift DB
final scoringRulesProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, toolType) async {
  // On web, no Drift — return null to use hardcoded scoring
  if (kIsWeb) return null;

  try {
    final db = DatabaseService.db;
    final rules = await db.screeningConfigDao.getScoringRulesForToolType(toolType);

    if (rules.isEmpty) return null;

    final result = <String, dynamic>{};
    for (final rule in rules) {
      final key = '${rule.ruleType}:${rule.domain ?? '__overall__'}:${rule.parameterName}';
      result[key] = jsonDecode(rule.parameterValueJson);
    }
    return result;
  } catch (_) {
    return null;
  }
});

// ── Helpers ─────────────────────────────────────────────────────────────

ScreeningToolType? _parseToolType(String type) {
  for (final t in ScreeningToolType.values) {
    if (t.name == type) return t;
  }
  return null;
}

ResponseFormat _parseResponseFormat(String format) {
  switch (format) {
    case 'yesNo':
      return ResponseFormat.yesNo;
    case 'threePoint':
      return ResponseFormat.threePoint;
    case 'fourPoint':
      return ResponseFormat.fourPoint;
    case 'fivePoint':
      return ResponseFormat.fivePoint;
    case 'numericInput':
      return ResponseFormat.numericInput;
    case 'mixed':
      return ResponseFormat.mixed;
    default:
      return ResponseFormat.yesNo;
  }
}
