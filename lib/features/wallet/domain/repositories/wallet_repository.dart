import '../entities/wallet.dart';

abstract class WalletRepository {
  Stream<List<Wallet>> watchWallets();

  Future<List<Wallet>> getWallets();

  Future<Wallet?> getWalletById(String id);

  Future<void> saveWallet(Wallet wallet);

  Future<void> deleteWallet(String id);
}
