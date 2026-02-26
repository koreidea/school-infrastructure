import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/api_config.dart';
import '../../../models/demand_plan.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_provider.dart';

class ValidationTab extends ConsumerStatefulWidget {
  const ValidationTab({super.key});

  @override
  ConsumerState<ValidationTab> createState() => _ValidationTabState();
}

class _ValidationTabState extends ConsumerState<ValidationTab>
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
    final demandsAsync = ref.watch(demandPlansProvider);
    final validateState = ref.watch(validateDemandProvider);

    return Column(
      children: [
        // Validate All button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: validateState.when(
                  data: (msg) => msg != null
                      ? Text(msg,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.green))
                      : const SizedBox.shrink(),
                  loading: () => const Row(
                    children: [
                      SizedBox(
                          width: 14,
                          height: 14,
                          child:
                              CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text('Validating...',
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  error: (e, _) => Text('Error: $e',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.red)),
                ),
              ),
              FilledButton.icon(
                onPressed: validateState.isLoading
                    ? null
                    : () async {
                        await ref
                            .read(validateDemandProvider.notifier)
                            .validateAllPending();
                        if (context.mounted) {
                          final result =
                              ref.read(validateDemandProvider);
                          result.whenOrNull(
                            data: (msg) {
                              if (msg != null) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(msg),
                                  backgroundColor: Colors.green,
                                ));
                              }
                            },
                          );
                        }
                      },
                icon: const Icon(Icons.auto_fix_high, size: 16),
                label: const Text('Validate All Pending'),
              ),
            ],
          ),
        ),
        // Tab bar with counts
        demandsAsync.when(
          data: (demands) {
            final pendingCount =
                demands.where((d) => d.isPending).length;
            final flaggedCount =
                demands.where((d) => d.isFlagged).length;
            final approvedCount =
                demands.where((d) => d.isApproved).length;
            final rejectedCount =
                demands.where((d) => d.isRejected).length;

            return Container(
              color: AppColors.primary.withValues(alpha: 0.05),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'Pending ($pendingCount)'),
                  Tab(text: 'Flagged ($flaggedCount)'),
                  Tab(text: 'Approved ($approvedCount)'),
                  Tab(text: 'Rejected ($rejectedCount)'),
                ],
              ),
            );
          },
          loading: () => Container(
            color: AppColors.primary.withValues(alpha: 0.05),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Flagged'),
                Tab(text: 'Approved'),
                Tab(text: 'Rejected'),
              ],
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
        Expanded(
          child: demandsAsync.when(
            data: (demands) => TabBarView(
              controller: _tabController,
              children: [
                _DemandList(
                    demands.where((d) => d.isPending).toList()),
                _DemandList(
                    demands.where((d) => d.isFlagged).toList()),
                _DemandList(
                    demands.where((d) => d.isApproved).toList()),
                _DemandList(
                    demands.where((d) => d.isRejected).toList()),
              ],
            ),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }
}

class _DemandList extends StatelessWidget {
  final List<DemandPlan> demands;
  const _DemandList(this.demands);

  @override
  Widget build(BuildContext context) {
    if (demands.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No demands in this category'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: demands.length,
      itemBuilder: (ctx, i) => _DemandCard(demand: demands[i]),
    );
  }
}

class _DemandCard extends ConsumerWidget {
  final DemandPlan demand;
  const _DemandCard({required this.demand});

  bool get _isAIValidated =>
      demand.validatedBy == 'AI_VALIDATOR' || demand.validatedBy == null;
  String get _validatorDisplayName {
    if (demand.validatedBy == null) return 'Not yet reviewed';
    if (demand.validatedBy == 'AI_VALIDATOR') return 'AI Validator';
    return demand.validatedBy!;
  }

  String get _timeAgo {
    if (demand.validatedAt == null) return '';
    final diff = DateTime.now().difference(demand.validatedAt!);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = AppColors.forValidation(demand.validationStatus);
    final infraColor = AppColors.forInfraType(demand.infraType);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header with status stripe
          Container(
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: infraColor.withValues(alpha: 0.15),
                  child: Icon(AppConstants.infraTypeIcon(demand.infraType),
                      color: infraColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        demand.infraTypeLabel,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        demand.schoolName ?? 'School #${demand.schoolId}',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        demand.isPending
                            ? Icons.hourglass_empty
                            : demand.isApproved
                                ? Icons.check_circle
                                : demand.isFlagged
                                    ? Icons.flag
                                    : Icons.cancel,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppConstants.validationLabel(
                            demand.validationStatus),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Column(
              children: [
                // Details row
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _DetailChip(Icons.numbers, '${demand.physicalCount} units'),
                    _DetailChip(Icons.currency_rupee,
                        '${demand.financialAmount.toStringAsFixed(2)}L'),
                    if (demand.validationScore != null)
                      _DetailChip(Icons.speed,
                          '${demand.validationScore!.toStringAsFixed(0)}%'),
                  ],
                ),

                // Validated by info (only for non-pending)
                if (!demand.isPending) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        // AI or Officer icon
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _isAIValidated
                                ? Colors.deepPurple.withValues(alpha: 0.1)
                                : AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            _isAIValidated
                                ? Icons.smart_toy
                                : Icons.person,
                            size: 16,
                            color: _isAIValidated
                                ? Colors.deepPurple
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _isAIValidated
                                        ? 'AI Validated'
                                        : 'Officer Review',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _isAIValidated
                                          ? Colors.deepPurple
                                          : AppColors.primary,
                                    ),
                                  ),
                                  if (_timeAgo.isNotEmpty) ...[
                                    Text(' · ',
                                        style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11)),
                                    Text(_timeAgo,
                                        style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11)),
                                  ],
                                ],
                              ),
                              Text(
                                _validatorDisplayName,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Validation flags
                if (demand.validationFlags != null &&
                    demand.validationFlags!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: demand.validationFlags!
                          .map<Widget>((flag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.statusFlagged
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: AppColors.statusFlagged
                                          .withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.warning_amber,
                                        size: 12,
                                        color: AppColors.statusFlagged),
                                    const SizedBox(width: 4),
                                    Text(flag.toString(),
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.statusFlagged,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Action buttons
          Builder(builder: (context) {
            final user = ref.watch(currentUserProvider).value;
            final canValidate = user?.canValidate ?? false;
            final showActions = demand.isPending || canValidate;
            if (!showActions) {
              return const SizedBox(height: 12);
            }

            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Divider(height: 16),
                ),
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      // AI Validate (only for pending)
                      if (demand.isPending)
                        _ActionButton(
                          icon: Icons.auto_fix_high,
                          label: 'AI Validate',
                          color: Colors.deepPurple,
                          onPressed: () =>
                              _runAIValidation(context, ref, demand),
                        ),
                      // Manual officer actions
                      if (canValidate) ...[
                        if (!demand.isApproved)
                          _ActionButton(
                            icon: Icons.check_circle_outline,
                            label: 'Approve',
                            color: AppColors.statusApproved,
                            onPressed: () => _manualValidate(
                                context,
                                ref,
                                demand,
                                'APPROVED',
                                user?.name ?? 'Officer'),
                          ),
                        if (!demand.isFlagged)
                          _ActionButton(
                            icon: Icons.flag_outlined,
                            label: 'Flag',
                            color: AppColors.statusFlagged,
                            onPressed: () => _manualValidate(
                                context,
                                ref,
                                demand,
                                'FLAGGED',
                                user?.name ?? 'Officer'),
                          ),
                        if (!demand.isRejected)
                          _ActionButton(
                            icon: Icons.cancel_outlined,
                            label: 'Reject',
                            color: AppColors.statusRejected,
                            onPressed: () => _manualValidate(
                                context,
                                ref,
                                demand,
                                'REJECTED',
                                user?.name ?? 'Officer'),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _manualValidate(BuildContext context, WidgetRef ref,
      DemandPlan demand, String status, String officerName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${AppConstants.validationLabel(status)} this demand?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(demand.infraTypeLabel,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(demand.schoolName ?? 'School #${demand.schoolId}'),
            const SizedBox(height: 8),
            Text(
                '${demand.physicalCount} units | ₹${demand.financialAmount.toStringAsFixed(2)}L'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Will be recorded as: $officerName',
                        style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.forValidation(status),
            ),
            child: Text(AppConstants.validationLabel(status)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(validateDemandProvider.notifier).manualValidate(
      demand,
      status: status,
      validatedBy: officerName,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${demand.infraTypeLabel}: ${AppConstants.validationLabel(status)} by $officerName'),
          backgroundColor: AppColors.forValidation(status),
        ),
      );
    }
  }

  void _runAIValidation(
      BuildContext context, WidgetRef ref, DemandPlan demand) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text('Running AI validation...')),
          ],
        ),
      ),
    );

    ValidationResult? result;
    try {
      result = await ref
          .read(validateDemandProvider.notifier)
          .validateSingle(demand)
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      result = null;
    }

    if (!context.mounted) return;
    Navigator.pop(context);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Validation failed or timed out'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final vResult = result;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.smart_toy,
                  size: 20, color: Colors.deepPurple),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'AI Validation: ${vResult.status}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(demand.infraTypeLabel,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(demand.schoolName ?? ''),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Confidence: '),
                Expanded(
                  child: LinearProgressIndicator(
                    value: vResult.score / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: vResult.isApproved
                        ? AppColors.statusApproved
                        : vResult.isFlagged
                            ? AppColors.statusFlagged
                            : AppColors.statusRejected,
                  ),
                ),
                const SizedBox(width: 8),
                Text('${vResult.score.toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (vResult.reasons.isNotEmpty) ...[
              const Text('Findings:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              ...vResult.reasons.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          vResult.flags.contains(r)
                              ? Icons.warning_amber
                              : Icons.check_circle_outline,
                          size: 16,
                          color: vResult.flags.isNotEmpty
                              ? AppColors.statusFlagged
                              : AppColors.statusApproved,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child:
                              Text(r, style: const TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: TextButton.styleFrom(
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailChip(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
