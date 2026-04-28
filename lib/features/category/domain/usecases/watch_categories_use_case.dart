import '../entities/category.dart';
import '../repositories/category_repository.dart';

class WatchCategoriesUseCase {
  const WatchCategoriesUseCase(this._repository);

  final CategoryRepository _repository;

  Stream<List<Category>> call() => _repository.watchCategories();
}
