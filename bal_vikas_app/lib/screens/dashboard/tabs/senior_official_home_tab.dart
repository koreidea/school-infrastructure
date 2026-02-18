import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/api_config.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_stats_provider.dart';
import '../../../providers/dataset_provider.dart';
import '../../profile/profile_edit_screen.dart';
import '../../../utils/telugu_transliterator.dart';
import '../scoped_dashboard_screen.dart';
import '../scoped_children_list_screen.dart';
import '../scoped_unit_list_screen.dart';
import '../widgets/challenge_dashboard_widgets.dart';
import '../widgets/shared_dashboard_widgets.dart';
import '../../governance/data_governance_dashboard.dart';

/// Dashboard for SENIOR_OFFICIAL — state-level view
class SeniorOfficialHomeTab extends ConsumerWidget {
  const SeniorOfficialHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';

    final datasetOverride = ref.watch(activeDatasetProvider);
    final isOverride = datasetOverride != null;
    final isMultiDistrict = datasetOverride?.isMultiDistrict ?? false;
    final stateId = ref.watch(effectiveStateIdProvider);
    final districtId = ref.watch(effectiveDistrictIdProvider);
    final sampleDistrictIds = ref.watch(sampleDatasetDistrictIdsProvider);
    final ecdDistrictIds = datasetOverride?.districtIds ?? [];

    // Multi-district ECD: use state scope, then filter sub_units to only ECD districts.
    // Single-district ECD: use district scope.
    // App Data (no override): use state scope, filter out sample districts.
    final String effectiveScopeLevel;
    final int? effectiveScopeId;
    if (isOverride && isMultiDistrict) {
      // State scope — we'll filter sub_units to ECD district IDs only
      effectiveScopeLevel = 'state';
      effectiveScopeId = stateId;
    } else if (isOverride) {
      effectiveScopeLevel = 'district';
      effectiveScopeId = districtId;
    } else {
      effectiveScopeLevel = 'state';
      effectiveScopeId = stateId;
    }

    if (effectiveScopeId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            isTelugu
                ? 'మీ ఖాతాకు రాష్ట్రం కేటాయించబడలేదు.\nనిర్వాహకుడిని సంప్రదించండి.'
                : 'No state assigned to your account.\nPlease contact the administrator.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final statsAsync = (isOverride && !isMultiDistrict && districtId != null)
        ? ref.watch(districtStatsProvider(districtId))
        : ref.watch(stateStatsProvider(effectiveScopeId!));

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (stats) => _buildDashboard(context, user, isTelugu, stats, effectiveScopeLevel, effectiveScopeId!, isOverride, sampleDistrictIds, isMultiDistrict, ecdDistrictIds),
    );
  }

  Widget _buildDashboard(
    BuildContext context, dynamic user, bool isTelugu, Map<String, dynamic> stats,
    String scopeLevel, int scopeId, bool isOverride, Set<int> sampleDistrictIds,
    bool isMultiDistrict, List<int> ecdDistrictIds,
  ) {
    // Filter sub_units based on context:
    // - App Data (no override): filter OUT sample dataset districts
    // - Multi-district ECD override: filter to ONLY ECD district IDs
    // - Single-district override: no filtering needed (already district-scoped)
    final rawSubUnits = (stats['sub_units'] as List?) ?? [];
    final List<dynamic> subUnits;
    final bool needsRecompute;
    if (isOverride && isMultiDistrict && ecdDistrictIds.isNotEmpty) {
      // Multi-district ECD: only show ECD districts
      subUnits = rawSubUnits.where((u) {
        final id = (u as Map)['id'];
        return id != null && ecdDistrictIds.contains(id);
      }).toList();
      needsRecompute = true;
    } else if (!isOverride && sampleDistrictIds.isNotEmpty) {
      // App Data: exclude sample districts
      subUnits = rawSubUnits.where((u) {
        final id = (u as Map)['id'];
        return id != null && !sampleDistrictIds.contains(id);
      }).toList();
      needsRecompute = true;
    } else {
      subUnits = rawSubUnits;
      needsRecompute = false;
    }

    // Recompute totals from filtered sub_units when needed
    int totalChildren, totalAwcs, screenedThisMonth, highRisk, referrals;
    int totalSubUnits;
    if (needsRecompute) {
      // Sum from filtered sub_units (districts)
      totalChildren = 0;
      totalAwcs = 0;
      screenedThisMonth = 0;
      highRisk = 0;
      referrals = 0;
      totalSubUnits = subUnits.length;
      for (final u in subUnits) {
        final m = u as Map;
        totalChildren += (m['children_count'] as num?)?.toInt() ?? 0;
        totalAwcs += (m['awc_count'] as num?)?.toInt() ?? 0;
        screenedThisMonth += (m['screened_count'] as num?)?.toInt() ?? 0;
        highRisk += (m['high_risk_count'] as num?)?.toInt() ?? 0;
        referrals += (m['referrals_needed'] as num?)?.toInt() ?? 0;
      }
    } else {
      totalChildren = stats['total_children'] ?? 0;
      totalAwcs = stats['total_awcs'] ?? 0;
      screenedThisMonth = stats['screened_this_month'] ?? 0;
      highRisk = stats['high_risk_count'] ?? 0;
      referrals = stats['referrals_needed'] ?? 0;
      totalSubUnits = isOverride
          ? (stats['total_projects'] ?? 0)
          : (stats['total_districts'] ?? 0);
    }
    final pending = totalChildren - screenedThisMonth;

    // Labels change based on scope level
    // Multi-district ECD uses state scope but shows districts as sub-units
    final showDistrictsAsSubUnits = !isOverride || isMultiDistrict;
    final subUnitLabel = showDistrictsAsSubUnits
        ? (isTelugu ? 'జిల్లాలు' : 'Districts')
        : (isTelugu ? 'ప్రాజెక్టులు' : 'Projects');
    final overviewLabel = (isOverride && !isMultiDistrict)
        ? (isTelugu ? 'జిల్లా విహంగావలోకనం' : 'District Overview')
        : (isOverride ? (isTelugu ? 'ECD నమూనా విహంగావలోకనం' : 'ECD Sample Overview')
            : (isTelugu ? 'రాష్ట్ర విహంగావలోకనం' : 'State Overview'));
    final perfLabel = showDistrictsAsSubUnits
        ? (isTelugu ? 'జిల్లాల వారీ పనితీరు' : 'District-wise Performance')
        : (isTelugu ? 'ప్రాజెక్ట్ వారీ పనితీరు' : 'Project-wise Performance');
    final subUnitDrillScope = showDistrictsAsSubUnits ? 'district' : 'project';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SOWelcomeCard(user: user, isTelugu: isTelugu),
          const SizedBox(height: 24),

          Text(overviewLabel,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: DashboardStatCard(icon: showDistrictsAsSubUnits ? Icons.map : Icons.business, value: '$totalSubUnits',
              label: showDistrictsAsSubUnits ? (isTelugu ? 'మొత్తం జిల్లాలు' : 'Total Districts') : (isTelugu ? 'మొత్తం ప్రాజెక్టులు' : 'Total Projects'),
              color: AppColors.primary,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ScopedUnitListScreen(
                  unitType: showDistrictsAsSubUnits ? 'district' : 'project',
                  scopeLevel: scopeLevel, scopeId: scopeId,
                  title: subUnitLabel, subUnits: subUnits))))),
            const SizedBox(width: 12),
            Expanded(child: DashboardStatCard(icon: Icons.location_on, value: '$totalAwcs',
              label: isTelugu ? 'మొత్తం AWCలు' : 'Total AWCs', color: AppColors.primaryDark,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ScopedUnitListScreen(unitType: 'awc', scopeLevel: scopeLevel, scopeId: scopeId,
                  title: isTelugu ? 'AWC కేంద్రాలు' : 'AWC Centres'))))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: DashboardStatCard(icon: Icons.people, value: '$totalChildren',
              label: isTelugu ? 'మొత్తం పిల్లలు' : 'Total Children', color: AppColors.accent,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ScopedChildrenListScreen(scopeLevel: scopeLevel, scopeId: scopeId,
                  title: isTelugu ? 'మొత్తం పిల్లలు' : 'All Children', filter: 'all', useRpc: isOverride))))),
            const SizedBox(width: 12),
            Expanded(child: DashboardStatCard(icon: Icons.warning, value: '$highRisk',
              label: isTelugu ? 'అధిక ప్రమాదం' : 'High Risk', color: AppColors.riskHigh,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ScopedChildrenListScreen(scopeLevel: scopeLevel, scopeId: scopeId,
                  title: isTelugu ? 'అధిక ప్రమాద పిల్లలు' : 'High Risk Children', filter: 'high_risk', useRpc: isOverride))))),
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
            role: 'SENIOR_OFFICIAL',
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

          // Data Governance
          Card(
            child: ListTile(
              leading: Icon(Icons.admin_panel_settings, color: const Color(0xFF00796B)),
              title: Text(isTelugu ? 'డేటా గవర్నెన్స్' : 'Data Governance'),
              subtitle: Text(isTelugu ? 'DPDP సమ్మతి & ఆడిట్ లాగ్' : 'DPDP Compliance & Audit Log'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const DataGovernanceDashboard())),
            ),
          ),
          const SizedBox(height: 24),

          // Sub-unit Performance (Districts when state scope, Projects when district scope)
          if (subUnits.isNotEmpty) ...[
            Text(perfLabel,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...subUnits.map((unit) {
              final u = Map<String, dynamic>.from(unit as Map);
              final unitName = u['name']?.toString() ?? '';
              return DashboardUnitCard(
                name: unitName,
                subUnitLabel: showDistrictsAsSubUnits
                    ? (isTelugu ? 'ప్రాజెక్టులు' : 'Projects')
                    : (isTelugu ? 'సెక్టార్లు' : 'Sectors'),
                subUnitCount: u['sub_unit_count'] ?? 0,
                childrenCount: u['children_count'] ?? 0,
                screenedCount: u['screened_count'] ?? 0,
                highRiskCount: u['high_risk_count'] ?? 0,
                isTelugu: isTelugu,
                icon: showDistrictsAsSubUnits ? Icons.map : Icons.business,
                onTap: () {
                  final unitId = u['id'] as int?;
                  if (unitId != null) {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ScopedDashboardScreen(
                        scopeLevel: subUnitDrillScope, scopeId: unitId, scopeName: unitName)));
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

// Welcome card — only used in the native SO tab
class _SOWelcomeCard extends StatelessWidget {
  final dynamic user;
  final bool isTelugu;
  const _SOWelcomeCard({required this.user, required this.isTelugu});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            CircleAvatar(radius: 30, backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.stars, size: 30, color: AppColors.primary)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isTelugu ? 'స్వాగతం' : 'Welcome', style: const TextStyle(color: AppColors.textSecondary)),
              Text(isTelugu ? toTelugu(user?.name ?? 'User') : (user?.name ?? 'User'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(user?.roleName ?? '', style: const TextStyle(color: AppColors.textSecondary)),
            ])),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ]),
        ),
      ),
    );
  }
}
