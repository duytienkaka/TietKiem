import '../../../../shared/finance_enums.dart';

enum NotificationImportStatus { pending, accepted, dismissed }

class NotificationImportEntry {
  const NotificationImportEntry({
    required this.id,
    required this.sourceKey,
    required this.packageName,
    required this.bankName,
    this.walletId,
    required this.amount,
    required this.inferredType,
    this.title,
    this.body,
    required this.status,
    required this.detectedAt,
    this.handledAt,
    this.createdTransactionId,
  });

  final String id;
  final String sourceKey;
  final String packageName;
  final String bankName;
  final String? walletId;
  final double amount;
  final TransactionType inferredType;
  final String? title;
  final String? body;
  final NotificationImportStatus status;
  final DateTime detectedAt;
  final DateTime? handledAt;
  final String? createdTransactionId;

  NotificationImportEntry copyWith({
    String? id,
    String? sourceKey,
    String? packageName,
    String? bankName,
    String? walletId,
    double? amount,
    TransactionType? inferredType,
    String? title,
    String? body,
    NotificationImportStatus? status,
    DateTime? detectedAt,
    DateTime? handledAt,
    String? createdTransactionId,
  }) {
    return NotificationImportEntry(
      id: id ?? this.id,
      sourceKey: sourceKey ?? this.sourceKey,
      packageName: packageName ?? this.packageName,
      bankName: bankName ?? this.bankName,
      walletId: walletId ?? this.walletId,
      amount: amount ?? this.amount,
      inferredType: inferredType ?? this.inferredType,
      title: title ?? this.title,
      body: body ?? this.body,
      status: status ?? this.status,
      detectedAt: detectedAt ?? this.detectedAt,
      handledAt: handledAt ?? this.handledAt,
      createdTransactionId: createdTransactionId ?? this.createdTransactionId,
    );
  }
}
