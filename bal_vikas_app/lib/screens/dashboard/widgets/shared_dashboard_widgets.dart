import 'package:flutter/material.dart';
import '../../../config/api_config.dart';
import '../../../utils/telugu_transliterator.dart';

// ============================================================================
// Shared dashboard widgets — used by both native tabs and scoped drill-down
// ============================================================================

/// Stat card showing icon, value, and label. Tappable when onTap is provided.
class DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const DashboardStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ]),
        ),
      ),
    );
  }
}

/// Summary row showing icon, label, value, and optional chevron. Tappable when onTap is provided.
class DashboardSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const DashboardSummaryRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
          ],
        ]),
      ),
    );
  }
}

/// Screening progress card with percentage and progress bar.
class DashboardProgressCard extends StatelessWidget {
  final int total;
  final int screened;
  final bool isTelugu;

  const DashboardProgressCard({
    super.key,
    required this.total,
    required this.screened,
    required this.isTelugu,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (screened / total) : 0.0;
    final color = pct >= 0.75 ? AppColors.riskLow : pct >= 0.5 ? AppColors.riskMedium : AppColors.riskHigh;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(isTelugu ? 'ఈ నెల తనిఖీ పురోగతి' : 'Screening Progress This Month',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text('${(pct * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isTelugu ? '$screened / $total పిల్లలు తనిఖీ చేయబడ్డారు' : '$screened / $total children screened',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ]),
      ),
    );
  }
}

/// Sub-unit comparison card showing name, progress bar, and stats.
class DashboardUnitCard extends StatelessWidget {
  final String name;
  final String subUnitLabel;
  final int subUnitCount;
  final int childrenCount;
  final int screenedCount;
  final int highRiskCount;
  final bool isTelugu;
  final VoidCallback? onTap;
  final IconData icon;

  const DashboardUnitCard({
    super.key,
    required this.name,
    required this.subUnitLabel,
    required this.subUnitCount,
    required this.childrenCount,
    required this.screenedCount,
    required this.highRiskCount,
    required this.isTelugu,
    this.onTap,
    this.icon = Icons.business,
  });

  @override
  Widget build(BuildContext context) {
    final pct = childrenCount > 0 ? screenedCount / childrenCount : 0.0;
    final color = pct >= 0.75 ? AppColors.riskLow : pct >= 0.5 ? AppColors.riskMedium : AppColors.riskHigh;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(backgroundColor: AppColors.primaryLight, child: Icon(icon, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(isTelugu ? toTelugu(name) : name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('$subUnitCount $subUnitLabel', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ])),
              if (onTap != null) const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ]),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pct.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(children: [
                Text('$childrenCount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
                Text(isTelugu ? 'పిల్లలు' : 'Children', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
              Column(children: [
                Text('$screenedCount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.riskLow)),
                Text(isTelugu ? 'తనిఖీ' : 'Screened', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
              Column(children: [
                Text('$highRiskCount',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: highRiskCount > 0 ? AppColors.riskHigh : AppColors.text)),
                Text(isTelugu ? 'అధిక ప్రమాదం' : 'High Risk', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
            ]),
          ]),
        ),
      ),
    );
  }
}

/// Header card for scoped drill-down dashboards (replaces welcome card).
class ScopeHeaderCard extends StatelessWidget {
  final String scopeName;
  final String scopeLevel;
  final bool isTelugu;

  const ScopeHeaderCard({
    super.key,
    required this.scopeName,
    required this.scopeLevel,
    required this.isTelugu,
  });

  IconData get _levelIcon {
    switch (scopeLevel) {
      case 'district':
        return Icons.map;
      case 'project':
        return Icons.business;
      case 'sector':
        return Icons.location_city;
      case 'awc':
        return Icons.location_on;
      default:
        return Icons.dashboard;
    }
  }

  String get _levelLabel {
    if (isTelugu) {
      switch (scopeLevel) {
        case 'district':
          return 'జిల్లా';
        case 'project':
          return 'ప్రాజెక్ట్';
        case 'sector':
          return 'సెక్టార్';
        case 'awc':
          return 'AWC కేంద్రం';
        default:
          return '';
      }
    }
    switch (scopeLevel) {
      case 'district':
        return 'District';
      case 'project':
        return 'Project';
      case 'sector':
        return 'Sector';
      case 'awc':
        return 'AWC Center';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryLight,
              child: Icon(_levelIcon, size: 24, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_levelLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                Text(
                  isTelugu ? toTelugu(scopeName) : scopeName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data-driven action pathways section that generates role-specific
/// suggested actions based on current dashboard stats.
class ActionPathwaysSection extends StatelessWidget {
  final String role; // SUPERVISOR, CDPO, DW, SENIOR_OFFICIAL
  final int totalChildren;
  final int screenedCount;
  final int highRiskCount;
  final int referralsNeeded;
  final List<dynamic> subUnits;
  final bool isTelugu;
  final VoidCallback? onScreenPending;
  final VoidCallback? onViewHighRisk;
  final VoidCallback? onViewReferrals;

  const ActionPathwaysSection({
    super.key,
    required this.role,
    required this.totalChildren,
    required this.screenedCount,
    required this.highRiskCount,
    required this.referralsNeeded,
    required this.subUnits,
    required this.isTelugu,
    this.onScreenPending,
    this.onViewHighRisk,
    this.onViewReferrals,
  });

  @override
  Widget build(BuildContext context) {
    final actions = _generateActions();
    if (actions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.route, color: AppColors.primary, size: 22),
          const SizedBox(width: 8),
          Text(isTelugu ? 'సూచించిన చర్యలు' : 'Suggested Actions',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 12),
        ...actions.map((a) => _ActionCard(
          icon: a['icon'] as IconData,
          title: a['title'] as String,
          subtitle: a['subtitle'] as String,
          priority: a['priority'] as String,
          color: a['color'] as Color,
          onTap: a['onTap'] as VoidCallback?,
        )),
      ],
    );
  }

  List<Map<String, dynamic>> _generateActions() {
    final actions = <Map<String, dynamic>>[];
    final pending = totalChildren - screenedCount;
    final coveragePct = totalChildren > 0 ? (screenedCount / totalChildren * 100) : 0.0;

    // Action 1: Screen pending children (if coverage < 100%)
    if (pending > 0) {
      final urgency = coveragePct < 50 ? 'HIGH' : coveragePct < 75 ? 'MEDIUM' : 'LOW';
      actions.add({
        'icon': Icons.assignment_add,
        'title': isTelugu
            ? '$pending పిల్లలను స్క్రీన్ చేయండి'
            : 'Screen $pending pending children',
        'subtitle': isTelugu
            ? 'కవరేజ్: ${coveragePct.toStringAsFixed(0)}% — ${_urgencyLabel(urgency)}'
            : 'Coverage: ${coveragePct.toStringAsFixed(0)}% — ${_urgencyLabel(urgency)}',
        'priority': urgency,
        'color': _urgencyColor(urgency),
        'onTap': onScreenPending,
      });
    }

    // Action 2: Follow up on high-risk children
    if (highRiskCount > 0) {
      actions.add({
        'icon': Icons.warning_amber_rounded,
        'title': isTelugu
            ? '$highRiskCount అధిక ప్రమాద పిల్లలను ఫాలో-అప్ చేయండి'
            : 'Follow up on $highRiskCount high-risk children',
        'subtitle': isTelugu
            ? 'రెఫరల్ స్థితి & జోక్య ప్రణాళికలను తనిఖీ చేయండి'
            : 'Check referral status & intervention plans',
        'priority': 'HIGH',
        'color': AppColors.riskHigh,
        'onTap': onViewHighRisk,
      });
    }

    // Action 3: Process pending referrals
    if (referralsNeeded > 0) {
      actions.add({
        'icon': Icons.local_hospital,
        'title': isTelugu
            ? '$referralsNeeded పెండింగ్ రెఫరల్లను ప్రాసెస్ చేయండి'
            : 'Process $referralsNeeded pending referrals',
        'subtitle': isTelugu
            ? 'DEIC/RBSK/PHC రెఫరల్లను పూర్తి చేయండి'
            : 'Complete DEIC/RBSK/PHC referrals',
        'priority': 'HIGH',
        'color': AppColors.riskHigh,
        'onTap': onViewReferrals,
      });
    }

    // Action 4: Role-specific actions
    if (role == 'SUPERVISOR' || role == 'CDPO' || role == 'CW' || role == 'EO') {
      // Check for underperforming sub-units
      final lowCoverageUnits = subUnits.where((u) {
        final map = u is Map ? u : {};
        final children = (map['children_count'] as num?)?.toInt() ?? 0;
        final screened = (map['screened_count'] as num?)?.toInt() ?? 0;
        return children > 0 && (screened / children) < 0.5;
      }).toList();

      if (lowCoverageUnits.isNotEmpty) {
        final unitType = role == 'SUPERVISOR'
            ? (isTelugu ? 'AWCలు' : 'AWCs')
            : (isTelugu ? 'సెక్టార్లు' : 'sectors');
        actions.add({
          'icon': Icons.trending_down,
          'title': isTelugu
              ? '${lowCoverageUnits.length} $unitType తక్కువ కవరేజ్‌తో ఉన్నాయి'
              : '${lowCoverageUnits.length} $unitType have low coverage',
          'subtitle': isTelugu
              ? '<50% కవరేజ్ — ప్రాధాన్యత ఇవ్వండి'
              : '<50% coverage — prioritize these',
          'priority': 'MEDIUM',
          'color': AppColors.riskMedium,
          'onTap': null,
        });
      }
    }

    if (role == 'DW' || role == 'SENIOR_OFFICIAL') {
      // District/state level: review overall trends
      if (highRiskCount > 0 && totalChildren > 0) {
        final hrPct = (highRiskCount / totalChildren * 100);
        if (hrPct > 20) {
          actions.add({
            'icon': Icons.analytics,
            'title': isTelugu
                ? 'అధిక ప్రమాద రేటు ${hrPct.toStringAsFixed(0)}% — సమీక్ష అవసరం'
                : 'High-risk rate ${hrPct.toStringAsFixed(0)}% — review needed',
            'subtitle': isTelugu
                ? 'జిల్లా/ప్రాజెక్ట్ వారీ ప్రమాద పంపిణీని విశ్లేషించండి'
                : 'Analyze risk distribution across districts/projects',
            'priority': 'MEDIUM',
            'color': AppColors.riskMedium,
            'onTap': null,
          });
        }
      }
    }

    // Action 5: Coverage milestone
    if (coveragePct >= 75 && coveragePct < 100 && pending > 0) {
      actions.add({
        'icon': Icons.emoji_events,
        'title': isTelugu
            ? '100% కవరేజ్‌కు దగ్గరగా! కేవలం $pending మిగిలి ఉన్నారు'
            : 'Nearly 100% coverage! Only $pending left',
        'subtitle': isTelugu
            ? 'ఈ నెల పూర్తి కవరేజ్ సాధించండి'
            : 'Achieve full coverage this month',
        'priority': 'LOW',
        'color': AppColors.riskLow,
        'onTap': onScreenPending,
      });
    }

    return actions;
  }

  String _urgencyLabel(String priority) {
    switch (priority) {
      case 'HIGH':
        return isTelugu ? 'అత్యవసరం' : 'Urgent';
      case 'MEDIUM':
        return isTelugu ? 'ముఖ్యం' : 'Important';
      default:
        return isTelugu ? 'సాధారణ' : 'Routine';
    }
  }

  Color _urgencyColor(String priority) {
    switch (priority) {
      case 'HIGH':
        return AppColors.riskHigh;
      case 'MEDIUM':
        return AppColors.riskMedium;
      default:
        return AppColors.riskLow;
    }
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String priority;
  final Color color;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.priority,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(priority, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
            ],
          ]),
        ),
      ),
    );
  }
}
