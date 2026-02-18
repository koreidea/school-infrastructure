import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../providers/screening_results_storage.dart';
import '../../utils/telugu_transliterator.dart';

/// Shared child card with rich status indicators — risk smiley, screening
/// timestamp, improvement tag, and domain DQ chips.
///
/// Used across all roles: Parent, AWW, CDPO, DW, Supervisor, Senior Official.
class ChildStatusCard extends StatelessWidget {
  final Map<String, dynamic> childData;
  final SavedScreeningResult? result;
  final Map<String, dynamic>? followup;
  final bool isTelugu;
  final VoidCallback onTap;

  const ChildStatusCard({
    super.key,
    required this.childData,
    required this.result,
    this.followup,
    required this.isTelugu,
    required this.onTap,
  });

  /// Build a lightweight SavedScreeningResult from a Supabase screening_results
  /// row (flat map with overall_risk, gm_dq, fm_dq, etc.).
  /// Useful when the caller has raw Supabase data instead of a full
  /// SavedScreeningResult object.
  static SavedScreeningResult resultFromMap(Map<String, dynamic> r) {
    final gmDq = (r['gm_dq'] as num?)?.toDouble() ?? 0.0;
    final fmDq = (r['fm_dq'] as num?)?.toDouble() ?? 0.0;
    final lcDq = (r['lc_dq'] as num?)?.toDouble() ?? 0.0;
    final cogDq = (r['cog_dq'] as num?)?.toDouble() ?? 0.0;
    final seDq = (r['se_dq'] as num?)?.toDouble() ?? 0.0;
    final compositeDq = (r['composite_dq'] as num?)?.toDouble() ?? 0.0;

    return SavedScreeningResult(
      childId: r['child_id'] as int? ?? 0,
      date: r['created_at'] != null
          ? DateTime.tryParse(r['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      overallRisk: r['overall_risk']?.toString() ?? 'LOW',
      overallRiskTe: _riskTe(r['overall_risk']?.toString()),
      referralNeeded: r['referral_needed'] == true,
      domainDqScores: {
        'gm_dq': gmDq,
        'fm_dq': fmDq,
        'lc_dq': lcDq,
        'cog_dq': cogDq,
        'se_dq': seDq,
        'composite_dq': compositeDq,
      },
      domainDelays: {
        'gm_delay': gmDq < 85,
        'fm_delay': fmDq < 85,
        'lc_delay': lcDq < 85,
        'cog_delay': cogDq < 85,
        'se_delay': seDq < 85,
      },
      concerns: [],
      concernsTe: [],
      toolsCompleted: (r['tools_completed'] as num?)?.toInt() ?? 0,
      toolsSkipped: (r['tools_skipped'] as num?)?.toInt() ?? 0,
      assessmentCycle: r['assessment_cycle']?.toString() ?? 'Baseline',
      baselineScore: (r['baseline_score'] as num?)?.toInt() ?? 0,
      baselineCategory: r['baseline_category']?.toString() ?? 'Low',
      numDelays: (r['num_delays'] as num?)?.toInt() ?? 0,
      autismRisk: r['autism_risk']?.toString() ?? 'Low',
      adhdRisk: r['adhd_risk']?.toString() ?? 'Low',
      behaviorRisk: r['behavior_risk']?.toString() ?? 'Low',
      behaviorScore: (r['behavior_score'] as num?)?.toInt() ?? 0,
    );
  }

  static String _riskTe(String? risk) {
    switch (risk?.toUpperCase()) {
      case 'HIGH':
        return 'అధిక';
      case 'MEDIUM':
        return 'మధ్యస్థ';
      default:
        return 'తక్కువ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = isTelugu
        ? toTelugu(childData['name'] ?? 'Unknown')
        : (childData['name'] ?? 'Unknown');
    final ageMonths = childData['age_months'];
    final ageText =
        ageMonths != null ? '$ageMonths ${isTelugu ? 'నెలలు' : 'months'}' : '';

    // Simplified risk → smiley
    String smiley;
    String riskLabel;
    Color riskColor;

    if (result == null) {
      smiley = '🔵';
      riskLabel = isTelugu ? 'తనిఖీ అవసరం' : 'Screening Needed';
      riskColor = AppColors.textSecondary;
    } else if (result!.overallRisk == 'HIGH') {
      smiley = '😟';
      riskLabel = isTelugu ? 'సహాయం అవసరం' : 'Needs Attention';
      riskColor = AppColors.riskHigh;
    } else if (result!.overallRisk == 'MEDIUM') {
      smiley = '😐';
      riskLabel = isTelugu ? 'కొంచెం మద్దతు అవసరం' : 'Some Support Needed';
      riskColor = AppColors.riskMedium;
    } else {
      smiley = '😊';
      riskLabel = isTelugu ? 'బాగా అభివృద్ధి చెందుతోంది' : 'Developing Well';
      riskColor = AppColors.riskLow;
    }

    // Screening status
    String statusText = '';
    if (result != null) {
      final daysSince = DateTime.now().difference(result!.date).inDays;
      statusText = daysSince == 0
          ? (isTelugu ? 'ఈ రోజు తనిఖీ చేశారు' : 'Screened today')
          : (isTelugu
              ? '$daysSince రోజుల క్రితం తనిఖీ'
              : 'Screened $daysSince days ago');
    }

    // Improvement status from followup
    String? improvementText;
    bool improvementPositive = false;
    if (followup != null && followup!['improvement_status'] != null) {
      final status = followup!['improvement_status'] as String;
      if (status == 'Improved' || status == 'Improving') {
        improvementText = isTelugu ? '↗ మెరుగుపడుతోంది' : '↗ Improving';
        improvementPositive = true;
      } else if (status == 'Stable') {
        improvementText = isTelugu ? '→ స్థిరంగా ఉంది' : '→ Stable';
        improvementPositive = true;
      } else if (status == 'Worsened' || status == 'Needs more support') {
        improvementText = isTelugu ? '↘ మరింత మద్దతు అవసరం' : '↘ Needs more support';
        improvementPositive = false;
      }
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: childData['photo_url'] != null
                        ? NetworkImage(childData['photo_url'])
                        : null,
                    child: childData['photo_url'] == null
                        ? const Icon(Icons.child_care,
                            color: AppColors.primary, size: 26)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                        if (ageText.isNotEmpty)
                          Text(ageText,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13)),
                      ],
                    ),
                  ),
                  // Smiley indicator
                  Column(
                    children: [
                      Text(smiley, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 2),
                      Text(riskLabel,
                          style: TextStyle(
                              fontSize: 10,
                              color: riskColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              if (statusText.isNotEmpty || improvementText != null) ...[
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (statusText.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(statusText,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    if (statusText.isNotEmpty && improvementText != null)
                      const SizedBox(width: 16),
                    if (improvementText != null)
                      Text(
                        improvementText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: improvementPositive
                              ? AppColors.riskLow
                              : AppColors.riskHigh,
                        ),
                      ),
                  ],
                ),
              ],
              // Domains quick summary (only for screened children)
              if (result != null) ...[
                const SizedBox(height: 10),
                _buildDomainChips(result!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDomainChips(SavedScreeningResult r) {
    final domains = [
      {'key': 'gm', 'en': 'Motor', 'te': 'చలనం'},
      {'key': 'fm', 'en': 'Fine Motor', 'te': 'సూక్ష్మం'},
      {'key': 'lc', 'en': 'Language', 'te': 'భాష'},
      {'key': 'cog', 'en': 'Thinking', 'te': 'ఆలోచన'},
      {'key': 'se', 'en': 'Social', 'te': 'సామాజిక'},
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: domains.map((d) {
        final isDelayed = r.domainDelays['${d['key']}_delay'] ?? false;
        final dq = r.domainDqScores['${d['key']}_dq'] ?? 0.0;
        final color = isDelayed ? AppColors.riskHigh : AppColors.riskLow;
        final label = isTelugu ? d['te'] as String : d['en'] as String;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDelayed ? Icons.arrow_downward : Icons.check_circle,
                size: 12,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                '$label ${dq.toInt()}',
                style: TextStyle(
                    fontSize: 11, color: color, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
