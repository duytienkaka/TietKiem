import '../finance_enums.dart';

class DefaultCategorySeed {
  const DefaultCategorySeed({
    required this.slug,
    required this.type,
    required this.icon,
  });

  final String slug;
  final TransactionType type;
  final String icon;
}

const defaultCategorySeeds = <DefaultCategorySeed>[
  DefaultCategorySeed(
    slug: 'salary',
    type: TransactionType.income,
    icon: 'payments',
  ),
  DefaultCategorySeed(
    slug: 'bonus',
    type: TransactionType.income,
    icon: 'workspace_premium',
  ),
  DefaultCategorySeed(
    slug: 'gift',
    type: TransactionType.income,
    icon: 'redeem',
  ),
  DefaultCategorySeed(
    slug: 'food',
    type: TransactionType.expense,
    icon: 'restaurant',
  ),
  DefaultCategorySeed(
    slug: 'transport',
    type: TransactionType.expense,
    icon: 'directions_car',
  ),
  DefaultCategorySeed(
    slug: 'shopping',
    type: TransactionType.expense,
    icon: 'shopping_bag',
  ),
  DefaultCategorySeed(
    slug: 'bills',
    type: TransactionType.expense,
    icon: 'receipt_long',
  ),
  DefaultCategorySeed(
    slug: 'health',
    type: TransactionType.expense,
    icon: 'health_and_safety',
  ),
];
