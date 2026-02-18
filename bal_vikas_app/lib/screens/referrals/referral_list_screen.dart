import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/api_config.dart';
import '../../database/app_database.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';

/// Provider for all referrals from Drift
final allReferralsProvider = FutureProvider<List<LocalReferral>>((ref) async {
  if (kIsWeb) return [];
  return DatabaseService.db.referralDao.getAllReferrals();
});

class ReferralListScreen extends ConsumerStatefulWidget {
  const ReferralListScreen({super.key});

  @override
  ConsumerState<ReferralListScreen> createState() => _ReferralListScreenState();
}

class _ReferralListScreenState extends ConsumerState<ReferralListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';
    final referralsAsync = ref.watch(allReferralsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isTelugu ? 'రిఫరల్‌లు' : 'Referrals'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: [
            Tab(text: isTelugu ? 'అన్నీ' : 'All'),
            Tab(text: isTelugu ? 'పెండింగ్' : 'Pending'),
            Tab(text: isTelugu ? 'పూర్తయింది' : 'Completed'),
            Tab(text: isTelugu ? 'చికిత్సలో' : 'Treatment'),
          ],
        ),
      ),
      body: referralsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (referrals) {
          return TabBarView(
            controller: _tabController,
            children: [
              _ReferralTab(referrals: referrals, isTelugu: isTelugu, onUpdate: _refresh),
              _ReferralTab(
                  referrals: referrals
                      .where((r) => r.referralStatus == 'Pending')
                      .toList(),
                  isTelugu: isTelugu,
                  onUpdate: _refresh),
              _ReferralTab(
                  referrals: referrals
                      .where((r) => r.referralStatus == 'Completed')
                      .toList(),
                  isTelugu: isTelugu,
                  onUpdate: _refresh),
              _ReferralTab(
                  referrals: referrals
                      .where((r) => r.referralStatus == 'Under_Treatment')
                      .toList(),
                  isTelugu: isTelugu,
                  onUpdate: _refresh),
            ],
          );
        },
      ),
    );
  }

  void _refresh() {
    ref.invalidate(allReferralsProvider);
  }
}

class _ReferralTab extends StatelessWidget {
  final List<LocalReferral> referrals;
  final bool isTelugu;
  final VoidCallback onUpdate;

  const _ReferralTab({
    required this.referrals,
    required this.isTelugu,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    if (referrals.isEmpty) {
      return Center(
        child: Text(
          isTelugu ? 'రిఫరల్‌లు లేవు' : 'No referrals',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: referrals.length,
      itemBuilder: (context, index) {
        final r = referrals[index];
        return _ReferralCard(referral: r, isTelugu: isTelugu, onUpdate: onUpdate);
      },
    );
  }
}

class _ReferralCard extends StatelessWidget {
  final LocalReferral referral;
  final bool isTelugu;
  final VoidCallback onUpdate;

  const _ReferralCard({
    required this.referral,
    required this.isTelugu,
    required this.onUpdate,
  });

  Color get _statusColor => switch (referral.referralStatus) {
        'Completed' => AppColors.riskLow,
        'Under_Treatment' => Colors.blue,
        _ => Colors.orange,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showActionSheet(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Child #${referral.childRemoteId ?? ''}',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${referral.referralType ?? ''} — ${referral.referralReason ?? ''}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade700),
                    ),
                    if (referral.referredDate != null)
                      Text(
                        referral.referredDate!,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  referral.referralStatus.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 11,
                    color: _statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    if (referral.referralStatus == 'Completed') return;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading:
                  const Icon(Icons.check_circle, color: AppColors.riskLow),
              title: Text(isTelugu ? 'పూర్తయినట్లు మార్క్' : 'Mark Completed'),
              onTap: () async {
                Navigator.pop(ctx);
                if (!kIsWeb) {
                  await DatabaseService.db.referralDao
                      .updateReferralStatus(referral.id, 'Completed');
                }
                onUpdate();
              },
            ),
            ListTile(
              leading: const Icon(Icons.medical_services, color: Colors.blue),
              title: Text(isTelugu ? 'చికిత్సలో' : 'Under Treatment'),
              onTap: () async {
                Navigator.pop(ctx);
                if (!kIsWeb) {
                  await DatabaseService.db.referralDao
                      .updateReferralStatus(referral.id, 'Under_Treatment');
                }
                onUpdate();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
