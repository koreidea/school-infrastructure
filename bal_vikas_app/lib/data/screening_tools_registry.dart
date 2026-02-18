import '../models/screening_tool.dart';
import 'tool_cdc_milestones.dart';
import 'tool_rbsk.dart';
import 'tool_mchat.dart';
import 'tool_isaa.dart';
import 'tool_adhd.dart';
import 'tool_rbsk_behavioral.dart';
import 'tool_sdq.dart';
import 'tool_parent_child.dart';
import 'tool_phq9.dart';
import 'tool_home_stimulation.dart';
import 'tool_nutrition.dart';
import 'tool_rbsk_birth_defects.dart';
import 'tool_rbsk_diseases.dart';

/// All screening tools in administration order
final allScreeningTools = <ScreeningToolConfig>[
  cdcMilestonesConfig,
  rbskConfig,
  mchatConfig,
  isaaConfig,
  adhdConfig,
  rbskBehavioralConfig,
  sdqConfig,
  parentChildConfig,
  phq9Config,
  homeStimulationConfig,
  nutritionConfig,
  rbskBirthDefectsConfig,
  rbskDiseasesConfig,
];

/// Get tools applicable for a given child age
List<ScreeningToolConfig> getToolsForAge(int ageMonths) {
  return allScreeningTools
      .where((tool) => tool.isApplicableForAge(ageMonths))
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));
}

/// Get a specific tool config by type
ScreeningToolConfig? getToolConfig(ScreeningToolType type) {
  try {
    return allScreeningTools.firstWhere((t) => t.type == type);
  } catch (_) {
    return null;
  }
}
