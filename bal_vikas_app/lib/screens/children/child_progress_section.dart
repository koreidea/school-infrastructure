import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/api_config.dart';
import '../../database/app_database.dart';
import '../../services/database_service.dart';

/// Progress section for child profile: DQ line chart + referral history + risk change
class ChildProgressSection extends ConsumerWidget {
  final int childRemoteId;
  final bool isTelugu;

  const ChildProgressSection({
    super.key,
    required this.childRemoteId,
    required this.isTelugu,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<_ProgressData>(
      future: _loadProgressData(childRemoteId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final data = snapshot.data!;
        if (data.results.isEmpty) return const SizedBox.shrink();

        final latestResult = data.results.first;
        final previousResult = data.results.length > 1 ? data.results[1] : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTelugu ? 'ప్రగతి' : 'Progress',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Assessment timeline chips
            if (data.results.length > 1) ...[
              _buildTimelineChips(data.results),
              const SizedBox(height: 12),
            ],

            // Assessment card — what the screening found (factual, clinical)
            _AssessmentCard(
              latestResult: latestResult,
              previousResult: previousResult,
              isTelugu: isTelugu,
            ),
            const SizedBox(height: 12),

            // Outlook card — what we predict will happen (advisory, forward-looking)
            if (latestResult.predictedRiskScore != null) ...[
              _OutlookCard(
                result: latestResult,
                isTelugu: isTelugu,
              ),
              const SizedBox(height: 16),
            ],

            // DQ Line Chart (only if multiple screenings)
            if (data.results.length >= 2) ...[
              Text(
                isTelugu ? 'DQ ట్రెండ్' : 'DQ Score Trend',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _DqLineChart(
                results: data.results,
                isTelugu: isTelugu,
              ),
              const SizedBox(height: 16),
            ],

            // Referral history
            if (data.referrals.isNotEmpty) ...[
              Text(
                isTelugu ? 'రిఫరల్ చరిత్ర' : 'Referral History',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...data.referrals.map((r) => _ReferralHistoryCard(
                    referral: r,
                    isTelugu: isTelugu,
                  )),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTimelineChips(List<LocalScreeningResult> results) {
    return Wrap(
      spacing: 8,
      children: results.reversed.map((r) {
        final date = r.createdAt.toIso8601String().split('T')[0];
        final cycle = r.assessmentCycle;
        return Chip(
          label: Text('$cycle\n$date',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10)),
          backgroundColor: cycle == 'Baseline'
              ? Colors.blue.shade50
              : Colors.green.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }

}

Future<_ProgressData> _loadProgressData(int childRemoteId) async {
  if (kIsWeb) {
    return const _ProgressData(results: [], referrals: []);
  }

  final db = DatabaseService.db;

  // Get all screening results for this child, ordered by date
  final allResults = await db.screeningDao.getAllResults();
  final childResults = allResults
      .where((r) => r.childRemoteId == childRemoteId)
      .toList()
    ..sort((a, b) => b.id.compareTo(a.id)); // latest first

  // Get referrals
  final referrals = await db.referralDao.getReferralsForChild(childRemoteId);

  return _ProgressData(results: childResults, referrals: referrals);
}

class _ProgressData {
  final List<LocalScreeningResult> results;
  final List<LocalReferral> referrals;
  const _ProgressData({required this.results, required this.referrals});
}

/// DQ Score Line Chart — shows domain DQ trends across screenings
class _DqLineChart extends StatelessWidget {
  final List<LocalScreeningResult> results;
  final bool isTelugu;

  const _DqLineChart({required this.results, required this.isTelugu});

  @override
  Widget build(BuildContext context) {
    // Results are latest-first, reverse for chronological order
    final chronological = results.reversed.toList();

    final domainConfigs = [
      (Colors.blue, (LocalScreeningResult r) => r.gmDq),
      (Colors.purple, (LocalScreeningResult r) => r.fmDq),
      (Colors.orange, (LocalScreeningResult r) => r.lcDq),
      (Colors.teal, (LocalScreeningResult r) => r.cogDq),
      (Colors.pink, (LocalScreeningResult r) => r.seDq),
    ];

    final lines = <LineChartBarData>[];
    for (final (color, getter) in domainConfigs) {
      final spots = <FlSpot>[];
      for (int i = 0; i < chronological.length; i++) {
        final val = getter(chronological[i]);
        if (val != null) {
          spots.add(FlSpot(i.toDouble(), val));
        }
      }
      if (spots.length >= 2) {
        lines.add(LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 2,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ));
      }
    }

    if (lines.isEmpty) {
      return Center(
        child: Text(
          isTelugu
              ? 'ట్రెండ్ చూడటానికి 2+ స్క్రీనింగ్‌లు అవసరం'
              : 'Need 2+ screenings to show trend',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    final domainNames = isTelugu
        ? ['స్థూల చలనం', 'సూక్ష్మ చలనం', 'భాష', 'జ్ఞాన', 'సామాజిక']
        : ['Gross Motor', 'Fine Motor', 'Language', 'Cognitive', 'Social-Emotional'];
    final domainColors = [Colors.blue, Colors.purple, Colors.orange, Colors.teal, Colors.pink];

    return Column(
      children: [
        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: List.generate(domainConfigs.length, (i) {
            final (color, getter) = domainConfigs[i];
            // Only show legend for domains that have data
            final hasData = chronological.any((r) => getter(r) != null);
            if (!hasData) return const SizedBox.shrink();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 12, height: 3, color: color),
                const SizedBox(width: 4),
                Text(domainNames[i], style: const TextStyle(fontSize: 10)),
              ],
            );
          }),
        ),
        const SizedBox(height: 8),
        // Chart
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              lineBarsData: lines,
              minY: 0,
              maxY: 120,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= chronological.length) {
                        return const SizedBox();
                      }
                      return Text(
                        '#${idx + 1}',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 25,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}',
                          style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                  left: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 25,
                getDrawingHorizontalLine: (value) {
                  if (value == 85) {
                    return FlLine(
                      color: Colors.red.shade200,
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    );
                  }
                  return FlLine(color: Colors.grey.shade200, strokeWidth: 0.5);
                },
              ),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => Colors.grey.shade800,
                  tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final lineIdx = spot.barIndex;
                      final name = lineIdx < domainNames.length ? domainNames[lineIdx] : '';
                      final color = lineIdx < domainColors.length ? domainColors[lineIdx] : Colors.white;
                      return LineTooltipItem(
                        '$name: ${spot.y.toStringAsFixed(0)}',
                        TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                      );
                    }).toList();
                  },
                ),
                handleBuiltInTouches: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Assessment card — shows the factual screening result (clinical, solid styling)
class _AssessmentCard extends StatelessWidget {
  final LocalScreeningResult latestResult;
  final LocalScreeningResult? previousResult;
  final bool isTelugu;

  const _AssessmentCard({
    required this.latestResult,
    required this.previousResult,
    required this.isTelugu,
  });

  @override
  Widget build(BuildContext context) {
    final riskCategory = latestResult.baselineCategory;
    final riskColor = switch (riskCategory) {
      'High' => AppColors.riskHigh,
      'Medium' => AppColors.riskMedium,
      _ => AppColors.riskLow,
    };
    final riskLabel = isTelugu
        ? switch (riskCategory) {
            'High' => 'అధిక ప్రమాదం',
            'Medium' => 'మధ్యస్థ ప్రమాదం',
            _ => 'తక్కువ ప్రమాదం',
          }
        : riskCategory.toUpperCase();
    final compositeDq = latestResult.compositeDq;
    final numDelays = latestResult.numDelays;
    final assessmentDate = latestResult.createdAt.toIso8601String().split('T')[0];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: riskColor.withValues(alpha: 0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left accent bar
            Container(
              width: 4,
              constraints: const BoxConstraints(minHeight: 100),
              color: riskColor,
            ),
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        Icon(Icons.fact_check, color: riskColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isTelugu ? 'స్క్రీనింగ్ ఫలితం' : 'Screening Result',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(assessmentDate,
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Risk badge row + risk change
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: riskColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            riskLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Risk change inline
                        if (previousResult != null) _buildRiskChange(riskColor),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // DQ + delays row
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isTelugu ? 'సమగ్ర DQ' : 'Composite DQ',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                            Text(
                              compositeDq?.toStringAsFixed(0) ?? '--',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(width: 32),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isTelugu ? 'డొమైన్ల ఆలస్యం' : 'Domains Delayed',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                            Text(
                              '$numDelays / 5',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: numDelays > 2 ? AppColors.riskHigh : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskChange(Color riskColor) {
    final latestCat = latestResult.baselineCategory;
    final prevCat = previousResult!.baselineCategory;

    if (latestCat == prevCat) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.horizontal_rule, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 4),
          Text(
            isTelugu ? 'మారలేదు' : 'Unchanged',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      );
    }

    final improved = _riskRank(latestCat) < _riskRank(prevCat);
    final changeColor = improved ? Colors.green.shade700 : Colors.red.shade700;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          improved ? Icons.arrow_downward : Icons.arrow_upward,
          size: 14,
          color: changeColor,
        ),
        const SizedBox(width: 4),
        Text(
          '$prevCat → $latestCat',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: changeColor),
        ),
      ],
    );
  }

  static int _riskRank(String category) {
    switch (category) {
      case 'High':
        return 2;
      case 'Medium':
        return 1;
      default:
        return 0;
    }
  }
}

/// Outlook card — shows predicted risk trajectory (advisory, forward-looking)
class _OutlookCard extends StatelessWidget {
  final LocalScreeningResult result;
  final bool isTelugu;

  const _OutlookCard({required this.result, required this.isTelugu});

  @override
  Widget build(BuildContext context) {
    final score = result.predictedRiskScore ?? 0;
    final category = result.predictedRiskCategory ?? 'Low';
    final trend = result.riskTrend ?? 'New';

    List<String> factors = [];
    if (result.topRiskFactorsJson != null) {
      try {
        factors = (jsonDecode(result.topRiskFactorsJson!) as List).cast<String>();
      } catch (_) {}
    }

    final categoryColor = _categoryColor(category);
    final trendIcon = _trendIcon(trend);
    final trendColor = _trendColor(trend);
    final trendLabel = isTelugu ? _trendTelugu(trend) : trend;

    return Container(
      decoration: BoxDecoration(
        color: Color.lerp(Colors.indigo.shade50, Colors.white, 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.auto_graph, color: Colors.indigo.shade400, size: 20),
              const SizedBox(width: 8),
              Text(
                isTelugu ? 'భవిష్యత్ అంచనా' : 'Outlook',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo.shade700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(trendIcon, size: 14, color: trendColor),
                    const SizedBox(width: 4),
                    Text(trendLabel,
                        style: TextStyle(fontSize: 11, color: trendColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Score bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 10,
                    backgroundColor: Colors.indigo.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${score.toStringAsFixed(0)}/100',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Explanation text
          Text(
            _explanationText(category, isTelugu),
            style: TextStyle(fontSize: 13, color: Colors.indigo.shade600),
          ),

          // Key concerns
          if (factors.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              isTelugu ? 'ముఖ్య ఆందోళనలు:' : 'Key concerns:',
              style: TextStyle(fontSize: 12, color: Colors.indigo.shade400),
            ),
            const SizedBox(height: 4),
            ...factors.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('  \u2022 ',
                          style: TextStyle(color: Colors.indigo.shade400, fontSize: 12)),
                      Expanded(
                        child: Text(f,
                            style: TextStyle(fontSize: 12, color: Colors.indigo.shade700)),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  static String _explanationText(String category, bool isTelugu) {
    if (isTelugu) {
      return switch (category) {
        'Very High' || 'High' => 'అధికమయ్యే అధిక అవకాశం',
        'Medium' => 'అధికమయ్యే మధ్యస్థ అవకాశం',
        _ => 'అధికమయ్యే అవకాశం తక్కువ',
      };
    }
    return switch (category) {
      'Very High' || 'High' => 'High likelihood of worsening',
      'Medium' => 'Moderate likelihood of worsening',
      _ => 'Low likelihood of worsening',
    };
  }

  static Color _categoryColor(String category) {
    switch (category) {
      case 'Very High':
        return Colors.red.shade700;
      case 'High':
        return Colors.orange.shade700;
      case 'Medium':
        return Colors.amber.shade700;
      default:
        return Colors.green.shade600;
    }
  }

  static IconData _trendIcon(String trend) {
    switch (trend) {
      case 'Improving':
        return Icons.trending_down;
      case 'Worsening':
        return Icons.trending_up;
      case 'Stable':
        return Icons.trending_flat;
      default:
        return Icons.fiber_new;
    }
  }

  static Color _trendColor(String trend) {
    switch (trend) {
      case 'Improving':
        return Colors.green;
      case 'Worsening':
        return Colors.red;
      case 'Stable':
        return Colors.grey.shade600;
      default:
        return Colors.blue;
    }
  }

  static String _trendTelugu(String trend) {
    switch (trend) {
      case 'Improving':
        return 'మెరుగవుతోంది';
      case 'Worsening':
        return 'క్షీణిస్తోంది';
      case 'Stable':
        return 'స్థిరంగా';
      default:
        return 'కొత్తది';
    }
  }
}

/// Referral history card
class _ReferralHistoryCard extends StatelessWidget {
  final LocalReferral referral;
  final bool isTelugu;

  const _ReferralHistoryCard({
    required this.referral,
    required this.isTelugu,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (referral.referralStatus) {
      'Completed' => AppColors.riskLow,
      'Under_Treatment' => Colors.blue,
      _ => Colors.orange,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${referral.referralType ?? ''} — ${referral.referralReason ?? ''}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${referral.referredDate ?? ''} • ${referral.referralStatus}',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                referral.referralStatus,
                style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
