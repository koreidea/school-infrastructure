import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/api_config.dart';
import '../../models/school.dart';
import '../../models/enrolment.dart';
import '../../models/demand_plan.dart';
import '../../models/priority_score.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../inspection/inspection_screen.dart';
import '../../services/export_service.dart';

class SchoolProfileScreen extends ConsumerWidget {
  final School school;
  const SchoolProfileScreen({super.key, required this.school});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrolmentAsync = ref.watch(schoolEnrolmentProvider(school.id));
    final demandsAsync = ref.watch(schoolDemandPlansProvider(school.id));
    final priorityAsync = ref.watch(schoolPriorityScoreProvider(school.id));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(school.schoolName, style: const TextStyle(fontSize: 16)),
        actions: [
          if (ref.watch(currentUserProvider).value?.canInspect ?? true)
            IconButton(
              icon: const Icon(Icons.assignment),
              tooltip: 'Field Inspection',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InspectionScreen(school: school),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
            onPressed: () {
              final enrolment = enrolmentAsync.value ?? [];
              final demands = demandsAsync.value ?? [];
              ExportService.exportSchoolPdf(
                school: school,
                enrolment: enrolment,
                demands: demands,
              ).then((_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PDF exported')),
                  );
                }
              }).catchError((e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              });
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // School Info Card
          _SchoolInfoCard(school: school),
          const SizedBox(height: 16),

          // Priority Score Breakdown
          priorityAsync.when(
            data: (score) => score != null
                ? _PriorityBreakdownCard(score: score)
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Enrolment Trend
          Text('Enrolment Trend',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          enrolmentAsync.when(
            data: (records) => _EnrolmentChart(records: records),
            loading: () => const SizedBox(
                height: 200, child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SizedBox(
                height: 200, child: Center(child: Text('Error: $e'))),
          ),
          const SizedBox(height: 16),

          // ML Forecast section
          _ForecastSection(schoolId: school.id),
          const SizedBox(height: 24),

          // Demand Plans
          Text('Infrastructure Demand Plans',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          demandsAsync.when(
            data: (demands) => _DemandPlansList(demands: demands),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }
}

class _SchoolInfoCard extends StatelessWidget {
  final School school;
  const _SchoolInfoCard({required this.school});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: school.priorityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.school, color: school.priorityColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(school.schoolName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('UDISE: ${school.udiseCode}',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                if (school.priorityLevel != null)
                  Column(
                    children: [
                      Text(
                        school.priorityScore?.toStringAsFixed(0) ?? '-',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: school.priorityColor,
                        ),
                      ),
                      Text(
                        AppConstants.priorityLabel(school.priorityLevel!),
                        style: TextStyle(
                            fontSize: 11, color: school.priorityColor),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            _InfoRow(Icons.location_on, 'Location',
                '${school.mandalName ?? "N/A"}, ${school.districtName ?? "N/A"}'),
            const SizedBox(height: 8),
            _InfoRow(Icons.category, 'Category', school.categoryLabel),
            const SizedBox(height: 8),
            _InfoRow(Icons.business, 'Management', school.managementLabel),
            const SizedBox(height: 8),
            _InfoRow(Icons.people, 'Enrolment',
                '${school.totalEnrolment ?? "N/A"} students'),
            if (school.hasLocation) ...[
              const SizedBox(height: 8),
              _InfoRow(Icons.gps_fixed, 'Coordinates',
                  '${school.latitude!.toStringAsFixed(4)}, ${school.longitude!.toStringAsFixed(4)}'),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Expanded(
          child: Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ),
      ],
    );
  }
}

class _PriorityBreakdownCard extends StatelessWidget {
  final SchoolPriorityScore score;
  const _PriorityBreakdownCard({required this.score});

  @override
  Widget build(BuildContext context) {
    final priorityColor = AppColors.forPriority(score.priorityLevel);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Icon(Icons.analytics, color: priorityColor, size: 20),
                const SizedBox(width: 8),
                Text('Priority Score Breakdown',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: priorityColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '${score.compositeScore.toStringAsFixed(0)} — ${score.priorityLabel}',
                    style: TextStyle(
                      color: priorityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Factor bars
            _ScoreBar(
              label: 'Enrolment Pressure',
              score: score.enrolmentPressureScore,
              weight: 30,
              icon: Icons.people,
              color: const Color(0xFF5C6BC0),
            ),
            const SizedBox(height: 10),
            _ScoreBar(
              label: 'Infrastructure Gap',
              score: score.infraGapScore,
              weight: 30,
              icon: Icons.construction,
              color: const Color(0xFFF57C00),
            ),
            const SizedBox(height: 10),
            _ScoreBar(
              label: 'CWSN Needs',
              score: score.cwsnNeedScore,
              weight: 20,
              icon: Icons.accessible,
              color: const Color(0xFF26A69A),
            ),
            const SizedBox(height: 10),
            _ScoreBar(
              label: 'Accessibility',
              score: score.accessibilityScore,
              weight: 20,
              icon: Icons.bolt,
              color: const Color(0xFF42A5F5),
            ),

            // Computed at
            if (score.computedAt != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Computed: ${_formatDate(score.computedAt!)}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'just now';
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final double score;
  final int weight;
  final IconData icon;
  final Color color;
  const _ScoreBar({
    required this.label,
    required this.score,
    required this.weight,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ),
            Text(
              '${score.toStringAsFixed(0)}/100',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
            const SizedBox(width: 6),
            Text(
              '(${weight}%)',
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 6,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _EnrolmentChart extends StatelessWidget {
  final List<EnrolmentRecord> records;
  const _EnrolmentChart({required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No enrolment data available')),
      );
    }

    final trend = EnrolmentTrend.compute(0, records);
    final summaries = trend.yearWise;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Trend indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      trend.trend == 'GROWING'
                          ? Icons.trending_up
                          : trend.trend == 'DECLINING'
                              ? Icons.trending_down
                              : Icons.trending_flat,
                      color: trend.trend == 'GROWING'
                          ? Colors.green
                          : trend.trend == 'DECLINING'
                              ? Colors.red
                              : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${trend.trend} (${trend.growthRate > 0 ? "+" : ""}${trend.growthRate.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: trend.trend == 'GROWING'
                            ? Colors.green
                            : trend.trend == 'DECLINING'
                                ? Colors.red
                                : Colors.orange,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Latest: ${summaries.isNotEmpty ? summaries.last.totalStudents : 0}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    // Total line
                    LineChartBarData(
                      spots: summaries
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                              e.key.toDouble(), e.value.totalStudents.toDouble()))
                          .toList(),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    // Boys line
                    LineChartBarData(
                      spots: summaries
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                              e.key.toDouble(), e.value.totalBoys.toDouble()))
                          .toList(),
                      isCurved: true,
                      color: Colors.blue.shade300,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                    // Girls line
                    LineChartBarData(
                      spots: summaries
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                              e.key.toDouble(), e.value.totalGirls.toDouble()))
                          .toList(),
                      isCurved: true,
                      color: Colors.pink.shade300,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i >= 0 && i < summaries.length) {
                            return Text(summaries[i].academicYear,
                                style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (v, _) => Text('${v.toInt()}',
                            style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                      show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ChartLegend('Total', AppColors.primary),
                const SizedBox(width: 16),
                _ChartLegend('Boys', Colors.blue.shade300),
                const SizedBox(width: 16),
                _ChartLegend('Girls', Colors.pink.shade300),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final String label;
  final Color color;
  const _ChartLegend(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 3, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _ForecastSection extends ConsumerWidget {
  final int schoolId;
  const _ForecastSection({required this.schoolId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecastState = ref.watch(forecastProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.trending_up,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Enrolment Forecast',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                FilledButton.tonalIcon(
                  onPressed: forecastState.isLoading
                      ? null
                      : () => ref
                          .read(forecastProvider.notifier)
                          .forecastSchool(schoolId),
                  icon: forecastState.isLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_fix_high, size: 14),
                  label: Text(
                      forecastState.isLoading ? 'Running...' : 'Forecast',
                      style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            forecastState.when(
              data: (result) {
                if (result == null) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Tap "Forecast" to predict enrolment for the next 3 years based on historical trends.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  );
                }
                final trend = result['overall_trend'] ?? 'STABLE';
                final growthRate = (result['growth_rate'] as num?)?.toDouble() ?? 0;
                final forecasts = (result['forecasts'] as List?) ?? [];
                final allForecasts = forecasts
                    .where((f) => f['grade'] == 'ALL')
                    .toList();
                final isClientModel = result['model'] == 'client_linear';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    if (isClientModel)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Client-side linear extrapolation',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.primary),
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Icon(
                          trend == 'GROWING'
                              ? Icons.trending_up
                              : trend == 'DECLINING'
                                  ? Icons.trending_down
                                  : Icons.trending_flat,
                          color: trend == 'GROWING'
                              ? Colors.green
                              : trend == 'DECLINING'
                                  ? Colors.red
                                  : Colors.orange,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$trend (${growthRate > 0 ? "+" : ""}${growthRate.toStringAsFixed(1)}% per year)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: trend == 'GROWING'
                                ? Colors.green
                                : trend == 'DECLINING'
                                    ? Colors.red
                                    : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    if (allForecasts.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...allForecasts.map((f) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Text('${f['forecast_year']}: ',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                                Text(
                                    '${f['predicted_total']} students predicted',
                                    style: const TextStyle(fontSize: 13)),
                                const Spacer(),
                                Text(
                                  '${((f['confidence'] as num?) ?? 0) * 100}% conf.',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cloud_off, size: 16, color: Colors.orange.shade400),
                        const SizedBox(width: 6),
                        Text(
                          'ML Backend Offline',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Start the Python server to enable forecasting:\n./start_backend.sh',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
}

class _DemandPlansList extends StatelessWidget {
  final List<DemandPlan> demands;
  const _DemandPlansList({required this.demands});

  @override
  Widget build(BuildContext context) {
    if (demands.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No demand plans for this school')),
        ),
      );
    }

    return Column(
      children: demands.map((d) {
        final statusColor = AppColors.forValidation(d.validationStatus);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  AppColors.forInfraType(d.infraType).withValues(alpha: 0.15),
              child: Icon(
                AppConstants.infraTypeIcon(d.infraType),
                color: AppColors.forInfraType(d.infraType),
              ),
            ),
            title: Text(d.infraTypeLabel),
            subtitle:
                Text('${d.physicalCount} units | ₹${d.financialAmount.toStringAsFixed(2)}L'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppConstants.validationLabel(d.validationStatus),
                style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
