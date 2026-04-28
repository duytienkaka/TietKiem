import 'package:drift/drift.dart' as drift;

import '../../../../core/database/app_database.dart' as db;
import '../../../../shared/finance_enums.dart';
import '../../domain/entities/finance_transaction.dart';

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.walletId,
    this.targetWalletId,
    required this.categoryId,
    this.note,
    this.imagePath,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final String walletId;
  final String? targetWalletId;
  final String categoryId;
  final String? note;
  final String? imagePath;
  final TransactionStatus status;
  final DateTime createdAt;

  factory TransactionModel.fromEntity(FinanceTransaction transaction) {
    return TransactionModel(
      id: transaction.id,
      type: transaction.type,
      amount: transaction.amount,
      walletId: transaction.walletId,
      targetWalletId: transaction.targetWalletId,
      categoryId: transaction.categoryId,
      note: transaction.note,
      imagePath: transaction.imagePath,
      status: transaction.status,
      createdAt: transaction.createdAt,
    );
  }

  factory TransactionModel.fromData(db.Transaction data) {
    return TransactionModel(
      id: data.id,
      type: TransactionType.values.byName(data.type),
      amount: data.amount,
      walletId: data.walletId,
      targetWalletId: data.targetWalletId,
      categoryId: data.categoryId,
      note: data.note,
      imagePath: data.imagePath,
      status: TransactionStatus.values.byName(data.status),
      createdAt: data.createdAt,
    );
  }

  FinanceTransaction toEntity() => FinanceTransaction(
        id: id,
        type: type,
        amount: amount,
        walletId: walletId,
        targetWalletId: targetWalletId,
        categoryId: categoryId,
        note: note,
        imagePath: imagePath,
        status: status,
        createdAt: createdAt,
      );

  db.TransactionsCompanion toCompanion() {
    return db.TransactionsCompanion.insert(
      id: id,
      type: type.name,
      amount: amount,
      walletId: walletId,
      targetWalletId: drift.Value(targetWalletId),
      categoryId: categoryId,
      note: drift.Value(note),
      imagePath: drift.Value(imagePath),
      status: status.name,
      createdAt: createdAt,
    );
  }
}
