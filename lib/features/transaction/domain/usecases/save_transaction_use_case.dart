import '../entities/finance_transaction.dart';
import '../repositories/transaction_repository.dart';

class SaveTransactionUseCase {
  const SaveTransactionUseCase(this._repository);

  final TransactionRepository _repository;

  Future<void> call(FinanceTransaction transaction) =>
      _repository.saveTransaction(transaction);
}
