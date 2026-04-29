import 'package:drift/drift.dart' as drift;

import '../../../../core/database/app_database.dart' as db;
import '../../../../core/error/app_exception.dart';
import '../../../../shared/services/sync_queue_service.dart';
import '../../domain/entities/wallet.dart' as entity;
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_local_data_source.dart';
import '../models/wallet_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  const WalletRepositoryImpl(
    this._database,
    this._localDataSource,
    this._syncQueueService,
  );

  final db.AppDatabase _database;
  final WalletLocalDataSource _localDataSource;
  final SyncQueueService _syncQueueService;

  @override
  Stream<List<entity.Wallet>> watchWallets() {
    return _localDataSource.watchWallets().map(
          (items) => items.map((item) => WalletModel.fromData(item).toEntity()).toList(),
        );
  }

  @override
  Future<List<entity.Wallet>> getWallets() async {
    final items = await _localDataSource.getWallets();
    return items.map((item) => WalletModel.fromData(item).toEntity()).toList();
  }

  @override
  Future<entity.Wallet?> getWalletById(String id) async {
    final item = await _localDataSource.getWalletById(id);
    return item == null ? null : WalletModel.fromData(item).toEntity();
  }

  @override
  Future<void> saveWallet(entity.Wallet wallet) async {
    if (wallet.name.trim().isEmpty) {
      throw const AppException('Wallet name is required.');
    }

    final now = DateTime.now().toUtc();
    final nextWallet = wallet.copyWith(
      workspaceId: wallet.workspaceId.isEmpty ? wallet.id : wallet.workspaceId,
      updatedAt: now,
      clearDeletedAt: true,
    );
    final model = WalletModel.fromEntity(nextWallet);
    await _localDataSource.upsertWallet(model.toCompanion());
    await _syncQueueService.enqueueUpsert(
      workspaceId: nextWallet.id,
      tableName: 'wallets',
      recordId: nextWallet.id,
      payload: model.toRemoteJson(),
    );
  }

  @override
  Future<void> deleteWallet(String id) async {
    final linkedTransactions = await (_database.select(_database.transactions)
          ..where((tbl) => drift.Expression.or([
                tbl.walletId.equals(id),
                tbl.targetWalletId.equalsNullable(id),
              ]) & tbl.deletedAt.isNull()))
        .get();
    if (linkedTransactions.isNotEmpty) {
      throw const AppException(
        'This wallet has transactions and cannot be deleted.',
      );
    }

    final existing = await getWalletById(id);
    if (existing == null) {
      return;
    }
    final deletedWallet = existing.copyWith(
      workspaceId: existing.workspaceId.isEmpty ? existing.id : existing.workspaceId,
      updatedAt: DateTime.now().toUtc(),
      deletedAt: DateTime.now().toUtc(),
    );
    final model = WalletModel.fromEntity(deletedWallet);
    await _localDataSource.upsertWallet(model.toCompanion());
    await _syncQueueService.enqueueUpsert(
      workspaceId: deletedWallet.id,
      tableName: 'wallets',
      recordId: id,
      payload: model.toRemoteJson(),
    );
  }
}
