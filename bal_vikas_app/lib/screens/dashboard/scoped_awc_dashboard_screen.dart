import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/api_config.dart';
import '../../models/user.dart';
import '../../providers/dataset_provider.dart';
import '../../providers/screening_results_storage.dart';
import '../../services/supabase_service.dart';
import '../../utils/telugu_transliterator.dart';
import '../children/child_profile_screen.dart';
import '../children/child_status_card.dart';
import 'widgets/shared_dashboard_widgets.dart';

/// Simplified AWC-level dashboard for drill-down navigation.
/// Shows AWC stats summary + children list with risk badges.
/// Uses RPC when dataset override is active to bypass RLS.
class ScopedAwcDashboardScreen extends ConsumerStatefulWidget {
  final int awcId;
  final String awcName;

  const ScopedAwcDashboardScreen({
    super.key,
    required this.awcId,
    required this.awcName,
  });

  @override
  ConsumerState<ScopedAwcDashboardScreen> createState() => _ScopedAwcDashboardScreenState();
}

class _ScopedAwcDashboardScreenState extends ConsumerState<ScopedAwcDashboardScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _children = [];
  int _screenedCount = 0;
  int _highRiskCount = 0;
  int _referralCount = 0;
  int _followUpCompleted = 0;
  int _followUpTotal = 0;
  int _totalSessions = 0;
  Map<int, SavedScreeningResult> _screeningResults = {};
  Map<int, Map<String, dynamic>> _followupData = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final isOverride = ref.read(activeDatasetProvider) != null;

    try {
      List<Map<String, dynamic>> children;
      List<Map<String, dynamic>> results;

      if (isOverride) {
        // RPC path: bypass RLS for cross-project browsing
        final childRows = await SupabaseService.client.rpc(
          'get_children_for_scope',
          params: {'p_scope': 'awc', 'p_scope_id': widget.awcId},
        );
        children = (childRows as List)
            .map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r as Map))
            .toList();

        // Get screening results via RPC
        final childIds = children.map((c) => c['id'] as int).toList();
        results = <Map<String, dynamic>>[];
        if (childIds.isNotEmpty) {
          for (var i = 0; i < childIds.length; i += 200) {
            final batch = childIds.sublist(i, (i + 200).clamp(0, childIds.length));
            final rpcRows = await SupabaseService.client.rpc(
              'get_screening_results_for_children',
              params: {'p_child_ids': batch},
            );
            results.addAll((rpcRows as List)
                .map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r as Map)));
          }
        }
      } else {
        // Standard path: direct Supabase queries
        children = await SupabaseService.getChildrenForAwc(widget.awcId);
        results = await SupabaseService.getScreeningResultsForAwc(widget.awcId);
      }

      // Build risk map + full screening results: child_id → latest
      final riskMap = <int, String>{};
      final referralMap = <int, bool>{};
      final screeningMap = <int, SavedScreeningResult>{};
      for (final r in results) {
        final childId = r['child_id'] as int?;
        if (childId != null && !riskMap.containsKey(childId)) {
          riskMap[childId] = r['overall_risk'] as String? ?? 'LOW';
          referralMap[childId] = r['referral_needed'] as bool? ?? false;
          screeningMap[childId] = ChildStatusCard.resultFromMap(r);
        }
      }

      // Annotate children
      final annotated = children.map((c) {
        final childId = c['id'] as int;
        return {
          ...c,
          '_risk': riskMap[childId],
          '_referral': referralMap[childId] ?? false,
        };
      }).toList();

      int screened = 0, highRisk = 0, referrals = 0;
      for (final c in annotated) {
        if (c['_risk'] != null) screened++;
        if (c['_risk'] == 'HIGH') highRisk++;
        if (c['_referral'] == true) referrals++;
      }

      // Count total screening sessions and follow-up data
      int totalSessions = results.length;
      int followUpTotal = 0, followUpCompleted = 0;
      final followupMap = <int, Map<String, dynamic>>{};
      try {
        final childIds = children.map((c) => c['id'] as int).toList();
        if (isOverride) {
          // Follow-ups via RPC
          if (childIds.isNotEmpty) {
            final fuRows = await SupabaseService.client.rpc(
              'get_followups_for_children',
              params: {'p_child_ids': childIds},
            );
            final followUps = (fuRows as List)
                .map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r as Map))
                .toList();
            followUpTotal = followUps.length;
            followUpCompleted = followUps
                .where((f) => f['improvement_status'] != null && f['improvement_status'] != 'pending')
                .length;
            // Build per-child followup map (latest per child)
            for (final f in followUps) {
              final cid = f['child_id'] as int?;
              if (cid != null && !followupMap.containsKey(cid)) {
                followupMap[cid] = f;
              }
            }
          }
        } else {
          final followUps = await SupabaseService.client
              .from('intervention_followups')
              .select()
              .eq('awc_id', widget.awcId)
              .order('created_at', ascending: false);
          followUpTotal = (followUps as List).length;
          followUpCompleted = (followUps as List)
              .where((f) => f['improvement_status'] != null && f['improvement_status'] != 'pending')
              .length;
          // Build per-child followup map (latest per child)
          for (final f in followUps) {
            final cid = (f as Map)['child_id'] as int?;
            if (cid != null && !followupMap.containsKey(cid)) {
              followupMap[cid] = Map<String, dynamic>.from(f);
            }
          }
        }
      } catch (_) {
        // Follow-up data optional
      }

      if (mounted) {
        setState(() {
          _children = annotated;
          _screenedCount = screened;
          _highRiskCount = highRisk;
          _referralCount = referrals;
          _totalSessions = totalSessions;
          _followUpTotal = followUpTotal;
          _followUpCompleted = followUpCompleted;
          _screeningResults = screeningMap;
          _followupData = followupMap;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _calculateAgeMonths(String dobStr) {
    final dob = DateTime.parse(dobStr);
    final now = DateTime.now();
    int months = (now.year - dob.year) * 12 + (now.month - dob.month);
    if (now.day < dob.day) months--;
    return months < 0 ? 0 : months;
  }

  @override
  Widget build(BuildContext context) {
    // Determine language from context (simple heuristic from system locale)
    final isTelugu = Localizations.localeOf(context).languageCode == 'te';

    return Scaffold(
      appBar: AppBar(
        title: Text(isTelugu ? toTelugu(widget.awcName) : widget.awcName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ScopeHeaderCard(
                      scopeName: widget.awcName,
                      scopeLevel: 'awc',
                      isTelugu: isTelugu,
                    ),
                  ),

                  // Stats row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(children: [
                      Expanded(
                        child: DashboardStatCard(
                          icon: Icons.people,
                          value: '${_children.length}',
                          label: isTelugu ? 'మొత్తం పిల్లలు' : 'Total Children',
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DashboardStatCard(
                          icon: Icons.check_circle,
                          value: '$_screenedCount',
                          label: isTelugu ? 'తనిఖీ' : 'Screened',
                          color: AppColors.riskLow,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DashboardStatCard(
                          icon: Icons.warning,
                          value: '$_highRiskCount',
                          label: isTelugu ? 'అధిక ప్రమాదం' : 'High Risk',
                          color: AppColors.riskHigh,
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 8),

                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DashboardProgressCard(
                      total: _children.length,
                      screened: _screenedCount,
                      isTelugu: isTelugu,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // KPI Assessment Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildKpiSection(isTelugu),
                  ),
                  const SizedBox(height: 16),

                  // Children header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: AppColors.primaryLight,
                    child: Text(
                      '${_children.length} ${isTelugu ? 'పిల్లలు' : 'Children'}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),

                  // Children list
                  if (_children.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          isTelugu ? 'పిల్లలు లేరు' : 'No children found',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _children.length,
                      itemBuilder: (context, index) {
                        final c = _children[index];
                        final dobStr = c['dob']?.toString() ?? '2000-01-01';
                        final ageMonths = _calculateAgeMonths(dobStr);
                        final childId = c['id'] as int?;

                        final childMap = {
                          'child_id': childId,
                          'child_unique_id': c['child_unique_id'] ?? '',
                          'name': c['name'] ?? '',
                          'date_of_birth': dobStr,
                          'gender': c['gender'] ?? 'male',
                          'age_months': ageMonths,
                          'photo_url': c['photo_url'],
                          'awc_id': c['awc_id'],
                          'parent_id': c['parent_id'],
                          'aww_id': c['aww_id'],
                        };

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ChildStatusCard(
                            childData: childMap,
                            result: childId != null
                                ? _screeningResults[childId]
                                : null,
                            followup: childId != null
                                ? _followupData[childId]
                                : null,
                            isTelugu: isTelugu,
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => ChildProfileScreen(child: Child.fromMap(childMap)),
                              ));
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildKpiSection(bool isTelugu) {
    final totalChildren = _children.length;
    final coveragePct = totalChildren > 0 ? (_screenedCount / totalChildren * 100) : 0.0;
    final hrRate = totalChildren > 0 ? (_highRiskCount / totalChildren * 100) : 0.0;
    final referralRate = _screenedCount > 0 ? (_referralCount / _screenedCount * 100) : 0.0;
    final followUpRate = _followUpTotal > 0 ? (_followUpCompleted / _followUpTotal * 100) : 0.0;
    final avgScreeningsPerChild = totalChildren > 0 ? (_totalSessions / totalChildren) : 0.0;

    // Compute KPI grade
    final grade = _computeKpiGrade(coveragePct, followUpRate);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.assessment, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                isTelugu ? 'AWC పనితీరు KPI' : 'AWC Performance KPIs',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _gradeColor(grade),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${isTelugu ? 'గ్రేడ్' : 'Grade'} $grade',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 16),

            // KPI rows
            _KpiRow(
              label: isTelugu ? 'స్క్రీనింగ్ కవరేజ్' : 'Screening Coverage',
              value: '${coveragePct.toStringAsFixed(0)}%',
              progress: coveragePct / 100,
              color: coveragePct >= 80 ? AppColors.riskLow : coveragePct >= 50 ? AppColors.riskMedium : AppColors.riskHigh,
              target: isTelugu ? 'లక్ష్యం: 100%' : 'Target: 100%',
            ),
            const SizedBox(height: 12),
            _KpiRow(
              label: isTelugu ? 'అధిక ప్రమాద రేటు' : 'High-Risk Rate',
              value: '${hrRate.toStringAsFixed(1)}%',
              progress: hrRate / 100,
              color: hrRate <= 10 ? AppColors.riskLow : hrRate <= 25 ? AppColors.riskMedium : AppColors.riskHigh,
              target: isTelugu ? 'అంచనా: <15%' : 'Benchmark: <15%',
            ),
            const SizedBox(height: 12),
            _KpiRow(
              label: isTelugu ? 'రెఫరల్ రేటు' : 'Referral Rate',
              value: '${referralRate.toStringAsFixed(1)}%',
              progress: referralRate / 100,
              color: AppColors.riskMedium,
              target: '$_referralCount ${isTelugu ? 'రెఫరల్లు' : 'referrals'}',
            ),
            const SizedBox(height: 12),
            _KpiRow(
              label: isTelugu ? 'ఫాలో-అప్ పూర్తి' : 'Follow-up Completion',
              value: _followUpTotal > 0 ? '${followUpRate.toStringAsFixed(0)}%' : 'N/A',
              progress: _followUpTotal > 0 ? followUpRate / 100 : 0,
              color: followUpRate >= 80 ? AppColors.riskLow : followUpRate >= 50 ? AppColors.riskMedium : AppColors.riskHigh,
              target: '$_followUpCompleted/$_followUpTotal ${isTelugu ? 'పూర్తి' : 'done'}',
            ),
            const SizedBox(height: 12),
            _KpiRow(
              label: isTelugu ? 'సగటు స్క్రీనింగ్/పిల్లవాడు' : 'Avg Screenings/Child',
              value: avgScreeningsPerChild.toStringAsFixed(1),
              progress: (avgScreeningsPerChild / 3).clamp(0, 1),
              color: AppColors.primary,
              target: isTelugu ? 'లక్ష్యం: 2-3' : 'Target: 2-3',
            ),
          ],
        ),
      ),
    );
  }

  String _computeKpiGrade(double coverage, double followUpRate) {
    double score = 0;
    // Coverage: 40% weight
    if (coverage >= 90) {
      score += 40;
    } else if (coverage >= 70) {
      score += 30;
    } else if (coverage >= 50) {
      score += 20;
    } else {
      score += 10;
    }
    // Follow-up: 30% weight
    if (followUpRate >= 80) {
      score += 30;
    } else if (followUpRate >= 50) {
      score += 20;
    } else {
      score += 10;
    }
    // Screening depth (totalSessions vs children): 30% weight
    final depth = _children.isNotEmpty ? _totalSessions / _children.length : 0;
    if (depth >= 2) {
      score += 30;
    } else if (depth >= 1) {
      score += 20;
    } else {
      score += 10;
    }

    if (score >= 85) return 'A';
    if (score >= 65) return 'B';
    if (score >= 45) return 'C';
    return 'D';
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A':
        return AppColors.riskLow;
      case 'B':
        return Colors.blue;
      case 'C':
        return AppColors.riskMedium;
      default:
        return AppColors.riskHigh;
    }
  }
}

class _KpiRow extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final Color color;
  final String target;

  const _KpiRow({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 2),
        Text(target, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ],
    );
  }
}
