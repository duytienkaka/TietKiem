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
        deletedAt: deletedAt,
      );

  db.WalletsCompanion toCompanion() {
    return db.WalletsCompanion.insert(
      id: id,
      workspaceId: workspaceId,
      name: name,
      type: type.name,
      balance: balance,
      color: color,
      icon: icon,
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
