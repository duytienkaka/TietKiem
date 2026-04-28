import '../../../../shared/finance_enums.dart';

class FinanceTransaction {
  const FinanceTransaction({
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

  FinanceTransaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? walletId,
    String? targetWalletId,
    String? categoryId,
    String? note,
    String? imagePath,
    TransactionStatus? status,
    DateTime? createdAt,
  }) {
    return FinanceTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      walletId: walletId ?? this.walletId,
      targetWalletId: targetWalletId ?? this.targetWalletId,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
