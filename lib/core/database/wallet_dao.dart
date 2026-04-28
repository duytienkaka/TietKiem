part of 'app_database.dart';

@DriftAccessor(tables: [Wallets])
class WalletDao extends DatabaseAccessor<AppDatabase> with _$WalletDaoMixin {
  WalletDao(super.db);

  Stream<List<Wallet>> watchWallets() {
    return (select(wallets)..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<List<Wallet>> getWallets() {
    return (select(wallets)..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<Wallet?> getWalletById(String id) {
    return (select(wallets)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsertWallet(WalletsCompanion wallet) {
    return into(wallets).insertOnConflictUpdate(wallet);
  }

  Future<int> deleteWalletById(String id) {
    return (delete(wallets)..where((tbl) => tbl.id.equals(id))).go();
  }
}
