import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/screening_tables.dart';

part 'referral_dao.g.dart';

@DriftAccessor(tables: [LocalReferrals])
class ReferralDao extends DatabaseAccessor<AppDatabase>
    with _$ReferralDaoMixin {
  ReferralDao(super.db);

  Future<int> insertReferral(LocalReferralsCompanion referral) {
    return into(localReferrals).insert(referral);
  }

  Future<List<LocalReferral>> getReferralsForChild(int childRemoteId) {
    return (select(localReferrals)
          ..where((r) => r.childRemoteId.equals(childRemoteId))
          ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]))
        .get();
  }

  Future<List<LocalReferral>> getAllReferrals() {
    return (select(localReferrals)
          ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]))
        .get();
  }

  Future<List<LocalReferral>> getReferralsByStatus(String status) {
    return (select(localReferrals)
          ..where((r) => r.referralStatus.equals(status))
          ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]))
        .get();
  }

  Future<void> updateReferralStatus(int id, String status, {String? notes}) {
    return (update(localReferrals)..where((r) => r.id.equals(id))).write(
      LocalReferralsCompanion(
        referralStatus: Value(status),
        completedDate: status == 'Completed'
            ? Value(DateTime.now().toIso8601String().split('T')[0])
            : const Value.absent(),
        notes: notes != null ? Value(notes) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<LocalReferral?> getReferralById(int id) {
    return (select(localReferrals)..where((r) => r.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> markReferralSynced(int id) {
    return (update(localReferrals)..where((r) => r.id.equals(id))).write(
      LocalReferralsCompanion(syncedAt: Value(DateTime.now())),
    );
  }

  Future<Map<String, int>> getReferralStatusCounts() async {
    final all = await select(localReferrals).get();
    final counts = <String, int>{'Pending': 0, 'Completed': 0, 'Under_Treatment': 0};
    for (final r in all) {
      counts[r.referralStatus] = (counts[r.referralStatus] ?? 0) + 1;
    }
    return counts;
  }
}
