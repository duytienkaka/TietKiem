import '../entities/category.dart';

abstract class CategoryRepository {
  Stream<List<Category>> watchCategories();

  Stream<List<Category>> watchCategoriesForWallet(String walletId);

  Future<List<Category>> getCategories();

  Future<List<Category>> getCategoriesForWallet(String walletId);

  Future<Category?> getCategoryById(String id);

  Future<void> saveCategory(Category category);

  Future<void> deleteCategory(String id);
}
