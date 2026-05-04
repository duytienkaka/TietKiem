import '../../../../shared/finance_enums.dart';

class Wallet {
  const Wallet({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.type,
    required this.balance,
    required this.color,
    required this.icon,
    required this.createdAt,
    required this.updatedAt,
    this.bankName,
    this.bankAliases,
    this.accountNumber,
    this.accountHolder,
    this.paymentNote,
    this.qrImagePath,
    this.qrPayload,
    this.deletedAt,
  });

  final String id;
  final String workspaceId;
  final String name;
  final WalletType type;
  final double balance;
  final int color;
  final String icon;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? bankName;
  final String? bankAliases;
  final String? accountNumber;
  final String? accountHolder;
  final String? paymentNote;
  final String? qrImagePath;
  final String? qrPayload;
  final DateTime? deletedAt;

  Wallet copyWith({
    String? id,
    String? workspaceId,
    String? name,
    WalletType? type,
    double? balance,
    int? color,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? bankName,
    String? bankAliases,
    String? accountNumber,
    String? accountHolder,
    String? paymentNote,
    String? qrImagePath,
    String? qrPayload,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Wallet(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bankName: bankName ?? this.bankName,
      bankAliases: bankAliases ?? this.bankAliases,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolder: accountHolder ?? this.accountHolder,
      paymentNote: paymentNote ?? this.paymentNote,
      qrImagePath: qrImagePath ?? this.qrImagePath,
      qrPayload: qrPayload ?? this.qrPayload,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
    );
  }
}
