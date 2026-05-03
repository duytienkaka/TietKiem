part of 'app_database.dart';

@DriftAccessor(tables: [Categories, Transactions])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Stream<List<Category>> watchCategories() {
    return (select(categories)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<List<Category>> getCategories() {
    return (select(categories)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<List<Category>> getCategoriesForScope(String scopeId) {
    return (select(categories)
          ..where((t) => t.workspaceId.equals(scopeId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Stream<List<Category>> watchCategoriesForScope(String scopeId) {
    return (select(categories)
          ..where((t) => t.workspaceId.equals(scopeId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<Category?> getCategoryById(String id) {
    return (select(
      categories,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<Category?> findActiveCategoryByName({
    required String scopeId,
    required String normalizedName,
    required String type,
    String? excludingId,
  }) {
    final query = select(categories)
      ..where(
        (tbl) =>
            tbl.workspaceId.equals(scopeId) &
            tbl.type.equals(type) &
            tbl.deletedAt.isNull() &
            tbl.name.lower().equals(normalizedName),
      );
    if (excludingId != null) {
      query.where((tbl) => tbl.id.isNotValue(excludingId));
    }
    return query.getSingleOrNull();
  }

  Future<void> upsertCategory(CategoriesCompanion category) {
    return into(categories).insertOnConflictUpdate(category);
  }

  Future<int> countTransactionsUsingCategory(String categoryId) {
    final countExpression = transactions.id.count();
    return (selectOnly(transactions)
          ..addColumns([countExpression])
          ..where(
            transactions.categoryId.equals(categoryId) &
                transactions.deletedAt.isNull(),
          ))
        .map((row) => row.read(countExpression) ?? 0)
        .getSingle();
  }
}
