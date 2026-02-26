import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../config/api_config.dart';
import '../../../models/demand_plan.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../models/priority_score.dart';
import '../../../l10n/app_localizations.dart';

class OverviewTab extends ConsumerWidget {
  final VoidCallback? onNavigateToSchools;
  final VoidCallback? onNavigateToValidation;

  const OverviewTab({
    super.key,
    this.onNavigateToSchools,
    this.onNavigateToValidation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final priorityAsync = ref.watch(priorityDistributionProvider);
    final demandSummaryAsync = ref.watch(demandSummaryProvider);
    final computeState = ref.watch(computePriorityScoresProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(dashboardStatsProvider);
        ref.invalidate(priorityScoresProvider);
        ref.invalidate(demandPlansProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Text(
            l10n.translate('nav_overview'),
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.appTagline,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Stats cards
          statsAsync.when(
            data: (stats) => _StatsGrid(
              stats: stats,
              onNavigateToSchools: onNavigateToSchools,
              onNavigateToValidation: onNavigateToValidation,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _StatsGrid(
              stats: _demoStats(),
              onNavigateToSchools: onNavigateToSchools,
              onNavigateToValidation: onNavigateToValidation,
            ),
          ),
          const SizedBox(height: 20),

          // Priority Distribution Pie Chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.translate('priority_level'),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              FilledButton.tonalIcon(
                onPressed: computeState.isLoading
                    ? null
                    : () async {
                        await ref
                            .read(computePriorityScoresProvider.notifier)
                            .computeAll();
                        final result =
                            ref.read(computePriorityScoresProvider);
                        if (context.mounted) {
                          result.whenOrNull(
                            data: (msg) {
                              if (msg != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(msg),
                                      backgroundColor: Colors.green),
                                );
                              }
                            },
                            error: (e, _) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('${l10n.translate("error")}: $e'),
                                    backgroundColor: Colors.red),
                              );
                            },
                          );
                        }
                      },
                icon: computeState.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_fix_high, size: 16),
                label: Text(computeState.isLoading
                    ? l10n.loading
                    : l10n.translate('ai_validate')),
              ),
            ],
          ),
          const SizedBox(height: 12),
          priorityAsync.when(
            data: (dist) => _PriorityPieChart(distribution: dist),
            loading: () => const SizedBox(
                height: 200, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => _PriorityPieChart(
                distribution: PriorityDistribution(
                    critical: 15, high: 45, medium: 120, low: 139)),
          ),
          const SizedBox(height: 20),

          // Demand Summary by Infrastructure Type
          Text(
            l10n.translate('infra_demand_plans'),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          demandSummaryAsync.when(
            data: (summaries) => _DemandSummaryCards(
              summaries: summaries,
              onNavigateToValidation: onNavigateToValidation,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => _DemandSummaryCards(
              summaries: _demoSummaries(),
              onNavigateToValidation: onNavigateToValidation,
            ),
          ),
        ],
      ),
    );
  }

  static Map<String, dynamic> _demoStats() => {
        'total_schools': 319,
        'demand_pending': 456,
        'demand_approved': 312,
        'demand_flagged': 89,
        'demand_rejected': 23,
        'total_demands': 880,
      };

  static List<DemandSummary> _demoSummaries() => [
        DemandSummary(infraType: 'CWSN_RESOURCE_ROOM', totalSchools: 45, totalPhysical: 45, totalFinancial: 131.85),
        DemandSummary(infraType: 'CWSN_TOILET', totalSchools: 120, totalPhysical: 120, totalFinancial: 558.0),
        DemandSummary(infraType: 'DRINKING_WATER', totalSchools: 95, totalPhysical: 95, totalFinancial: 323.0),
        DemandSummary(infraType: 'ELECTRIFICATION', totalSchools: 80, totalPhysical: 80, totalFinancial: 140.0),
        DemandSummary(infraType: 'RAMPS', totalSchools: 319, totalPhysical: 319, totalFinancial: 398.75),
      ];
}


class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;
  final VoidCallback? onNavigateToSchools;
  final VoidCallback? onNavigateToValidation;
  const _StatsGrid({
    required this.stats,
    this.onNavigateToSchools,
    this.onNavigateToValidation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          title: l10n.translate('total_schools'),
          value: '${stats['total_schools'] ?? 0}',
          icon: Icons.school,
          color: AppColors.primary,
          onTap: onNavigateToSchools,
        ),
        _StatCard(
          title: l10n.translate('pending_demands'),
          value: '${stats['total_demands'] ?? 0}',
          icon: Icons.description,
          color: AppColors.accent,
          onTap: onNavigateToValidation,
        ),
        _StatCard(
          title: l10n.translate('approved'),
          value: '${stats['demand_approved'] ?? 0}',
          icon: Icons.check_circle,
          color: AppColors.statusApproved,
          onTap: onNavigateToValidation,
        ),
        _StatCard(
          title: l10n.translate('flagged'),
          value: '${stats['demand_flagged'] ?? 0}',
          icon: Icons.flag,
          color: AppColors.statusFlagged,
          onTap: onNavigateToValidation,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (onTap != null)
                    Icon(Icons.arrow_forward_ios,
                        size: 12, color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityPieChart extends StatelessWidget {
  final PriorityDistribution distribution;
  const _PriorityPieChart({required this.distribution});

  @override
  Widget build(BuildContext context) {
    if (distribution.total == 0) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No priority data available')),
      );
    }

    return SizedBox(
      height: 240,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: distribution.critical.toDouble(),
                    title: '${distribution.critical}',
                    color: AppColors.priorityCritical,
                    radius: 60,
                    titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                  PieChartSectionData(
                    value: distribution.high.toDouble(),
                    title: '${distribution.high}',
                    color: AppColors.priorityHigh,
                    radius: 60,
                    titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                  PieChartSectionData(
                    value: distribution.medium.toDouble(),
                    title: '${distribution.medium}',
                    color: AppColors.priorityMedium,
                    radius: 60,
                    titleStyle: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                  PieChartSectionData(
                    value: distribution.low.toDouble(),
                    title: '${distribution.low}',
                    color: AppColors.priorityLow,
                    radius: 60,
                    titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Builder(builder: (context) {
            final l10n = AppLocalizations.of(context);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LegendItem(l10n.translate('critical'), AppColors.priorityCritical,
                    distribution.critical),
                const SizedBox(height: 8),
                _LegendItem(
                    l10n.translate('high_priority'), AppColors.priorityHigh, distribution.high),
                const SizedBox(height: 8),
                _LegendItem(
                    l10n.translate('medium_priority'), AppColors.priorityMedium, distribution.medium),
                const SizedBox(height: 8),
                _LegendItem(l10n.translate('low_priority'), AppColors.priorityLow, distribution.low),
                const SizedBox(height: 12),
                Text('${l10n.translate("total")}: ${distribution.total}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  final int count;
  const _LegendItem(this.label, this.color, this.count);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 8),
        Text('$label ($count)', style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

class _DemandSummaryCards extends StatelessWidget {
  final List<DemandSummary> summaries;
  final VoidCallback? onNavigateToValidation;
  const _DemandSummaryCards({
    required this.summaries,
    this.onNavigateToValidation,
  });

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No demand plan data')),
        ),
      );
    }

    return Column(
      children: summaries.map<Widget>((s) {
        final color = AppColors.forInfraType(s.infraType);
        final icon = AppConstants.infraTypeIcon(s.infraType);
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onNavigateToValidation,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color),
              ),
              title: Text(s.infraTypeLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${s.totalSchools} schools | ${s.totalPhysical} units'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '₹${s.totalFinancial.toStringAsFixed(1)}L',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 14),
                  ),
                  if (onNavigateToValidation != null) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios,
                        size: 12, color: AppColors.textSecondary),
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
