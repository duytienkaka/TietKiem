import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../shared/finance_enums.dart';
import '../../data/repositories/wallet_repository_factory.dart';
import '../../domain/entities/wallet.dart' as entity;
import '../../domain/repositories/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>(createWalletRepository);

final walletProvider =
    AsyncNotifierProvider<WalletNotifier, List<entity.Wallet>>(WalletNotifier.new);

class WalletNotifier extends AsyncNotifier<List<entity.Wallet>> {
  StreamSubscription<List<entity.Wallet>>? _subscription;

  WalletRepository get _repository => ref.read(walletRepositoryProvider);

  @override
  Future<List<entity.Wallet>> build() async {
    final initial = await _repository.getWallets();
    _subscription = _repository.watchWallets().listen(
      (wallets) => state = AsyncData(wallets),
      onError: (Object error, StackTrace stackTrace) {
        state = AsyncError(error, stackTrace);
      },
    );
    ref.onDispose(() => _subscription?.cancel());
    return initial;
  }

  Future<void> saveWallet({
    required String? id,
    required String name,
    required WalletType type,
    required double balance,
    required int color,
    required String icon,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const AppException('Wallet name is required.');
    }

    final existing =
        id == null ? null : state.valueOrNull?.where((item) => item.id == id).firstOrNull;

    final wallet = entity.Wallet(
      id: id ?? const Uuid().v4(),
      name: trimmedName,
      type: type,
      balance: balance,
      color: color,
      icon: icon,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    await _repository.saveWallet(wallet);
  }

  Future<void> deleteWallet(String id) => _repository.deleteWallet(id);
}
