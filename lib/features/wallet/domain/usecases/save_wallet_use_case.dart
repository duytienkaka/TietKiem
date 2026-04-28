import '../entities/wallet.dart';
import '../repositories/wallet_repository.dart';

class SaveWalletUseCase {
  const SaveWalletUseCase(this._repository);

  final WalletRepository _repository;

  Future<void> call(Wallet wallet) => _repository.saveWallet(wallet);
}
