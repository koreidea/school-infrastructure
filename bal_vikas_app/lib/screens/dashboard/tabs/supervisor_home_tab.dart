import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/api_config.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_stats_provider.dart';
import '../../../providers/dataset_provider.dart';
import '../../../utils/telugu_transliterator.dart';
import '../../profile/profile_edit_screen.dart';
import '../scoped_awc_dashboard_screen.dart';
import '../scoped_children_list_screen.dart';
import '../scoped_unit_list_screen.dart';
import '../widgets/challenge_dashboard_widgets.dart';
import '../widgets/shared_dashboard_widgets.dart';


/// Dashboard for Supervisor role (sector-level view)
class SupervisorHomeTab extends ConsumerWidget {
  const SupervisorHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';

    // When a dataset override is active, use project-level stats instead of sector
    final datasetOverride = ref.watch(activeDatasetProvider);
    final overrideProjectId = datasetOverride?.projectId;
    final isOverride = datasetOverride != null;

    final sectorId = overrideProjectId != null ? null : user?.sectorId;
    if (sectorId == null && overrideProjectId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            isTelugu
                ? 'మీ ఖాతాకు సెక్టార్ కేటాయించబడలేదు.\nనిర్వాహకుడిని సంప్రదించండి.'
                : 'No sector assigned to your account.\nPlease contact the administrator.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final statsAsync = overrideProjectId != null
        ? ref.watch(projectStatsProvider(overrideProjectId))
        : ref.watch(sectorStatsProvider(sectorId!));

    // Determine scope level and ID for drill-down navigation
    final scopeLevel = overrideProjectId != null ? 'project' : 'sector';
    final scopeId = overrideProjectId ?? sectorId!;

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (stats) => _buildDashboard(context, user, isTelugu, stats, scopeLevel, scopeId, isOverride),
    );
  }

  Widget _buildDashboard(
    BuildContext context, dynamic user, bool isTelugu, Map<String, dynamic> stats, String scopeLevel, int scopeId, bool isOverride,
  ) {
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
          _SupervisorWelcomeCard(user: user, isTelugu: isTelugu),
          const SizedBox(height: 24),

          Text(scopeLevel == 'project'
              ? (isTelugu ? 'ప్రాజెక్ట్ విహంగావలోకనం' : 'Project Overview')
              : (isTelugu ? 'సెక్టార్ విహంగావలోకనం' : 'Sector Overview'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: DashboardStatCard(icon: Icons.location_on, value: '$totalAwcs',
              label: isTelugu ? 'మొత్తం AWCలు' : 'Total AWCs', color: AppColors.primary,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ScopedUnitListScreen(unitType: 'awc', scopeLevel: scopeLevel, scopeId: scopeId,
                  title: isTelugu ? 'AWC కేంద్రాలు' : 'AWC Centres', subUnits: subUnits))))),
            const SizedBox(width: 12),
            Expanded(child: DashboardStatCard(icon: Icons.people, value: '$totalChildren',
              label: isTelugu ? 'మొత్తం పిల్లలు' : 'Total Children', color: AppColors.primaryDark,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ScopedChildrenListScreen(scopeLevel: scopeLevel, scopeId: scopeId,
                  title: isTelugu ? 'మొత్తం పిల్లలు' : 'All Children', filter: 'all', useRpc: isOverride))))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: DashboardStatCard(icon: Icons.warning, value: '$highRisk',
              label: isTelugu ? 'అధిక ప్రమాదం' : 'High Risk', color: AppColors.riskHigh,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ScopedChildrenListScreen(scopeLevel: scopeLevel, scopeId: scopeId,
                  title: isTelugu ? 'అధిక ప్రమాద పిల్లలు' : 'High Risk Children', filter: 'high_risk', useRpc: isOverride))))),
            const SizedBox(width: 12),
            Expanded(child: DashboardStatCard(icon: Icons.check_circle, value: '$screenedThisMonth',
              label: isTelugu ? 'ఈ నెల తనిఖీలు' : 'Screened', color: AppColors.riskLow,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ScopedChildrenListScreen(scopeLevel: scopeLevel, scopeId: scopeId,
                  title: isTelugu ? 'ఈ నెల తనిఖీ చేసిన పిల్లలు' : 'Screened This Month', filter: 'screened', useRpc: isOverride))))),
          ]),
          const SizedBox(height: 24),

          DashboardProgressCard(total: totalChildren, screened: screenedThisMonth, isTelugu: isTelugu),
          const SizedBox(height: 24),

          Text(isTelugu ? 'స్క్రీనింగ్ సారాంశం' : 'Screening Summary',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            DashboardSummaryRow(label: isTelugu ? 'ఈ నెల తనిఖీలు' : 'Screened This Month',
              value: '$screenedThisMonth', icon: Icons.check_circle, color: AppColors.riskLow,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ScopedChildrenListScreen(scopeLevel: scopeLevel, scopeId: scopeId,
                  title: isTelugu ? 'ఈ నెల తనిఖీ చేసిన పిల్లలు' : 'Screened This Month', filter: 'screened', useRpc: isOverride)))),
            const Divider(),
            DashboardSummaryRow(label: isTelugu ? 'పెండింగ్' : 'Pending',
              value: '${pending < 0 ? 0 : pending}', icon: Icons.pending, color: AppColors.riskMedium,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ScopedChildrenListScreen(scopeLevel: scopeLevel, scopeId: scopeId,
                  title: isTelugu ? 'పెండింగ్ పిల్లలు' : 'Pending Children', filter: 'pending', useRpc: isOverride)))),
            const Divider(),
            DashboardSummaryRow(label: isTelugu ? 'రెఫరల్ అవసరం' : 'Referrals Needed',
              value: '$referrals', icon: Icons.local_hospital, color: AppColors.riskHigh,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ScopedChildrenListScreen(scopeLevel: scopeLevel, scopeId: scopeId,
                  title: isTelugu ? 'రెఫరల్ అవసరమైన పిల్లలు' : 'Referrals Needed', filter: 'referral', useRpc: isOverride)))),
          ]))),
          const SizedBox(height: 24),

          ActionPathwaysSection(
            role: 'SUPERVISOR',
            totalChildren: totalChildren,
            screenedCount: screenedThisMonth,
            highRiskCount: highRisk,
            referralsNeeded: referrals,
            subUnits: subUnits,
            isTelugu: isTelugu,
            onScreenPending: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => ScopedChildrenListScreen(scopeLevel: scopeLevel, scopeId: scopeId,
                title: isTelugu ? 'పెండింగ్ పిల్లలు' : 'Pending Children', filter: 'pending', useRpc: isOverride))),
            onViewHighRisk: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => ScopedChildrenListScreen(scopeLevel: scopeLevel, scopeId: scopeId,
                title: isTelugu ? 'అధిక ప్రమాద పిల్లలు' : 'High Risk Children', filter: 'high_risk', useRpc: isOverride))),
            onViewReferrals: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => ScopedChildrenListScreen(scopeLevel: scopeLevel, scopeId: scopeId,
                title: isTelugu ? 'రెఫరల్ అవసరమైన పిల్లలు' : 'Referrals Needed', filter: 'referral', useRpc: isOverride))),
          ),
          const SizedBox(height: 24),

          RiskStratificationSection(isTelugu: isTelugu),
          const SizedBox(height: 24),
          ReferralBoardSection(isTelugu: isTelugu),
          const SizedBox(height: 24),
          FollowupOutcomesSection(isTelugu: isTelugu),
          const SizedBox(height: 24),

          // AWC-wise Performance — tap to drill into AWC dashboard
          if (subUnits.isNotEmpty) ...[
            Text(isTelugu ? 'AWC వారీ పనితీరు' : 'AWC-wise Performance',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...subUnits.map((unit) {
              final u = Map<String, dynamic>.from(unit as Map);
              final awcName = u['name']?.toString() ?? u['centre_code']?.toString() ?? '';
              return DashboardUnitCard(
                name: awcName,
                subUnitLabel: isTelugu ? 'పిల్లలు' : 'Children',
                subUnitCount: u['children_count'] ?? 0,
                childrenCount: u['children_count'] ?? 0,
                screenedCount: u['screened_count'] ?? 0,
                highRiskCount: u['high_risk_count'] ?? 0,
                isTelugu: isTelugu,
                icon: Icons.location_on,
                onTap: () {
                  final awcId = u['id'] as int?;
                  if (awcId != null) {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ScopedAwcDashboardScreen(
                        awcId: awcId, awcName: awcName)));
                  }
                },
              );
            }),
          ],
        ],
      ),
    );
  }
}

// Welcome card — only used in the native Supervisor tab
class _SupervisorWelcomeCard extends StatelessWidget {
  final dynamic user;
  final bool isTelugu;
  const _SupervisorWelcomeCard({required this.user, required this.isTelugu});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: user?.profilePhotoUrl != null
                  ? NetworkImage(user!.profilePhotoUrl!)
                  : null,
              child: user?.profilePhotoUrl == null
                  ? const Icon(Icons.manage_accounts, size: 30, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isTelugu ? 'స్వాగతం' : 'Welcome', style: const TextStyle(color: AppColors.textSecondary)),
              Text(isTelugu ? toTelugu(user?.name ?? 'User') : (user?.name ?? 'User'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(isTelugu ? 'పర్యవేక్షకులు' : (user?.roleName ?? 'Supervisor'),
                style: const TextStyle(color: AppColors.textSecondary)),
            ])),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ]),
        ),
      ),
    );
  }
}
