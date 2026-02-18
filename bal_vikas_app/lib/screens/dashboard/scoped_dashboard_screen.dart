import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/api_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_stats_provider.dart';
import '../../utils/telugu_transliterator.dart';
import 'scoped_awc_dashboard_screen.dart';
import 'scoped_children_list_screen.dart';
import 'widgets/challenge_dashboard_widgets.dart';
import 'widgets/shared_dashboard_widgets.dart';
import '../../providers/dataset_provider.dart';

/// Reusable scoped dashboard screen for hierarchical drill-down.
/// Shows a full dashboard (stats, progress, summary, challenge sections, sub-units)
/// for any hierarchy level: district, project, or sector.
class ScopedDashboardScreen extends ConsumerWidget {
  final String scopeLevel; // 'district', 'project', 'sector'
  final int scopeId;
  final String scopeName;

  const ScopedDashboardScreen({
    super.key,
    required this.scopeLevel,
    required this.scopeId,
    required this.scopeName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';
    final isOverride = ref.watch(activeDatasetProvider) != null;

    final statsAsync = _watchStats(ref);

    return Scaffold(
      appBar: AppBar(
        title: Text(isTelugu ? toTelugu(scopeName) : scopeName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stats) => _buildDashboard(context, isTelugu, stats, isOverride),
      ),
    );
  }

  AsyncValue<Map<String, dynamic>> _watchStats(WidgetRef ref) {
    switch (scopeLevel) {
      case 'district':
        return ref.watch(districtStatsProvider(scopeId));
      case 'project':
        return ref.watch(projectStatsProvider(scopeId));
      case 'sector':
        return ref.watch(sectorStatsProvider(scopeId));
      default:
        return ref.watch(districtStatsProvider(scopeId));
    }
  }

  // Level-specific configuration
  String _overviewTitle(bool isTelugu) {
    switch (scopeLevel) {
      case 'district':
        return isTelugu ? 'జిల్లా విహంగావలోకనం' : 'District Overview';
      case 'project':
        return isTelugu ? 'ప్రాజెక్ట్ విహంగావలోకనం' : 'Project Overview';
      case 'sector':
        return isTelugu ? 'సెక్టార్ విహంగావలోకనం' : 'Sector Overview';
      default:
        return 'Overview';
    }
  }

  String _subUnitLabel(bool isTelugu) {
    switch (scopeLevel) {
      case 'district':
        return isTelugu ? 'ప్రాజెక్టులు' : 'Projects';
      case 'project':
        return isTelugu ? 'సెక్టార్లు' : 'Sectors';
      case 'sector':
        return isTelugu ? 'AWCలు' : 'AWCs';
      default:
        return '';
    }
  }

  String _subUnitComparisonTitle(bool isTelugu) {
    switch (scopeLevel) {
      case 'district':
        return isTelugu ? 'ప్రాజెక్టుల వారీ పనితీరు' : 'Project-wise Performance';
      case 'project':
        return isTelugu ? 'సెక్టార్ల వారీ పనితీరు' : 'Sector-wise Performance';
      case 'sector':
        return isTelugu ? 'AWC వారీ పనితీరు' : 'AWC-wise Performance';
      default:
        return '';
    }
  }

  IconData _primaryCardIcon() {
    switch (scopeLevel) {
      case 'district':
        return Icons.business;
      case 'project':
        return Icons.location_city;
      case 'sector':
        return Icons.location_on;
      default:
        return Icons.dashboard;
    }
  }

  String _primaryCardLabel(bool isTelugu) {
    switch (scopeLevel) {
      case 'district':
        return isTelugu ? 'మొత్తం ప్రాజెక్టులు' : 'Total Projects';
      case 'project':
        return isTelugu ? 'మొత్తం సెక్టార్లు' : 'Total Sectors';
      case 'sector':
        return isTelugu ? 'మొత్తం AWCలు' : 'Total AWCs';
      default:
        return '';
    }
  }

  int _primaryCardCount(Map<String, dynamic> stats) {
    switch (scopeLevel) {
      case 'district':
        return stats['total_projects'] ?? 0;
      case 'project':
        return stats['total_sectors'] ?? 0;
      case 'sector':
        return stats['total_awcs'] ?? 0;
      default:
        return 0;
    }
  }

  IconData _subUnitIcon() {
    switch (scopeLevel) {
      case 'district':
        return Icons.business;
      case 'project':
        return Icons.location_city;
      case 'sector':
        return Icons.location_on;
      default:
        return Icons.dashboard;
    }
  }

  Widget _buildDashboard(BuildContext context, bool isTelugu, Map<String, dynamic> stats, bool isOverride) {
    final totalChildren = stats['total_children'] ?? 0;
    final totalAwcs = stats['total_awcs'] ?? 0;
    final screenedThisMonth = stats['screened_this_month'] ?? 0;
    final highRisk = stats['high_risk_count'] ?? 0;
    final referrals = stats['referrals_needed'] ?? 0;
    final pending = totalChildren - screenedThisMonth;
    final subUnits = (stats['sub_units'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scope Header
          ScopeHeaderCard(scopeName: scopeName, scopeLevel: scopeLevel, isTelugu: isTelugu),
          const SizedBox(height: 24),

          // Overview
          Text(_overviewTitle(isTelugu), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: DashboardStatCard(
                icon: _primaryCardIcon(),
                value: '${_primaryCardCount(stats)}',
                label: _primaryCardLabel(isTelugu),
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardStatCard(
                icon: Icons.location_on,
                value: '$totalAwcs',
                label: isTelugu ? 'మొత్తం AWCలు' : 'Total AWCs',
                color: AppColors.primaryDark,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: DashboardStatCard(
                icon: Icons.people,
                value: '$totalChildren',
                label: isTelugu ? 'మొత్తం పిల్లలు' : 'Total Children',
                color: AppColors.accent,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ScopedChildrenListScreen(
                    scopeLevel: scopeLevel, scopeId: scopeId,
                    title: isTelugu ? 'మొత్తం పిల్లలు' : 'All Children', filter: 'all', useRpc: isOverride,
                  ),
                )),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardStatCard(
                icon: Icons.warning,
                value: '$highRisk',
                label: isTelugu ? 'అధిక ప్రమాదం' : 'High Risk',
                color: AppColors.riskHigh,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ScopedChildrenListScreen(
                    scopeLevel: scopeLevel, scopeId: scopeId,
                    title: isTelugu ? 'అధిక ప్రమాద పిల్లలు' : 'High Risk Children', filter: 'high_risk', useRpc: isOverride,
                  ),
                )),
              ),
            ),
          ]),
          const SizedBox(height: 24),

          // Screening Progress
          DashboardProgressCard(total: totalChildren, screened: screenedThisMonth, isTelugu: isTelugu),
          const SizedBox(height: 24),

          // Screening Summary
          Text(isTelugu ? 'స్క్రీనింగ్ సారాంశం' : 'Screening Summary',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                DashboardSummaryRow(
                  label: isTelugu ? 'ఈ నెల తనిఖీలు' : 'Screened This Month',
                  value: '$screenedThisMonth', icon: Icons.check_circle, color: AppColors.riskLow,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ScopedChildrenListScreen(
                      scopeLevel: scopeLevel, scopeId: scopeId,
                      title: isTelugu ? 'ఈ నెల తనిఖీ చేసిన పిల్లలు' : 'Screened This Month', filter: 'screened', useRpc: isOverride,
                    ),
                  )),
                ),
                const Divider(),
                DashboardSummaryRow(
                  label: isTelugu ? 'పెండింగ్' : 'Pending',
                  value: '${pending < 0 ? 0 : pending}', icon: Icons.pending, color: AppColors.riskMedium,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ScopedChildrenListScreen(
                      scopeLevel: scopeLevel, scopeId: scopeId,
                      title: isTelugu ? 'పెండింగ్ పిల్లలు' : 'Pending Children', filter: 'pending', useRpc: isOverride,
                    ),
                  )),
                ),
                const Divider(),
                DashboardSummaryRow(
                  label: isTelugu ? 'రెఫరల్ అవసరం' : 'Referrals Needed',
                  value: '$referrals', icon: Icons.local_hospital, color: AppColors.riskHigh,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ScopedChildrenListScreen(
                      scopeLevel: scopeLevel, scopeId: scopeId,
                      title: isTelugu ? 'రెఫరల్ అవసరమైన పిల్లలు' : 'Referrals Needed', filter: 'referral', useRpc: isOverride,
                    ),
                  )),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 24),

          // Challenge Dashboard sections — scoped
          RiskStratificationSection(isTelugu: isTelugu, scopeLevel: scopeLevel, scopeId: scopeId),
          const SizedBox(height: 24),
          ReferralBoardSection(isTelugu: isTelugu, scopeLevel: scopeLevel, scopeId: scopeId),
          const SizedBox(height: 24),
          FollowupOutcomesSection(isTelugu: isTelugu, scopeLevel: scopeLevel, scopeId: scopeId),
          const SizedBox(height: 24),

          // Sub-unit comparison
          if (subUnits.isNotEmpty) ...[
            Text(_subUnitComparisonTitle(isTelugu),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...subUnits.map((unit) {
              final u = Map<String, dynamic>.from(unit as Map);
              final unitName = u['name']?.toString() ?? '';
              final unitId = u['id'] as int?;
              return DashboardUnitCard(
                name: unitName,
                subUnitLabel: _subUnitLabel(isTelugu),
                subUnitCount: u['sub_unit_count'] ?? 0,
                childrenCount: u['children_count'] ?? 0,
                screenedCount: u['screened_count'] ?? 0,
                highRiskCount: u['high_risk_count'] ?? 0,
                isTelugu: isTelugu,
                icon: _subUnitIcon(),
                onTap: unitId != null ? () => _navigateToSubUnit(context, isTelugu, unitId, unitName) : null,
              );
            }),
          ],
        ],
      ),
    );
  }

  void _navigateToSubUnit(BuildContext context, bool isTelugu, int unitId, String unitName) {
    switch (scopeLevel) {
      case 'district':
        // Sub-units are projects → show project-level dashboard
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ScopedDashboardScreen(scopeLevel: 'project', scopeId: unitId, scopeName: unitName),
        ));
      case 'project':
        // Sub-units are sectors → show sector-level dashboard
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ScopedDashboardScreen(scopeLevel: 'sector', scopeId: unitId, scopeName: unitName),
        ));
      case 'sector':
        // Sub-units are AWCs → show AWC dashboard
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ScopedAwcDashboardScreen(awcId: unitId, awcName: unitName),
        ));
    }
  }
}
