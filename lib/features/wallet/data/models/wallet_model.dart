import 'package:drift/drift.dart' as drift;

import '../../../../core/database/app_database.dart' as db;
import '../../../../shared/finance_enums.dart';
import '../../domain/entities/wallet.dart';

class WalletModel {
  const WalletModel({
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
    this.accountNumber,
    this.accountHolder,
    this.paymentNote,
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
  final String? accountNumber;
  final String? accountHolder;
  final String? paymentNote;
  final DateTime? deletedAt;

  factory WalletModel.fromEntity(Wallet wallet) {
    return WalletModel(
      id: wallet.id,
      workspaceId: wallet.workspaceId,
      name: wallet.name,
      type: wallet.type,
      balance: wallet.balance,
      color: wallet.color,
      icon: wallet.icon,
      createdAt: wallet.createdAt,
      updatedAt: wallet.updatedAt,
      bankName: wallet.bankName,
      accountNumber: wallet.accountNumber,
      accountHolder: wallet.accountHolder,
      paymentNote: wallet.paymentNote,
      deletedAt: wallet.deletedAt,
    );
  }

  factory WalletModel.fromData(db.Wallet data) {
    return WalletModel(
      id: data.id,
      workspaceId: data.workspaceId,
      name: data.name,
      type: WalletType.values.byName(data.type),
      balance: data.balance,
      color: data.color,
      icon: data.icon,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      bankName: data.bankName,
      accountNumber: data.accountNumber,
      accountHolder: data.accountHolder,
      paymentNote: data.paymentNote,
      deletedAt: data.deletedAt,
    );
  }

  Wallet toEntity() => Wallet(
    id: id,
    workspaceId: workspaceId,
    name: name,
    type: type,
    balance: balance,
    color: color,
    icon: icon,
    createdAt: createdAt,
    updatedAt: updatedAt,
    bankName: bankName,
    accountNumber: accountNumber,
    accountHolder: accountHolder,
    paymentNote: paymentNote,
    deletedAt: deletedAt,
  );

  db.WalletsCompanion toCompanion({bool includeLocalMetadata = true}) {
    return db.WalletsCompanion.insert(
      id: id,
      workspaceId: workspaceId,
      name: name,
      type: type.name,
      balance: balance,
      color: color,
      icon: icon,
      bankName: includeLocalMetadata
          ? drift.Value(bankName)
          : const drift.Value.absent(),
      accountNumber: includeLocalMetadata
          ? drift.Value(accountNumber)
          : const drift.Value.absent(),
      accountHolder: includeLocalMetadata
          ? drift.Value(accountHolder)
          : const drift.Value.absent(),
      paymentNote: includeLocalMetadata
          ? drift.Value(paymentNote)
          : const drift.Value.absent(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: drift.Value(deletedAt),
    );
  }

  Map<String, dynamic> toRemoteJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'balance': balance,
      'color': _toPostgresInt32(color),
      'icon': icon,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }

  static int _toPostgresInt32(int value) {
    final normalized = value & 0xFFFFFFFF;
    return normalized >= 0x80000000 ? normalized - 0x100000000 : normalized;
  }
}
