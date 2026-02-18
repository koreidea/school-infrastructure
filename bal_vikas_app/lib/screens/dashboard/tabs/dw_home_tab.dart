import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/api_config.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_stats_provider.dart';
import '../../../providers/dataset_provider.dart';
import '../../../services/database_service.dart';
import '../../profile/profile_edit_screen.dart';
import '../../../utils/telugu_transliterator.dart';
import '../scoped_dashboard_screen.dart';
import '../scoped_children_list_screen.dart';
import '../scoped_unit_list_screen.dart';
import '../widgets/challenge_dashboard_widgets.dart';
import '../widgets/shared_dashboard_widgets.dart';


/// Dashboard for DW (District Welfare Officer) — district-level view
class DWHomeTab extends ConsumerWidget {
  const DWHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';

    final districtId = ref.watch(effectiveDistrictIdProvider);
    final isOverride = ref.watch(activeDatasetProvider) != null;
    if (districtId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            isTelugu
                ? 'మీ ఖాతాకు జిల్లా కేటాయించబడలేదు.\nనిర్వాహకుడిని సంప్రదించండి.'
                : 'No district assigned to your account.\nPlease contact the administrator.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final statsAsync = ref.watch(districtStatsProvider(districtId));

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (stats) => _buildDashboard(context, user, isTelugu, stats, districtId, isOverride),
    );
  }

  Widget _buildDashboard(
    BuildContext context, dynamic user, bool isTelugu, Map<String, dynamic> stats, int districtId, bool isOverride,
  ) {
    final totalChildren = stats['total_children'] ?? 0;
    final totalAwcs = stats['total_awcs'] ?? 0;
    final totalProjects = stats['total_projects'] ?? 0;
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
          _DWWelcomeCard(user: user, isTelugu: isTelugu),
          const SizedBox(height: 24),

          Text(isTelugu ? 'జిల్లా విహంగావలోకనం' : 'District Overview',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: DashboardStatCard(icon: Icons.business, value: '$totalProjects',
              label: isTelugu ? 'మొత్తం ప్రాజెక్టులు' : 'Total Projects', color: AppColors.primary,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ScopedUnitListScreen(unitType: 'project', scopeLevel: 'district', scopeId: districtId,
                  title: isTelugu ? 'ప్రాజెక్టులు' : 'Projects', subUnits: subUnits))))),
            const SizedBox(width: 12),
            Expanded(child: DashboardStatCard(icon: Icons.location_on, value: '$totalAwcs',
              label: isTelugu ? 'మొత్తం AWCలు' : 'Total AWCs', color: AppColors.primaryDark,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ScopedUnitListScreen(unitType: 'awc', scopeLevel: 'district', scopeId: districtId,
                  title: isTelugu ? 'AWC కేంద్రాలు' : 'AWC Centres'))))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: DashboardStatCard(icon: Icons.people, value: '$totalChildren',
              label: isTelugu ? 'మొత్తం పిల్లలు' : 'Total Children', color: AppColors.accent,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ScopedChildrenListScreen(scopeLevel: 'district', scopeId: districtId,
                  title: isTelugu ? 'మొత్తం పిల్లలు' : 'All Children', filter: 'all', useRpc: isOverride))))),
            const SizedBox(width: 12),
            Expanded(child: DashboardStatCard(icon: Icons.warning, value: '$highRisk',
              label: isTelugu ? 'అధిక ప్రమాదం' : 'High Risk', color: AppColors.riskHigh,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ScopedChildrenListScreen(scopeLevel: 'district', scopeId: districtId,
                  title: isTelugu ? 'అధిక ప్రమాద పిల్లలు' : 'High Risk Children', filter: 'high_risk', useRpc: isOverride))))),
          ]),
          const SizedBox(height: 24),

          // Early Warning section — children predicted to worsen
          _DWEarlyWarningSection(isTelugu: isTelugu),
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
                builder: (_) => ScopedChildrenListScreen(scopeLevel: 'district', scopeId: districtId,
                  title: isTelugu ? 'ఈ నెల తనిఖీ చేసిన పిల్లలు' : 'Screened This Month', filter: 'screened', useRpc: isOverride)))),
            const Divider(),
            DashboardSummaryRow(label: isTelugu ? 'పెండింగ్' : 'Pending',
              value: '${pending < 0 ? 0 : pending}', icon: Icons.pending, color: AppColors.riskMedium,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ScopedChildrenListScreen(scopeLevel: 'district', scopeId: districtId,
                  title: isTelugu ? 'పెండింగ్ పిల్లలు' : 'Pending Children', filter: 'pending', useRpc: isOverride)))),
            const Divider(),
            DashboardSummaryRow(label: isTelugu ? 'రెఫరల్ అవసరం' : 'Referrals Needed',
              value: '$referrals', icon: Icons.local_hospital, color: AppColors.riskHigh,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ScopedChildrenListScreen(scopeLevel: 'district', scopeId: districtId,
                  title: isTelugu ? 'రెఫరల్ అవసరమైన పిల్లలు' : 'Referrals Needed', filter: 'referral', useRpc: isOverride)))),
          ]))),
          const SizedBox(height: 24),

          ActionPathwaysSection(
            role: 'DW',
            totalChildren: totalChildren,
            screenedCount: screenedThisMonth,
            highRiskCount: highRisk,
            referralsNeeded: referrals,
            subUnits: subUnits,
            isTelugu: isTelugu,
            onScreenPending: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => ScopedChildrenListScreen(scopeLevel: 'district', scopeId: districtId,
                title: isTelugu ? 'పెండింగ్ పిల్లలు' : 'Pending Children', filter: 'pending', useRpc: isOverride))),
            onViewHighRisk: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => ScopedChildrenListScreen(scopeLevel: 'district', scopeId: districtId,
                title: isTelugu ? 'అధిక ప్రమాద పిల్లలు' : 'High Risk Children', filter: 'high_risk', useRpc: isOverride))),
            onViewReferrals: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => ScopedChildrenListScreen(scopeLevel: 'district', scopeId: districtId,
                title: isTelugu ? 'రెఫరల్ అవసరమైన పిల్లలు' : 'Referrals Needed', filter: 'referral', useRpc: isOverride))),
          ),
          const SizedBox(height: 24),

          RiskStratificationSection(isTelugu: isTelugu),
          const SizedBox(height: 24),
          ReferralBoardSection(isTelugu: isTelugu),
          const SizedBox(height: 24),
          FollowupOutcomesSection(isTelugu: isTelugu),
          const SizedBox(height: 24),

          // Project-wise Performance — tap to drill into CDPO-style dashboard
          if (subUnits.isNotEmpty) ...[
            Text(isTelugu ? 'ప్రాజెక్టుల వారీ పనితీరు' : 'Project-wise Performance',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...subUnits.map((unit) {
              final u = Map<String, dynamic>.from(unit as Map);
              final unitName = u['name']?.toString() ?? '';
              return DashboardUnitCard(
                name: unitName,
                subUnitLabel: isTelugu ? 'సెక్టార్లు' : 'Sectors',
                subUnitCount: u['sub_unit_count'] ?? 0,
                childrenCount: u['children_count'] ?? 0,
                screenedCount: u['screened_count'] ?? 0,
                highRiskCount: u['high_risk_count'] ?? 0,
                isTelugu: isTelugu,
                icon: Icons.business,
                onTap: () {
                  final projectId = u['id'] as int?;
                  if (projectId != null) {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ScopedDashboardScreen(
                        scopeLevel: 'project', scopeId: projectId, scopeName: unitName)));
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

/// Early Warning section for DW dashboard
class _DWEarlyWarningSection extends StatelessWidget {
  final bool isTelugu;
  const _DWEarlyWarningSection({required this.isTelugu});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadEarlyWarningChildren(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final children = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  isTelugu
                      ? 'ముందస్తు హెచ్చరిక (${children.length})'
                      : 'Early Warning (${children.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isTelugu
                  ? 'ప్రస్తుతం తక్కువ/మధ్యస్థ ప్రమాదం — అధిక ప్రమాదంగా మారే అవకాశం'
                  : 'Currently Low/Medium risk — predicted to become High',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            ...children.take(5).map((child) => Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.orange.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.orange.shade50,
                          child: Icon(Icons.child_care, size: 18, color: Colors.orange.shade700),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                child['name'] ?? 'Child #${child['childRemoteId']}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${isTelugu ? 'ప్రస్తుతం' : 'Current'}: ${child['currentRisk']}  →  '
                                '${isTelugu ? 'అంచనా' : 'Predicted'}: ${child['predictedCategory']}',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${child['score']?.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        );
      },
    );
  }

  static Future<List<Map<String, dynamic>>> _loadEarlyWarningChildren() async {
    if (kIsWeb) return [];
    try {
      final db = DatabaseService.db;
      final results = await db.screeningDao.getEarlyWarningResults();
      if (results.isEmpty) return [];

      final latestByChild = <int, dynamic>{};
      for (final r in results) {
        if (r.childRemoteId == null) continue;
        final existing = latestByChild[r.childRemoteId!];
        if (existing == null || r.id > existing.id) {
          latestByChild[r.childRemoteId!] = r;
        }
      }

      final allChildren = await db.childrenDao.getAllChildren();
      final childNames = <int, String>{};
      for (final c in allChildren) {
        if (c.remoteId != null) {
          childNames[c.remoteId!] = c.name;
        }
      }

      return latestByChild.entries.map((e) {
        final r = e.value;
        return {
          'childRemoteId': e.key,
          'name': childNames[e.key],
          'currentRisk': r.overallRisk,
          'predictedCategory': r.predictedRiskCategory ?? 'High',
          'score': r.predictedRiskScore ?? 0,
        };
      }).toList()
        ..sort((a, b) => ((b['score'] as num?) ?? 0).compareTo((a['score'] as num?) ?? 0));
    } catch (e) {
      return [];
    }
  }
}

// Welcome card — only used in the native DW tab
class _DWWelcomeCard extends StatelessWidget {
  final dynamic user;
  final bool isTelugu;
  const _DWWelcomeCard({required this.user, required this.isTelugu});

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
              child: Icon(Icons.account_balance, size: 30, color: AppColors.primary)),
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
