import '../entities/category.dart';

abstract class CategoryRepository {
  Stream<List<Category>> watchCategories();

  Future<List<Category>> getCategories();

  Future<Category?> getCategoryById(String id);
}
