import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/children_table.dart';

part 'children_dao.g.dart';

@DriftAccessor(tables: [LocalChildren])
class ChildrenDao extends DatabaseAccessor<AppDatabase> with _$ChildrenDaoMixin {
  ChildrenDao(super.db);

  Future<List<LocalChildrenData>> getAllChildren() {
    return (select(localChildren)
          ..where((c) => c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
  }

  Future<LocalChildrenData?> getChildByLocalId(int id) {
    return (select(localChildren)..where((c) => c.localId.equals(id)))
        .getSingleOrNull();
  }

  Future<LocalChildrenData?> getChildByRemoteId(int remoteId) {
    // Use limit(1) to avoid throwing when duplicates exist
    return (select(localChildren)
          ..where((c) => c.remoteId.equals(remoteId))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Safely convert a value to int? (handles UUID strings, ints, nulls)
  static int? _toIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  Future<int> upsertFromRemote(Map<String, dynamic> row) async {
    final remoteId = row['id'] as int;
    final existing = await getChildByRemoteId(remoteId);

    if (existing != null) {
      await (update(localChildren)..where((c) => c.remoteId.equals(remoteId)))
          .write(LocalChildrenCompanion(
        name: Value(row['name'] as String),
        dob: Value(DateTime.parse(row['dob'] as String)),
        gender: Value(row['gender'] as String),
        photoUrl: Value(row['photo_url'] as String?),
        awcId: Value(_toIntOrNull(row['awc_id'])),
        isActive: Value(row['is_active'] as bool? ?? true),
        lastSyncedAt: Value(DateTime.now()),
      ));
      return existing.localId;
    }

    return into(localChildren).insert(LocalChildrenCompanion.insert(
      remoteId: Value(remoteId),
      childUniqueId: row['child_unique_id'] as String? ?? 'UNKNOWN_$remoteId',
      name: row['name'] as String,
      dob: DateTime.parse(row['dob'] as String),
      gender: row['gender'] as String,
      parentId: Value(_toIntOrNull(row['parent_id'])),
      awwId: Value(row['aww_id']?.toString()),
      awcId: Value(_toIntOrNull(row['awc_id'])),
      photoUrl: Value(row['photo_url'] as String?),
      isActive: Value(row['is_active'] as bool? ?? true),
      lastSyncedAt: Value(DateTime.now()),
    ));
  }

  Stream<List<LocalChildrenData>> watchAllChildren() {
    return (select(localChildren)
          ..where((c) => c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  /// Delete all children from local cache (used on user switch)
  Future<void> deleteAllChildren() {
    return delete(localChildren).go();
  }

  /// Delete children whose remoteId is NOT in the given set (prune stale)
  Future<void> deleteChildrenNotIn(Set<int> remoteIds) async {
    final all = await select(localChildren).get();
    for (final child in all) {
      if (child.remoteId != null && !remoteIds.contains(child.remoteId)) {
        await (delete(localChildren)..where((c) => c.localId.equals(child.localId))).go();
      }
    }
  }

  /// Remove duplicate children rows with the same remoteId, keeping only the first
  Future<int> deduplicateByRemoteId() async {
    final all = await select(localChildren).get();
    final seen = <int>{};
    int removed = 0;
    for (final child in all) {
      if (child.remoteId != null) {
        if (seen.contains(child.remoteId)) {
          await (delete(localChildren)..where((c) => c.localId.equals(child.localId))).go();
          removed++;
        } else {
          seen.add(child.remoteId!);
        }
      }
    }
    return removed;
  }
}
