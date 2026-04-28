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

  TransactionRepository get _repository => ref.read(transactionRepositoryProvider);

  @override
  Future<List<FinanceTransaction>> build() async {
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

  Future<void> addTransaction({
    required TransactionType type,
    required double amount,
    required String walletId,
    String? targetWalletId,
    required String categoryId,
    String? note,
    String? imagePath,
    required TransactionStatus status,
  }) async {
    if (amount <= 0) {
      throw const AppException('Amount must be greater than zero.');
    }

    final transaction = FinanceTransaction(
      id: const Uuid().v4(),
      type: type,
      amount: amount,
      walletId: walletId,
      targetWalletId: type == TransactionType.transfer ? targetWalletId : null,
      categoryId: type == TransactionType.transfer ? 'transfer' : categoryId,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
      imagePath: imagePath,
      status: status,
      createdAt: DateTime.now(),
    );

    await _repository.addTransaction(transaction);
  }
}
