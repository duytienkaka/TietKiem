import '../entities/finance_transaction.dart';

abstract class TransactionRepository {
  Stream<List<FinanceTransaction>> watchTransactions();

  Future<List<FinanceTransaction>> getTransactions();

  Future<FinanceTransaction?> getTransactionById(String id);

  Future<void> saveTransaction(FinanceTransaction transaction);

  Future<void> deleteTransaction(String id);
}
