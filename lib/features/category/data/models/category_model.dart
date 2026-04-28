import '../../../../core/database/app_database.dart' as db;
import '../../../../shared/finance_enums.dart';
import '../../domain/entities/category.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
  });

  final String id;
  final String name;
  final TransactionType type;
  final String icon;

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      type: category.type,
      icon: category.icon,
    );
  }

  factory CategoryModel.fromData(db.Category data) {
    return CategoryModel(
      id: data.id,
      name: data.name,
      type: TransactionType.values.byName(data.type),
      icon: data.icon,
    );
  }

  Category toEntity() => Category(id: id, name: name, type: type, icon: icon);

  db.CategoriesCompanion toCompanion() {
    return db.CategoriesCompanion.insert(
      id: id,
      name: name,
      type: type.name,
      icon: icon,
    );
  }
}
