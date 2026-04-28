import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_data_source.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._localDataSource);

  final CategoryLocalDataSource _localDataSource;

  @override
  Stream<List<Category>> watchCategories() {
    return _localDataSource.watchCategories().map(
          (items) =>
              items.map((item) => CategoryModel.fromData(item).toEntity()).toList(),
        );
  }

  @override
  Future<List<Category>> getCategories() async {
    final items = await _localDataSource.getCategories();
    return items.map((item) => CategoryModel.fromData(item).toEntity()).toList();
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final item = await _localDataSource.getCategoryById(id);
    return item == null ? null : CategoryModel.fromData(item).toEntity();
  }
}
