import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../shared/finance_enums.dart';
import '../../data/repositories/transaction_repository_factory.dart';
import '../../domain/entities/finance_transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

final transactionRepositoryProvider =
    Provider<TransactionRepository>(createTransactionRepository);

final transactionProvider = AsyncNotifierProvider<TransactionNotifier,
    List<FinanceTransaction>>(TransactionNotifier.new);

class TransactionNotifier extends AsyncNotifier<List<FinanceTransaction>> {
  StreamSubscription<List<FinanceTransaction>>? _subscription;

  TransactionRepository get _repository => ref.watch(transactionRepositoryProvider);

  @override
  Future<List<FinanceTransaction>> build() async {
    await _subscription?.cancel();
    final initial = await _repository.getTransactions();
    _subscription = _repository.watchTransactions().listen(
      (transactions) => state = AsyncData(transactions),
      onError: (Object error, StackTrace stackTrace) {
        state = AsyncError(error, stackTrace);
      },
    );
    ref.onDispose(() => _subscription?.cancel());
    return initial;
  }

  Future<String> saveTransaction({
    required String? id,
    required TransactionType type,
    required double amount,
    required String walletId,
    String? targetWalletId,
    required String categoryId,
    String? note,
    String? imagePath,
    required TransactionStatus status,
    DateTime? createdAt,
  }) async {
    if (amount <= 0) {
      throw const AppException('Amount must be greater than zero.');
    }

    final existing = id == null
        ? null
        : state.valueOrNull?.where((item) => item.id == id).firstOrNull;
    final now = DateTime.now().toUtc();

    final transaction = FinanceTransaction(
      id: id ?? const Uuid().v4(),
      workspaceId: existing?.workspaceId ?? '',
      type: type,
      amount: amount,
      walletId: walletId,
      targetWalletId: type == TransactionType.transfer ? targetWalletId : null,
      categoryId: type == TransactionType.transfer ? 'transfer' : categoryId,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
      imagePath: imagePath,
      status: status,
      createdAt: createdAt ?? existing?.createdAt ?? now,
      updatedAt: now,
    );

    await _repository.saveTransaction(transaction);
    return transaction.id;
  }

  Future<void> updateTransactionStatus(
    String id,
    TransactionStatus status,
  ) async {
    final existing = state.valueOrNull?.where((item) => item.id == id).firstOrNull;
    if (existing == null) {
      throw const AppException('Transaction not found.');
    }

    await _repository.saveTransaction(
      existing.copyWith(
        status: status,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> deleteTransaction(String id) => _repository.deleteTransaction(id);
}
