import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/api_config.dart';
import '../../../models/demand_plan.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../services/offline_cache_service.dart';
import '../../../l10n/app_localizations.dart';

class HMRequestsTab extends ConsumerStatefulWidget {
  const HMRequestsTab({super.key});

  @override
  ConsumerState<HMRequestsTab> createState() => _HMRequestsTabState();
}

class _HMRequestsTabState extends ConsumerState<HMRequestsTab> {
  String _filter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final demandsAsync = ref.watch(demandPlansProvider);
    final l10n = AppLocalizations.of(context);
    final pendingSync = OfflineCacheService.pendingDemandCount;

    return Column(
      children: [
        // Offline sync banner
        if (pendingSync > 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.statusFlagged.withAlpha(20),
            child: Row(
              children: [
                const Icon(Icons.cloud_upload, size: 16, color: AppColors.statusFlagged),
                const SizedBox(width: 8),
                Text(
                  '$pendingSync ${l10n.translate('hm_pending_sync')}',
                  style: const TextStyle(fontSize: 12, color: AppColors.statusFlagged),
                ),
              ],
            ),
          ),

        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _FilterChip(label: 'All', value: 'ALL', selected: _filter, onSelected: (v) => setState(() => _filter = v)),
              const SizedBox(width: 6),
              _FilterChip(label: 'Pending', value: 'PENDING', selected: _filter, onSelected: (v) => setState(() => _filter = v)),
              const SizedBox(width: 6),
              _FilterChip(label: 'AI Reviewed', value: 'AI_REVIEWED', selected: _filter, onSelected: (v) => setState(() => _filter = v)),
              const SizedBox(width: 6),
              _FilterChip(label: 'Approved', value: 'FINAL_APPROVED', selected: _filter, onSelected: (v) => setState(() => _filter = v)),
              const SizedBox(width: 6),
              _FilterChip(label: 'Flagged', value: 'FLAGGED', selected: _filter, onSelected: (v) => setState(() => _filter = v)),
              const SizedBox(width: 6),
              _FilterChip(label: 'Rejected', value: 'REJECTED', selected: _filter, onSelected: (v) => setState(() => _filter = v)),
            ],
          ),
        ),

        // List
        Expanded(
          child: demandsAsync.when(
            data: (demands) {
              final filtered = _filter == 'ALL'
                  ? demands
                  : demands.where((d) => d.pipelineStage == _filter).toList();

              if (filtered.isEmpty) {
                return _EmptyState(l10n: l10n, hasAnyDemands: demands.isNotEmpty);
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(demandPlansProvider);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _HMDemandCard(
                    demand: filtered[i],
                    onCancel: () => _cancelDemand(filtered[i]),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  Future<void> _cancelDemand(DemandPlan demand) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.translate('hm_cancel_request')),
        content: Text(l10n.translate('hm_cancel_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.translate('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.statusRejected),
            child: Text(l10n.translate('hm_cancel_request')),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(createDemandProvider.notifier).cancelDemandPlan(demand.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Request cancelled' : 'Failed to cancel'),
            backgroundColor: success ? AppColors.statusApproved : AppColors.statusRejected,
          ),
        );
      }
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onSelected;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    final color = _chipColor(value);

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? Colors.white : color,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      backgroundColor: color.withAlpha(15),
      selectedColor: color,
      checkmarkColor: Colors.white,
      side: BorderSide(color: color.withAlpha(80)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }

  Color _chipColor(String stage) {
    switch (stage) {
      case 'PENDING':
        return AppColors.statusPending;
      case 'AI_REVIEWED':
        return AppColors.statusAIReviewed;
      case 'FINAL_APPROVED':
        return AppColors.statusApproved;
      case 'FLAGGED':
        return AppColors.statusFlagged;
      case 'REJECTED':
        return AppColors.statusRejected;
      default:
        return AppColors.primary;
    }
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  final bool hasAnyDemands;

  const _EmptyState({required this.l10n, required this.hasAnyDemands});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasAnyDemands ? Icons.filter_list_off : Icons.description_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              hasAnyDemands ? 'No requests match this filter' : l10n.translate('hm_no_requests'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            if (!hasAnyDemands)
              Text(
                l10n.translate('hm_no_requests_hint'),
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
          ],
        ),
      ),
    );
  }
}

class _HMDemandCard extends StatelessWidget {
  final DemandPlan demand;
  final VoidCallback onCancel;

  const _HMDemandCard({required this.demand, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final stageColor = AppColors.forPipelineStage(demand.pipelineStage);
    final stageLabel = AppConstants.pipelineStageLabel(demand.pipelineStage);
    final infraIcon = AppConstants.infraTypeIcon(demand.infraType);
    final infraColor = AppColors.forInfraType(demand.infraType);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: infra type + stage badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: infraColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(infraIcon, size: 20, color: infraColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        demand.infraTypeLabel,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Plan Year: ${demand.planYear}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: stageColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: stageColor.withAlpha(80)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AppConstants.pipelineStageIcon(demand.pipelineStage),
                          size: 12, color: stageColor),
                      const SizedBox(width: 4),
                      Text(
                        stageLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: stageColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Detail chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _DetailChip(
                  icon: Icons.inventory_2,
                  label: '${demand.physicalCount} units',
                ),
                _DetailChip(
                  icon: Icons.currency_rupee,
                  label: '₹${demand.financialAmount.toStringAsFixed(2)}L',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Pipeline indicator
            _PipelineIndicator(demand: demand),

            // AI feedback if reviewed
            if (demand.isAIReviewed && demand.validationScore != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withAlpha(10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.smart_toy, size: 14, color: Colors.deepPurple),
                    const SizedBox(width: 6),
                    Text(
                      'AI Score: ${demand.validationScore!.toStringAsFixed(0)}% — ${demand.validationStatus}',
                      style: const TextStyle(fontSize: 11, color: Colors.deepPurple),
                    ),
                  ],
                ),
              ),
            ],

            // Officer feedback
            if (!demand.isOfficerPending) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: stageColor.withAlpha(10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 14, color: stageColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Officer: ${demand.officerStatus}${demand.officerName != null ? ' by ${demand.officerName}' : ''}',
                        style: TextStyle(fontSize: 11, color: stageColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Officer notes
            if (demand.officerNotes != null && demand.officerNotes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Notes: ${demand.officerNotes}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
              ),
            ],

            // Cancel button (only for fully PENDING demands)
            if (demand.isAIPending && demand.isOfficerPending) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close, size: 14),
                  label: const Text('Cancel Request', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.statusRejected,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class _PipelineIndicator extends StatelessWidget {
  final DemandPlan demand;
  const _PipelineIndicator({required this.demand});

  @override
  Widget build(BuildContext context) {
    final aiDone = demand.isAIReviewed;
    final assessDone = demand.hasAssessment;
    final officerDone = !demand.isOfficerPending;

    return Row(
      children: [
        _StageCircle(label: 'AI', done: aiDone, active: !aiDone),
        _StageConnector(done: aiDone),
        _StageCircle(label: 'Field', done: assessDone, active: aiDone && !assessDone),
        _StageConnector(done: assessDone),
        _StageCircle(label: 'Officer', done: officerDone, active: aiDone && assessDone && !officerDone),
      ],
    );
  }
}

class _StageCircle extends StatelessWidget {
  final String label;
  final bool done;
  final bool active;
  const _StageCircle({required this.label, required this.done, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = done
        ? AppColors.statusApproved
        : active
            ? AppColors.primary
            : Colors.grey[300]!;
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: done ? color : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: done
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _StageConnector extends StatelessWidget {
  final bool done;
  const _StageConnector({required this.done});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14),
        color: done ? AppColors.statusApproved : Colors.grey[300],
      ),
    );
  }
}
