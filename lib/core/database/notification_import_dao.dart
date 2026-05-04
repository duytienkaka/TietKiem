part of 'app_database.dart';

@DriftAccessor(tables: [NotificationImports])
class NotificationImportDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationImportDaoMixin {
  NotificationImportDao(super.db);

  Stream<List<NotificationImport>> watchImports() {
    return (select(notificationImports)
          ..orderBy([(t) => OrderingTerm.desc(t.detectedAt)]))
        .watch();
  }

  Future<List<NotificationImport>> getImports() {
    return (select(notificationImports)
          ..orderBy([(t) => OrderingTerm.desc(t.detectedAt)]))
        .get();
  }

  Stream<List<NotificationImport>> watchPendingImports() {
    return (select(notificationImports)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.detectedAt)]))
        .watch();
  }

  Future<List<NotificationImport>> getPendingImports() {
    return (select(notificationImports)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.detectedAt)]))
        .get();
  }

  Future<NotificationImport?> getBySourceKey(String sourceKey) {
    return (select(notificationImports)
          ..where((t) => t.sourceKey.equals(sourceKey)))
        .getSingleOrNull();
  }

  Future<NotificationImport?> getById(String id) {
    return (select(notificationImports)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> upsertImport(NotificationImportsCompanion value) {
    return into(notificationImports).insertOnConflictUpdate(value);
  }
}
