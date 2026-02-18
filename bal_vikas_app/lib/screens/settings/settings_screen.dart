import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../config/api_config.dart';
import '../../providers/children_provider.dart';
import '../../providers/screening_config_provider.dart';
import '../../providers/intervention_provider.dart';
import '../../providers/admin_global_config_provider.dart';
import '../../providers/dataset_provider.dart';
import '../dashboard/widgets/challenge_dashboard_widgets.dart';
import '../../services/connectivity_service.dart';
import '../../services/sync_service.dart';
import '../../utils/telugu_transliterator.dart';
import 'scalability_screen.dart';
import 'api_interop_screen.dart';
import '../privacy/privacy_policy_screen.dart';
import '../governance/data_governance_dashboard.dart';

/// Provider for the offline mode toggle (true = offline, false = online)
class OfflineModeNotifier extends Notifier<bool> {
  @override
  bool build() => ConnectivityService.forceOffline;

  void toggle(bool value) {
    ConnectivityService.forceOffline = value;
    state = value;
  }
}

final offlineModeProvider = NotifierProvider<OfflineModeNotifier, bool>(
  () => OfflineModeNotifier(),
);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // User Profile Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
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
                  user?.mobileNumber ?? '',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Chip(
                  label: Text(user?.roleName ?? ''),
                  backgroundColor: AppColors.primaryLight,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Language Settings
        Text(
          isTelugu ? 'భాష సెట్టింగులు' : 'Language Settings',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text('English'),
                value: 'en',
                groupValue: language,
                onChanged: (value) {
                  ref.read(languageProvider.notifier).setLanguage(value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('తెలుగు (Telugu)'),
                value: 'te',
                groupValue: language,
                onChanged: (value) {
                  ref.read(languageProvider.notifier).setLanguage(value!);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // App Settings
        Text(
          isTelugu ? 'అనువర్తన సెట్టింగులు' : 'App Settings',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.sync),
                title: Text(isTelugu ? 'డేటా సమకాలీకరించు' : 'Sync Data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _performFullSync(context, ref, isTelugu),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  ref.watch(offlineModeProvider) ? Icons.cloud_off : Icons.cloud_done,
                  color: ref.watch(offlineModeProvider) ? Colors.grey : Colors.green,
                ),
                title: Text(isTelugu ? 'ఆఫ్‌లైన్ మోడ్' : 'Offline Mode'),
                subtitle: Text(
                  ref.watch(offlineModeProvider)
                      ? (isTelugu ? 'డేటా స్థానికంగా మాత్రమే' : 'Data stored locally only')
                      : (isTelugu ? 'డేటాబేస్‌తో సమకాలీకరిస్తోంది' : 'Syncing with database'),
                  style: TextStyle(
                    color: ref.watch(offlineModeProvider) ? Colors.orange : Colors.green,
                    fontSize: 12,
                  ),
                ),
                trailing: Switch(
                  value: ref.watch(offlineModeProvider),
                  onChanged: (value) {
                    ref.read(offlineModeProvider.notifier).toggle(value);
                    if (!value) {
                      // Switched to online — trigger full sync
                      _performFullSync(context, ref, isTelugu);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isTelugu ? 'ఆఫ్‌లైన్ మోడ్ ఆన్' : 'Offline mode enabled'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Data Source
        _DataSourceSection(isTelugu: isTelugu),
        const SizedBox(height: 24),

        // About
        Text(
          isTelugu ? 'గురించి' : 'About',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.info),
                title: Text(isTelugu ? 'అనువర్తన సమాచారం' : 'App Information'),
                subtitle: const Text('Version 1.0.0'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.rocket_launch),
                title: Text(isTelugu ? 'స్కేలబిలిటీ ఆర్కిటెక్చర్' : 'Scalability Architecture'),
                subtitle: Text(isTelugu ? 'పైలట్ → జాతీయ స్థాయి' : 'Pilot → National Scale'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const ScalabilityScreen())),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.api),
                title: Text(isTelugu ? 'API & ఇంటరాపరబిలిటీ' : 'API & Interoperability'),
                subtitle: Text(isTelugu ? 'డేటా ప్రమాణాలు & ఇంటిగ్రేషన్' : 'Data standards & integration'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const ApiInteropScreen())),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.privacy_tip, color: Colors.blue.shade700),
                title: Text(isTelugu ? 'గోప్యతా విధానం' : 'Privacy Policy'),
                subtitle: const Text('DPDP Act 2023'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const PrivacyPolicyScreen())),
              ),
              if (user != null && (user.isCDPO || user.isDW || user.isSeniorOfficial || user.isSupervisor)) ...[
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.admin_panel_settings, color: const Color(0xFF00796B)),
                  title: Text(isTelugu ? 'డేటా గవర్నెన్స్' : 'Data Governance'),
                  subtitle: Text(isTelugu ? 'అనుమతి రేట్లు & ఆడిట్ లాగ్' : 'Consent rates & audit log'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const DataGovernanceDashboard())),
                ),
              ],
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.help),
                title: Text(isTelugu ? 'సహాయం & మద్దతు' : 'Help & Support'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Logout
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.riskHigh,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.logout),
            label: Text(isTelugu ? 'లాగ్ అవుట్' : 'Logout'),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  static Future<void> _performFullSync(
      BuildContext context, WidgetRef ref, bool isTelugu) async {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(isTelugu ? 'సమకాలీకరిస్తోంది...' : 'Syncing all data...'),
          ],
        ),
        duration: const Duration(seconds: 30),
      ),
    );

    try {
      // 1. Pull configs (tool configs, questions, activities) from Supabase → Drift
      Map<String, int> configResult = {};
      if (!kIsWeb) {
        configResult = await SyncService.pullAllConfigs();
      }

      // 2. Refresh children data
      ref.read(childrenProvider.notifier).refresh();

      // 3. Push pending local changes to Supabase
      if (!kIsWeb) {
        await SyncService.processQueue();
      }

      // 4. Invalidate providers so UI picks up new data
      ref.invalidate(screeningToolConfigsProvider);
      ref.invalidate(dbActivitiesProvider);
      ref.invalidate(globalConfigProvider);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      final tools = configResult['tools'] ?? 0;
      final activities = configResult['activities'] ?? 0;
      final detail = kIsWeb
          ? (isTelugu ? 'డేటా సమకాలీకరించబడింది' : 'Data synced successfully')
          : (isTelugu
              ? 'సమకాలీకరించబడింది: $tools టూల్స్, $activities కార్యకలాపాలు'
              : 'Synced: $tools tools, $activities activities');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(detail)),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isTelugu ? 'సమకాలీకరణ విఫలమైంది' : 'Sync failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Data Source selector — switch between available datasets.
class _DataSourceSection extends ConsumerWidget {
  final bool isTelugu;
  const _DataSourceSection({required this.isTelugu});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datasetsAsync = ref.watch(availableDatasetsProvider);
    final activeDataset = ref.watch(activeDatasetProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isTelugu ? 'డేటా మూలం' : 'Data Source',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: datasetsAsync.when(
            loading: () => const ListTile(
              leading: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              title: Text('Loading datasets...'),
            ),
            error: (_, __) => ListTile(
              leading: const Icon(Icons.error_outline, color: Colors.red),
              title: Text(isTelugu ? 'డేటాసెట్‌లు లోడ్ కాలేదు' : 'Could not load datasets'),
            ),
            data: (datasets) {
              if (datasets.isEmpty) {
                return ListTile(
                  leading: const Icon(Icons.storage),
                  title: Text(isTelugu ? 'యాప్ డేటా (డిఫాల్ట్)' : 'App Data (Default)'),
                  subtitle: Text(
                    isTelugu
                        ? 'డేటాసెట్ టేబుల్ ఇంకా సృష్టించబడలేదు'
                        : 'Run the import script to add datasets',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                );
              }

              // Current selection: active override or default
              final currentName = activeDataset != null
                  ? (isTelugu ? (activeDataset.nameTe ?? activeDataset.name) : activeDataset.name)
                  : (isTelugu ? 'యాప్ డేటా (డిఫాల్ట్)' : 'App Data (Default)');

              return ListTile(
                leading: Icon(
                  Icons.storage,
                  color: activeDataset != null
                      ? const Color(0xFF00796B)
                      : Colors.grey,
                ),
                title: Text(isTelugu ? 'ప్రస్తుత డేటా' : 'Current Data'),
                subtitle: Text(
                  currentName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: activeDataset != null
                        ? const Color(0xFF00796B)
                        : null,
                  ),
                ),
                trailing: PopupMenuButton<DatasetConfig?>(
                  icon: const Icon(Icons.arrow_drop_down),
                  onSelected: (dataset) {
                    ref.read(activeDatasetProvider.notifier).setDataset(dataset);
                    // Invalidate providers so they reload with new dataset scope
                    ref.invalidate(availableDatasetsProvider);
                    ref.invalidate(childrenProvider);
                    // Invalidate challenge dashboard providers
                    ref.invalidate(riskStratificationProvider);
                    ref.invalidate(referralStatsProvider);
                    ref.invalidate(followupStatsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          dataset == null || dataset.isDefault
                              ? (isTelugu ? 'యాప్ డేటాకు మారారు' : 'Switched to App Data')
                              : (isTelugu
                                  ? '${dataset.nameTe ?? dataset.name}కు మారారు'
                                  : 'Switched to ${dataset.name}'),
                        ),
                        backgroundColor: const Color(0xFF00796B),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  itemBuilder: (context) {
                    final items = <PopupMenuEntry<DatasetConfig?>>[];
                    for (final ds in datasets) {
                      final label = isTelugu ? (ds.nameTe ?? ds.name) : ds.name;
                      final isSelected = ds.isDefault
                          ? activeDataset == null
                          : activeDataset?.id == ds.id;
                      items.add(PopupMenuItem<DatasetConfig?>(
                        value: ds,
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              size: 20,
                              color: isSelected ? const Color(0xFF00796B) : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(label)),
                          ],
                        ),
                      ));
                    }
                    return items;
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
