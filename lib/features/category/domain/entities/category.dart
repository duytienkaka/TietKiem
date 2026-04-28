import '../../../../shared/finance_enums.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
  });

  final String id;
  final String name;
  final TransactionType type;
  final String icon;
}
