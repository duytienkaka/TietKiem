import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart' as uuid;

import '../../core/database/app_database.dart' as db;
import '../../core/database/database_provider.dart';
import '../../features/category/data/models/category_model.dart';
import '../../features/category/domain/entities/category.dart' as entity;
import '../constants/default_categories.dart';
import 'sync_queue_service.dart';

final walletBootstrapServiceProvider = Provider<WalletBootstrapService>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final queue = ref.watch(syncQueueServiceProvider);
  return WalletBootstrapService(
    database: database,
    queue: queue,
  );
});

class WalletBootstrapService {
  WalletBootstrapService({
    required this.database,
    required this.queue,
  });

  final db.AppDatabase database;
  final SyncQueueService queue;
  static const _uuid = uuid.Uuid();

  Future<void> ensureDefaultCategories(String walletId) async {
    final existing = await database.categoryDao.getCategoriesForScope(walletId);
    if (existing.isNotEmpty) {
      return;
    }

    final now = DateTime.now().toUtc();
    for (final seed in defaultCategorySeeds) {
      final category = entity.Category(
        id: _uuid.v5(
          uuid.Namespace.url.value,
          '$walletId:${seed.slug}:${seed.type.name}',
        ),
        workspaceId: walletId,
        name: seed.slug,
        type: seed.type,
        icon: seed.icon,
        createdAt: now,
        updatedAt: now,
      );
      final model = CategoryModel.fromEntity(category);
      await database.categoryDao.upsertCategory(model.toCompanion());
      await queue.enqueueUpsert(
        workspaceId: walletId,
        tableName: 'categories',
        recordId: category.id,
        payload: model.toRemoteJson(),
      );
    }
  }
}
