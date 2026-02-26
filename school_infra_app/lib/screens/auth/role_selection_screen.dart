import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/api_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isTelugu = ref.watch(localeProvider).languageCode == 'te';

    final roles = [
      _Role(
        key: AppConstants.roleStateOfficial,
        title: l10n.translate('role_state_official'),
        subtitle: l10n.translate('nav_analytics'),
        icon: Icons.account_balance,
      ),
      _Role(
        key: AppConstants.roleDistrictOfficer,
        title: l10n.translate('role_district_officer'),
        subtitle: l10n.translate('nav_validate'),
        icon: Icons.location_city,
      ),
      _Role(
        key: AppConstants.roleBlockOfficer,
        title: l10n.translate('role_block_officer'),
        subtitle: l10n.translate('nav_schools'),
        icon: Icons.map,
      ),
      _Role(
        key: AppConstants.roleFieldInspector,
        title: l10n.translate('role_field_inspector'),
        subtitle: l10n.translate('infrastructure_assessment'),
        icon: Icons.assignment,
      ),
      _Role(
        key: AppConstants.roleSchoolHM,
        title: l10n.translate('role_school_hm'),
        subtitle: l10n.translate('school_profile'),
        icon: Icons.person,
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Language toggle at top
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton.icon(
                      onPressed: () {
                        ref.read(localeProvider.notifier).toggleLocale();
                      },
                      icon: const Icon(Icons.translate, color: Colors.white70, size: 18),
                      label: Text(
                        isTelugu ? 'English' : 'తెలుగు',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.school, size: 64, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.appName,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.appTagline,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Department of School Education, Andhra Pradesh',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white60),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  Text(
                    l10n.translate('select_role'),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ...roles.map((r) => _RoleCard(role: r, ref: ref)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Role {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  const _Role(
      {required this.key,
      required this.title,
      required this.subtitle,
      required this.icon});
}

class _RoleCard extends StatelessWidget {
  final _Role role;
  final WidgetRef ref;
  const _RoleCard({required this.role, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 4,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () =>
                ref.read(currentUserProvider.notifier).setDemoUser(role.key),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(role.icon, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(role.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(role.subtitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
