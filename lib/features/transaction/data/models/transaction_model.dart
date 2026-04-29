import 'package:drift/drift.dart' as drift;

import '../../../../core/database/app_database.dart' as db;
import '../../../../shared/finance_enums.dart';
import '../../domain/entities/finance_transaction.dart';

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.workspaceId,
    required this.type,
    required this.amount,
    required this.walletId,
    this.targetWalletId,
    required this.categoryId,
    this.note,
    this.imagePath,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String workspaceId;
  final TransactionType type;
  final double amount;
  final String walletId;
  final String? targetWalletId;
  final String categoryId;
  final String? note;
  final String? imagePath;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  factory TransactionModel.fromEntity(FinanceTransaction transaction) {
    return TransactionModel(
      id: transaction.id,
      workspaceId: transaction.workspaceId,
      type: transaction.type,
      amount: transaction.amount,
      walletId: transaction.walletId,
      targetWalletId: transaction.targetWalletId,
      categoryId: transaction.categoryId,
      note: transaction.note,
      imagePath: transaction.imagePath,
      status: transaction.status,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
      deletedAt: transaction.deletedAt,
    );
  }

  factory TransactionModel.fromData(db.Transaction data) {
    return TransactionModel(
      id: data.id,
      workspaceId: data.workspaceId,
      type: TransactionType.values.byName(data.type),
      amount: data.amount,
      walletId: data.walletId,
      targetWalletId: data.targetWalletId,
      categoryId: data.categoryId ?? 'transfer',
      note: data.note,
      imagePath: data.imagePath,
      status: TransactionStatus.values.byName(data.status),
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      deletedAt: data.deletedAt,
    );
  }

  FinanceTransaction toEntity() => FinanceTransaction(
        id: id,
        workspaceId: workspaceId,
        type: type,
        amount: amount,
        walletId: walletId,
        targetWalletId: targetWalletId,
        categoryId: categoryId,
        note: note,
        imagePath: imagePath,
        status: status,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  db.TransactionsCompanion toCompanion() {
    return db.TransactionsCompanion.insert(
      id: id,
      workspaceId: workspaceId,
      type: type.name,
      amount: amount,
      walletId: walletId,
      targetWalletId: drift.Value(targetWalletId),
      categoryId: type == TransactionType.transfer
          ? const drift.Value(null)
          : drift.Value(categoryId),
      note: drift.Value(note),
      imagePath: drift.Value(imagePath),
      status: status.name,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: drift.Value(deletedAt),
    );
  }

  Map<String, dynamic> toRemoteJson() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'wallet_id': walletId,
      'target_wallet_id': targetWalletId,
      'category_id': type == TransactionType.transfer ? null : categoryId,
      'note': note,
      'image_path': imagePath,
      'status': status.name,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }
}
