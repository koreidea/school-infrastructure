import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../services/database_service.dart';

/// Stats model for the data governance dashboard.
class GovernanceStats {
  final int totalChildren;
  final int consentedChildren;
  final double consentRate;
  final Map<String, int> actionCounts;
  final List<LocalAuditLog> recentLogs;

  GovernanceStats({
    required this.totalChildren,
    required this.consentedChildren,
    required this.consentRate,
    required this.actionCounts,
    required this.recentLogs,
  });
}

/// Provider for data governance dashboard statistics.
final governanceStatsProvider = FutureProvider<GovernanceStats>((ref) async {
  final db = DatabaseService.db;
  final dpdpDao = db.dpdpDao;

  final allChildren = await db.childrenDao.getAllChildren();
  final totalChildren = allChildren.length;
  final consentedCount = await dpdpDao.getConsentedChildrenCount();
  final consentRate =
      totalChildren > 0 ? consentedCount / totalChildren : 0.0;
  final actionCounts = await dpdpDao.getActionCounts();
  final recentLogs = await dpdpDao.getRecentLogs(limit: 30);

  return GovernanceStats(
    totalChildren: totalChildren,
    consentedChildren: consentedCount,
    consentRate: consentRate,
    actionCounts: actionCounts,
    recentLogs: recentLogs,
  );
});
