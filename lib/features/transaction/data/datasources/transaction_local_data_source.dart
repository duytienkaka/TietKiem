import '../../../../core/database/app_database.dart';

class TransactionLocalDataSource {
  const TransactionLocalDataSource(this._dao);

  final TransactionDao _dao;

  Stream<List<Transaction>> watchTransactions() => _dao.watchTransactions();

  Future<List<Transaction>> getTransactions() => _dao.getTransactions();

  Future<Transaction?> getTransactionById(String id) => _dao.getTransactionById(id);

  Future<void> insertTransaction(TransactionsCompanion transaction) =>
      _dao.insertTransaction(transaction);
}
