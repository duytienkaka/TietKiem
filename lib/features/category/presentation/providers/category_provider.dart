import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/category_repository_factory.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>(createCategoryRepository);

final categoryProvider =
    AsyncNotifierProvider<CategoryNotifier, List<Category>>(CategoryNotifier.new);

class CategoryNotifier extends AsyncNotifier<List<Category>> {
  StreamSubscription<List<Category>>? _subscription;

  CategoryRepository get _repository => ref.watch(categoryRepositoryProvider);

  @override
  Future<List<Category>> build() async {
    await _subscription?.cancel();
    final initial = await _repository.getCategories();
    _subscription = _repository.watchCategories().listen(
      (categories) => state = AsyncData(categories),
      onError: (Object error, StackTrace stackTrace) {
        state = AsyncError(error, stackTrace);
      },
    );
    ref.onDispose(() => _subscription?.cancel());
    return initial;
  }
}
