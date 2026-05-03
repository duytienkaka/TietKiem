import '../../../../core/database/app_database.dart';

class CategoryLocalDataSource {
  const CategoryLocalDataSource(this._dao);

  final CategoryDao _dao;

  Stream<List<Category>> watchCategories() => _dao.watchCategories();

  Stream<List<Category>> watchCategoriesForScope(String scopeId) =>
      _dao.watchCategoriesForScope(scopeId);

  Future<List<Category>> getCategories() => _dao.getCategories();

  Future<List<Category>> getCategoriesForScope(String scopeId) =>
      _dao.getCategoriesForScope(scopeId);

  Future<Category?> getCategoryById(String id) => _dao.getCategoryById(id);

  Future<Category?> findActiveCategoryByName({
    required String scopeId,
    required String normalizedName,
    required String type,
    String? excludingId,
  }) => _dao.findActiveCategoryByName(
    scopeId: scopeId,
    normalizedName: normalizedName,
    type: type,
    excludingId: excludingId,
  );

  Future<int> countTransactionsUsingCategory(String categoryId) =>
      _dao.countTransactionsUsingCategory(categoryId);

  Future<void> upsertCategory(CategoriesCompanion category) =>
      _dao.upsertCategory(category);
}
