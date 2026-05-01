class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.title,
    required this.walletId,
    required this.targetAmount,
    required this.targetDate,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String title;
  final String walletId;
  final double targetAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final String? note;

  SavingsGoal copyWith({
    String? id,
    String? title,
    String? walletId,
    double? targetAmount,
    DateTime? targetDate,
    DateTime? createdAt,
    String? note,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      walletId: walletId ?? this.walletId,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
    );
  }

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      walletId: json['walletId'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      targetDate: DateTime.parse(json['targetDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'walletId': walletId,
      'targetAmount': targetAmount,
      'targetDate': targetDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'note': note,
    };
  }
}
