import '../../../../shared/finance_enums.dart';

class Wallet {
  const Wallet({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.color,
    required this.icon,
    required this.createdAt,
  });

  final String id;
  final String name;
  final WalletType type;
  final double balance;
  final int color;
  final String icon;
  final DateTime createdAt;

  Wallet copyWith({
    String? id,
    String? name,
    WalletType? type,
    double? balance,
    int? color,
    String? icon,
    DateTime? createdAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
