part of 'app_database.dart';

@DriftAccessor(tables: [Transactions])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  Stream<List<Transaction>> watchTransactions() {
    return (select(transactions)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<List<Transaction>> getTransactions() {
    return (select(transactions)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<Transaction?> getTransactionById(String id) {
    return (select(transactions)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> upsertTransaction(TransactionsCompanion transaction) async {
    await into(transactions).insertOnConflictUpdate(transaction);
  }

  Future<int> deleteTransactionById(String id) {
    return (delete(transactions)..where((tbl) => tbl.id.equals(id))).go();
  }
}
