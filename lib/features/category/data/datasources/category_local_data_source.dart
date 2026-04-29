import '../../../../core/database/app_database.dart';

class CategoryLocalDataSource {
  const CategoryLocalDataSource(this._dao);

  final CategoryDao _dao;

  Stream<List<Category>> watchCategories() => _dao.watchCategories();

  Future<List<Category>> getCategories() => _dao.getCategories();

  Future<List<Category>> getCategoriesForScope(String scopeId) => _dao.getCategoriesForScope(scopeId);

  Future<Category?> getCategoryById(String id) => _dao.getCategoryById(id);

  Future<void> upsertCategory(CategoriesCompanion category) =>
      _dao.upsertCategory(category);
}
