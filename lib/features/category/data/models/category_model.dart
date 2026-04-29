import 'package:drift/drift.dart' as drift;

import '../../../../core/database/app_database.dart' as db;
import '../../../../shared/finance_enums.dart';
import '../../domain/entities/category.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.type,
    required this.icon,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String workspaceId;
  final String name;
  final TransactionType type;
  final String icon;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      workspaceId: category.workspaceId,
      name: category.name,
      type: category.type,
      icon: category.icon,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
      deletedAt: category.deletedAt,
    );
  }

  factory CategoryModel.fromData(db.Category data) {
    return CategoryModel(
      id: data.id,
      workspaceId: data.workspaceId,
      name: data.name,
      type: TransactionType.values.byName(data.type),
      icon: data.icon,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      deletedAt: data.deletedAt,
    );
  }

  Category toEntity() => Category(
        id: id,
        workspaceId: workspaceId,
        name: name,
        type: type,
        icon: icon,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  db.CategoriesCompanion toCompanion() {
    return db.CategoriesCompanion.insert(
      id: id,
      workspaceId: workspaceId,
      name: name,
      type: type.name,
      icon: icon,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: drift.Value(deletedAt),
    );
  }

  Map<String, dynamic> toRemoteJson() {
    return {
      'id': id,
      'wallet_id': workspaceId,
      'name': name,
      'type': type.name,
      'icon': icon,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }
}
