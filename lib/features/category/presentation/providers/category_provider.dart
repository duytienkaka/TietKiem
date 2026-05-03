import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../shared/finance_enums.dart';
import '../../data/repositories/category_repository_factory.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>(
  createCategoryRepository,
);

final categoryProvider =
    AsyncNotifierProvider<CategoryNotifier, List<Category>>(
      CategoryNotifier.new,
    );

class CategoryNotifier extends AsyncNotifier<List<Category>> {
  StreamSubscription<List<Category>>? _subscription;
  static const _uuid = Uuid();

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

  List<Category> categoriesForWallet(String walletId, {TransactionType? type}) {
    final categories = state.valueOrNull ?? const <Category>[];
    return categories.where((item) {
        if (item.workspaceId != walletId) {
          return false;
        }
        return type == null || item.type == type;
      }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<void> saveCategory({
    String? id,
    required String walletId,
    required String name,
    required TransactionType type,
    required String icon,
  }) async {
    final trimmedName = name.trim();
    final trimmedIcon = icon.trim();
    if (trimmedName.isEmpty) {
      throw const AppException('Category name is required.');
    }
    if (trimmedIcon.isEmpty) {
      throw const AppException('Category icon is required.');
    }

    final existing = id == null
        ? null
        : state.valueOrNull?.where((item) => item.id == id).firstOrNull;
    final now = DateTime.now().toUtc();
    final category = Category(
      id: id ?? _uuid.v4(),
      workspaceId: walletId,
      name: trimmedName,
      type: type,
      icon: trimmedIcon,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      deletedAt: existing?.deletedAt,
    );

    await _repository.saveCategory(category);
  }

  Future<void> deleteCategory(String id) => _repository.deleteCategory(id);
}
