import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sync_queue_table.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<int> enqueue({
    required String entityType,
    required int entityLocalId,
    required String operation,
    int priority = 0,
  }) {
    return into(syncQueue).insert(SyncQueueCompanion.insert(
      entityType: entityType,
      entityLocalId: entityLocalId,
      operation: operation,
      priority: Value(priority),
    ));
  }

  Future<List<SyncQueueData>> getPendingItems({int limit = 20}) {
    return (select(syncQueue)
          ..where((q) => q.retryCount.isSmallerThanValue(5))
          ..orderBy([
            (q) => OrderingTerm.asc(q.priority),
            (q) => OrderingTerm.asc(q.createdAt),
          ])
          ..limit(limit))
        .get();
  }

  Future<void> markFailed(int id, String errorMessage) async {
    final item =
        await (select(syncQueue)..where((q) => q.id.equals(id))).getSingle();
    await (update(syncQueue)..where((q) => q.id.equals(id))).write(
      SyncQueueCompanion(
        retryCount: Value(item.retryCount + 1),
        lastError: Value(errorMessage),
        lastAttemptAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> removeItem(int id) {
    return (delete(syncQueue)..where((q) => q.id.equals(id))).go();
  }

  Future<int> getPendingCount() async {
    final count = countAll();
    final query = selectOnly(syncQueue)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Stream<int> watchPendingCount() {
    final count = countAll();
    final query = selectOnly(syncQueue)..addColumns([count]);
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }
}
