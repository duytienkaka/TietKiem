import '../../../../core/error/app_exception.dart';
import '../../../../shared/services/sync_queue_service.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_data_source.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._localDataSource, this._syncQueueService);

  final CategoryLocalDataSource _localDataSource;
  final SyncQueueService _syncQueueService;

  @override
  Stream<List<Category>> watchCategories() {
    return _localDataSource.watchCategories().map(
      (items) =>
          items.map((item) => CategoryModel.fromData(item).toEntity()).toList(),
    );
  }

  @override
  Stream<List<Category>> watchCategoriesForWallet(String walletId) {
    return _localDataSource
        .watchCategoriesForScope(walletId)
        .map(
          (items) => items
              .map((item) => CategoryModel.fromData(item).toEntity())
              .toList(),
        );
  }

  @override
  Future<List<Category>> getCategories() async {
    final items = await _localDataSource.getCategories();
    return items
        .map((item) => CategoryModel.fromData(item).toEntity())
        .toList();
  }

  @override
  Future<List<Category>> getCategoriesForWallet(String walletId) async {
    final items = await _localDataSource.getCategoriesForScope(walletId);
    return items
        .map((item) => CategoryModel.fromData(item).toEntity())
        .toList();
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final item = await _localDataSource.getCategoryById(id);
    return item == null ? null : CategoryModel.fromData(item).toEntity();
  }

  @override
  Future<void> saveCategory(Category category) async {
    final trimmedName = category.name.trim();
    if (trimmedName.isEmpty) {
      throw const AppException('Category name is required.');
    }
    final icon = category.icon.trim();
    if (icon.isEmpty) {
      throw const AppException('Category icon is required.');
    }

    final existing = await _localDataSource.findActiveCategoryByName(
      scopeId: category.workspaceId,
      normalizedName: trimmedName.toLowerCase(),
      type: category.type.name,
      excludingId: category.id,
    );
    if (existing != null) {
      throw const AppException('This category already exists in the wallet.');
    }

    final next = category.copyWith(
      name: trimmedName,
      icon: icon,
      updatedAt: DateTime.now().toUtc(),
      clearDeletedAt: true,
    );
    final model = CategoryModel.fromEntity(next);
    await _localDataSource.upsertCategory(model.toCompanion());
    await _syncQueueService.enqueueUpsert(
      workspaceId: next.workspaceId,
      tableName: 'categories',
      recordId: next.id,
      payload: model.toRemoteJson(),
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    final existing = await getCategoryById(id);
    if (existing == null) {
      return;
    }

    final usageCount = await _localDataSource.countTransactionsUsingCategory(
      id,
    );
    if (usageCount > 0) {
      throw const AppException(
        'This category is in use and cannot be deleted.',
      );
    }

    final deleted = existing.copyWith(
      updatedAt: DateTime.now().toUtc(),
      deletedAt: DateTime.now().toUtc(),
    );
    final model = CategoryModel.fromEntity(deleted);
    await _localDataSource.upsertCategory(model.toCompanion());
    await _syncQueueService.enqueueUpsert(
      workspaceId: deleted.workspaceId,
      tableName: 'categories',
      recordId: deleted.id,
      payload: model.toRemoteJson(),
    );
  }
}
