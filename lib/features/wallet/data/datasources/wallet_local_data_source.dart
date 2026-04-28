import '../../../../core/database/app_database.dart';

class WalletLocalDataSource {
  const WalletLocalDataSource(this._dao);

  final WalletDao _dao;

  Stream<List<Wallet>> watchWallets() => _dao.watchWallets();

  Future<List<Wallet>> getWallets() => _dao.getWallets();

  Future<Wallet?> getWalletById(String id) => _dao.getWalletById(id);

  Future<void> upsertWallet(WalletsCompanion wallet) => _dao.upsertWallet(wallet);

  Future<void> deleteWallet(String id) => _dao.deleteWalletById(id);
}
