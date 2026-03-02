import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/api_config.dart';
import '../../models/school.dart';
import '../../models/enrolment.dart';
import '../../models/demand_plan.dart';
import '../../models/priority_score.dart';
import '../../models/infra_assessment.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/supabase_service.dart';
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
          Builder(
            builder: (buttonContext) => IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Export PDF',
              onPressed: () {
                final box = buttonContext.findRenderObject() as RenderBox?;
                final shareOrigin = box != null
                    ? box.localToGlobal(Offset.zero) & box.size
                    : null;
                final enrolment = enrolmentAsync.value ?? [];
                final demands = demandsAsync.value ?? [];
                ExportService.exportSchoolPdf(
                  school: school,
                  enrolment: enrolment,
                  demands: demands,
                  sharePositionOrigin: shareOrigin,
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
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // School Info Card
          _SchoolInfoCard(school: school),
          const SizedBox(height: 16),

          // School Location Map
          if (school.hasLocation)
            _SchoolLocationMap(school: school),
          if (school.hasLocation)
            const SizedBox(height: 16),

          // Priority Score Breakdown
          priorityAsync.when(
            data: (score) => score != null
                ? _PriorityBreakdownCard(score: score)
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Enrolment Analysis (unified trend + forecast)
          _EnrolmentAnalysisCard(schoolId: school.id),
          const SizedBox(height: 16),

          // Infrastructure Requirement Forecast (PS5 core capability)
          _InfraRequirementForecast(
            schoolId: school.id,
            schoolCategory: school.schoolCategory,
          ),
          const SizedBox(height: 16),

          // Budget Allocation Planner (PS5 — Strategic Planning)
          _BudgetAllocationPlanner(
            schoolId: school.id,
            schoolCategory: school.schoolCategory,
          ),
          const SizedBox(height: 16),

          // Repair & Maintenance Forecast (PS5 Capability 1)
          _RepairMaintenanceForecast(schoolId: school.id),
          const SizedBox(height: 16),

          // Inspection History Timeline (PS5 continuous monitoring)
          _InspectionHistoryCard(schoolId: school.id),
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

class _SchoolLocationMap extends StatelessWidget {
  final School school;
  const _SchoolLocationMap({required this.school});

  @override
  Widget build(BuildContext context) {
    final schoolLatLng = LatLng(school.latitude!, school.longitude!);
    final color = school.priorityColor;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.map, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('School Location',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(
                  '${school.latitude!.toStringAsFixed(4)}, ${school.longitude!.toStringAsFixed(4)}',
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: schoolLatLng,
                initialZoom: 15.0,
                minZoom: 5.0,
                maxZoom: 18.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.schoolinfra.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: schoolLatLng,
                      width: 44,
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.school,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${school.mandalName ?? ''}, ${school.districtName ?? ''}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
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

class _EnrolmentAnalysisCard extends ConsumerWidget {
  final int schoolId;
  const _EnrolmentAnalysisCard({required this.schoolId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrolmentAsync = ref.watch(schoolEnrolmentProvider(schoolId));
    final forecastState = ref.watch(forecastProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title + Forecast button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Enrolment Analysis',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
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
            const SizedBox(height: 12),

            // Content: depends on enrolment data
            enrolmentAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return const SizedBox(
                    height: 120,
                    child: Center(child: Text('No enrolment data available')),
                  );
                }

                final trend = EnrolmentTrend.compute(schoolId, records);
                final historical = trend.yearWise;

                // Only use forecast if it belongs to THIS school
                final rawResult = forecastState is AsyncData<Map<String, dynamic>?>
                    ? forecastState.value
                    : null;
                final forecastResult =
                    (rawResult != null && rawResult['school_id'] == schoolId)
                        ? rawResult
                        : null;
                final forecasts = forecastResult != null
                    ? ((forecastResult['forecasts'] as List?) ?? [])
                        .where((f) => f['grade'] == 'ALL')
                        .toList()
                    : <dynamic>[];
                final hasForecast = forecasts.isNotEmpty;

                // Determine which growth info to show
                final String growthTrend;
                final double growthRate;
                final String growthLabel;
                if (hasForecast) {
                  growthTrend = forecastResult!['overall_trend'] ?? 'STABLE';
                  growthRate = (forecastResult['growth_rate'] as num?)?.toDouble() ?? 0;
                  growthLabel = 'Projected Growth';
                } else {
                  growthTrend = trend.trend;
                  growthRate = trend.growthRate;
                  growthLabel = 'Historical Growth';
                }

                final trendColor = growthTrend == 'GROWING'
                    ? Colors.green
                    : growthTrend == 'DECLINING'
                        ? Colors.red
                        : Colors.orange;

                // Model badge
                final isClientModel = forecastResult?['model'] == 'client_linear';
                final isBackendModel = forecastResult?['model'] == 'backend_ml';
                final modelUsed = forecasts.isNotEmpty
                    ? (forecasts.first['model_used'] as String? ?? 'LinearRegression')
                    : '';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Model badge (only when forecast has been run)
                    if (isBackendModel)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.smart_toy,
                                  size: 14, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(
                                'AI-Enhanced: $modelUsed',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (isClientModel)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.smart_toy,
                                  size: 14, color: Colors.green),
                              SizedBox(width: 4),
                              Text(
                                'AI Forecast: Linear Regression',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Single growth rate row
                    Row(
                      children: [
                        Icon(
                          growthTrend == 'GROWING'
                              ? Icons.trending_up
                              : growthTrend == 'DECLINING'
                                  ? Icons.trending_down
                                  : Icons.trending_flat,
                          color: trendColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$growthLabel: $growthTrend (${growthRate > 0 ? "+" : ""}${growthRate.toStringAsFixed(1)}%/yr)',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: trendColor,
                            ),
                          ),
                        ),
                        Text(
                          'Latest: ${historical.isNotEmpty ? historical.last.totalStudents : 0}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Unified chart
                    SizedBox(
                      height: 180,
                      child: _buildUnifiedChart(historical, forecasts),
                    ),
                    const SizedBox(height: 8),

                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legendDot(AppColors.primary, 'Total'),
                        const SizedBox(width: 12),
                        _legendDot(Colors.blue.shade300, 'Boys'),
                        const SizedBox(width: 12),
                        _legendDot(Colors.pink.shade300, 'Girls'),
                        if (hasForecast) ...[
                          const SizedBox(width: 12),
                          _legendDash(Colors.orange, 'Forecast'),
                        ],
                      ],
                    ),

                    // Forecast year details
                    if (hasForecast) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      ...forecasts.map((f) => Padding(
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

                    // Hint when no forecast data yet
                    if (!hasForecast && forecastResult == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Forecast data will appear once batch forecast computation completes.',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator())),
              error: (e, _) => SizedBox(
                  height: 120,
                  child: Center(child: Text('Error loading enrolment: $e'))),
            ),

            // Forecast loading/error state
            if (forecastState.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 6),
                    Text('Computing forecast...',
                        style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            if (forecastState.hasError && !forecastState.isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.cloud_off,
                        size: 14, color: Colors.orange.shade400),
                    const SizedBox(width: 6),
                    Text(
                      'Forecast computation failed',
                      style: TextStyle(
                          fontSize: 11, color: Colors.orange.shade700),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnifiedChart(
      List<EnrolmentSummary> historical, List<dynamic> forecasts) {
    final histTotal = historical
        .asMap()
        .entries
        .map((e) =>
            FlSpot(e.key.toDouble(), e.value.totalStudents.toDouble()))
        .toList();
    final histBoys = historical
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.totalBoys.toDouble()))
        .toList();
    final histGirls = historical
        .asMap()
        .entries
        .map(
            (e) => FlSpot(e.key.toDouble(), e.value.totalGirls.toDouble()))
        .toList();

    // Build forecast spots (connect from last historical point)
    final forecastSpots = <FlSpot>[];
    if (forecasts.isNotEmpty && histTotal.isNotEmpty) {
      forecastSpots.add(histTotal.last);
      for (var i = 0; i < forecasts.length; i++) {
        final x = (historical.length + i).toDouble();
        final y = (forecasts[i]['predicted_total'] as num).toDouble();
        forecastSpots.add(FlSpot(x, y));
      }
    }

    // All year labels
    final allLabels = [
      ...historical.map((s) => s.academicYear),
      ...forecasts.map((f) => f['forecast_year'] as String),
    ];

    return LineChart(LineChartData(
      lineBarsData: [
        // Total (solid)
        LineChartBarData(
          spots: histTotal,
          isCurved: true,
          color: AppColors.primary,
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withValues(alpha: 0.08),
          ),
        ),
        // Boys
        LineChartBarData(
          spots: histBoys,
          isCurved: true,
          color: Colors.blue.shade300,
          barWidth: 2,
          dotData: const FlDotData(show: false),
        ),
        // Girls
        LineChartBarData(
          spots: histGirls,
          isCurved: true,
          color: Colors.pink.shade300,
          barWidth: 2,
          dotData: const FlDotData(show: false),
        ),
        // Forecast (dashed orange)
        if (forecastSpots.length > 1)
          LineChartBarData(
            spots: forecastSpots,
            isCurved: true,
            color: Colors.orange,
            barWidth: 2,
            dashArray: [6, 4],
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withValues(alpha: 0.08),
            ),
          ),
      ],
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= allLabels.length) {
                return const SizedBox.shrink();
              }
              final label = allLabels[idx];
              final short = label.length > 4 ? label.substring(2) : label;
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(short,
                    style: TextStyle(
                      fontSize: 9,
                      color: idx >= historical.length
                          ? Colors.orange
                          : AppColors.textSecondary,
                    )),
              );
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
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(show: true, drawVerticalLine: false),
      borderData: FlBorderData(show: false),
    ));
  }

  static Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 3, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  static Widget _legendDash(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 12,
          height: 3,
          child: CustomPaint(painter: _DashPainter(color: color)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;
  _DashPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, size.height / 2),
          Offset((x + 3).clamp(0, size.width), size.height / 2), paint);
      x += 5;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Infrastructure Requirement Forecast — translates enrolment projections
/// into specific infrastructure needs using Samagra Shiksha norms.
class _InfraRequirementForecast extends ConsumerWidget {
  final int schoolId;
  final String? schoolCategory;
  const _InfraRequirementForecast({
    required this.schoolId,
    this.schoolCategory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecastState = ref.watch(forecastProvider);
    final enrolmentAsync = ref.watch(schoolEnrolmentProvider(schoolId));

    // Only use forecast if it belongs to THIS school
    final rawResult = forecastState is AsyncData<Map<String, dynamic>?>
        ? forecastState.value
        : null;
    final forecastResult =
        (rawResult != null && rawResult['school_id'] == schoolId)
            ? rawResult
            : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.construction,
                    color: Color(0xFFF57C00), size: 20),
                const SizedBox(width: 8),
                Text('Infrastructure Requirement Forecast',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Projected needs based on enrolment forecast + Samagra Shiksha norms',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),

            Builder(builder: (context) {
              final result = forecastResult;
              if (result == null) {
                if (forecastState.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const Text(
                  'Click "Forecast" in Enrolment Analysis to generate infrastructure projections.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                );
              }

                final forecasts = (result['forecasts'] as List?) ?? [];
                final allForecasts =
                    forecasts.where((f) => f['grade'] == 'ALL').toList();

                if (allForecasts.isEmpty) {
                  return const Text('No forecast data available');
                }

                // Get current enrolment for comparison
                final currentEnrolment = enrolmentAsync.when(
                  data: (records) {
                    if (records.isEmpty) return 0;
                    final trend = EnrolmentTrend.compute(schoolId, records);
                    return trend.yearWise.isNotEmpty
                        ? trend.yearWise.last.totalStudents
                        : 0;
                  },
                  loading: () => 0,
                  error: (_, __) => 0,
                );

                // Samagra Shiksha norms
                final isSecondary = schoolCategory == 'HS' ||
                    schoolCategory == 'HSS';
                final classroomRatio = isSecondary
                    ? AppConstants.normStudentClassroomRatioSecondary
                    : AppConstants.normStudentClassroomRatioPrimary;
                final toiletRatio = AppConstants.normStudentToiletRatio;

                return Column(
                  children: [
                    // Current vs Future comparison table
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(7)),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                    flex: 2,
                                    child: Text('Year',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600))),
                                const Expanded(
                                    child: Text('Students',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.center)),
                                const Expanded(
                                    child: Text('Rooms',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.center)),
                                const Expanded(
                                    child: Text('Toilets',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.center)),
                                const Expanded(
                                    child: Text('Est. Cost',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.center)),
                              ],
                            ),
                          ),
                          // Current row
                          _InfraRow(
                            year: 'Current',
                            students: currentEnrolment,
                            classrooms:
                                (currentEnrolment / classroomRatio).ceil(),
                            toilets: (currentEnrolment / toiletRatio).ceil(),
                            isCurrent: true,
                          ),
                          // Forecast rows
                          ...allForecasts.map((f) {
                            final predicted =
                                (f['predicted_total'] as num?)?.toInt() ?? 0;
                            final rooms =
                                (predicted / classroomRatio).ceil();
                            final toilets =
                                (predicted / toiletRatio).ceil();
                            final currentRooms =
                                (currentEnrolment / classroomRatio).ceil();
                            final currentToilets =
                                (currentEnrolment / toiletRatio).ceil();
                            final newRooms = (rooms - currentRooms)
                                .clamp(0, 999);
                            final newToilets = (toilets - currentToilets)
                                .clamp(0, 999);
                            // Estimate cost: new classrooms * avg cost + new toilets * CWSN toilet cost
                            final estCost =
                                newRooms * 29.3 + newToilets * 4.65;
                            return _InfraRow(
                              year: f['forecast_year'] as String? ?? '?',
                              students: predicted,
                              classrooms: rooms,
                              toilets: toilets,
                              additionalRooms: newRooms,
                              additionalToilets: newToilets,
                              estimatedCost: estCost,
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Norms: 1 classroom per ${classroomRatio.toInt()} students, 1 toilet per ${toiletRatio.toInt()} students',
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _InfraRow extends StatelessWidget {
  final String year;
  final int students;
  final int classrooms;
  final int toilets;
  final bool isCurrent;
  final int additionalRooms;
  final int additionalToilets;
  final double estimatedCost;

  const _InfraRow({
    required this.year,
    required this.students,
    required this.classrooms,
    required this.toilets,
    this.isCurrent = false,
    this.additionalRooms = 0,
    this.additionalToilets = 0,
    this.estimatedCost = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrent ? Colors.green.withValues(alpha: 0.05) : null,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              year,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                color: isCurrent ? Colors.green.shade700 : null,
              ),
            ),
          ),
          Expanded(
            child: Text('$students',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11)),
          ),
          Expanded(
            child: Text(
              isCurrent
                  ? '$classrooms'
                  : '$classrooms${additionalRooms > 0 ? " (+$additionalRooms)" : ""}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: additionalRooms > 0 ? Colors.orange.shade700 : null,
                fontWeight:
                    additionalRooms > 0 ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              isCurrent
                  ? '$toilets'
                  : '$toilets${additionalToilets > 0 ? " (+$additionalToilets)" : ""}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: additionalToilets > 0 ? Colors.orange.shade700 : null,
                fontWeight: additionalToilets > 0
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              isCurrent
                  ? '-'
                  : estimatedCost > 0
                      ? '\u20B9${estimatedCost.toStringAsFixed(0)}L'
                      : '-',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: estimatedCost > 0 ? Colors.deepOrange : null,
                fontWeight:
                    estimatedCost > 0 ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Budget Allocation Planner (PS5 — Strategic Planning) ────────────
class _BudgetAllocationPlanner extends ConsumerWidget {
  final int schoolId;
  final String? schoolCategory;
  const _BudgetAllocationPlanner({
    required this.schoolId,
    this.schoolCategory,
  });

  // Priority order: safety/compliance first, then enhancements
  static const _safetyInfraTypes = {
    AppConstants.infraDrinkingWater,
    AppConstants.infraElectrification,
    AppConstants.infraRamps,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecastState = ref.watch(forecastProvider);
    final demandsAsync = ref.watch(schoolDemandPlansProvider(schoolId));

    // Only use forecast if it belongs to THIS school
    final rawResult = forecastState is AsyncData<Map<String, dynamic>?>
        ? forecastState.value
        : null;
    final forecastScopedResult =
        (rawResult != null && rawResult['school_id'] == schoolId)
            ? rawResult
            : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet,
                    color: Color(0xFF2E7D32), size: 20),
                const SizedBox(width: 8),
                Text('Budget Allocation Planner',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Prioritized allocation — items funded at full unit cost',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),

            demandsAsync.when(
              data: (demands) {
                if (demands.isEmpty) {
                  return const Text(
                    'No demand plans available for budget planning.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  );
                }

                // Include all demands that aren't officer-rejected
                final pendingDemands = demands
                    .where((d) => !d.isOfficerRejected)
                    .toList();
                if (pendingDemands.isEmpty) {
                  return const Text(
                    'No actionable demands for budget planning.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  );
                }

                // Separate safety-critical vs enhancement demands
                final safetyDemands = pendingDemands
                    .where((d) => _safetyInfraTypes.contains(d.infraType))
                    .toList();
                final enhancementDemands = pendingDemands
                    .where((d) => !_safetyInfraTypes.contains(d.infraType))
                    .toList();

                // Get growth rate from school-scoped forecast
                double growthPct = 0;
                final forecastResult = forecastScopedResult;
                if (forecastResult != null) {
                  growthPct =
                      (forecastResult['growth_rate'] as num?)?.toDouble() ?? 0;
                }

                // --- Conservative: only safety/compliance items at full cost ---
                final conservativeItems = _buildItems(safetyDemands);
                final conservativeBudget =
                    conservativeItems.fold<double>(0, (s, i) => s + i.cost);

                // --- Balanced: all demands at full cost ---
                final balancedItems = _buildItems(pendingDemands);
                final balancedBudget =
                    balancedItems.fold<double>(0, (s, i) => s + i.cost);

                // --- Growth: all demands + extra units scaled by growth ---
                final hasForecast = forecastResult != null;
                final growthItems =
                    _buildGrowthItems(pendingDemands, growthPct, hasForecast);
                final growthBudget =
                    growthItems.fold<double>(0, (s, i) => s + i.cost);

                // Growth-oriented description based on scenario
                final String growthDesc;
                if (growthPct > 0) {
                  growthDesc =
                      'All demands + ${growthPct.toStringAsFixed(1)}% growth buffer';
                } else if (growthPct < 0) {
                  growthDesc =
                      'Enrolment declining (${growthPct.toStringAsFixed(1)}%) — no extra units needed';
                } else if (!hasForecast) {
                  growthDesc =
                      'All demands + 10% buffer (run Forecast for actual data)';
                } else {
                  growthDesc = 'Enrolment stable — no extra units needed';
                }

                final strategies = [
                  _BudgetStrategy(
                    name: 'Conservative',
                    icon: Icons.shield_outlined,
                    color: const Color(0xFF1565C0),
                    description:
                        'Safety & compliance only — ${safetyDemands.length} of ${pendingDemands.length} items',
                    totalBudget: conservativeBudget,
                    items: conservativeItems,
                    skippedCount: enhancementDemands.length,
                  ),
                  _BudgetStrategy(
                    name: 'Balanced',
                    icon: Icons.balance,
                    color: const Color(0xFF2E7D32),
                    description:
                        'All ${pendingDemands.length} demand items at full unit cost',
                    totalBudget: balancedBudget,
                    items: balancedItems,
                    skippedCount: 0,
                  ),
                  _BudgetStrategy(
                    name: 'Growth-Oriented',
                    icon: Icons.rocket_launch,
                    color: const Color(0xFFF57C00),
                    description: growthDesc,
                    totalBudget: growthBudget,
                    items: growthItems,
                    skippedCount: 0,
                  ),
                ];

                return Column(
                  children: strategies
                      .map((s) => _BudgetStrategyCard(strategy: s))
                      .toList(),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text(
                'Unable to load demand data for budget planning.',
                style:
                    TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build line items from demands — each item at its FULL unit cost
  List<_BudgetItem> _buildItems(List<DemandPlan> demands) {
    final grouped = <String, _BudgetItem>{};
    for (final d in demands) {
      final label = d.infraTypeLabel;
      if (grouped.containsKey(label)) {
        grouped[label] = _BudgetItem(
          label: label,
          units: grouped[label]!.units + d.physicalCount,
          cost: grouped[label]!.cost + d.financialAmount,
          infraType: d.infraType,
        );
      } else {
        grouped[label] = _BudgetItem(
          label: label,
          units: d.physicalCount,
          cost: d.financialAmount,
          infraType: d.infraType,
        );
      }
    }
    return grouped.values.toList();
  }

  /// Build growth items — all demands at full cost + extra units for growth.
  /// If enrolment is declining, no extra units are needed (same as Balanced).
  /// If no forecast data available, add a small 10% buffer.
  /// If enrolment is growing, add extra units proportional to growth rate.
  List<_BudgetItem> _buildGrowthItems(
      List<DemandPlan> demands, double growthPct, bool hasForecast) {
    final base = _buildItems(demands);
    if (growthPct < 0) {
      // Declining enrolment — no extra infra needed, same as Balanced
      return base;
    }
    if (growthPct == 0 && !hasForecast) {
      // No forecast data — add a conservative 10% buffer
      return base
          .map((item) {
            final extraUnits = (item.units * 0.1).ceil();
            final unitCost =
                AppConstants.unitCosts[item.infraType] ??
                    (item.units > 0 ? item.cost / item.units : 0);
            return _BudgetItem(
              label: item.label,
              units: item.units + extraUnits,
              cost: item.cost + extraUnits * unitCost,
              infraType: item.infraType,
              extraUnits: extraUnits,
            );
          })
          .toList();
    }
    if (growthPct == 0) {
      // Forecast says stable — no extra units needed
      return base;
    }
    // Positive growth — add extra units proportional to growth rate
    return base
        .map((item) {
          final extraUnits = (item.units * growthPct / 100).ceil();
          final unitCost =
              AppConstants.unitCosts[item.infraType] ??
                  (item.units > 0 ? item.cost / item.units : 0);
          return _BudgetItem(
            label: item.label,
            units: item.units + extraUnits,
            cost: item.cost + extraUnits * unitCost,
            infraType: item.infraType,
            extraUnits: extraUnits,
          );
        })
        .toList();
  }
}

class _BudgetItem {
  final String label;
  final int units;
  final double cost;
  final String infraType;
  final int extraUnits;

  const _BudgetItem({
    required this.label,
    required this.units,
    required this.cost,
    required this.infraType,
    this.extraUnits = 0,
  });
}

class _BudgetStrategy {
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final double totalBudget;
  final List<_BudgetItem> items;
  final int skippedCount;

  const _BudgetStrategy({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.totalBudget,
    required this.items,
    required this.skippedCount,
  });
}

class _BudgetStrategyCard extends StatefulWidget {
  final _BudgetStrategy strategy;
  const _BudgetStrategyCard({required this.strategy});

  @override
  State<_BudgetStrategyCard> createState() => _BudgetStrategyCardState();
}

class _BudgetStrategyCardState extends State<_BudgetStrategyCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.strategy;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: s.color.withValues(alpha: 0.25)),
        color: s.color.withValues(alpha: 0.03),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: s.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(s.icon, color: s.color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: s.color,
                          ),
                        ),
                        Text(
                          s.description,
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\u20B9${s.totalBudget.toStringAsFixed(1)}L',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: s.color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          // Expanded breakdown
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                children: [
                  // Item rows with units and full cost
                  ...s.items.map((item) {
                    final unitCost = AppConstants.unitCosts[item.infraType];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(
                            AppConstants.infraTypeIcon(item.infraType),
                            size: 14,
                            color: AppColors.forInfraType(item.infraType),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.label,
                                    style: const TextStyle(fontSize: 11)),
                                Text(
                                  '${item.units} unit${item.units != 1 ? "s" : ""}'
                                  '${item.extraUnits > 0 ? " (+${item.extraUnits} growth)" : ""}'
                                  '${unitCost != null ? " \u00D7 \u20B9${unitCost}L each" : ""}',
                                  style: const TextStyle(
                                      fontSize: 9,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\u20B9${item.cost.toStringAsFixed(1)}L',
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  }),
                  // Skipped items note
                  if (s.skippedCount > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 12, color: Colors.orange.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${s.skippedCount} non-essential item${s.skippedCount != 1 ? "s" : ""} deferred (CWSN rooms/toilets)',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange.shade700,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      Text(
                        '\u20B9${s.totalBudget.toStringAsFixed(1)} Lakhs',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: s.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DemandPlansList extends StatelessWidget {
  final List<DemandPlan> demands;
  const _DemandPlansList({required this.demands});

  /// Returns a descriptive status label showing the full pipeline state
  /// so users can distinguish AI-approved vs officer-approved.
  static ({String label, String? subLabel, Color color, IconData icon})
      _pipelineDisplay(DemandPlan d) {
    final stage = d.pipelineStage;
    final color = AppColors.forPipelineStage(stage);
    final icon = AppConstants.pipelineStageIcon(stage);

    switch (stage) {
      case 'PENDING':
        return (
          label: 'Pending',
          subLabel: 'AI Review',
          color: color,
          icon: icon,
        );
      case 'AI_REVIEWED':
        // AI has reviewed — show what AI decided + next step
        final aiVerdict = d.validationStatus; // APPROVED, FLAGGED, REJECTED
        final aiLabel = AppConstants.validationLabel(aiVerdict);
        return (
          label: 'AI $aiLabel',
          subLabel: 'Officer Pending',
          color: color,
          icon: icon,
        );
      case 'FINAL_APPROVED':
        return (
          label: 'Approved',
          subLabel: 'Officer ✓',
          color: color,
          icon: icon,
        );
      case 'FLAGGED':
        return (
          label: 'Flagged',
          subLabel: d.isOfficerPending ? 'By AI' : 'By Officer',
          color: color,
          icon: icon,
        );
      case 'REJECTED':
        return (
          label: 'Rejected',
          subLabel: d.isOfficerPending ? 'By AI' : 'By Officer',
          color: color,
          icon: icon,
        );
      default:
        return (
          label: stage,
          subLabel: null,
          color: color,
          icon: icon,
        );
    }
  }

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
        final display = _pipelineDisplay(d);
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: display.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: display.color.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(display.icon, size: 13, color: display.color),
                      const SizedBox(width: 4),
                      Text(
                        display.label,
                        style: TextStyle(
                          color: display.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  if (display.subLabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      display.subLabel!,
                      style: TextStyle(
                        color: display.color.withValues(alpha: 0.7),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Repair & Maintenance Forecast (PS5 Capability 1) ────────────
class _RepairMaintenanceForecast extends StatelessWidget {
  final int schoolId;
  const _RepairMaintenanceForecast({required this.schoolId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<InfraAssessment?>(
      future: SupabaseService.getLatestAssessment(schoolId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        final assessment = snapshot.data;
        if (assessment == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.build_circle, color: Colors.grey.shade400, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'No inspection data — submit a field assessment to enable repair & maintenance forecasting',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Compute repair/maintenance cost forecast
        final repairItems = <_RepairItem>[];

        // Condition-based repair
        if (assessment.conditionRating == 'CRITICAL') {
          repairItems.add(_RepairItem(
            item: 'Major structural repair',
            urgency: 'Immediate',
            urgencyColor: AppColors.priorityCritical,
            estimatedCost: assessment.existingClassrooms * 5.0,
          ));
        } else if (assessment.conditionRating == 'NEEDS_REPAIR') {
          repairItems.add(_RepairItem(
            item: 'Building maintenance',
            urgency: 'Within 6 months',
            urgencyColor: AppColors.priorityHigh,
            estimatedCost: assessment.existingClassrooms * 2.0,
          ));
        }

        // Missing infrastructure items
        if (!assessment.drinkingWaterAvailable) {
          repairItems.add(_RepairItem(
            item: 'Drinking water facility',
            urgency: 'High',
            urgencyColor: AppColors.priorityHigh,
            estimatedCost: AppConstants.unitCosts['DRINKING_WATER']!,
          ));
        }
        if (assessment.electrificationStatus == 'NONE') {
          repairItems.add(_RepairItem(
            item: 'Full electrification',
            urgency: 'High',
            urgencyColor: AppColors.priorityHigh,
            estimatedCost: AppConstants.unitCosts['ELECTRIFICATION']!,
          ));
        } else if (assessment.electrificationStatus == 'PARTIAL') {
          repairItems.add(_RepairItem(
            item: 'Complete electrification',
            urgency: 'Medium',
            urgencyColor: AppColors.priorityMedium,
            estimatedCost: AppConstants.unitCosts['ELECTRIFICATION']! * 0.5,
          ));
        }
        if (!assessment.rampAvailable) {
          repairItems.add(_RepairItem(
            item: 'Accessibility ramps',
            urgency: 'Medium',
            urgencyColor: AppColors.priorityMedium,
            estimatedCost: AppConstants.unitCosts['RAMPS']!,
          ));
        }
        if (!assessment.cwsnResourceRoomAvailable) {
          repairItems.add(_RepairItem(
            item: 'CWSN Resource Room',
            urgency: 'Medium',
            urgencyColor: AppColors.priorityMedium,
            estimatedCost: AppConstants.unitCosts['CWSN_RESOURCE_ROOM']!,
          ));
        }
        if (!assessment.cwsnToiletAvailable) {
          repairItems.add(_RepairItem(
            item: 'CWSN Toilet',
            urgency: 'Medium',
            urgencyColor: AppColors.priorityMedium,
            estimatedCost: AppConstants.unitCosts['CWSN_TOILET']!,
          ));
        }

        final totalCost = repairItems.fold<double>(0, (s, r) => s + r.estimatedCost);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.build_circle, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Repair & Maintenance Forecast',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on field inspection (${assessment.assessmentDate.toString().split(' ')[0]})',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                // Condition badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: assessment.isCritical
                            ? AppColors.priorityCritical.withValues(alpha: 0.1)
                            : assessment.needsRepair
                                ? AppColors.priorityHigh.withValues(alpha: 0.1)
                                : AppColors.priorityLow.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Condition: ${assessment.conditionRating}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: assessment.isCritical
                              ? AppColors.priorityCritical
                              : assessment.needsRepair
                                  ? AppColors.priorityHigh
                                  : AppColors.priorityLow,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${assessment.existingClassrooms} rooms, ${assessment.existingToilets} toilets',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                if (repairItems.isEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('All infrastructure in good condition',
                      style: TextStyle(color: AppColors.statusApproved, fontSize: 12)),
                ] else ...[
                  const SizedBox(height: 12),
                  ...repairItems.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(
                                color: r.urgencyColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(r.item,
                                  style: const TextStyle(fontSize: 12)),
                            ),
                            Text(r.urgency,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: r.urgencyColor,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(width: 12),
                            Text('₹${r.estimatedCost.toStringAsFixed(1)}L',
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total estimated maintenance',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                      Text('₹${totalCost.toStringAsFixed(1)} Lakhs',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RepairItem {
  final String item;
  final String urgency;
  final Color urgencyColor;
  final double estimatedCost;
  _RepairItem({
    required this.item,
    required this.urgency,
    required this.urgencyColor,
    required this.estimatedCost,
  });
}

// ── Inspection History Timeline (PS5 — Continuous Monitoring) ────────
class _InspectionHistoryCard extends StatelessWidget {
  final int schoolId;
  const _InspectionHistoryCard({required this.schoolId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<InfraAssessment>>(
      future: SupabaseService.getAllAssessments(schoolId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        final assessments = snapshot.data ?? [];
        if (assessments.isEmpty) {
          return const SizedBox.shrink(); // Don't show if no history
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Inspection History',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${assessments.length} inspection${assessments.length != 1 ? "s" : ""}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Timeline list
                ...assessments.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final a = entry.value;
                  final isLast = idx == assessments.length - 1;
                  return _InspectionTimelineItem(
                    assessment: a,
                    isFirst: idx == 0,
                    isLast: isLast,
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InspectionTimelineItem extends StatelessWidget {
  final InfraAssessment assessment;
  final bool isFirst;
  final bool isLast;

  const _InspectionTimelineItem({
    required this.assessment,
    this.isFirst = false,
    this.isLast = false,
  });

  Color _conditionColor(String rating) {
    switch (rating) {
      case 'CRITICAL':
        return AppColors.priorityCritical;
      case 'NEEDS_REPAIR':
        return AppColors.priorityHigh;
      default:
        return AppColors.priorityLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final condColor = _conditionColor(assessment.conditionRating);
    final dateStr = assessment.assessmentDate.toString().split(' ')[0];
    final missing = assessment.missingFacilitiesCount;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline connector
          SizedBox(
            width: 28,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: condColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: condColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isFirst
                    ? condColor.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isFirst
                      ? condColor.withValues(alpha: 0.2)
                      : Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isFirst ? condColor : Colors.black87,
                        ),
                      ),
                      if (isFirst) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: condColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Latest',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: condColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          assessment.conditionRating,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: condColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _MiniStat(Icons.meeting_room, '${assessment.existingClassrooms} rooms'),
                      const SizedBox(width: 12),
                      _MiniStat(Icons.wc, '${assessment.existingToilets} toilets'),
                      const SizedBox(width: 12),
                      _MiniStat(
                        Icons.warning_amber,
                        '$missing missing',
                        color: missing > 0 ? Colors.orange : Colors.green,
                      ),
                    ],
                  ),
                  if (assessment.assessedBy != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Inspector: ${assessment.assessedBy}',
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                  if (assessment.notes != null && assessment.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      assessment.notes!,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _MiniStat(this.icon, this.label, {this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: color ?? AppColors.textSecondary)),
      ],
    );
  }
}
