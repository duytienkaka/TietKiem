part of 'app_database.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase> with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Stream<List<Category>> watchCategories() {
    return (select(categories)..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<List<Category>> getCategories() {
    return (select(categories)..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<Category?> getCategoryById(String id) {
    return (select(categories)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> upsertCategory(CategoriesCompanion category) {
    return into(categories).insertOnConflictUpdate(category);
  }
}
