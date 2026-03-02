import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/api_config.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/schools_provider.dart';
import '../../services/api_service.dart';
import '../../services/export_service.dart';
import '../../services/offline_cache_service.dart';
import '../../services/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import 'tabs/overview_tab.dart';
import 'tabs/schools_tab.dart';
import 'tabs/map_tab.dart';
import 'tabs/validation_tab.dart';
import 'tabs/analytics_tab.dart';
import 'tabs/hm_home_tab.dart';
import 'tabs/hm_requests_tab.dart';
import 'raise_demand_screen.dart';
import '../inspection/inspection_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;
  bool _autoComputeTriggered = false;
  bool? _backendOnline;

  bool _autoForecastTriggered = false;

  @override
  void initState() {
    super.initState();
    // Auto-compute priority scores + forecasts if none exist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoComputeScoresIfNeeded();
      _autoComputeForecastsIfNeeded();
      _checkBackendStatus();
    });
  }

  Future<void> _checkBackendStatus() async {
    final online = await ApiService.healthCheck();
    if (mounted) {
      setState(() => _backendOnline = online);
    }
  }

  Future<void> _autoComputeScoresIfNeeded() async {
    if (_autoComputeTriggered) return;
    _autoComputeTriggered = true;
    try {
      final scores = await ref.read(priorityScoresProvider.future);
      if (scores.isEmpty) {
        ref.read(computePriorityScoresProvider.notifier).computeAll();
      }
    } catch (_) {
      // Silently skip if network is unavailable
    }
  }

  Future<void> _autoComputeForecastsIfNeeded() async {
    if (_autoForecastTriggered) return;
    _autoForecastTriggered = true;
    try {
      final hasData = await SupabaseService.hasForecastData();
      if (!hasData) {
        ref.read(batchForecastProvider.notifier).computeAllForecasts();
      }
    } catch (_) {
      // Silently skip if network is unavailable
    }
  }

  String _getScopeInfo(AppUser? user) {
    if (user == null || user.isStateOfficial) return '';
    final parts = <String>[];
    if (user.districtName != null) parts.add(user.districtName!);
    if (user.mandalName != null) parts.add(user.mandalName!);
    return parts.join(', ');
  }

  List<_TabDef> _getTabsForRole(AppUser? user, AppLocalizations l10n) {
    // HM gets a purpose-built 2-tab experience
    if (user != null && user.isSchoolHM) {
      return [
        _TabDef(
          widget: HMHomeTab(
            onNavigateToRequests: () => setState(() => _currentIndex = 1),
          ),
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: l10n.translate('hm_my_school'),
        ),
        _TabDef(
          widget: const HMRequestsTab(),
          icon: Icons.description_outlined,
          selectedIcon: Icons.description,
          label: l10n.translate('hm_my_requests'),
        ),
      ];
    }

    final tabs = <_TabDef>[
      _TabDef(
        widget: const OverviewTab(),
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        label: l10n.navOverview,
      ),
      _TabDef(
        widget: const SchoolsTab(),
        icon: Icons.school_outlined,
        selectedIcon: Icons.school,
        label: l10n.navSchools,
      ),
    ];

    // Map is available to all roles
    if (user == null || user.canViewMap) {
      tabs.add(_TabDef(
        widget: const MapTab(),
        icon: Icons.map_outlined,
        selectedIcon: Icons.map,
        label: l10n.navMap,
      ));
    }

    // Validation tab only for district/state officers
    if (user == null || user.canViewAllSchools) {
      tabs.add(_TabDef(
        widget: const ValidationTab(),
        icon: Icons.verified_outlined,
        selectedIcon: Icons.verified,
        label: l10n.navValidate,
      ));
    }

    // Inspection for field inspectors and block officers
    if (user != null && user.canInspect) {
      tabs.add(_TabDef(
        widget: const _InspectionListTab(),
        icon: Icons.assignment_outlined,
        selectedIcon: Icons.assignment,
        label: l10n.translate('nav_inspect'),
      ));
    }

    // Analytics only for district/state officers
    if (user == null || user.canViewAllSchools) {
      tabs.add(_TabDef(
        widget: const AnalyticsTab(), // placeholder — overridden in IndexedStack
        icon: Icons.analytics_outlined,
        selectedIcon: Icons.analytics,
        label: l10n.navAnalytics,
        isAnalytics: true,
      ));
    }

    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final l10n = AppLocalizations.of(context);
    final isTelugu = ref.watch(localeProvider).languageCode == 'te';
    final AppUser? user;
    switch (userAsync) {
      case AsyncData(:final value):
        user = value;
      default:
        user = null;
    }
    final roleName = user?.name ?? 'User';
    // Show scope info (district/mandal) for non-state roles
    final scopeInfo = _getScopeInfo(user);
    final tabs = _getTabsForRole(user, l10n);

    // Clamp index if role changed and tabs reduced
    if (_currentIndex >= tabs.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              scopeInfo.isNotEmpty ? '$roleName • $scopeInfo' : roleName,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          // ML Backend status indicator (hidden for HM)
          if (_backendOnline != null && (user == null || !user.isSchoolHM))
            Tooltip(
              message: _backendOnline!
                  ? l10n.translate('backend_online')
                  : l10n.translate('backend_offline'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _backendOnline! ? Colors.greenAccent : Colors.orange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_backendOnline! ? Colors.greenAccent : Colors.orange)
                                .withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _backendOnline! ? l10n.translate('ai_label') : l10n.translate('rules_label'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Language toggle (Item 5)
          IconButton(
            icon: Text(
              isTelugu ? 'EN' : 'తె',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            tooltip: isTelugu ? 'Switch to English' : 'తెలుగులో చూడండి',
            onPressed: () {
              ref.read(localeProvider.notifier).toggleLocale();
            },
          ),
          if (user == null || user.canExport)
            Builder(
              builder: (buttonContext) => IconButton(
                icon: const Icon(Icons.file_download),
                tooltip: l10n.translate('export_excel'),
                onPressed: () async {
                  // Get share position origin for iOS share popover
                  final box = buttonContext.findRenderObject() as RenderBox?;
                  final shareOrigin = box != null
                      ? box.localToGlobal(Offset.zero) & box.size
                      : null;

                  // Check if data has loaded
                  final schoolsAsync = ref.read(schoolsProvider);
                  final demandsAsync = ref.read(demandPlansProvider);
                  if (schoolsAsync is AsyncLoading || demandsAsync is AsyncLoading) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data is still loading, please wait...')),
                    );
                    return;
                  }
                  final schools = schoolsAsync.value ?? [];
                  final demands = demandsAsync.value ?? [];
                  if (schools.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No school data to export')),
                    );
                    return;
                  }

                  // Show loading indicator
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                            SizedBox(width: 12),
                            Text('Generating report...'),
                          ],
                        ),
                        duration: Duration(seconds: 10),
                      ),
                    );
                  }

                  try {
                    await ExportService.exportSchoolsExcel(
                      schools: schools,
                      demands: demands,
                      sharePositionOrigin: shareOrigin,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.translate('excel_exported'))),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Export failed: $e'),
                            backgroundColor: Colors.red),
                      );
                    }
                  }
                },
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(currentUserProvider.notifier).logout();
            },
            tooltip: l10n.translate('switch_role'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline sync queue banner
          if (OfflineCacheService.pendingAssessmentCount > 0)
            MaterialBanner(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              content: Text(
                '${OfflineCacheService.pendingAssessmentCount} assessment(s) pending sync',
                style: const TextStyle(fontSize: 12),
              ),
              leading: const Icon(Icons.cloud_upload, color: AppColors.statusFlagged, size: 20),
              backgroundColor: AppColors.statusFlagged.withAlpha(20),
              actions: [
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Syncing assessments...')),
                    );
                  },
                  child: const Text('Sync Now', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          Expanded(child: IndexedStack(
        index: _currentIndex,
        children: tabs.asMap().entries.map((entry) {
          // HM tabs: use widgets as-is (no overrides needed)
          if (user != null && user.isSchoolHM) {
            return entry.value.widget;
          }
          if (entry.key == 0) {
            // Override OverviewTab with navigation callbacks
            final validationIdx =
                tabs.indexWhere((t) => t.label == l10n.navValidate);
            return OverviewTab(
              onNavigateToSchools: () =>
                  setState(() => _currentIndex = 1),
              onNavigateToValidation: validationIdx >= 0
                  ? () => setState(() => _currentIndex = validationIdx)
                  : null,
              onNavigateToSchoolsWithPriority: (priority) {
                ref.read(selectedInfraTypeProvider.notifier).set(null);
                ref.read(selectedPriorityProvider.notifier).set(priority);
                setState(() => _currentIndex = 1);
              },
              onNavigateToSchoolsWithInfraType: (infraType) {
                ref.read(selectedPriorityProvider.notifier).set(null);
                ref.read(selectedInfraTypeProvider.notifier).set(infraType);
                setState(() => _currentIndex = 1);
              },
            );
          }
          // Override AnalyticsTab with navigation callbacks
          if (entry.value.isAnalytics) {
            return AnalyticsTab(
              onNavigateToSchoolsWithCategory: (category) {
                ref.read(selectedManagementProvider.notifier).set(null);
                ref.read(selectedCategoryProvider.notifier).set(category);
                setState(() => _currentIndex = 1);
              },
              onNavigateToSchoolsWithManagement: (management) {
                ref.read(selectedCategoryProvider.notifier).set(null);
                ref.read(selectedManagementProvider.notifier).set(management);
                setState(() => _currentIndex = 1);
              },
            );
          }
          return entry.value.widget;
        }).toList(),
      )),
        ],
      ),
      floatingActionButton: (user != null && user.isSchoolHM && _currentIndex == 1)
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RaiseDemandScreen(),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: Text(l10n.translate('hm_raise_request')),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.icon),
                  selectedIcon: Icon(t.selectedIcon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}

class _TabDef {
  final Widget widget;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isAnalytics;

  const _TabDef({
    required this.widget,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.isAnalytics = false,
  });
}

/// Inspection list tab — shows schools assigned to this inspector for assessments
class _InspectionListTab extends ConsumerWidget {
  const _InspectionListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolsAsync = ref.watch(schoolsProvider);

    return schoolsAsync.when(
      data: (schools) {
        if (schools.isEmpty) {
          return const Center(child: Text('No schools assigned'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: schools.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Field Inspections',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${schools.length} schools to inspect',
                        style: const TextStyle(
                            color: AppColors.textSecondary)),
                    if (OfflineCacheService.pendingAssessmentCount > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.statusFlagged.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_upload,
                                size: 16, color: AppColors.statusFlagged),
                            const SizedBox(width: 6),
                            Text(
                              '${OfflineCacheService.pendingAssessmentCount} pending sync',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.statusFlagged),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }
            final school = schools[index - 1];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      school.priorityColor.withValues(alpha: 0.2),
                  child: Icon(Icons.school,
                      color: school.priorityColor, size: 20),
                ),
                title: Text(school.schoolName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 13)),
                subtitle: Text(
                    '${school.mandalName ?? ""} • ${school.categoryLabel}',
                    style: const TextStyle(fontSize: 11)),
                trailing: FilledButton.tonalIcon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          InspectionScreen(school: school),
                    ),
                  ),
                  icon: const Icon(Icons.assignment, size: 14),
                  label: const Text('Inspect', style: TextStyle(fontSize: 11)),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
