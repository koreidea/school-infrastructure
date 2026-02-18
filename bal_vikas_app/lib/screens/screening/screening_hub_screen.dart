import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/screening_tool.dart';
import '../../providers/screening_hub_provider.dart';
import '../../providers/screening_results_storage.dart';
import '../../providers/auth_provider.dart';
import '../../providers/screening_provider.dart';
import '../../config/api_config.dart';
import '../../utils/scoring/tool_scorer.dart';
import '../../providers/screening_config_provider.dart';
import 'tool_questionnaire_screen.dart';
import 'results_screen.dart';
import 'nutrition_challenge_screen.dart';
import '../../utils/telugu_transliterator.dart';

class ScreeningHubScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> session;
  final Map<String, dynamic> child;
  final int childAgeMonths;

  const ScreeningHubScreen({
    super.key,
    required this.session,
    required this.child,
    required this.childAgeMonths,
  });

  @override
  ConsumerState<ScreeningHubScreen> createState() => _ScreeningHubScreenState();
}

class _ScreeningHubScreenState extends ConsumerState<ScreeningHubScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the hub if not already
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hub = ref.read(screeningHubProvider);
      if (hub == null) {
        ref.read(screeningHubProvider.notifier).initialize(
          session: widget.session,
          child: widget.child,
          childAgeMonths: widget.childAgeMonths,
        );
      }
    });
  }

  void _startTool(ToolState toolState) {
    final hubNotifier = ref.read(screeningHubProvider.notifier);
    hubNotifier.updateToolStatus(toolState.config.type, ToolStatus.inProgress);

    Widget screen;
    switch (toolState.config.type) {
      case ScreeningToolType.nutritionAssessment:
        screen = NutritionChallengeScreen(
          toolConfig: toolState.config,
          childAgeMonths: widget.childAgeMonths,
          onComplete: (responses) {
            hubNotifier.completeTool(toolState.config.type, responses);
          },
        );
      default:
        screen = ToolQuestionnaireScreen(
          toolConfig: toolState.config,
          childAgeMonths: widget.childAgeMonths,
          onComplete: (responses) {
            hubNotifier.completeTool(toolState.config.type, responses);
          },
        );
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _skipTool(ToolState toolState) {
    ref.read(screeningHubProvider.notifier).skipTool(toolState.config.type);
  }

  void _viewResults() async {
    final hub = ref.read(screeningHubProvider);
    if (hub == null) return;

    // Store all responses in screening provider
    ref.read(screeningResponsesProvider.notifier).set({
      'hub_responses': hub.allResponses.map(
        (type, responses) => MapEntry(type.toString(), responses),
      ),
      'child_age_months': widget.childAgeMonths,
    });

    // Load DB scoring rules for each completed tool type
    Map<String, Map<String, dynamic>>? allScoringRules;
    try {
      final rulesMap = <String, Map<String, dynamic>>{};
      for (final toolType in hub.allResponses.keys) {
        final rules = await ref.read(scoringRulesProvider(toolType.name).future);
        if (rules != null) {
          rulesMap[toolType.name] = rules;
        }
      }
      if (rulesMap.isNotEmpty) allScoringRules = rulesMap;
    } catch (_) {}

    if (!mounted) return;

    // Compute and save results to local storage for child profile
    final toolResults = scoreAllTools(hub.allResponses, hub.childAgeMonths, allScoringRules: allScoringRules);
    final compositeResult = computeCompositeRisk(toolResults);

    final childId = widget.child['child_id'] as int?;
    if (childId != null) {
      final cdcResult = toolResults[ScreeningToolType.cdcMilestones];
      final domainDqs = cdcResult?.domainScores ?? {};
      final domainDelays = <String, bool>{};
      for (final entry in domainDqs.entries) {
        final domain = entry.key.replaceAll('_dq', '');
        domainDelays['${domain}_delay'] = entry.value < 85;
      }

      // Extract neuro-behavioral risk levels for challenge scoring
      final mchatResult = toolResults[ScreeningToolType.mchatAutism];
      final isaaResult = toolResults[ScreeningToolType.isaaAutism];
      final adhdResult = toolResults[ScreeningToolType.adhdScreening];
      final sdqResult = toolResults[ScreeningToolType.sdqBehavioral];

      // Autism risk: prefer MCHAT, fallback to ISAA
      final autismRisk = mapRiskLevel(
        mchatResult?.riskLevel ?? isaaResult?.riskLevel ?? 'LOW',
      );
      final adhdRisk = mapRiskLevel(adhdResult?.riskLevel ?? 'LOW');
      final behaviorRisk = mapRiskLevel(sdqResult?.riskLevel ?? 'LOW');
      final behaviorScore = sdqResult?.totalScore.toInt() ?? 0;
      final numDelays = domainDelays.values.where((d) => d).length;

      final bScore = computeBaselineScore(
        numDelays: numDelays,
        autismRisk: autismRisk,
        adhdRisk: adhdRisk,
        behaviorRisk: behaviorRisk,
      );
      final bCategory = baselineCategory(bScore);

      ref.read(screeningResultsStorageProvider.notifier).saveResult(
        childId,
        SavedScreeningResult(
          childId: childId,
          date: DateTime.now(),
          overallRisk: compositeResult.riskLevel,
          overallRiskTe: compositeResult.riskLevelTe,
          referralNeeded: compositeResult.referralNeeded,
          domainDqScores: Map<String, double>.from(domainDqs),
          domainDelays: domainDelays,
          concerns: List<String>.from(compositeResult.concerns),
          concernsTe: List<String>.from(compositeResult.concernsTe),
          toolsCompleted: toolResults.length,
          toolsSkipped: hub.skippedCount,
          assessmentCycle: hub.assessmentCycle,
          baselineScore: bScore,
          baselineCategory: bCategory,
          numDelays: numDelays,
          autismRisk: autismRisk,
          adhdRisk: adhdRisk,
          behaviorRisk: behaviorRisk,
          behaviorScore: behaviorScore,
        ),
      );
    }

    final sessionId = widget.session['session_id'] ?? widget.session['id'] ?? 0;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsScreen(sessionId: sessionId as int),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';
    final hub = ref.watch(screeningHubProvider);

    if (hub == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isTelugu ? 'స్క్రీనింగ్ సాధనాలు' : 'Screening Tools'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isTelugu ? 'స్క్రీనింగ్ సాధనాలు' : 'Screening Tools'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Progress header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.primary.withValues(alpha: 0.05),
            child: Column(
              children: [
                Text(
                  isTelugu
                      ? toTelugu(widget.child['name'] ?? 'Child')
                      : (widget.child['name'] ?? 'Child'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  isTelugu
                      ? '${widget.childAgeMonths} నెలలు • ${hub.completedCount}/${hub.totalCount} పూర్తయింది'
                      : '${widget.childAgeMonths} months • ${hub.completedCount}/${hub.totalCount} completed',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: hub.totalCount > 0
                      ? (hub.completedCount + hub.skippedCount) / hub.totalCount
                      : 0,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.riskLow),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),

          // Tool list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: hub.tools.length,
              itemBuilder: (context, index) {
                final tool = hub.tools[index];
                return _ToolCard(
                  toolState: tool,
                  isTelugu: isTelugu,
                  index: index + 1,
                  childAgeMonths: widget.childAgeMonths,
                  onStart: () => _startTool(tool),
                  onSkip: () => _skipTool(tool),
                );
              },
            ),
          ),

          // View Results button
          if (hub.allDone)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _viewResults,
                icon: const Icon(Icons.assessment),
                label: Text(
                  isTelugu ? 'ఫలితాలు చూడండి' : 'View Results',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.riskLow,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final ToolState toolState;
  final bool isTelugu;
  final int index;
  final int childAgeMonths;
  final VoidCallback onStart;
  final VoidCallback onSkip;

  static const _cdcAgeBrackets = [2, 4, 6, 9, 12, 18, 24, 30, 36, 48, 60];

  const _ToolCard({
    required this.toolState,
    required this.isTelugu,
    required this.index,
    required this.childAgeMonths,
    required this.onStart,
    required this.onSkip,
  });

  /// Get the actual question count for this tool at the child's age
  int _getQuestionCount(ScreeningToolConfig config) {
    if (!config.isAgeBracketFiltered) return config.questions.length;

    // For age-bracket-filtered tools (CDC), count only questions in the 2 tested brackets
    final brackets = _getCdcTwoBrackets(childAgeMonths);
    return config.questions
        .where((q) => q.ageMonths != null && brackets.contains(q.ageMonths))
        .length;
  }

  Set<int> _getCdcTwoBrackets(int ageMonths) {
    if (ageMonths < _cdcAgeBrackets.first) return {_cdcAgeBrackets.first};
    int currentIdx = 0;
    for (int i = 0; i < _cdcAgeBrackets.length; i++) {
      if (_cdcAgeBrackets[i] <= ageMonths) {
        currentIdx = i;
      } else {
        break;
      }
    }
    if (_cdcAgeBrackets[currentIdx] == ageMonths) {
      if (currentIdx > 0) return {_cdcAgeBrackets[currentIdx - 1], _cdcAgeBrackets[currentIdx]};
      return {_cdcAgeBrackets[currentIdx]};
    } else {
      if (currentIdx < _cdcAgeBrackets.length - 1) return {_cdcAgeBrackets[currentIdx], _cdcAgeBrackets[currentIdx + 1]};
      return {_cdcAgeBrackets[currentIdx]};
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = toolState.config;
    final status = toolState.status;

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case ToolStatus.completed:
        statusColor = AppColors.riskLow;
        statusIcon = Icons.check_circle;
      case ToolStatus.skipped:
        statusColor = Colors.grey;
        statusIcon = Icons.skip_next;
      case ToolStatus.inProgress:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
      case ToolStatus.pending:
        statusColor = Colors.blue;
        statusIcon = Icons.radio_button_unchecked;
    }

    final isDone = status == ToolStatus.completed || status == ToolStatus.skipped;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isDone ? 0 : 2,
      color: isDone ? Colors.grey.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDone
            ? BorderSide(color: Colors.grey.shade200)
            : BorderSide(color: config.color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Tool icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDone
                        ? Colors.grey.shade200
                        : config.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    config.icon,
                    color: isDone ? Colors.grey : config.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Tool info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$index. ${isTelugu ? config.nameTe : config.name}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDone ? Colors.grey : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_getQuestionCount(config)} ${isTelugu ? 'ప్రశ్నలు' : 'questions'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status icon
                Icon(statusIcon, color: statusColor, size: 24),
              ],
            ),

            // Action buttons
            if (!isDone) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSkip,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(isTelugu ? 'స్కిప్' : 'Skip'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: onStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: config.color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        isTelugu ? 'ప్రారంభించండి' : 'Start',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
