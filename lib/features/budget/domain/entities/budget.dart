class Budget {
  const Budget({
    required this.categoryId,
    required this.monthKey,
    required this.amount,
  });

  final String categoryId;
  final String monthKey;
  final double amount;

  Budget copyWith({
    String? categoryId,
    String? monthKey,
    double? amount,
  }) {
    return Budget(
      categoryId: categoryId ?? this.categoryId,
      monthKey: monthKey ?? this.monthKey,
      amount: amount ?? this.amount,
    );
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      categoryId: json['categoryId'] as String,
      monthKey: json['monthKey'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'monthKey': monthKey,
      'amount': amount,
    };
  }
}
