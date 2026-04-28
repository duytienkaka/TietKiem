import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_local_data_source.dart';
import 'wallet_repository_impl.dart';

WalletRepository createWalletRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  final localDataSource = WalletLocalDataSource(database.walletDao);
  return WalletRepositoryImpl(database, localDataSource);
}
