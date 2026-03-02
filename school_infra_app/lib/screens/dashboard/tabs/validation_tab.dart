import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/api_config.dart';
import '../../../models/demand_plan.dart';
import '../../../models/infra_assessment.dart';
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
    _tabController = TabController(length: 6, vsync: this);
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
        // Tab bar with pipeline-stage counts
        demandsAsync.when(
          data: (demands) {
            final pendingCount =
                demands.where((d) => d.pipelineStage == 'PENDING').length;
            final aiReviewedCount =
                demands.where((d) => d.pipelineStage == 'AI_REVIEWED').length;
            final inspectedCount =
                demands.where((d) => d.hasAssessment).length;
            final approvedCount =
                demands.where((d) => d.pipelineStage == 'FINAL_APPROVED').length;
            final flaggedCount =
                demands.where((d) => d.pipelineStage == 'FLAGGED').length;
            final rejectedCount =
                demands.where((d) => d.pipelineStage == 'REJECTED').length;

            return Container(
              color: AppColors.primary.withValues(alpha: 0.05),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                indicatorColor: AppColors.primary,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 11),
                tabs: [
                  Tab(text: 'Pending ($pendingCount)'),
                  Tab(text: 'AI Reviewed ($aiReviewedCount)'),
                  Tab(text: 'Inspected ($inspectedCount)'),
                  Tab(text: 'Approved ($approvedCount)'),
                  Tab(text: 'Flagged ($flaggedCount)'),
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
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.symmetric(horizontal: 10),
              labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'AI Reviewed'),
                Tab(text: 'Inspected'),
                Tab(text: 'Approved'),
                Tab(text: 'Flagged'),
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
                    demands.where((d) => d.pipelineStage == 'PENDING').toList()),
                _AIReviewedList(
                    demands.where((d) => d.pipelineStage == 'AI_REVIEWED').toList()),
                _InspectedList(
                    demands.where((d) => d.hasAssessment).toList()),
                _DemandList(
                    demands.where((d) => d.pipelineStage == 'FINAL_APPROVED').toList()),
                _DemandList(
                    demands.where((d) => d.pipelineStage == 'FLAGGED').toList()),
                _DemandList(
                    demands.where((d) => d.pipelineStage == 'REJECTED').toList()),
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

class _AIReviewedList extends StatefulWidget {
  final List<DemandPlan> demands;
  const _AIReviewedList(this.demands);

  @override
  State<_AIReviewedList> createState() => _AIReviewedListState();
}

class _AIReviewedListState extends State<_AIReviewedList> {
  String _aiFilter = 'ALL'; // ALL, APPROVED, FLAGGED, REJECTED

  @override
  Widget build(BuildContext context) {
    final filtered = _aiFilter == 'ALL'
        ? widget.demands
        : widget.demands
            .where((d) => d.validationStatus == _aiFilter)
            .toList();

    // Counts for each AI status within AI_REVIEWED pipeline stage
    final approvedCount =
        widget.demands.where((d) => d.validationStatus == 'APPROVED').length;
    final flaggedCount =
        widget.demands.where((d) => d.validationStatus == 'FLAGGED').length;
    final rejectedCount =
        widget.demands.where((d) => d.validationStatus == 'REJECTED').length;

    return Column(
      children: [
        // AI status filter chips
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _AIFilterChip(
                  label: 'All (${widget.demands.length})',
                  selected: _aiFilter == 'ALL',
                  color: Colors.deepPurple,
                  onTap: () => setState(() => _aiFilter = 'ALL'),
                ),
                const SizedBox(width: 6),
                _AIFilterChip(
                  label: 'AI Approved ($approvedCount)',
                  selected: _aiFilter == 'APPROVED',
                  color: AppColors.statusApproved,
                  onTap: () => setState(() => _aiFilter = 'APPROVED'),
                ),
                const SizedBox(width: 6),
                _AIFilterChip(
                  label: 'AI Flagged ($flaggedCount)',
                  selected: _aiFilter == 'FLAGGED',
                  color: AppColors.statusFlagged,
                  onTap: () => setState(() => _aiFilter = 'FLAGGED'),
                ),
                const SizedBox(width: 6),
                _AIFilterChip(
                  label: 'AI Rejected ($rejectedCount)',
                  selected: _aiFilter == 'REJECTED',
                  color: AppColors.statusRejected,
                  onTap: () => setState(() => _aiFilter = 'REJECTED'),
                ),
              ],
            ),
          ),
        ),
        // Filtered demand list
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.filter_list_off,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        'No $_aiFilter demands in AI Reviewed',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) =>
                      _DemandCard(demand: filtered[i]),
                ),
        ),
      ],
    );
  }
}

class _AIFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _AIFilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? color : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DemandCard extends ConsumerWidget {
  final DemandPlan demand;
  final InfraAssessment? assessment;
  const _DemandCard({required this.demand, this.assessment});

  String _aiTimeAgo() {
    if (demand.validatedAt == null) return '';
    final diff = DateTime.now().difference(demand.validatedAt!);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  String _officerTimeAgo() {
    if (demand.officerReviewedAt == null) return '';
    final diff = DateTime.now().difference(demand.officerReviewedAt!);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stageColor = AppColors.forPipelineStage(demand.pipelineStage);
    final infraColor = AppColors.forInfraType(demand.infraType);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: stageColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header with status stripe
          Container(
            decoration: BoxDecoration(
              color: stageColor.withValues(alpha: 0.08),
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
                // Pipeline stage badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: stageColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: stageColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppConstants.pipelineStageIcon(demand.pipelineStage),
                        size: 14,
                        color: stageColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppConstants.pipelineStageLabel(demand.pipelineStage),
                        style: TextStyle(
                          color: stageColor,
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
                          'AI: ${demand.validationScore!.toStringAsFixed(0)}%'),
                  ],
                ),

                // Pipeline Status Indicator
                const SizedBox(height: 10),
                _PipelineStatusIndicator(demand: demand),

                // AI Validation info (for AI-reviewed demands)
                if (demand.isAIReviewed) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.smart_toy,
                              size: 16, color: Colors.deepPurple),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'AI: ${AppConstants.validationLabel(demand.validationStatus)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  if (_aiTimeAgo().isNotEmpty) ...[
                                    Text(' · ',
                                        style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11)),
                                    Text(_aiTimeAgo(),
                                        style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11)),
                                  ],
                                ],
                              ),
                              Text(
                                'Score: ${demand.validationScore?.toStringAsFixed(0) ?? "?"}%',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Officer review info (for officer-decided demands)
                if (!demand.isOfficerPending) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.person,
                              size: 16, color: AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Officer: ${AppConstants.validationLabel(demand.officerStatus)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  if (_officerTimeAgo().isNotEmpty) ...[
                                    Text(' · ',
                                        style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11)),
                                    Text(_officerTimeAgo(),
                                        style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11)),
                                  ],
                                ],
                              ),
                              Text(
                                demand.officerName ?? 'Unknown officer',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary),
                              ),
                              if (demand.officerNotes != null &&
                                  demand.officerNotes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Notes: ${demand.officerNotes}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Validation Rule Breakdown (XAI - Explainable AI)
                if (demand.isAIReviewed && demand.validationScore != null) ...[
                  const SizedBox(height: 8),
                  _ValidationRuleBreakdown(demand: demand),
                ],

                // Assessment Details (for inspected demands)
                if (assessment != null) ...[
                  const SizedBox(height: 8),
                  _AssessmentDetailsExpandable(assessment: assessment!),
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
            final showAI = demand.isAIPending;
            final showOfficer = canValidate && demand.isAIReviewed;
            if (!showAI && !showOfficer) {
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
                      // AI Validate (only for pending — Stage 1)
                      if (showAI)
                        _ActionButton(
                          icon: Icons.auto_fix_high,
                          label: 'AI Validate',
                          color: Colors.deepPurple,
                          onPressed: () =>
                              _runAIValidation(context, ref, demand),
                        ),
                      // Officer actions (Stage 3)
                      if (showOfficer) ...[
                        // HARD GATE: Approve disabled if no assessment
                        if (!demand.isOfficerApproved)
                          _ActionButton(
                            icon: Icons.check_circle_outline,
                            label: demand.canOfficerApprove
                                ? 'Approve'
                                : 'Approve (needs assessment)',
                            color: demand.canOfficerApprove
                                ? AppColors.statusApproved
                                : Colors.grey,
                            onPressed: demand.canOfficerApprove
                                ? () => _officerDecision(
                                    context,
                                    ref,
                                    demand,
                                    'APPROVED',
                                    user?.name ?? 'Officer')
                                : () => _showAssessmentRequired(context),
                          ),
                        if (!demand.isOfficerFlagged)
                          _ActionButton(
                            icon: Icons.flag_outlined,
                            label: 'Flag',
                            color: AppColors.statusFlagged,
                            onPressed: () => _officerDecision(
                                context,
                                ref,
                                demand,
                                'FLAGGED',
                                user?.name ?? 'Officer'),
                          ),
                        if (!demand.isOfficerRejected)
                          _ActionButton(
                            icon: Icons.cancel_outlined,
                            label: 'Reject',
                            color: AppColors.statusRejected,
                            onPressed: () => _officerDecision(
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

  void _showAssessmentRequired(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Field assessment required before approval. '
                'A field inspector must visit this school first.',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _officerDecision(BuildContext context, WidgetRef ref,
      DemandPlan demand, String status, String officerName) async {
    final notesController = TextEditingController();
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
                '${demand.physicalCount} units | \u20B9${demand.financialAmount.toStringAsFixed(2)}L'),
            const SizedBox(height: 12),
            // Notes input
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                hintText: 'Reason for decision...',
                isDense: true,
              ),
              maxLines: 3,
            ),
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

    final success = await ref.read(validateDemandProvider.notifier).officerDecision(
      demand,
      status: status,
      officerName: officerName,
      notes: notesController.text.isEmpty ? null : notesController.text,
    );

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${demand.infraTypeLabel}: ${AppConstants.validationLabel(status)} by $officerName'),
            backgroundColor: AppColors.forValidation(status),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot approve: field assessment required'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            const Text('Note: An officer must still review and approve this demand.',
                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
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

// =============================================================================
// Pipeline Status Indicator — 3-stage horizontal row
// =============================================================================

enum _StageStatus { pending, passed, warning, failed }

class _PipelineStatusIndicator extends StatelessWidget {
  final DemandPlan demand;
  const _PipelineStatusIndicator({required this.demand});

  @override
  Widget build(BuildContext context) {
    // Stage 1: AI Review
    final aiStatus = demand.isAIReviewed
        ? (demand.isAIApproved ? _StageStatus.passed : _StageStatus.warning)
        : _StageStatus.pending;
    final aiDetail = demand.isAIReviewed
        ? '${demand.validationScore?.toStringAsFixed(0) ?? "?"}%'
        : null;

    // Stage 2: Assessment
    final assessStatus =
        demand.hasAssessment ? _StageStatus.passed : _StageStatus.pending;
    String? assessDetail;
    if (demand.hasAssessment && demand.assessmentDate != null) {
      final diff = DateTime.now().difference(demand.assessmentDate!);
      if (diff.inDays > 0) {
        assessDetail = '${diff.inDays}d ago';
      } else {
        assessDetail = 'today';
      }
    }

    // Stage 3: Officer
    _StageStatus officerStatus;
    if (demand.isOfficerApproved) {
      officerStatus = _StageStatus.passed;
    } else if (demand.isOfficerFlagged) {
      officerStatus = _StageStatus.warning;
    } else if (demand.isOfficerRejected) {
      officerStatus = _StageStatus.failed;
    } else {
      officerStatus = _StageStatus.pending;
    }
    final officerDetail =
        demand.isOfficerPending ? null : demand.officerName;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _StageChip(
            icon: Icons.smart_toy,
            label: 'AI',
            detail: aiDetail,
            status: aiStatus,
          ),
          _StageConnector(passed: aiStatus != _StageStatus.pending),
          _StageChip(
            icon: Icons.assignment,
            label: 'Assessment',
            detail: assessDetail,
            status: assessStatus,
          ),
          _StageConnector(passed: assessStatus != _StageStatus.pending),
          _StageChip(
            icon: Icons.person,
            label: 'Officer',
            detail: officerDetail,
            status: officerStatus,
          ),
        ],
      ),
    );
  }
}

class _StageChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? detail;
  final _StageStatus status;
  const _StageChip({
    required this.icon,
    required this.label,
    this.detail,
    required this.status,
  });

  Color get _color {
    switch (status) {
      case _StageStatus.passed:
        return AppColors.statusApproved;
      case _StageStatus.warning:
        return AppColors.statusFlagged;
      case _StageStatus.failed:
        return AppColors.statusRejected;
      case _StageStatus.pending:
        return Colors.grey;
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case _StageStatus.passed:
        return Icons.check_circle;
      case _StageStatus.warning:
        return Icons.warning_amber;
      case _StageStatus.failed:
        return Icons.cancel;
      case _StageStatus.pending:
        return Icons.radio_button_unchecked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon, size: 16, color: _color),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: _color)),
          if (detail != null)
            Text(detail!,
                style: TextStyle(fontSize: 8, color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _StageConnector extends StatelessWidget {
  final bool passed;
  const _StageConnector({this.passed = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      child: Divider(
        thickness: 1.5,
        color: passed ? AppColors.statusApproved : Colors.grey.shade300,
      ),
    );
  }
}

// =============================================================================
// Shared Widgets
// =============================================================================

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

/// XAI: Explainable AI - Per-rule validation breakdown (collapsible)
class _ValidationRuleBreakdown extends StatefulWidget {
  final DemandPlan demand;
  const _ValidationRuleBreakdown({required this.demand});

  @override
  State<_ValidationRuleBreakdown> createState() =>
      _ValidationRuleBreakdownState();
}

class _ValidationRuleBreakdownState extends State<_ValidationRuleBreakdown> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final demand = widget.demand;
    final rules = _generateRuleDisplay();
    final passedCount = rules.where((r) => r['passed'] == true).length;
    final totalCount = rules.length;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row — always visible
            Row(
              children: [
                const Icon(Icons.psychology, size: 14, color: Colors.deepPurple),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'AI Validation Rules ($passedCount/$totalCount passed)',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                // Confidence bar
                SizedBox(
                  width: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: (demand.validationScore ?? 0) / 100,
                      minHeight: 4,
                      backgroundColor: Colors.grey.shade200,
                      color: demand.isAIApproved
                          ? AppColors.statusApproved
                          : demand.isAIFlagged
                              ? AppColors.statusFlagged
                              : AppColors.statusRejected,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${demand.validationScore?.toStringAsFixed(0) ?? "?"}%',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.expand_more,
                      size: 16, color: Colors.deepPurple),
                ),
              ],
            ),
            // Rules list — collapsible
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: rules
                      .map((rule) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  rule['passed'] == true
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  size: 13,
                                  color: rule['passed'] == true
                                      ? AppColors.statusApproved
                                      : AppColors.statusRejected,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rule['name'] as String,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        rule['detail'] as String,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generateRuleDisplay() {
    final demand = widget.demand;
    final flags = demand.validationFlags ?? [];
    final rules = <Map<String, dynamic>>[];

    // Rule 1: Unit Cost
    final hasCostIssue = flags.contains('COST_ANOMALY') || flags.contains('COST_WARNING');
    rules.add({
      'name': 'Unit Cost Check',
      'passed': !hasCostIssue,
      'detail': hasCostIssue
          ? 'Cost deviates from Samagra Shiksha standard (\u20B9${demand.expectedCost.toStringAsFixed(2)}L expected)'
          : 'Within acceptable cost range',
    });

    // Rule 2: Duplicate
    rules.add({
      'name': 'Duplicate Detection',
      'passed': !flags.contains('DUPLICATE'),
      'detail': flags.contains('DUPLICATE')
          ? 'Duplicate request found for same infra type & year'
          : 'No duplicates found',
    });

    // Rule 3: Enrolment Correlation
    final hasEnrolIssue = flags.contains('OVER_DEMAND') || flags.contains('DECLINING_ENROLMENT');
    rules.add({
      'name': 'Enrolment Correlation',
      'passed': !hasEnrolIssue,
      'detail': flags.contains('OVER_DEMAND')
          ? 'Demand exceeds school capacity'
          : flags.contains('DECLINING_ENROLMENT')
              ? 'Enrolment declining but expansion requested'
              : 'Demand consistent with enrolment',
    });

    // Rule 4: Peer Comparison
    rules.add({
      'name': 'Peer Comparison',
      'passed': !flags.contains('PEER_OUTLIER'),
      'detail': flags.contains('PEER_OUTLIER')
          ? 'Significantly above regional peer average'
          : 'Within peer range',
    });

    // Rule 5: Zero-Value
    final hasZeroIssue = flags.contains('ZERO_PHYSICAL') || flags.contains('ZERO_FINANCIAL');
    rules.add({
      'name': 'Value Integrity',
      'passed': !hasZeroIssue,
      'detail': hasZeroIssue
          ? 'Invalid zero or negative values detected'
          : '${demand.physicalCount} units, \u20B9${demand.financialAmount.toStringAsFixed(2)}L',
    });

    // Rule 6: Already Exists
    rules.add({
      'name': 'Existing Infrastructure',
      'passed': !flags.contains('ALREADY_EXISTS'),
      'detail': flags.contains('ALREADY_EXISTS')
          ? 'This infrastructure already exists at the school'
          : 'Not yet available at school',
    });

    // Rule 7: Over-Reporting Check
    rules.add({
      'name': 'Over-Reporting Check',
      'passed': !flags.contains('OVER_REPORTING'),
      'detail': flags.contains('OVER_REPORTING')
          ? 'School requests excessive infrastructure across multiple types'
          : 'Demand volume within acceptable limits',
    });

    return rules;
  }
}

// =============================================================================
// Inspected Demands List — demands with field assessments
// =============================================================================

class _InspectedList extends ConsumerWidget {
  final List<DemandPlan> demands;
  const _InspectedList(this.demands);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (demands.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No inspected demands yet'),
          ],
        ),
      );
    }

    final assessmentsAsync = ref.watch(scopedAssessmentsProvider);

    return assessmentsAsync.when(
      data: (assessmentRows) {
        // Build map: schoolId → latest InfraAssessment
        final assessmentMap = <int, InfraAssessment>{};
        for (final row in assessmentRows) {
          final a = InfraAssessment.fromJson(row);
          // Keep the first per school (latest due to order desc)
          if (!assessmentMap.containsKey(a.schoolId)) {
            assessmentMap[a.schoolId] = a;
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: demands.length,
          itemBuilder: (ctx, i) {
            final demand = demands[i];
            final assessment = assessmentMap[demand.schoolId];
            return _DemandCard(demand: demand, assessment: assessment);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

// =============================================================================
// Assessment Details Expandable — inline collapsible section in demand card
// =============================================================================

class _AssessmentDetailsExpandable extends StatefulWidget {
  final InfraAssessment assessment;
  const _AssessmentDetailsExpandable({required this.assessment});

  @override
  State<_AssessmentDetailsExpandable> createState() =>
      _AssessmentDetailsExpandableState();
}

class _AssessmentDetailsExpandableState
    extends State<_AssessmentDetailsExpandable> {
  bool _expanded = false;

  Color _conditionColor(String condition) {
    switch (condition) {
      case 'Good':
        return Colors.green;
      case 'Needs Repair':
        return Colors.orange;
      case 'Critical':
        return Colors.red;
      case 'Dilapidated':
        return Colors.red.shade900;
      case 'Non-Functional':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Returns an image widget: network for URLs, file for local paths
  Widget _buildPhotoThumbnail(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image, size: 24, color: Colors.grey),
        ),
      );
    }
    // Local file path (offline mode fallback)
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported, size: 24, color: Colors.grey),
    );
  }

  /// Opens a full-screen photo viewer dialog with swipe navigation
  void _showPhotoViewer(
      BuildContext context, List<String> photos, int initialIndex) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: photos.length,
              itemBuilder: (_, idx) {
                final path = photos[idx];
                return InteractiveViewer(
                  child: Center(
                    child: path.startsWith('http')
                        ? Image.network(path,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.broken_image,
                                size: 64,
                                color: Colors.white54))
                        : File(path).existsSync()
                            ? Image.file(File(path), fit: BoxFit.contain)
                            : const Icon(Icons.image_not_supported,
                                size: 64, color: Colors.white54),
                  ),
                );
              },
            ),
            // Close button
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                ),
              ),
            ),
            // Photo counter
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${initialIndex + 1} / ${photos.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.assessment;
    final missing = a.extendedMissingFacilitiesCount;
    final dateStr = a.assessmentDate.toIso8601String().split('T')[0];

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.teal.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.teal.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row — always visible
            Row(
              children: [
                const Icon(Icons.assignment_turned_in,
                    size: 14, color: Colors.teal),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Assessment Details · $dateStr',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal,
                    ),
                  ),
                ),
                // Condition badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _conditionColor(a.conditionRating)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    a.conditionRating,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: _conditionColor(a.conditionRating),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Missing count
                if (missing > 0) ...[
                  Icon(Icons.warning_amber,
                      size: 12,
                      color: missing > 5 ? Colors.red : Colors.orange),
                  Text(' $missing',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color:
                              missing > 5 ? Colors.red : Colors.orange)),
                  const SizedBox(width: 4),
                ],
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.expand_more,
                      size: 16, color: Colors.teal),
                ),
              ],
            ),
            // Details — collapsible
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Inspector + GPS
                    if (a.assessedBy != null)
                      _AssessRow('Inspector', a.assessedBy!),
                    if (a.hasGPS)
                      _AssessRow('GPS',
                          '${a.inspectionLatitude!.toStringAsFixed(4)}, ${a.inspectionLongitude!.toStringAsFixed(4)}',
                          color: Colors.green),
                    const Divider(height: 12),

                    // Classrooms & Building
                    _AssessSectionHeader('Classrooms & Building'),
                    _AssessRow('Classrooms',
                        '${a.functionalClassrooms}/${a.existingClassrooms} functional'),
                    _AssessRow('Furniture', a.furnitureAdequacy),
                    _AssessRow('Building', a.buildingCondition,
                        color: _conditionColor(a.buildingCondition)),
                    const Divider(height: 12),

                    // Toilets
                    _AssessSectionHeader('Toilets & Sanitation'),
                    _AssessRow('Toilets',
                        '${a.functionalToilets}/${a.existingToilets} functional (B:${a.boysToilets} G:${a.girlsToilets})'),
                    _AssessRow('Handwash',
                        a.handwashAvailable ? 'Available' : 'Not Available',
                        color: a.handwashAvailable
                            ? Colors.green
                            : Colors.red),
                    _AssessRow('Condition', a.toiletCondition,
                        color: _conditionColor(a.toiletCondition)),
                    const Divider(height: 12),

                    // CWSN
                    _AssessSectionHeader('CWSN Facilities'),
                    _AssessRow('Resource Room',
                        a.cwsnResourceRoomAvailable ? 'Available' : 'N/A',
                        color: a.cwsnResourceRoomAvailable
                            ? Colors.green
                            : Colors.red),
                    _AssessRow('CWSN Toilet',
                        a.cwsnToiletAvailable ? 'Available' : 'N/A',
                        color: a.cwsnToiletAvailable
                            ? Colors.green
                            : Colors.red),
                    _AssessRow('Ramp',
                        a.rampAvailable ? 'Available' : 'N/A',
                        color:
                            a.rampAvailable ? Colors.green : Colors.red),
                    const Divider(height: 12),

                    // Water
                    _AssessSectionHeader('Water Supply'),
                    _AssessRow('Drinking Water',
                        a.drinkingWaterAvailable ? 'Available' : 'N/A',
                        color: a.drinkingWaterAvailable
                            ? Colors.green
                            : Colors.red),
                    _AssessRow('Source', a.waterSourceType),
                    _AssessRow('Purifier',
                        a.waterPurifierAvailable ? 'Available' : 'N/A',
                        color: a.waterPurifierAvailable
                            ? Colors.green
                            : Colors.red),
                    const Divider(height: 12),

                    // Electrification
                    _AssessSectionHeader('Electrification'),
                    _AssessRow('Status', a.electrificationStatus),
                    _AssessRow('Condition', a.electricalCondition,
                        color: _conditionColor(a.electricalCondition)),
                    const Divider(height: 12),

                    // Other facilities
                    _AssessSectionHeader('Other Facilities'),
                    _AssessRow('Boundary Wall', a.boundaryWall,
                        color: a.boundaryWall == 'Complete'
                            ? Colors.green
                            : a.boundaryWall == 'Partial'
                                ? Colors.orange
                                : Colors.red),
                    _AssessRow(
                        'MDM Kitchen',
                        a.mdmKitchenAvailable
                            ? 'Available (${a.mdmKitchenCondition})'
                            : 'N/A',
                        color: a.mdmKitchenAvailable
                            ? Colors.green
                            : Colors.red),
                    _AssessRow('Library',
                        a.libraryAvailable ? 'Available' : 'N/A',
                        color: a.libraryAvailable
                            ? Colors.green
                            : Colors.red),
                    _AssessRow(
                        'Computer Lab',
                        a.computerLabAvailable
                            ? 'Available (${a.functionalComputers} PCs)'
                            : 'N/A',
                        color: a.computerLabAvailable
                            ? Colors.green
                            : Colors.red),
                    const Divider(height: 12),

                    // Safety
                    _AssessSectionHeader('Safety Equipment'),
                    _AssessRow('Fire Extinguisher',
                        a.fireExtinguisherAvailable ? 'Available' : 'N/A',
                        color: a.fireExtinguisherAvailable
                            ? Colors.green
                            : Colors.red),
                    _AssessRow('First Aid',
                        a.firstAidAvailable ? 'Available' : 'N/A',
                        color: a.firstAidAvailable
                            ? Colors.green
                            : Colors.red),
                    const Divider(height: 12),

                    // Overall
                    _AssessRow('Overall Condition', a.conditionRating,
                        color: _conditionColor(a.conditionRating)),
                    _AssessRow('Missing Facilities', '$missing of 13',
                        color: missing > 5 ? Colors.red : Colors.orange),

                    // Photos
                    if (a.photos != null && a.photos!.isNotEmpty) ...[
                      const Divider(height: 12),
                      _AssessSectionHeader(
                          'Inspection Photos (${a.photos!.length})'),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: a.photos!.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (ctx, idx) {
                            final photoPath = a.photos![idx];
                            return GestureDetector(
                              onTap: () => _showPhotoViewer(
                                  ctx, a.photos!, idx),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: _buildPhotoThumbnail(photoPath),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    // Notes
                    if (a.notes != null && a.notes!.isNotEmpty) ...[
                      const Divider(height: 12),
                      _AssessSectionHeader('Inspector Notes'),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(a.notes!,
                            style: const TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textSecondary)),
                      ),
                    ],
                  ],
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact section header for assessment expandable
class _AssessSectionHeader extends StatelessWidget {
  final String title;
  const _AssessSectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.teal,
        ),
      ),
    );
  }
}

/// Compact data row for assessment expandable
class _AssessRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _AssessRow(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: TextStyle(
                    fontSize: 10, color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

