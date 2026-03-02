import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../config/api_config.dart';
import '../../../models/school.dart';
import '../../../models/infra_assessment.dart';
import '../../../models/enrolment.dart';
import '../../../providers/schools_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../schools/school_profile_screen.dart';

class HMHomeTab extends ConsumerWidget {
  final VoidCallback? onNavigateToRequests;

  const HMHomeTab({super.key, this.onNavigateToRequests});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolsAsync = ref.watch(schoolsProvider);

    return schoolsAsync.when(
      data: (schools) {
        if (schools.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('No school assigned', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              ],
            ),
          );
        }
        final school = schools.first;
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(schoolsProvider);
            ref.invalidate(hmLatestAssessmentProvider(school.id));
            ref.invalidate(schoolPriorityScoreProvider(school.id));
            ref.invalidate(schoolEnrolmentProvider(school.id));
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SchoolHeader(school: school),
              const SizedBox(height: 16),
              _InfraStatusCard(schoolId: school.id),
              const SizedBox(height: 16),
              _PriorityBreakdownCard(schoolId: school.id),
              const SizedBox(height: 16),
              _EnrolmentSnapshotCard(schoolId: school.id),
              if (school.hasLocation) ...[
                const SizedBox(height: 16),
                _InlineMapCard(school: school),
              ],
              const SizedBox(height: 16),
              _QuickLinksRow(
                school: school,
                onNavigateToRequests: onNavigateToRequests,
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

// ─── Section A: School Identity Header ───────────────────────────────
class _SchoolHeader extends StatelessWidget {
  final School school;
  const _SchoolHeader({required this.school});

  @override
  Widget build(BuildContext context) {
    final priorityLevel = school.priorityLevel ?? 'LOW';
    final priorityColor = AppColors.forPriority(priorityLevel);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    school.schoolName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: priorityColor.withAlpha(100)),
                  ),
                  child: Text(
                    AppConstants.priorityLabel(priorityLevel),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: priorityColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'UDISE: ${school.udiseCode}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _InfoChip(icon: Icons.category, label: school.categoryLabel),
                _InfoChip(icon: Icons.business, label: school.managementLabel),
                if (school.totalEnrolment != null)
                  _InfoChip(
                    icon: Icons.people,
                    label: '${school.totalEnrolment} students',
                  ),
                if (school.districtName != null)
                  _InfoChip(icon: Icons.location_city, label: school.districtName!),
                if (school.mandalName != null)
                  _InfoChip(icon: Icons.place, label: school.mandalName!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.text)),
        ],
      ),
    );
  }
}

// ─── Section B: Infrastructure Status Card ───────────────────────────
class _InfraStatusCard extends ConsumerWidget {
  final int schoolId;
  const _InfraStatusCard({required this.schoolId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessmentAsync = ref.watch(hmLatestAssessmentProvider(schoolId));
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.construction, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.translate('hm_infra_status'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            assessmentAsync.when(
              data: (assessment) {
                // Show "not inspected" if:
                // 1. No assessment exists
                // 2. Record has no assessor set (test/dummy entry)
                // 3. All facilities are at defaults (empty submission)
                if (assessment == null ||
                    (assessment.assessedBy == null || assessment.assessedBy!.isEmpty) ||
                    _isAssessmentAllDefaults(assessment)) {
                  return _buildNoAssessmentPlaceholder(l10n);
                }
                return _buildInfraGrid(assessment, l10n);
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns true if every facility field is at its default value,
  /// indicating an empty / test submission.
  bool _isAssessmentAllDefaults(InfraAssessment a) {
    return !a.cwsnToiletAvailable &&
        !a.cwsnResourceRoomAvailable &&
        !a.drinkingWaterAvailable &&
        (a.electrificationStatus == 'None' || a.electrificationStatus.isEmpty) &&
        !a.rampAvailable &&
        !a.libraryAvailable &&
        !a.computerLabAvailable &&
        !a.mdmKitchenAvailable &&
        !a.fireExtinguisherAvailable &&
        !a.firstAidAvailable &&
        !a.handwashAvailable &&
        !a.waterPurifierAvailable &&
        a.existingClassrooms == 0 &&
        a.existingToilets == 0 &&
        a.functionalComputers == 0;
  }

  Widget _buildNoAssessmentPlaceholder(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withAlpha(40)),
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_late_outlined, size: 40, color: Colors.orange[400]),
          const SizedBox(height: 12),
          Text(
            l10n.translate('hm_no_assessment'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Infrastructure data will appear here after a field inspector assesses your school.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfraGrid(InfraAssessment a, AppLocalizations l10n) {
    final items = [
      _InfraItem('CWSN Resource Room', a.cwsnResourceRoomAvailable, Icons.meeting_room),
      _InfraItem('CWSN Toilet', a.cwsnToiletAvailable, Icons.wc),
      _InfraItem('Drinking Water', a.drinkingWaterAvailable, Icons.water_drop),
      _InfraItem('Electrification', a.electrificationStatus == 'FULL' || a.electrificationStatus == 'Electrified', Icons.electric_bolt),
      _InfraItem('Ramps', a.rampAvailable, Icons.accessible),
      _InfraItem('Library', a.libraryAvailable, Icons.local_library),
      _InfraItem('Computer Lab', a.computerLabAvailable, Icons.computer),
      _InfraItem('MDM Kitchen', a.mdmKitchenAvailable, Icons.restaurant),
      _InfraItem('Fire Extinguisher', a.fireExtinguisherAvailable, Icons.fire_extinguisher),
      _InfraItem('First Aid', a.firstAidAvailable, Icons.medical_services),
    ];

    final available = items.where((i) => i.available).length;
    final total = items.length;

    return Column(
      children: [
        // Inspector info header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.person_search, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Inspected by ${a.assessedBy ?? "Unknown"} on ${_formatDate(a.assessmentDate)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.primary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (available > total / 2
                          ? AppColors.statusApproved
                          : AppColors.statusRejected)
                      .withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$available/$total',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: available > total / 2
                        ? AppColors.statusApproved
                        : AppColors.statusRejected,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final item = items[i];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.available
                    ? AppColors.statusApproved.withAlpha(15)
                    : AppColors.statusRejected.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (item.available
                          ? AppColors.statusApproved
                          : AppColors.statusRejected)
                      .withAlpha(50),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    item.available ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: item.available
                        ? AppColors.statusApproved
                        : AppColors.statusRejected,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: item.available
                            ? AppColors.statusApproved
                            : AppColors.statusRejected,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Overall condition
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _conditionColor(a.conditionRating).withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Condition: ${a.conditionRating}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _conditionColor(a.conditionRating),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _conditionColor(String condition) {
    switch (condition) {
      case 'Good':
        return AppColors.statusApproved;
      case 'Needs Repair':
        return AppColors.statusFlagged;
      case 'Critical':
      case 'Dilapidated':
        return AppColors.statusRejected;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfraItem {
  final String label;
  final bool available;
  final IconData icon;
  const _InfraItem(this.label, this.available, this.icon);
}

// ─── Section C: Priority Score Breakdown ─────────────────────────────
class _PriorityBreakdownCard extends ConsumerWidget {
  final int schoolId;
  const _PriorityBreakdownCard({required this.schoolId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreAsync = ref.watch(schoolPriorityScoreProvider(schoolId));
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.translate('hm_priority_breakdown'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            scoreAsync.when(
              data: (score) {
                if (score == null) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Priority score not yet computed',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  );
                }
                final level = score.priorityLevel;
                final color = AppColors.forPriority(level);
                return Column(
                  children: [
                    // Composite score badge
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color.withAlpha(25),
                            shape: BoxShape.circle,
                            border: Border.all(color: color, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              score.compositeScore.toStringAsFixed(0),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppConstants.priorityLabel(level),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                              Text(
                                l10n.translate('hm_priority_explanation'),
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Factor bars
                    _FactorBar(
                      label: l10n.translate('enrolment_pressure'),
                      weight: '30%',
                      value: score.enrolmentPressureScore,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    _FactorBar(
                      label: l10n.translate('infrastructure_gap'),
                      weight: '30%',
                      value: score.infraGapScore,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    _FactorBar(
                      label: l10n.translate('cwsn_needs'),
                      weight: '20%',
                      value: score.cwsnNeedScore,
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 8),
                    _FactorBar(
                      label: l10n.translate('accessibility'),
                      weight: '20%',
                      value: score.accessibilityScore,
                      color: Colors.teal,
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FactorBar extends StatelessWidget {
  final String label;
  final String weight;
  final double value;
  final Color color;

  const _FactorBar({
    required this.label,
    required this.weight,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label ($weight)',
            style: const TextStyle(fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 8,
              backgroundColor: color.withAlpha(30),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          child: Text(
            value.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ─── Section D: Enrolment Snapshot ───────────────────────────────────
class _EnrolmentSnapshotCard extends ConsumerWidget {
  final int schoolId;
  const _EnrolmentSnapshotCard({required this.schoolId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrolmentAsync = ref.watch(schoolEnrolmentProvider(schoolId));
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.translate('hm_enrolment_snapshot'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            enrolmentAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return const Text(
                    'No enrolment data available',
                    style: TextStyle(color: AppColors.textSecondary),
                  );
                }
                final trend = EnrolmentTrend.compute(schoolId, records);
                final yearSummaries = trend.yearWise;
                if (yearSummaries.isEmpty) {
                  return const Text('No enrolment data');
                }

                final latest = yearSummaries.last;
                final annualGrowth = yearSummaries.length >= 2
                    ? trend.growthRate / (yearSummaries.length - 1)
                    : 0.0;
                final isGrowing = annualGrowth > 0;

                return Column(
                  children: [
                    // Current enrolment big number
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${latest.totalStudents}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(
                                isGrowing ? Icons.trending_up : Icons.trending_down,
                                size: 16,
                                color: isGrowing ? AppColors.statusApproved : AppColors.statusRejected,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${annualGrowth >= 0 ? '+' : ''}${annualGrowth.toStringAsFixed(1)}%/yr',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isGrowing ? AppColors.statusApproved : AppColors.statusRejected,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          latest.academicYear,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Bar chart (last 3 years max)
                    if (yearSummaries.length >= 2)
                      SizedBox(
                        height: 120,
                        child: _buildBarChart(yearSummaries),
                      ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List<EnrolmentSummary> summaries) {
    // Show last 3 years
    final data = summaries.length > 3
        ? summaries.sublist(summaries.length - 3)
        : summaries;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.map((d) => d.totalStudents.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    data[idx].academicYear,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 24,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.totalStudents.toDouble(),
                width: 24,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [AppColors.primary.withAlpha(150), AppColors.primary],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Section E: Inline Map ───────────────────────────────────────────
class _InlineMapCard extends StatelessWidget {
  final School school;
  const _InlineMapCard({required this.school});

  @override
  Widget build(BuildContext context) {
    if (!school.hasLocation) return const SizedBox.shrink();

    final center = LatLng(school.latitude!, school.longitude!);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 180,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 15,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.vidyasoudha.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.location_pin,
                    size: 40,
                    color: school.priorityColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section F: Quick Links ──────────────────────────────────────────
class _QuickLinksRow extends StatelessWidget {
  final School school;
  final VoidCallback? onNavigateToRequests;

  const _QuickLinksRow({
    required this.school,
    this.onNavigateToRequests,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SchoolProfileScreen(school: school),
              ),
            ),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: Text(
              l10n.translate('hm_view_full_profile'),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: onNavigateToRequests,
            icon: const Icon(Icons.description, size: 16),
            label: Text(
              l10n.translate('hm_my_requests'),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
