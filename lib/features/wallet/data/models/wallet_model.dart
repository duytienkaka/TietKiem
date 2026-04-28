import '../../../../core/database/app_database.dart' as db;
import '../../../../shared/finance_enums.dart';
import '../../domain/entities/wallet.dart';

class WalletModel {
  const WalletModel({
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

  factory WalletModel.fromEntity(Wallet wallet) {
    return WalletModel(
      id: wallet.id,
      name: wallet.name,
      type: wallet.type,
      balance: wallet.balance,
      color: wallet.color,
      icon: wallet.icon,
      createdAt: wallet.createdAt,
    );
  }

  factory WalletModel.fromData(db.Wallet data) {
    return WalletModel(
      id: data.id,
      name: data.name,
      type: WalletType.values.byName(data.type),
      balance: data.balance,
      color: data.color,
      icon: data.icon,
      createdAt: data.createdAt,
    );
  }

  Wallet toEntity() => Wallet(
        id: id,
        name: name,
        type: type,
        balance: balance,
        color: color,
        icon: icon,
        createdAt: createdAt,
      );

  db.WalletsCompanion toCompanion() {
    return db.WalletsCompanion.insert(
      id: id,
      name: name,
      type: type.name,
      balance: balance,
      color: color,
      icon: icon,
      createdAt: createdAt,
    );
  }
}
