import '../../../../shared/finance_enums.dart';

class Category {
  const Category({
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

  Category copyWith({
    String? id,
    String? workspaceId,
    String? name,
    TransactionType? type,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Category(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
    );
  }
}
