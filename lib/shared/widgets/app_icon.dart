import 'package:flutter/material.dart';

final Map<String, IconData> appIconMap = {
  'account_balance_wallet': Icons.account_balance_wallet_rounded,
  'account_balance': Icons.account_balance_rounded,
  'savings': Icons.savings_rounded,
  'restaurant': Icons.restaurant_rounded,
  'directions_car': Icons.directions_car_rounded,
  'shopping_bag': Icons.shopping_bag_rounded,
  'receipt_long': Icons.receipt_long_rounded,
  'favorite': Icons.favorite_rounded,
  'work': Icons.work_rounded,
  'redeem': Icons.redeem_rounded,
  'stars': Icons.stars_rounded,
  'swap_horiz': Icons.swap_horiz_rounded,
};

IconData resolveIcon(String name) => appIconMap[name] ?? Icons.circle_rounded;
