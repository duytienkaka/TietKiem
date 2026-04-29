part of 'app_database.dart';

@DriftAccessor(tables: [SyncQueueItems])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Stream<List<SyncQueueItem>> watchPendingQueue() {
    return (select(syncQueueItems)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<List<SyncQueueItem>> getPendingQueue() {
    return (select(syncQueueItems)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<void> enqueue(SyncQueueItemsCompanion item) {
    return into(syncQueueItems).insertOnConflictUpdate(item);
  }

  Future<void> acknowledge(String id) {
    return (delete(syncQueueItems)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> markFailure({
    required String id,
    required int attemptCount,
    required String error,
    required DateTime lastTriedAt,
  }) {
    return (update(syncQueueItems)..where((tbl) => tbl.id.equals(id))).write(
      SyncQueueItemsCompanion(
        attemptCount: Value(attemptCount),
        lastError: Value(error),
        lastTriedAt: Value(lastTriedAt),
      ),
    );
  }
}
