import '../../../../core/database/app_database.dart' as db;
import '../../../../core/error/app_exception.dart';
import '../../../../shared/finance_enums.dart';
import '../../../wallet/data/models/wallet_model.dart';
import '../../domain/entities/finance_transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_data_source.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(this._database, this._localDataSource);

  final db.AppDatabase _database;
  final TransactionLocalDataSource _localDataSource;

  @override
  Stream<List<FinanceTransaction>> watchTransactions() {
    return _localDataSource.watchTransactions().map(
          (items) => items
              .map((item) => TransactionModel.fromData(item).toEntity())
              .toList(),
        );
  }

  @override
  Future<List<FinanceTransaction>> getTransactions() async {
    final items = await _localDataSource.getTransactions();
    return items.map((item) => TransactionModel.fromData(item).toEntity()).toList();
  }

  @override
  Future<FinanceTransaction?> getTransactionById(String id) async {
    final item = await _localDataSource.getTransactionById(id);
    return item == null ? null : TransactionModel.fromData(item).toEntity();
  }

  @override
  Future<void> saveTransaction(FinanceTransaction transaction) async {
    _validateTransaction(transaction);

    await _database.transaction(() async {
      final existingData = await _localDataSource.getTransactionById(transaction.id);
      if (existingData != null) {
        final existing = TransactionModel.fromData(existingData).toEntity();
        await _applyBalanceImpact(existing, reverse: true);
      }

      await _applyBalanceImpact(transaction);
      await _localDataSource.upsertTransaction(
        TransactionModel.fromEntity(transaction).toCompanion(),
      );
    });
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _database.transaction(() async {
      final existingData = await _localDataSource.getTransactionById(id);
      if (existingData == null) {
        return;
      }

      final existing = TransactionModel.fromData(existingData).toEntity();
      await _applyBalanceImpact(existing, reverse: true);
      await _localDataSource.deleteTransaction(id);
    });
  }

  void _validateTransaction(FinanceTransaction transaction) {
    if (transaction.amount <= 0) {
      throw const AppException('Amount must be greater than zero.');
    }

    if (transaction.type == TransactionType.transfer) {
      if (transaction.targetWalletId == null || transaction.targetWalletId!.isEmpty) {
        throw const AppException('Select a target wallet for transfer.');
      }
      if (transaction.targetWalletId == transaction.walletId) {
        throw const AppException('Transfer wallets must be different.');
      }
    }
  }

  Future<void> _applyBalanceImpact(
    FinanceTransaction transaction, {
    bool reverse = false,
  }) async {
    final source = await _database.walletDao.getWalletById(transaction.walletId);
    if (source == null) {
      throw const AppException('Source wallet not found.');
    }

    final multiplier = reverse ? -1.0 : 1.0;

    switch (transaction.type) {
      case TransactionType.income:
        await _updateWalletBalance(source, source.balance + (transaction.amount * multiplier));
      case TransactionType.expense:
        await _updateWalletBalance(source, source.balance - (transaction.amount * multiplier));
      case TransactionType.transfer:
        final targetId = transaction.targetWalletId;
        final target = targetId == null
            ? null
            : await _database.walletDao.getWalletById(targetId);
        if (target == null) {
          throw const AppException('Target wallet not found.');
        }

        await _updateWalletBalance(
          source,
          source.balance - (transaction.amount * multiplier),
        );
        await _updateWalletBalance(
          target,
          target.balance + (transaction.amount * multiplier),
        );
    }
  }

  Future<void> _updateWalletBalance(db.Wallet dbWallet, double nextBalance) async {
    final entity = WalletModel.fromData(dbWallet).toEntity().copyWith(balance: nextBalance);
    await _database.walletDao.upsertWallet(WalletModel.fromEntity(entity).toCompanion());
  }
}
