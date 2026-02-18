import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../config/api_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/governance_provider.dart';

/// Data Governance Dashboard — shows DPDP compliance metrics,
/// consent rates, audit trail, and data access patterns.
class DataGovernanceDashboard extends ConsumerWidget {
  const DataGovernanceDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final isTelugu = language == 'te';
    final statsAsync = ref.watch(governanceStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isTelugu ? 'డేటా గవర్నెన్స్' : 'Data Governance'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(governanceStatsProvider),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stats) => _buildDashboard(context, stats, isTelugu),
      ),
    );
  }

  Widget _buildDashboard(
      BuildContext context, GovernanceStats stats, bool isTelugu) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // DPDP Compliance Score
        _buildComplianceScore(stats, isTelugu),
        const SizedBox(height: 16),

        // Consent Metrics
        _buildConsentMetrics(stats, isTelugu),
        const SizedBox(height: 16),

        // Compliance Checklist
        _buildComplianceChecklist(stats, isTelugu),
        const SizedBox(height: 16),

        // Data Access Patterns
        if (stats.actionCounts.isNotEmpty) ...[
          _buildAccessPatternsChart(stats, isTelugu),
          const SizedBox(height: 16),
        ],

        // Recent Audit Log
        _buildAuditLog(stats, isTelugu),
      ],
    );
  }

  Widget _buildComplianceScore(GovernanceStats stats, bool isTelugu) {
    final percent = (stats.consentRate * 100).round();
    final color = percent >= 90
        ? Colors.green
        : percent >= 70
            ? Colors.orange
            : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              isTelugu ? 'DPDP సమ్మతి స్కోర్' : 'DPDP Compliance Score',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: CircularProgressIndicator(
                      value: stats.consentRate,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey.shade200,
                      color: color,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$percent%',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        isTelugu ? 'అనుమతి రేటు' : 'Consent Rate',
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentMetrics(GovernanceStats stats, bool isTelugu) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTelugu ? 'అనుమతి కొలమానాలు' : 'Consent Metrics',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _metricTile(
                  icon: Icons.people,
                  label: isTelugu ? 'మొత్తం పిల్లలు' : 'Total Children',
                  value: '${stats.totalChildren}',
                  color: Colors.blue,
                ),
                _metricTile(
                  icon: Icons.verified_user,
                  label: isTelugu ? 'అనుమతి ఉన్నవి' : 'With Consent',
                  value: '${stats.consentedChildren}',
                  color: Colors.green,
                ),
                _metricTile(
                  icon: Icons.warning_amber,
                  label: isTelugu ? 'పెండింగ్' : 'Pending',
                  value: '${stats.totalChildren - stats.consentedChildren}',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceChecklist(GovernanceStats stats, bool isTelugu) {
    final items = [
      _CheckItem(
        isTelugu ? 'అనుమతి సేకరణ' : 'Consent Collection',
        stats.consentedChildren > 0,
      ),
      _CheckItem(
        isTelugu ? 'గోప్యతా విధానం' : 'Privacy Policy',
        true, // Always true since we now have it
      ),
      _CheckItem(
        isTelugu ? 'ఆడిట్ లాగింగ్' : 'Audit Logging',
        stats.recentLogs.isNotEmpty,
      ),
      _CheckItem(
        isTelugu ? 'పాత్ర-ఆధారిత ప్రాప్యత' : 'Role-Based Access',
        true, // Supabase RLS
      ),
      _CheckItem(
        isTelugu ? 'డేటా అనామకీకరణ' : 'Data Anonymization',
        true, // Export anonymization feature
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTelugu ? 'సమ్మతి చెక్‌లిస్ట్' : 'Compliance Checklist',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        item.isCompliant
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color:
                            item.isCompliant ? Colors.green : Colors.grey.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 13,
                          color: item.isCompliant
                              ? Colors.black87
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessPatternsChart(GovernanceStats stats, bool isTelugu) {
    final entries = stats.actionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(6).toList();

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTelugu
                  ? 'డేటా ప్రాప్యత నమూనాలు'
                  : 'Data Access Patterns',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (top.isEmpty
                          ? 10
                          : top.first.value.toDouble() * 1.2)
                      .ceilToDouble(),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= top.length) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _shortActionLabel(top[idx].key),
                              style: const TextStyle(fontSize: 9),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                    ),
                    topTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(top.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: top[i].value.toDouble(),
                          color: colors[i % colors.length],
                          width: 18,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortActionLabel(String action) {
    switch (action) {
      case 'view_child':
        return 'View';
      case 'create_child':
        return 'Create';
      case 'start_screening':
        return 'Screen';
      case 'complete_screening':
        return 'Complete';
      case 'export_data':
        return 'Export';
      case 'record_consent':
        return 'Consent';
      case 'view_report':
        return 'Report';
      default:
        return action.length > 8 ? '${action.substring(0, 8)}...' : action;
    }
  }

  Widget _buildAuditLog(GovernanceStats stats, bool isTelugu) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isTelugu ? 'ఇటీవలి ఆడిట్ లాగ్' : 'Recent Audit Log',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${stats.recentLogs.length} ${isTelugu ? 'ఎంట్రీలు' : 'entries'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (stats.recentLogs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    isTelugu
                        ? 'ఇంకా ఆడిట్ లాగ్‌లు లేవు'
                        : 'No audit logs yet',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              )
            else
              ...stats.recentLogs.take(15).map((log) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _actionIcon(log.action),
                          size: 16,
                          color: _actionColor(log.action),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_actionLabel(log.action)} ${log.auditEntityName ?? log.entityType}',
                                style: const TextStyle(fontSize: 12.5),
                              ),
                              Text(
                                '${log.userRole} \u2022 ${DateFormat('dd/MM HH:mm').format(log.timestamp)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  IconData _actionIcon(String action) {
    switch (action) {
      case 'view_child':
        return Icons.visibility;
      case 'create_child':
        return Icons.person_add;
      case 'start_screening':
        return Icons.play_circle;
      case 'complete_screening':
        return Icons.check_circle;
      case 'export_data':
        return Icons.download;
      case 'record_consent':
        return Icons.verified_user;
      case 'revoke_consent':
        return Icons.remove_circle;
      case 'view_report':
        return Icons.analytics;
      default:
        return Icons.history;
    }
  }

  Color _actionColor(String action) {
    switch (action) {
      case 'view_child':
        return Colors.blue;
      case 'create_child':
        return Colors.green;
      case 'start_screening':
        return Colors.orange;
      case 'complete_screening':
        return Colors.green;
      case 'export_data':
        return Colors.purple;
      case 'record_consent':
        return Colors.teal;
      case 'revoke_consent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _actionLabel(String action) {
    switch (action) {
      case 'view_child':
        return 'Viewed';
      case 'create_child':
        return 'Registered';
      case 'start_screening':
        return 'Started screening for';
      case 'complete_screening':
        return 'Completed screening for';
      case 'export_data':
        return 'Exported data';
      case 'record_consent':
        return 'Recorded consent for';
      case 'revoke_consent':
        return 'Revoked consent for';
      case 'view_report':
        return 'Viewed report';
      default:
        return action;
    }
  }
}

class _CheckItem {
  final String label;
  final bool isCompliant;
  _CheckItem(this.label, this.isCompliant);
}
