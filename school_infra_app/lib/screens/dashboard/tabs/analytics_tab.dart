import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../config/api_config.dart';
import '../../../models/demand_plan.dart';
import '../../../providers/dashboard_provider.dart';

class AnalyticsTab extends ConsumerWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demandSummaryAsync = ref.watch(demandSummaryProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final districtCountsAsync = ref.watch(districtSchoolCountsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Infrastructure Analytics',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Infrastructure demand by type (bar chart)
        _SectionTitle('Demand by Infrastructure Type'),
        const SizedBox(height: 12),
        demandSummaryAsync.when(
          data: (summaries) => SizedBox(
            height: 250,
            child: _InfraDemandBarChart(summaries: summaries),
          ),
          loading: () => const SizedBox(
              height: 250, child: Center(child: CircularProgressIndicator())),
          error: (_, __) => const SizedBox(
              height: 250, child: Center(child: Text('Failed to load'))),
        ),
        const SizedBox(height: 24),

        // Financial allocation
        _SectionTitle('Financial Allocation (₹ Lakhs)'),
        const SizedBox(height: 12),
        demandSummaryAsync.when(
          data: (summaries) => SizedBox(
            height: 200,
            child: _FinancialPieChart(summaries: summaries),
          ),
          loading: () => const SizedBox(
              height: 200, child: Center(child: CircularProgressIndicator())),
          error: (_, __) => const SizedBox(
              height: 200, child: Center(child: Text('Failed to load'))),
        ),
        const SizedBox(height: 24),

        // Key metrics
        _SectionTitle('Key Metrics'),
        const SizedBox(height: 12),
        statsAsync.when(
          data: (stats) => demandSummaryAsync.when(
            data: (summaries) =>
                _KeyMetricsGrid(stats: stats, summaries: summaries),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) =>
                _KeyMetricsGrid(stats: stats, summaries: const []),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) =>
              _KeyMetricsGrid(stats: const {}, summaries: const []),
        ),
        const SizedBox(height: 24),

        // District-wise distribution
        _SectionTitle('District-wise School Distribution'),
        const SizedBox(height: 12),
        districtCountsAsync.when(
          data: (counts) => _DistrictBarChart(districtCounts: counts),
          loading: () => const SizedBox(
              height: 250, child: Center(child: CircularProgressIndicator())),
          error: (_, __) => const SizedBox(
              height: 250, child: Center(child: Text('Failed to load'))),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _InfraDemandBarChart extends StatelessWidget {
  final List<DemandSummary> summaries;
  const _InfraDemandBarChart({required this.summaries});

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty) {
      return const Card(
          child: Center(child: Text('No demand data available')));
    }

    final data = summaries.map((s) {
      final label = _shortLabel(s.infraType);
      return _BarData(label, s.totalPhysical, AppColors.forInfraType(s.infraType));
    }).toList();

    final maxVal =
        data.fold<int>(0, (m, d) => d.value > m ? d.value : m).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxVal * 1.2,
            barGroups: data
                .asMap()
                .entries
                .map((e) => BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.value.toDouble(),
                          color: e.value.color,
                          width: 28,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ],
                    ))
                .toList(),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}',
                      style: const TextStyle(fontSize: 10)),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i >= 0 && i < data.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(data[i].label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 9)),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: true, drawVerticalLine: false),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  String _shortLabel(String infraType) {
    switch (infraType) {
      case 'CWSN_RESOURCE_ROOM':
        return 'CWSN\nRoom';
      case 'CWSN_TOILET':
        return 'CWSN\nToilet';
      case 'DRINKING_WATER':
        return 'Water';
      case 'ELECTRIFICATION':
        return 'Electric';
      case 'RAMPS':
        return 'Ramps';
      default:
        return infraType;
    }
  }
}

class _BarData {
  final String label;
  final int value;
  final Color color;
  _BarData(this.label, this.value, this.color);
}

class _FinancialPieChart extends StatelessWidget {
  final List<DemandSummary> summaries;
  const _FinancialPieChart({required this.summaries});

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty) {
      return const Card(
          child: Center(child: Text('No financial data available')));
    }

    final data = summaries
        .map((s) => _PieData(
              s.infraTypeLabel,
              s.totalFinancial,
              AppColors.forInfraType(s.infraType),
            ))
        .toList();
    final total = data.fold<double>(0, (s, d) => s + d.value);

    if (total == 0) {
      return const Card(
          child: Center(child: Text('No financial data available')));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: PieChart(PieChartData(
                sections: data
                    .map((d) => PieChartSectionData(
                          value: d.value,
                          title:
                              '${(d.value / total * 100).toStringAsFixed(0)}%',
                          color: d.color,
                          radius: 50,
                          titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11),
                        ))
                    .toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              )),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data
                  .map((d) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 10, height: 10, color: d.color),
                            const SizedBox(width: 6),
                            Text(
                                '${d.label}: ₹${d.value.toStringAsFixed(0)}L',
                                style: const TextStyle(fontSize: 11)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PieData {
  final String label;
  final double value;
  final Color color;
  _PieData(this.label, this.value, this.color);
}

class _KeyMetricsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;
  final List<DemandSummary> summaries;
  const _KeyMetricsGrid({required this.stats, required this.summaries});

  @override
  Widget build(BuildContext context) {
    final totalSchools = stats['total_schools'] ?? 0;
    final totalDemands = stats['total_demands'] ?? 0;
    final totalFinancial =
        summaries.fold<double>(0, (s, d) => s + d.totalFinancial);
    final avgPerSchool =
        totalSchools > 0 ? totalFinancial / totalSchools : 0.0;
    final approvedCount = stats['demand_approved'] ?? 0;
    final approvalRate =
        totalDemands > 0 ? (approvedCount / totalDemands * 100) : 0.0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.0,
      children: [
        _MetricCard('Schools Covered', '$totalSchools', Icons.school,
            AppColors.primary),
        _MetricCard('Total Demands', '$totalDemands', Icons.description,
            AppColors.accent),
        _MetricCard(
            'Total Investment',
            '₹${totalFinancial.toStringAsFixed(0)}L',
            Icons.currency_rupee,
            Colors.green),
        _MetricCard('Avg Per School', '₹${avgPerSchool.toStringAsFixed(1)}L',
            Icons.calculate, Colors.orange),
        _MetricCard('Approved', '$approvedCount', Icons.check_circle,
            AppColors.statusApproved),
        _MetricCard('Approval Rate', '${approvalRate.toStringAsFixed(0)}%',
            Icons.percent, AppColors.statusApproved),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _MetricCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(value,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: color)),
                  Text(label,
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DistrictBarChart extends StatelessWidget {
  final Map<String, int> districtCounts;
  const _DistrictBarChart({required this.districtCounts});

  @override
  Widget build(BuildContext context) {
    if (districtCounts.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Card(child: Center(child: Text('No district data'))),
      );
    }

    // Sort by count descending and take top 10
    final sorted = districtCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(10).toList();
    final maxVal =
        top.fold<int>(0, (m, e) => e.value > m ? e.value : m).toDouble();

    return SizedBox(
      height: 250,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxVal * 1.2,
              barGroups: top
                  .asMap()
                  .entries
                  .map((e) => BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value.value.toDouble(),
                            color: AppColors.primary,
                            width: 16,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(3)),
                          ),
                        ],
                      ))
                  .toList(),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (v, _) => Text('${v.toInt()}',
                        style: const TextStyle(fontSize: 10)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i >= 0 && i < top.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: Text(top[i].key,
                                style: const TextStyle(fontSize: 8)),
                          ),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 60,
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ),
    );
  }
}
