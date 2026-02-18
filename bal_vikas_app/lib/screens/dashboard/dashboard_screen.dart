import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../config/api_config.dart';
import '../../models/user.dart';
import '../../providers/children_provider.dart';
import '../../providers/dataset_provider.dart';
import '../../providers/intervention_provider.dart';
import '../../services/database_service.dart';
import '../../services/supabase_service.dart';
import '../../services/connectivity_service.dart';
import '../children/child_list_screen.dart';
import '../children/child_profile_screen.dart';
import '../screening/screening_start_screen.dart';
import '../settings/settings_screen.dart';
import '../interventions/activity_list_screen.dart';
import '../profile/profile_edit_screen.dart';
import 'tabs/cdpo_home_tab.dart';
import 'tabs/dw_home_tab.dart';
import 'tabs/senior_official_home_tab.dart';
import 'tabs/reports_tab.dart';
import 'tabs/supervisor_home_tab.dart';
import 'tabs/parent_home_tab.dart';
import '../../utils/telugu_transliterator.dart';
import 'widgets/challenge_dashboard_widgets.dart';
import 'widgets/shared_dashboard_widgets.dart';
import '../../services/ecd_excel_export_service.dart';
import '../admin/admin_dashboard_screen.dart';
import '../children/child_status_card.dart';
import '../../providers/screening_results_storage.dart';
import 'tabs/model_validation_tab.dart';
import 'tabs/pilot_impact_tab.dart';


/// AWW dashboard stats from local Drift DB
class AwwStatsData {
  final int totalChildren;
  final int screenedThisMonth;
  final int highRisk;
  final int mediumRisk;
  final int pendingScreenings;
  final List<Map<String, dynamic>> priorityChildren; // HIGH + MEDIUM
  final List<Map<String, dynamic>> screenedThisMonthChildren;
  final Set<int> screenedChildIds;

  const AwwStatsData({
    this.totalChildren = 0,
    this.screenedThisMonth = 0,
    this.highRisk = 0,
    this.mediumRisk = 0,
    this.pendingScreenings = 0,
    this.priorityChildren = const [],
    this.screenedThisMonthChildren = const [],
    this.screenedChildIds = const {},
  });
}

final awwStatsProvider = FutureProvider<AwwStatsData>((ref) async {
  final children = ref.watch(childrenProvider).value ?? [];
  final totalChildren = children.length;
  final isOverride = ref.watch(activeDatasetProvider) != null;
  // ignore: avoid_print
  print('[AWW-STATS] children count=$totalChildren, override=$isOverride');

  // Build child lookup by child_id
  final childById = <int, Map<String, dynamic>>{};
  final childIds = <int>[];
  for (final c in children) {
    final cid = c['child_id'];
    if (cid is int) {
      childById[cid] = c;
      childIds.add(cid);
    }
  }
  // ignore: avoid_print
  print('[AWW-STATS] childIds=$childIds');

  // Latest result per child: {child_id → {overall_risk, composite_dq, created_at}}
  final latestPerChild = <int, Map<String, dynamic>>{};

  // === Source 1: Supabase (primary, if online) ===
  // ignore: avoid_print
  print('[AWW-STATS] online=${ConnectivityService.isOnline}, childIds.length=${childIds.length}');
  if (ConnectivityService.isOnline && childIds.isNotEmpty) {
    try {
      List<Map<String, dynamic>> remoteResults;
      if (isOverride) {
        // Dataset override: use RPC to bypass RLS for ECD sample data
        final rpcRows = await SupabaseService.client.rpc(
          'get_screening_results_for_children',
          params: {'p_child_ids': childIds},
        );
        remoteResults = (rpcRows as List)
            .map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r as Map))
            .toList();
      } else {
        remoteResults = await SupabaseService.getScreeningResultsForChildren(childIds);
      }
      // ignore: avoid_print
      print('[AWW-STATS] Supabase returned ${remoteResults.length} results (rpc=$isOverride)');
      // Results are ordered by created_at DESC, so first occurrence per child_id is latest
      for (final r in remoteResults) {
        final cid = r['child_id'] as int?;
        if (cid != null && !latestPerChild.containsKey(cid)) {
          // RPC returns flat rows; direct query has nested screening_sessions
          final session = isOverride ? null : r['screening_sessions'] as Map<String, dynamic>?;
          latestPerChild[cid] = {
            'overall_risk': r['overall_risk'] ?? 'LOW',
            'composite_dq': r['composite_dq'],
            'assessment_date': isOverride
                ? (r['assessment_date'] ?? r['created_at'] ?? '')
                : (session?['assessment_date'] ?? r['created_at'] ?? ''),
          };
          // ignore: avoid_print
          print('[AWW-STATS] Supabase child=$cid risk=${r['overall_risk']}');
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[AWW-STATS] Supabase FAILED: $e');
    }
  }

  // === Source 2: Drift local DB (fallback / merge) ===
  // Skip Drift when dataset override is active — ECD data lives on Supabase only
  if (!isOverride && !kIsWeb) {
    try {
      final db = DatabaseService.db;
      final localResults = await db.screeningDao.getAllResults();
      // ignore: avoid_print
      print('[AWW-STATS] Drift has ${localResults.length} local results');
      // Sort by id DESC for reliable latest-first
      localResults.sort((a, b) => b.id.compareTo(a.id));

      // Also build local_id → child_id mapping for fallback matching
      final localIdToChildId = <int, int>{};
      for (final c in children) {
        final cid = c['child_id'];
        final lid = c['local_id'];
        if (cid is int && lid is int) localIdToChildId[lid] = cid;
      }

      for (final r in localResults) {
        // Resolve to child_id
        int? resolvedChildId;
        if (r.childRemoteId != null && childById.containsKey(r.childRemoteId!)) {
          resolvedChildId = r.childRemoteId!;
        } else if (r.childLocalId != null) {
          resolvedChildId = localIdToChildId[r.childLocalId!];
        }
        if (resolvedChildId == null) continue;

        // Only use Drift result if Supabase didn't already provide one for this child
        if (!latestPerChild.containsKey(resolvedChildId)) {
          latestPerChild[resolvedChildId] = {
            'overall_risk': r.overallRisk,
            'composite_dq': r.compositeDq,
            'assessment_date': '',
          };
          // ignore: avoid_print
          print('[AWW-STATS] Drift child=$resolvedChildId risk=${r.overallRisk}');
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[AWW-STATS] Drift FAILED: $e');
    }
  }

  // ignore: avoid_print
  print('[AWW-STATS] latestPerChild has ${latestPerChild.length} entries');
  for (final e in latestPerChild.entries) {
    // ignore: avoid_print
    print('[AWW-STATS]   child=${e.key} risk=${e.value['overall_risk']} date=${e.value['assessment_date']}');
  }

  // === Count screened this month ===
  final now = DateTime.now();
  final monthPrefix = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  final screenedThisMonthIds = <int>{};
  // Check Drift sessions first (skip when dataset override is active)
  if (!isOverride && !kIsWeb) {
    try {
      final db = DatabaseService.db;
      final monthSessions = await db.screeningDao.getSessionsCompletedThisMonth();
      for (final s in monthSessions) {
        final cid = s.childRemoteId;
        if (cid != null) screenedThisMonthIds.add(cid);
      }
      // ignore: avoid_print
      print('[AWW-STATS] Drift monthSessions=${monthSessions.length} uniqueChildren=${screenedThisMonthIds.length}');
    } catch (_) {}
  }
  // Also check Supabase results (by assessment_date)
  for (final entry in latestPerChild.entries) {
    final date = entry.value['assessment_date']?.toString() ?? '';
    if (date.startsWith(monthPrefix)) {
      screenedThisMonthIds.add(entry.key);
    }
  }
  final screenedThisMonth = screenedThisMonthIds.length;
  // ignore: avoid_print
  print('[AWW-STATS] screenedThisMonth=$screenedThisMonth (monthPrefix=$monthPrefix)');

  // === Build stats ===
  final screenedChildIds = latestPerChild.keys.toSet();
  final pending = totalChildren - screenedChildIds.length;

  int highCount = 0;
  int mediumCount = 0;
  final priorityChildren = <Map<String, dynamic>>[];

  // Collect HIGH first, then MEDIUM
  for (final risk in ['HIGH', 'MEDIUM']) {
    for (final entry in latestPerChild.entries) {
      if (entry.value['overall_risk'] == risk) {
        if (risk == 'HIGH') highCount++;
        if (risk == 'MEDIUM') mediumCount++;
        final child = childById[entry.key];
        if (child != null) {
          priorityChildren.add({
            ...child,
            'overall_risk': risk,
            'composite_dq': entry.value['composite_dq'],
          });
        }
      }
    }
  }

  // Build screened-this-month children list
  final screenedThisMonthChildren = <Map<String, dynamic>>[];
  for (final cid in screenedThisMonthIds) {
    final child = childById[cid];
    if (child != null) {
      final result = latestPerChild[cid];
      screenedThisMonthChildren.add({
        ...child,
        'overall_risk': result?['overall_risk'] ?? 'LOW',
        'composite_dq': result?['composite_dq'],
      });
    }
  }

  // ignore: avoid_print
  print('[AWW-STATS] FINAL: total=$totalChildren screened=$screenedThisMonth high=$highCount med=$mediumCount priority=${priorityChildren.length} pending=$pending');

  return AwwStatsData(
    totalChildren: totalChildren,
    screenedThisMonth: screenedThisMonth,
    highRisk: highCount,
    mediumRisk: mediumCount,
    pendingScreenings: pending < 0 ? 0 : pending,
    priorityChildren: priorityChildren,
    screenedThisMonthChildren: screenedThisMonthChildren,
    screenedChildIds: screenedChildIds,
  );
});

/// Aggregated daily activities for the AWW centre based on all screened children
final awwDailyActivitiesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final children = ref.watch(childrenProvider).value ?? [];
  if (children.isEmpty) return [];

  // Reuse stats provider to get latest per child (already queries Supabase + Drift)
  final stats = await ref.watch(awwStatsProvider.future);
  if (stats.priorityChildren.isEmpty) return [];

  final activityCounts = <String, Map<String, dynamic>>{};

  for (final child in stats.priorityChildren) {
    final ageMonths = child['age_months'] as int? ?? 0;
    final risk = child['overall_risk'] as String? ?? 'LOW';

    // For priority children (HIGH/MEDIUM), assume general delays
    final delays = <String, dynamic>{
      'gm_delay': true,
      'fm_delay': true,
      'lc_delay': true,
      'cog_delay': true,
      'se_delay': true,
    };

    final recommended = getRecommendedActivities(
      childAgeMonths: ageMonths,
      delays: delays,
      overallRisk: risk,
    );

    // Only take the top 1 activity per child
    if (recommended.isNotEmpty) {
      final activity = recommended.first;
      final code = activity['activity_code'] as String;
      if (activityCounts.containsKey(code)) {
        activityCounts[code]!['child_count'] =
            (activityCounts[code]!['child_count'] as int) + 1;
      } else {
        activityCounts[code] = {
          ...activity,
          'child_count': 1,
        };
      }
    }
  }

  // Sort by child_count descending, then by domain
  final activities = activityCounts.values.toList();
  activities.sort((a, b) {
    final countCmp = (b['child_count'] as int).compareTo(a['child_count'] as int);
    if (countCmp != 0) return countCmp;
    return (a['domain'] as String).compareTo(b['domain'] as String);
  });

  return activities.take(10).toList();
});

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final language = ref.watch(languageProvider);
    
    final isTelugu = language == 'te';

    // Build screens based on user role
    final screens = _buildScreensForRole(user);
    final destinations = _buildDestinationsForRole(user, isTelugu);

    return Scaffold(
      appBar: AppBar(
        title: Text(isTelugu ? 'బాల్ వికాస్' : 'Bal Vikas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // Analytics menu (visible to supervisory roles)
          if (user != null && !user.isAWW && !user.isParent)
            PopupMenuButton<String>(
              icon: const Icon(Icons.analytics),
              onSelected: (value) {
                if (value == 'validation') {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const ModelValidationScreen(),
                  ));
                } else if (value == 'impact') {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const PilotImpactScreen(),
                  ));
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'validation',
                  child: ListTile(
                    leading: const Icon(Icons.verified, size: 20),
                    title: Text(isTelugu ? 'మోడల్ ధృవీకరణ' : 'Model Validation'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'impact',
                  child: ListTile(
                    leading: const Icon(Icons.assessment, size: 20),
                    title: Text(isTelugu ? 'పైలట్ ప్రభావం' : 'Pilot Impact'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Dataset override banner
          const _DatasetBanner(),
          Expanded(child: screens[_currentIndex]),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(user),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: destinations,
      ),
    );
  }

  /// Build screens based on user role
  List<Widget> _buildScreensForRole(user) {
    // PARENT: Home, My Children, Activities, Settings
    if (user?.isParent ?? false) {
      return [
        const ParentHomeTab(),
        const ChildListScreen(),
        const _ActivitiesTab(),
        const SettingsScreen(),
      ];
    }
    
    // AWW: Home, Children, Activities, Settings
    if (user?.isAWW ?? false) {
      return [
        const _AWWHomeTab(),
        const ChildListScreen(),
        const _ActivitiesTab(),
        const SettingsScreen(),
      ];
    }
    
    // SUPERVISOR: Home, Children, Reports, Admin, Settings
    if (user?.isSupervisor ?? false) {
      return [
        const SupervisorHomeTab(),
        const ChildListScreen(),
        const ReportsTab(),
        const AdminDashboardScreen(),
        const SettingsScreen(),
      ];
    }

    // CDPO / CW / EO: Home, Children, Reports, Admin, Settings
    if ((user?.isCDPO ?? false) || (user?.isCW ?? false) || (user?.isEO ?? false)) {
      return [
        const CDPOHomeTab(),
        const ChildListScreen(),
        const ReportsTab(),
        const AdminDashboardScreen(),
        const SettingsScreen(),
      ];
    }

    // DW: Home, Children, Reports, Admin, Settings
    if (user?.isDW ?? false) {
      return [
        const DWHomeTab(),
        const ChildListScreen(),
        const ReportsTab(),
        const AdminDashboardScreen(),
        const SettingsScreen(),
      ];
    }

    // SENIOR_OFFICIAL: Home, Children, Reports, Admin, Settings
    if (user?.isSeniorOfficial ?? false) {
      return [
        const SeniorOfficialHomeTab(),
        const ChildListScreen(),
        const ReportsTab(),
        const AdminDashboardScreen(),
        const SettingsScreen(),
      ];
    }

    // Default view for users without role
    return [
      const _DefaultHomeTab(),
      const ChildListScreen(),
      const _ActivitiesTab(),
      const SettingsScreen(),
    ];
  }

  /// Build navigation destinations based on user role
  List<NavigationDestination> _buildDestinationsForRole(user, bool isTelugu) {
    // SUPERVISOR: Home, Children, Reports, Admin, Settings
    if (user?.isSupervisor ?? false) {
      return [
        NavigationDestination(
          icon: const Icon(Icons.home),
          label: isTelugu ? 'హోమ్' : 'Home',
        ),
        NavigationDestination(
          icon: const Icon(Icons.people),
          label: isTelugu ? 'పిల్లలు' : 'Children',
        ),
        NavigationDestination(
          icon: const Icon(Icons.assessment),
          label: isTelugu ? 'నివేదికలు' : 'Reports',
        ),
        NavigationDestination(
          icon: const Icon(Icons.admin_panel_settings),
          label: isTelugu ? 'అడ్మిన్' : 'Admin',
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings),
          label: isTelugu ? 'సెట్టింగులు' : 'Settings',
        ),
      ];
    }

    // CDPO / CW / EO / DW / SENIOR_OFFICIAL: Home, Children, Reports, Admin, Settings
    if ((user?.isCDPO ?? false) || (user?.isCW ?? false) || (user?.isEO ?? false) ||
        (user?.isDW ?? false) || (user?.isSeniorOfficial ?? false)) {
      return [
        NavigationDestination(
          icon: const Icon(Icons.home),
          label: isTelugu ? 'హోమ్' : 'Home',
        ),
        NavigationDestination(
          icon: const Icon(Icons.people),
          label: isTelugu ? 'పిల్లలు' : 'Children',
        ),
        NavigationDestination(
          icon: const Icon(Icons.assessment),
          label: isTelugu ? 'నివేదికలు' : 'Reports',
        ),
        NavigationDestination(
          icon: const Icon(Icons.admin_panel_settings),
          label: isTelugu ? 'అడ్మిన్' : 'Admin',
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings),
          label: isTelugu ? 'సెట్టింగులు' : 'Settings',
        ),
      ];
    }

    // PARENT and AWW: Standard navigation
    return [
      NavigationDestination(
        icon: const Icon(Icons.home),
        label: isTelugu ? 'హోమ్' : 'Home',
      ),
      NavigationDestination(
        icon: const Icon(Icons.people),
        label: isTelugu ? 'పిల్లలు' : 'Children',
      ),
      NavigationDestination(
        icon: const Icon(Icons.fitness_center),
        label: isTelugu ? 'కార్యకలాపాలు' : 'Activities',
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings),
        label: isTelugu ? 'సెట్టింగులు' : 'Settings',
      ),
    ];
  }

  /// Build FAB based on role and current tab
  /// Returns null — each tab screen manages its own FAB to avoid nested Scaffold overlap
  Widget? _buildFloatingActionButton(user) {
    return null;
  }
}

// PARENT DASHBOARD → moved to tabs/parent_home_tab.dart
// ============================================================================
// AWW DASHBOARD
// ============================================================================

class _AWWHomeTab extends ConsumerWidget {
  const _AWWHomeTab();

  void _showFilteredChildren(
    BuildContext context,
    String title,
    List<Map<String, dynamic>> children,
    bool isTelugu,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FilteredChildListScreen(
          title: title,
          children: children,
          isTelugu: isTelugu,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';
    final statsAsync = ref.watch(awwStatsProvider);
    final allChildren = ref.watch(childrenProvider).value ?? [];

    final stats = statsAsync.value ?? const AwwStatsData();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          _WelcomeCard(
            user: user,
            isTelugu: isTelugu,
            icon: Icons.school,
          ),
          const SizedBox(height: 24),

          // Center Stats
          Text(
            isTelugu ? 'కేంద్ర గణాంకాలు' : 'Center Statistics',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.people,
                  value: '${stats.totalChildren}',
                  label: isTelugu ? 'మొత్తం పిల్లలు' : 'Total Children',
                  color: AppColors.primary,
                  onTap: () => _showFilteredChildren(
                    context,
                    isTelugu ? 'మొత్తం పిల్లలు' : 'All Children',
                    allChildren,
                    isTelugu,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle,
                  value: '${stats.screenedThisMonth}',
                  label: isTelugu ? 'ఈ నెల తనిఖీలు' : 'Screened This Month',
                  color: AppColors.riskLow,
                  onTap: stats.screenedThisMonthChildren.isNotEmpty
                      ? () => _showFilteredChildren(
                            context,
                            isTelugu ? 'ఈ నెల తనిఖీలు' : 'Screened This Month',
                            stats.screenedThisMonthChildren,
                            isTelugu,
                          )
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.warning,
                  value: '${stats.priorityChildren.length}',
                  label: isTelugu ? 'ప్రాధాన్యత' : 'Priority',
                  color: AppColors.riskHigh,
                  onTap: stats.priorityChildren.isNotEmpty
                      ? () => _showFilteredChildren(
                            context,
                            isTelugu ? 'ప్రాధాన్యత పిల్లలు' : 'Priority Children',
                            stats.priorityChildren,
                            isTelugu,
                          )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.pending,
                  value: '${stats.pendingScreenings}',
                  label: isTelugu ? 'పెండింగ్ తనిఖీలు' : 'Pending',
                  color: AppColors.riskMedium,
                  onTap: () {
                    // Show children not yet screened
                    final pendingChildren = allChildren
                        .where((c) => !stats.screenedChildIds.contains(c['child_id']))
                        .toList();
                    _showFilteredChildren(
                      context,
                      isTelugu ? 'పెండింగ్ తనిఖీలు' : 'Pending Screenings',
                      pendingChildren,
                      isTelugu,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Challenge: Risk Stratification
          RiskStratificationSection(isTelugu: isTelugu),

          // Challenge: Referral Board
          ReferralBoardSection(isTelugu: isTelugu),

          // Challenge: Follow-up & Outcomes
          FollowupOutcomesSection(isTelugu: isTelugu),

          // Action Pathways / Decision Support
          Builder(builder: (context) {
            final pendingChildren = allChildren
                .where((c) => !stats.screenedChildIds.contains(c['child_id']))
                .toList();
            final highRiskChildren = stats.priorityChildren
                .where((c) => c['overall_risk'] == 'HIGH')
                .toList();
            return ActionPathwaysSection(
              role: 'AWW',
              totalChildren: stats.totalChildren,
              screenedCount: stats.totalChildren - pendingChildren.length,
              highRiskCount: highRiskChildren.length,
              referralsNeeded: highRiskChildren.length,
              subUnits: const [],
              isTelugu: isTelugu,
              onScreenPending: pendingChildren.isNotEmpty
                  ? () => _showFilteredChildren(
                        context,
                        isTelugu ? 'పెండింగ్ తనిఖీలు' : 'Pending Screenings',
                        pendingChildren,
                        isTelugu,
                      )
                  : null,
              onViewHighRisk: highRiskChildren.isNotEmpty
                  ? () => _showFilteredChildren(
                        context,
                        isTelugu ? 'అధిక ప్రమాద పిల్లలు' : 'High-Risk Children',
                        highRiskChildren,
                        isTelugu,
                      )
                  : null,
            );
          }),
          const SizedBox(height: 24),

          // Quick Actions
          Text(
            isTelugu ? 'త్వరిత చర్యలు' : 'Quick Actions',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _QuickActionButton(
            icon: Icons.add_circle,
            title: isTelugu ? 'కొత్త తనిఖీ' : 'New Screening',
            titleTe: '',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScreeningStartScreen()),
            ),
          ),
          const SizedBox(height: 8),
          _QuickActionButton(
            icon: Icons.table_chart,
            title: isTelugu ? 'ECD డేటా ఎగుమతి' : 'Export ECD Data',
            titleTe: '',
            onTap: () => EcdExcelExportService.exportAndShare(
              context: context,
              children: allChildren,
              isTelugu: isTelugu,
            ),
          ),
          const SizedBox(height: 24),

          // Priority Children (HIGH + MEDIUM risk)
          Text(
            isTelugu ? 'ప్రాధాన్యత పిల్లలు' : 'Priority Children',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (stats.priorityChildren.isNotEmpty) ...[
            ...stats.priorityChildren.take(8).map((child) {
              final childId = child['child_id'] as int?;
              final localResults = ref.watch(screeningResultsStorageProvider);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ChildStatusCard(
                  childData: child,
                  result: childId != null ? localResults[childId] : null,
                  isTelugu: isTelugu,
                  onTap: () {
                    ref.read(selectedChildProvider.notifier).set(child);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChildProfileScreen(
                          child: Child.fromMap(child),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    isTelugu
                        ? 'ప్రాధాన్యత పిల్లలు లేరు'
                        : 'No priority children found',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Today's Activities (aggregated across all children)
          _AWWDailyActivitiesSection(isTelugu: isTelugu),
        ],
      ),
    );
  }
}

/// Aggregated daily activities section for AWW home tab
class _AWWDailyActivitiesSection extends ConsumerWidget {
  final bool isTelugu;
  const _AWWDailyActivitiesSection({required this.isTelugu});

  static const _domainColors = {
    'gm': Colors.blue,
    'fm': Colors.purple,
    'lc': Colors.orange,
    'cog': Colors.teal,
    'se': Colors.pink,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(awwDailyActivitiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isTelugu ? 'నేటి కార్యకలాపాలు' : "Today's Activities",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isTelugu
              ? 'పిల్లల స్క్రీనింగ్ ఫలితాల ఆధారంగా'
              : 'Based on screening results of children',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        activitiesAsync.when(
          data: (activities) {
            if (activities.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      isTelugu
                          ? 'కార్యకలాపాలు చూడటానికి స్క్రీనింగ్ పూర్తి చేయండి'
                          : 'Complete screenings to see recommended activities',
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: [
                ...activities.map((activity) {
                  final domain = activity['domain'] as String;
                  final domainColor = _domainColors[domain] ?? Colors.grey;
                  final domainLabel = isTelugu
                      ? (domainNames[domain]?['te'] ?? domain)
                      : (domainNames[domain]?['en'] ?? domain);
                  final title = isTelugu
                      ? (activity['activity_title_te'] ?? activity['activity_title'])
                      : activity['activity_title'];
                  final duration = activity['duration_minutes'] ?? 15;
                  final childCount = activity['child_count'] as int;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: InkWell(
                        onTap: () => showActivityDetailSheet(context, activity, isTelugu),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: domainColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _domainIcon(domain),
                                  color: domainColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: domainColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            domainLabel as String,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: domainColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(Icons.timer_outlined,
                                            size: 14, color: Colors.grey.shade500),
                                        const SizedBox(width: 2),
                                        Text(
                                          '$duration ${isTelugu ? 'ని.' : 'min'}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(Icons.people_outline,
                                            size: 14, color: Colors.grey.shade500),
                                        const SizedBox(width: 2),
                                        Text(
                                          '$childCount ${isTelugu ? 'పిల్లలు' : 'children'}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ActivityListScreen()),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: Text(
                    isTelugu ? 'అన్ని కార్యకలాపాలు చూడండి' : 'View All Activities',
                  ),
                ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  IconData _domainIcon(String domain) {
    switch (domain) {
      case 'gm':
        return Icons.directions_run;
      case 'fm':
        return Icons.pan_tool;
      case 'lc':
        return Icons.chat_bubble_outline;
      case 'cog':
        return Icons.psychology;
      case 'se':
        return Icons.favorite_outline;
      default:
        return Icons.star;
    }
  }
}

/// Screen to show a filtered list of children with rich status cards.
class _FilteredChildListScreen extends ConsumerStatefulWidget {
  final String title;
  final List<Map<String, dynamic>> children;
  final bool isTelugu;

  const _FilteredChildListScreen({
    required this.title,
    required this.children,
    required this.isTelugu,
  });

  @override
  ConsumerState<_FilteredChildListScreen> createState() =>
      _FilteredChildListScreenState();
}

class _FilteredChildListScreenState
    extends ConsumerState<_FilteredChildListScreen> {
  Map<int, Map<String, dynamic>> _followupData = {};

  @override
  void initState() {
    super.initState();
    _loadFollowupData();
  }

  Future<void> _loadFollowupData() async {
    try {
      final childIds = widget.children
          .map((c) => c['child_id'] as int?)
          .whereType<int>()
          .toList();
      if (childIds.isEmpty) return;

      if (!ConnectivityService.isOnline) return;

      final datasetOverride = ref.read(activeDatasetProvider);
      List<dynamic> data;
      if (datasetOverride != null) {
        data = await SupabaseService.client.rpc(
          'get_followups_for_children',
          params: {'p_child_ids': childIds},
        );
      } else {
        data = await SupabaseService.client
            .from('intervention_followups')
            .select()
            .inFilter('child_id', childIds)
            .order('created_at', ascending: false);
      }

      final map = <int, Map<String, dynamic>>{};
      for (final row in data) {
        final cid = (row as Map)['child_id'] as int;
        if (!map.containsKey(cid)) {
          map[cid] = Map<String, dynamic>.from(row);
        }
      }

      if (mounted) setState(() => _followupData = map);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isTelugu = widget.isTelugu;
    final children = widget.children;
    final localResults = ref.watch(screeningResultsStorageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: children.isEmpty
          ? Center(
              child: Text(
                isTelugu ? 'పిల్లలు కనుగొనబడలేదు' : 'No children found',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                final childId = child['child_id'] as int?;

                // Use full screening result from provider if available
                SavedScreeningResult? result;
                if (childId != null) {
                  result = localResults[childId];
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ChildStatusCard(
                    childData: child,
                    result: result,
                    followup: childId != null ? _followupData[childId] : null,
                    isTelugu: isTelugu,
                    onTap: () {
                      try {
                        final childModel = Child.fromMap(child);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ChildProfileScreen(child: childModel),
                          ),
                        );
                      } catch (_) {}
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String titleTe;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.titleTe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (titleTe.isNotEmpty)
                      Text(
                        titleTe,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// DEFAULT DASHBOARD (for users without role)
// ============================================================================

class _DefaultHomeTab extends ConsumerWidget {
  const _DefaultHomeTab();

  Future<void> _updateRole(BuildContext context, WidgetRef ref, String roleCode) async {
    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.updateUserRole(roleCode);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(languageProvider) == 'te'
                  ? 'పాత్ర విజయవంతంగా నవీకరించబడింది'
                  : 'Role updated successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WelcomeCard(
            user: user,
            isTelugu: isTelugu,
            icon: Icons.person,
          ),
          const SizedBox(height: 24),
          
          // Role selection
          Card(
            color: AppColors.riskMedium.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 48,
                    color: AppColors.riskMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isTelugu 
                        ? 'దయచేసి మీ పాత్రను ఎంచుకోండి' 
                        : 'Please select your role',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _RoleSelectionButton(
                    code: 'PARENT',
                    name: isTelugu ? 'తల్లిదండ్రులు / సంరక్షకులు' : 'Parent / Caregiver',
                    icon: Icons.family_restroom,
                    onSelect: (role) => _updateRole(context, ref, role),
                  ),
                  const SizedBox(height: 8),
                  _RoleSelectionButton(
                    code: 'AWW',
                    name: isTelugu ? 'అంగన్వాడీ కార్యకర్త' : 'Anganwadi Worker',
                    icon: Icons.school,
                    onSelect: (role) => _updateRole(context, ref, role),
                  ),
                  const SizedBox(height: 8),
                  _RoleSelectionButton(
                    code: 'SUPERVISOR',
                    name: isTelugu ? 'పర్యవేక్షకులు' : 'Supervisor',
                    icon: Icons.manage_accounts,
                    onSelect: (role) => _updateRole(context, ref, role),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ROLE SELECTION BUTTON
// ============================================================================

class _RoleSelectionButton extends StatelessWidget {
  final String code;
  final String name;
  final IconData icon;
  final Function(String) onSelect;

  const _RoleSelectionButton({
    required this.code,
    required this.name,
    required this.icon,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => onSelect(code),
        icon: Icon(icon),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            name,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          side: const BorderSide(color: AppColors.primary),
          foregroundColor: AppColors.primary,
        ),
      ),
    );
  }
}

// ============================================================================
// SHARED WIDGETS
// ============================================================================

class _WelcomeCard extends StatelessWidget {
  final user;
  final bool isTelugu;
  final IconData icon;

  const _WelcomeCard({
    required this.user,
    required this.isTelugu,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileEditScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: user?.profilePhotoUrl != null
                    ? NetworkImage(user!.profilePhotoUrl!)
                    : null,
                child: user?.profilePhotoUrl == null
                    ? Icon(
                        icon,
                        size: 30,
                        color: AppColors.primary,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTelugu ? 'స్వాగతం' : 'Welcome',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      isTelugu
                          ? toTelugu(user?.name ?? 'User')
                          : (user?.name ?? 'User'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?.roleName ?? '',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ACTIVITIES TAB - Shows personalized recommendations based on child's delays
// ============================================================================

class _ActivitiesTab extends ConsumerStatefulWidget {
  const _ActivitiesTab();

  @override
  ConsumerState<_ActivitiesTab> createState() => _ActivitiesTabState();
}

class _ActivitiesTabState extends ConsumerState<_ActivitiesTab> {
  int? _selectedChildId;
  String _selectedDomainFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';
    final childrenAsync = ref.watch(childrenProvider);

    return childrenAsync.when(
      data: (children) {
        if (children.isEmpty) {
          return _buildEmptyState(isTelugu);
        }

        // If no child selected, show child selection
        if (_selectedChildId == null) {
          return _buildChildSelectionList(children, isTelugu);
        }

        // Get selected child data
        final selectedChild = children.firstWhere(
          (c) => c['child_id'] == _selectedChildId,
          orElse: () => children.first,
        );

        return _buildChildActivitiesView(selectedChild, isTelugu);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildErrorState(isTelugu),
    );
  }

  /// Build child selection list
  Widget _buildChildSelectionList(List<Map<String, dynamic>> children, bool isTelugu) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            isTelugu ? 'కార్యకలాపాలు' : 'Activities',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isTelugu 
                ? 'బిడ్డను ఎంచుకుని వ్యక్తిగతీకరించిన కార్యకలాపాలను చూడండి'
                : 'Select a child to view personalized activities',
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Child selection cards
          Text(
            isTelugu ? 'ఒక బిడ్డను ఎంచుకోండి' : 'Select a Child',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children.map((child) => _ChildSelectionCard(
            child: child,
            isTelugu: isTelugu,
            onTap: () {
              setState(() {
                _selectedChildId = child['child_id'] as int;
              });
            },
          )),

          const SizedBox(height: 24),

          // View all activities button
          Card(
            color: AppColors.primary.withOpacity(0.1),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ActivityListScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isTelugu ? 'అన్ని కార్యకలాపాలు' : 'Browse All Activities',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isTelugu 
                                ? 'వర్గాల ప్రకారం అన్ని కార్యకలాపాలను చూడండి'
                                : 'View all activities by category',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build activities view for selected child
  Widget _buildChildActivitiesView(Map<String, dynamic> child, bool isTelugu) {
    final childId = child['child_id'] as int;
    final childAge = child['age_months'] as int;
    final childName = isTelugu
        ? toTelugu(child['name'] as String)
        : child['name'] as String;

    // Watch child's delays and recommended activities
    final delaysAsync = ref.watch(childDelaysProvider(childId));
    
    // Get activities params
    final sessionId = delaysAsync.when(
      data: (delays) => delays?['session_id'] as int?,
      loading: () => null,
      error: (_, __) => null,
    );
    final activitiesAsync = ref.watch(recommendedActivitiesProvider((childId, childAge, sessionId)));

    return activitiesAsync.when(
      data: (activities) {
        // Filter by domain if selected
        final filteredActivities = _selectedDomainFilter == 'all'
            ? activities
            : activities.where((a) => a['domain'] == _selectedDomainFilter).toList();
        
        // Group by domain
        final groupedActivities = getActivitiesByDomain(filteredActivities);
        
        // Get completion state
        final completionState = ref.watch(activityCompletionProvider);
        final completedCount = completionState.values.where((v) => v).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with change child button
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTelugu ? 'కార్యకలాపాలు' : 'Activities',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isTelugu 
                              ? '$childName కోసం సిఫార్సు చేయబడ్డాయి'
                              : 'Recommended for $childName',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedChildId = null;
                        _selectedDomainFilter = 'all';
                      });
                    },
                    icon: const Icon(Icons.swap_horiz, size: 18),
                    label: Text(isTelugu ? 'మార్చు' : 'Change'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Child delays summary card
              delaysAsync.when(
                data: (delaysData) => _ChildDelaysCard(
                  delaysData: delaysData,
                  isTelugu: isTelugu,
                ),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // Progress card
              if (activities.isNotEmpty)
                _ProgressCard(
                  totalActivities: activities.length,
                  completedActivities: completedCount,
                  isTelugu: isTelugu,
                ),
              const SizedBox(height: 20),

              // Domain filter chips
              _buildDomainFilterChips(isTelugu),
              const SizedBox(height: 16),

              // Activities by domain
              if (filteredActivities.isEmpty)
                _buildNoActivitiesState(isTelugu)
              else
                ..._buildActivitiesByDomain(groupedActivities, isTelugu),

              const SizedBox(height: 24),

              // View full details button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ActivityListScreen(
                          childId: childId,
                          child: child,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: Text(isTelugu ? 'పూర్తి వివరాలు చూడండి' : 'View Full Details'),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.riskHigh),
            const SizedBox(height: 16),
            Text(
              isTelugu ? 'లోడ్ చేయడంలో లోపం' : 'Error loading activities',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  /// Build domain filter chips
  Widget _buildDomainFilterChips(bool isTelugu) {
    final domains = [
      {'code': 'all', 'name': isTelugu ? 'అన్నీ' : 'All', 'name_te': 'అన్నీ'},
      {'code': DomainCodes.gm, 'name': 'Gross Motor', 'name_te': 'స్థూల చలనం'},
      {'code': DomainCodes.fm, 'name': 'Fine Motor', 'name_te': 'సూక్ష్మ చలనం'},
      {'code': DomainCodes.lc, 'name': 'Language', 'name_te': 'భాష'},
      {'code': DomainCodes.cog, 'name': 'Cognitive', 'name_te': 'జ్ఞానాత్మకం'},
      {'code': DomainCodes.se, 'name': 'Social', 'name_te': 'సామాజిక'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: domains.map((domain) {
          final isSelected = _selectedDomainFilter == domain['code'];
          final label = isTelugu ? domain['name_te'] : domain['name'];
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label!),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedDomainFilter = domain['code']!;
                  });
                }
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.text,
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build activities grouped by domain
  List<Widget> _buildActivitiesByDomain(
    Map<String, List<Map<String, dynamic>>> groupedActivities, 
    bool isTelugu
  ) {
    final widgets = <Widget>[];
    final domains = [DomainCodes.gm, DomainCodes.fm, DomainCodes.lc, DomainCodes.cog, DomainCodes.se];
    
    for (final domain in domains) {
      final activities = groupedActivities[domain] ?? [];
      if (activities.isEmpty) continue;
      
      final domainColor = getDomainColor(domain);
      final domainName = getDomainDisplayName(domain, isTelugu);
      
      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Domain header
            Row(
              children: [
                Icon(getDomainIcon(domain), color: domainColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  domainName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: domainColor,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: domainColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${activities.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: domainColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Activities for this domain
            ...activities.map((activity) => _RecommendedActivityCard(
              activity: activity,
              isTelugu: isTelugu,
              onToggleComplete: () {
                ref.read(activityCompletionProvider.notifier)
                    .toggle(activity['activity_code'] as String);
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      );
    }
    
    return widgets;
  }

  Widget _buildEmptyState(bool isTelugu) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.fitness_center,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            isTelugu ? 'పిల్లలు కనుగొనబడలేదు' : 'No children found',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isTelugu 
                ? 'కార్యకలాపాలను చూడటానికి ముందు పిల్లలను జోడించండి'
                : 'Add children first to see activities',
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoActivitiesState(bool isTelugu) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.fitness_center,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            isTelugu ? 'కార్యకలాపాలు కనుగొనబడలేదు' : 'No activities found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isTelugu 
                ? 'దయచేసి వేరే ఫిల్టర్ ఎంచుకోండి' 
                : 'Please try a different filter',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isTelugu) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.riskHigh,
          ),
          const SizedBox(height: 16),
          Text(
            isTelugu ? 'లోడ్ చేయడంలో లోపం' : 'Error loading data',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Child delays summary card
class _ChildDelaysCard extends StatelessWidget {
  final Map<String, dynamic>? delaysData;
  final bool isTelugu;

  const _ChildDelaysCard({
    required this.delaysData,
    required this.isTelugu,
  });

  @override
  Widget build(BuildContext context) {
    if (delaysData == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isTelugu ? 'స్క్రీనింగ్ సమాచారం' : 'Screening Information',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isTelugu 
                    ? 'ఇంకా స్క్రీనింగ్ పూర్తి కాలేదు. సిఫార్సు చేయబడిన కార్యకలాపాలు వయసుకు తగినవి.'
                    : 'No screening completed yet. Showing age-appropriate activities.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final delays = delaysData!['delays'] as Map<String, dynamic>? ?? {};
    final domainScores = delaysData!['domain_scores'] as Map<String, dynamic>? ?? {};
    final overallRisk = delaysData!['overall_risk'] as String? ?? 'LOW';
    final primaryConcern = delaysData!['primary_concern'] as String? ?? 'None';
    final numDelays = delaysData!['num_delays'] as int? ?? 0;

    final hasDelays = numDelays > 0;
    final riskColor = _getRiskColor(overallRisk);

    return Card(
      color: hasDelays ? Colors.orange.shade50 : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasDelays ? Icons.warning_amber : Icons.check_circle,
                  color: hasDelays ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasDelays 
                        ? (isTelugu ? 'అభివృద్ధి ఆలస్యం గుర్తించబడింది' : 'Development Delays Detected')
                        : (isTelugu ? 'అభివృద్ధి సాధారణం' : 'Development On Track'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: hasDelays ? Colors.orange.shade800 : Colors.green.shade800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    overallRisk,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: riskColor,
                    ),
                  ),
                ),
              ],
            ),
            if (hasDelays && primaryConcern != 'None') ...[
              const SizedBox(height: 8),
              Text(
                '${isTelugu ? 'ప్రధాన ఆందోళన' : 'Primary concern'}: $primaryConcern',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            
            // Domain scores/delays
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDomainChip('GM', domainScores['gm_dq'] ?? 100.0, delays['gm_delay'] ?? false, isTelugu),
                _buildDomainChip('FM', domainScores['fm_dq'] ?? 100.0, delays['fm_delay'] ?? false, isTelugu),
                _buildDomainChip('LC', domainScores['lc_dq'] ?? 100.0, delays['lc_delay'] ?? false, isTelugu),
                _buildDomainChip('COG', domainScores['cog_dq'] ?? 100.0, delays['cog_delay'] ?? false, isTelugu),
                _buildDomainChip('SE', domainScores['se_dq'] ?? 100.0, delays['se_delay'] ?? false, isTelugu),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDomainChip(String code, double score, bool hasDelay, bool isTelugu) {
    final color = hasDelay ? AppColors.riskHigh : AppColors.riskLow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            code,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${score.toInt()}',
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
          if (hasDelay) ...[
            const SizedBox(width: 4),
            Icon(Icons.warning, size: 12, color: color),
          ],
        ],
      ),
    );
  }

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'HIGH':
        return AppColors.riskHigh;
      case 'MEDIUM':
        return AppColors.riskMedium;
      case 'LOW':
      default:
        return AppColors.riskLow;
    }
  }
}

/// Progress tracking card
class _ProgressCard extends StatelessWidget {
  final int totalActivities;
  final int completedActivities;
  final bool isTelugu;

  const _ProgressCard({
    required this.totalActivities,
    required this.completedActivities,
    required this.isTelugu,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalActivities > 0 ? completedActivities / totalActivities : 0.0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isTelugu ? 'మీ పురోగతి' : 'Your Progress',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$completedActivities / $totalActivities',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 0.7 ? AppColors.riskLow : AppColors.primary,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}% ${isTelugu ? 'పూర్తయింది' : 'completed'}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Recommended activity card with checkbox
class _RecommendedActivityCard extends ConsumerWidget {
  final Map<String, dynamic> activity;
  final bool isTelugu;
  final VoidCallback onToggleComplete;

  const _RecommendedActivityCard({
    required this.activity,
    required this.isTelugu,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = isTelugu 
        ? activity['activity_title_te'] ?? activity['activity_title']
        : activity['activity_title'];
    final domain = activity['domain'] as String;
    final duration = activity['duration_minutes'] as int;
    final activityCode = activity['activity_code'] as String;
    final riskLevel = activity['risk_level'] as String? ?? 'LOW';
    
    final isCompleted = ref.watch(activityCompletionProvider)[activityCode] ?? false;
    final domainColor = getDomainColor(domain);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onToggleComplete,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Checkbox(
                value: isCompleted,
                onChanged: (_) => onToggleComplete(),
                activeColor: AppColors.riskLow,
              ),
              const SizedBox(width: 8),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              color: isCompleted ? Colors.grey : AppColors.text,
                            ),
                          ),
                        ),
                        if (riskLevel == 'HIGH')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.riskHigh.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isTelugu ? 'అధిక' : 'HIGH',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.riskHigh,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$duration ${isTelugu ? 'నిమి' : 'min'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          getDomainIcon(domain),
                          size: 14,
                          color: domainColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          getDomainDisplayName(domain, isTelugu),
                          style: TextStyle(
                            fontSize: 12,
                            color: domainColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Child activity card with preview
class _ChildActivityCard extends StatelessWidget {
  final Map<String, dynamic> child;
  final bool isTelugu;
  final VoidCallback onTap;

  const _ChildActivityCard({
    required this.child,
    required this.isTelugu,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = isTelugu
        ? toTelugu(child['name'] as String)
        : child['name'] as String;
    final age = child['age_months'] as int;
    final ageText = _getAgeText(age, isTelugu);

    // Sample activity previews based on age
    final activities = _getSampleActivities(age, isTelugu);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Child header
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(
                      Icons.child_care,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ageText,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
              const Divider(height: 24),

              // Activity previews
              Text(
                isTelugu ? 'సిఫార్సు చేయబడ్డాయి:' : 'Recommended:',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ...activities.map((activity) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.riskLow,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        activity,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  String _getAgeText(int months, bool isTelugu) {
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    
    if (isTelugu) {
      if (years > 0 && remainingMonths > 0) {
        return '$years సంవత్సరాలు $remainingMonths నెలలు';
      } else if (years > 0) {
        return '$years సంవత్సరాలు';
      } else {
        return '$months నెలలు';
      }
    } else {
      if (years > 0 && remainingMonths > 0) {
        return '$years years $remainingMonths months';
      } else if (years > 0) {
        return '$years years';
      } else {
        return '$months months';
      }
    }
  }

  List<String> _getSampleActivities(int ageMonths, bool isTelugu) {
    if (isTelugu) {
      if (ageMonths < 12) {
        return ['పొట్టపై ఆడుకోవడం', 'బొమ్మల పుస్తకం చూపించడం'];
      } else if (ageMonths < 24) {
        return ['బ్లాకులతో ఆట', 'నడక అభ్యాసం'];
      } else if (ageMonths < 36) {
        return ['భాషా ఆటలు', 'దుముకు వ్యాయామాలు'];
      } else {
        return ['పజిల్స్', 'పంచుకోవడం నేర్పడం'];
      }
    } else {
      if (ageMonths < 12) {
        return ['Tummy time play', 'Picture book reading'];
      } else if (ageMonths < 24) {
        return ['Block stacking', 'Walking practice'];
      } else if (ageMonths < 36) {
        return ['Language games', 'Jumping exercises'];
      } else {
        return ['Puzzles', 'Sharing activities'];
      }
    }
  }
}

/// Child selection card for choosing which child to view activities for
class _ChildSelectionCard extends StatelessWidget {
  final Map<String, dynamic> child;
  final bool isTelugu;
  final VoidCallback onTap;

  const _ChildSelectionCard({
    required this.child,
    required this.isTelugu,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = isTelugu
        ? toTelugu(child['name'] as String)
        : child['name'] as String;
    final age = child['age_months'] as int;
    final ageText = _getAgeText(age, isTelugu);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryLight,
                child: Icon(
                  Icons.child_care,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ageText,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAgeText(int months, bool isTelugu) {
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    
    if (isTelugu) {
      if (years > 0 && remainingMonths > 0) {
        return '$years సంవత్సరాలు $remainingMonths నెలలు';
      } else if (years > 0) {
        return '$years సంవత్సరాలు';
      } else {
        return '$months నెలలు';
      }
    } else {
      if (years > 0 && remainingMonths > 0) {
        return '$years years $remainingMonths months';
      } else if (years > 0) {
        return '$years years';
      } else {
        return '$months months';
      }
    }
  }
}

/// Domain category grid
class _DomainCategoryGrid extends StatelessWidget {
  final bool isTelugu;

  const _DomainCategoryGrid({required this.isTelugu});

  @override
  Widget build(BuildContext context) {
    final domains = [
      {
        'code': 'gm',
        'name': isTelugu ? 'స్థూల చలనం' : 'Gross Motor',
        'icon': Icons.directions_run,
        'color': Colors.blue,
        'desc': isTelugu ? 'నడక, పరుగు, జంప్' : 'Walking, running, jumping',
      },
      {
        'code': 'fm',
        'name': isTelugu ? 'సూక్ష్మ చలనం' : 'Fine Motor',
        'icon': Icons.back_hand,
        'color': Colors.green,
        'desc': isTelugu ? 'బ్లాకులు, గీతలు' : 'Blocks, drawing',
      },
      {
        'code': 'lc',
        'name': isTelugu ? 'భాష' : 'Language',
        'icon': Icons.record_voice_over,
        'color': Colors.orange,
        'desc': isTelugu ? 'మాట్లాడటం, చదవడం' : 'Speaking, reading',
      },
      {
        'code': 'cog',
        'name': isTelugu ? 'జ్ఞానాత్మకం' : 'Cognitive',
        'icon': Icons.psychology,
        'color': Colors.purple,
        'desc': isTelugu ? 'తెలివి, పజిల్స్' : 'Thinking, puzzles',
      },
      {
        'code': 'se',
        'name': isTelugu ? 'సామాజికం' : 'Social',
        'icon': Icons.people,
        'color': Colors.pink,
        'desc': isTelugu ? 'స్నేహితులు, భావనలు' : 'Friends, emotions',
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: domains.map((domain) => _DomainCategoryCard(
        name: domain['name'] as String,
        icon: domain['icon'] as IconData,
        color: domain['color'] as Color,
        description: domain['desc'] as String,
      )).toList(),
    );
  }
}

/// Banner shown when a non-default dataset is active.
class _DatasetBanner extends ConsumerWidget {
  const _DatasetBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataset = ref.watch(activeDatasetProvider);
    if (dataset == null) return const SizedBox.shrink();

    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';
    final label = isTelugu ? (dataset.nameTe ?? dataset.name) : dataset.name;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF00796B).withValues(alpha: 0.12),
      child: Row(
        children: [
          const Icon(Icons.storage, size: 16, color: Color(0xFF00796B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${isTelugu ? "డేటా మూలం" : "Data Source"}: $label',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00796B),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.read(activeDatasetProvider.notifier).setDataset(null);
            },
            child: const Icon(Icons.close, size: 16, color: Color(0xFF00796B)),
          ),
        ],
      ),
    );
  }
}

/// Domain category card
class _DomainCategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  const _DomainCategoryCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
