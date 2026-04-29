import '../../../../shared/finance_enums.dart';

class RecurringRule {
  const RecurringRule({
    required this.id,
    required this.type,
    required this.amount,
    required this.walletId,
    required this.categoryId,
    required this.note,
    required this.status,
    required this.interval,
    required this.nextRunAt,
    required this.isActive,
    required this.createdAt,
    this.lastRunAt,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final String walletId;
  final String categoryId;
  final String? note;
  final TransactionStatus status;
  final RecurringInterval interval;
  final DateTime nextRunAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastRunAt;

  RecurringRule copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? walletId,
    String? categoryId,
    String? note,
    TransactionStatus? status,
    RecurringInterval? interval,
    DateTime? nextRunAt,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastRunAt,
  }) {
    return RecurringRule(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      walletId: walletId ?? this.walletId,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      status: status ?? this.status,
      interval: interval ?? this.interval,
      nextRunAt: nextRunAt ?? this.nextRunAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastRunAt: lastRunAt ?? this.lastRunAt,
    );
  }

  factory RecurringRule.fromJson(Map<String, dynamic> json) {
    return RecurringRule(
      id: json['id'] as String,
      type: TransactionType.values.byName(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      walletId: json['walletId'] as String,
      categoryId: json['categoryId'] as String,
      note: json['note'] as String?,
      status: TransactionStatus.values.byName(json['status'] as String),
      interval: RecurringInterval.values.byName(json['interval'] as String),
      nextRunAt: DateTime.parse(json['nextRunAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastRunAt: json['lastRunAt'] == null
          ? null
          : DateTime.parse(json['lastRunAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'walletId': walletId,
      'categoryId': categoryId,
      'note': note,
      'status': status.name,
      'interval': interval.name,
      'nextRunAt': nextRunAt.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastRunAt': lastRunAt?.toIso8601String(),
    };
  }
}
