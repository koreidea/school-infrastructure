import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/screening_hub_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/api_config.dart';
import '../../models/screening_tool.dart';
import '../../utils/scoring/tool_scorer.dart';

class ResultsScreen extends ConsumerWidget {
  final int sessionId;

  const ResultsScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';
    final hub = ref.watch(screeningHubProvider);

    // Compute results from hub responses
    if (hub == null || hub.allResponses.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isTelugu ? 'ఫలితాలు' : 'Results'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                isTelugu ? 'ఫలితాలు అందుబాటులో లేవు' : 'No results available',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: Text(isTelugu ? 'హోమ్‌కు తిరిగి వెళ్ళండి' : 'Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    final toolResults = scoreAllTools(hub.allResponses, hub.childAgeMonths);
    final compositeResult = computeCompositeRisk(toolResults);

    Color riskColor;
    switch (compositeResult.riskLevel) {
      case 'HIGH':
        riskColor = AppColors.riskHigh;
      case 'MEDIUM':
        riskColor = AppColors.riskMedium;
      default:
        riskColor = AppColors.riskLow;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isTelugu ? 'ఫలితాలు' : 'Results'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Overall Risk Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: riskColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    compositeResult.riskLevel == 'HIGH'
                        ? Icons.warning
                        : compositeResult.riskLevel == 'MEDIUM'
                            ? Icons.info
                            : Icons.check_circle,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isTelugu ? compositeResult.riskLevelTe : compositeResult.riskLevel,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    isTelugu ? 'మొత్తం ప్రమాద వర్గం' : 'Overall Risk Category',
                    style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.8)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isTelugu
                        ? '${toolResults.length} సాధనాలు పూర్తయింది, ${hub.skippedCount} స్కిప్'
                        : '${toolResults.length} tools completed, ${hub.skippedCount} skipped',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
                  ),
                  if (compositeResult.referralNeeded) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isTelugu ? 'రిఫరల్ అవసరం' : 'Referral Needed',
                        style: TextStyle(color: riskColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tool-wise results
            Text(
              isTelugu ? 'సాధన-వారీ ఫలితాలు' : 'Tool-wise Results',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...toolResults.entries.map((entry) {
              return _ToolResultCard(
                result: entry.value,
                isTelugu: isTelugu,
              );
            }),

            // Skipped tools
            ...hub.tools
                .where((t) => t.status == ToolStatus.skipped)
                .map((t) => _SkippedToolCard(config: t.config, isTelugu: isTelugu)),

            const SizedBox(height: 20),

            // Concerns Summary
            if (compositeResult.concerns.isNotEmpty) ...[
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            isTelugu ? 'ఆందోళనలు' : 'Concerns',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...(isTelugu ? compositeResult.concernsTe : compositeResult.concerns)
                          .take(10)
                          .map((c) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(fontSize: 16)),
                                    Expanded(child: Text(c, style: const TextStyle(fontSize: 14))),
                                  ],
                                ),
                              )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Done Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  isTelugu ? 'పూర్తయింది' : 'Done',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ToolResultCard extends StatelessWidget {
  final ToolResult result;
  final bool isTelugu;

  const _ToolResultCard({required this.result, required this.isTelugu});

  /// Tools where lower score = better outcome (invert the bar display)
  static const _lowerIsBetter = {
    ScreeningToolType.mchatAutism,
    ScreeningToolType.isaaAutism,
    ScreeningToolType.adhdScreening,
    ScreeningToolType.rbskBehavioral,
    ScreeningToolType.sdqBehavioral,
    ScreeningToolType.parentMentalHealth,
    ScreeningToolType.nutritionAssessment,
  };

  /// Get DQ bar color using 3-tier thresholds
  static Color _dqColor(double dq) {
    if (dq >= 85) return AppColors.riskLow;
    if (dq >= 70) return AppColors.riskMedium;
    return AppColors.riskHigh;
  }

  @override
  Widget build(BuildContext context) {
    Color riskColor;
    switch (result.riskLevel) {
      case 'HIGH':
        riskColor = AppColors.riskHigh;
      case 'MEDIUM':
        riskColor = AppColors.riskMedium;
      default:
        riskColor = AppColors.riskLow;
    }

    final isInverted = _lowerIsBetter.contains(result.toolType);
    final rawRatio = result.maxScore > 0 ? (result.totalScore / result.maxScore).clamp(0.0, 1.0) : 0.0;
    // For "lower is better" tools: invert the bar so 0/27 shows as full green
    final barValue = isInverted ? 1.0 - rawRatio : rawRatio;
    // For "lower is better" tools: show correct count (e.g. 14/20 instead of 6/20)
    final displayScore = isInverted ? (result.maxScore - result.totalScore) : result.totalScore;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: riskColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    isTelugu ? result.toolNameTe : result.toolName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isTelugu ? result.riskLevelTe : result.riskLevel,
                    style: TextStyle(
                      color: riskColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Score bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: barValue,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(riskColor),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${displayScore.toStringAsFixed(0)}/${result.maxScore.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: riskColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            // Domain scores (if CDC milestones, show DQ per domain)
            if (result.domainScores.isNotEmpty && result.toolType == ScreeningToolType.cdcMilestones) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              ...result.domainScores.entries.map((e) {
                final domainCode = e.key.replaceAll('_dq', '');
                final domainNames = {'gm': 'Gross Motor', 'fm': 'Fine Motor', 'lc': 'Language', 'cog': 'Cognitive', 'se': 'Social-Emotional'};
                final domainNamesTe = {'gm': 'స్థూల చలనం', 'fm': 'సూక్ష్మ చలనం', 'lc': 'భాష', 'cog': 'జ్ఞానాత్మకం', 'se': 'సామాజిక-భావోద్వేగ'};
                final dq = e.value;
                final dqBarColor = _dqColor(dq);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          isTelugu ? (domainNamesTe[domainCode] ?? domainCode) : (domainNames[domainCode] ?? domainCode),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: (dq / 100).clamp(0.0, 1.0),
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(dqBarColor),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dq.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: dqBarColor,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            // Concerns
            if (result.concerns.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...(isTelugu ? result.concernsTe : result.concerns).take(3).map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '• $c',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  )),
            ],

            if (result.referralNeeded)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.local_hospital, size: 16, color: AppColors.riskHigh),
                    const SizedBox(width: 4),
                    Text(
                      isTelugu ? 'రిఫరల్ సిఫారసు' : 'Referral recommended',
                      style: const TextStyle(fontSize: 12, color: AppColors.riskHigh, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SkippedToolCard extends StatelessWidget {
  final ScreeningToolConfig config;
  final bool isTelugu;

  const _SkippedToolCard({required this.config, required this.isTelugu});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(config.icon, color: Colors.grey, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isTelugu ? config.nameTe : config.name,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isTelugu ? 'స్కిప్' : 'Skipped',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
