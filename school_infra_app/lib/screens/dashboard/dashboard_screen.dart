import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/api_config.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/schools_provider.dart';
import '../../services/export_service.dart';
import '../../l10n/app_localizations.dart';
import 'tabs/overview_tab.dart';
import 'tabs/schools_tab.dart';
import 'tabs/map_tab.dart';
import 'tabs/validation_tab.dart';
import 'tabs/analytics_tab.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;
  bool _autoComputeTriggered = false;

  @override
  void initState() {
    super.initState();
    // Auto-compute priority scores if none exist (Item 1)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoComputeScoresIfNeeded();
    });
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

  String _getScopeInfo(AppUser? user) {
    if (user == null || user.isStateOfficial) return '';
    final parts = <String>[];
    if (user.districtName != null) parts.add(user.districtName!);
    if (user.mandalName != null) parts.add(user.mandalName!);
    return parts.join(', ');
  }

  List<_TabDef> _getTabsForRole(AppUser? user, AppLocalizations l10n) {
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

    // Validation tab only for officers who can validate
    if (user == null || user.canValidate) {
      tabs.add(_TabDef(
        widget: const ValidationTab(),
        icon: Icons.verified_outlined,
        selectedIcon: Icons.verified,
        label: l10n.navValidate,
      ));
    }

    // Analytics for officers and state officials
    if (user == null || user.canViewAllSchools || user.canValidate) {
      tabs.add(_TabDef(
        widget: const AnalyticsTab(),
        icon: Icons.analytics_outlined,
        selectedIcon: Icons.analytics,
        label: l10n.navAnalytics,
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
            IconButton(
              icon: const Icon(Icons.file_download),
              tooltip: l10n.translate('export_excel'),
              onPressed: () async {
                try {
                  final schools =
                      ref.read(schoolsProvider).value ?? [];
                  final demands =
                      ref.read(demandPlansProvider).value ?? [];
                  await ExportService.exportSchoolsExcel(
                    schools: schools,
                    demands: demands,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Excel exported')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Export failed: $e'),
                          backgroundColor: Colors.red),
                    );
                  }
                }
              },
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
      body: IndexedStack(
        index: _currentIndex,
        children: tabs.asMap().entries.map((entry) {
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
            );
          }
          return entry.value.widget;
        }).toList(),
      ),
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

  const _TabDef({
    required this.widget,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
