import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_data_source.dart';
import 'transaction_repository_impl.dart';

TransactionRepository createTransactionRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  final localDataSource = TransactionLocalDataSource(database.transactionDao);
  return TransactionRepositoryImpl(database, localDataSource);
}
