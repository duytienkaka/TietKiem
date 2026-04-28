import 'package:drift/drift.dart' as drift;

import '../../../../core/database/app_database.dart' as db;
import '../../../../core/error/app_exception.dart';
import '../../domain/entities/wallet.dart' as entity;
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_local_data_source.dart';
import '../models/wallet_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  const WalletRepositoryImpl(this._database, this._localDataSource);

  final db.AppDatabase _database;
  final WalletLocalDataSource _localDataSource;

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

    await _localDataSource.upsertWallet(WalletModel.fromEntity(wallet).toCompanion());
  }

  @override
  Future<void> deleteWallet(String id) async {
    final linkedTransactions = await (_database.select(_database.transactions)
          ..where((tbl) => drift.Expression.or([
                tbl.walletId.equals(id),
                tbl.targetWalletId.equalsNullable(id),
              ])))
        .get();
    if (linkedTransactions.isNotEmpty) {
      throw const AppException(
        'This wallet has transactions and cannot be deleted.',
      );
    }

    await _localDataSource.deleteWallet(id);
  }
}
