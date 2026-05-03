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
  'payments': Icons.payments_rounded,
  'workspace_premium': Icons.workspace_premium_rounded,
  'health_and_safety': Icons.health_and_safety_rounded,
};

IconData resolveIcon(String name) => appIconMap[name] ?? Icons.category_rounded;

bool hasMappedIcon(String name) => appIconMap.containsKey(name);

Widget buildAdaptiveIcon(
  String name, {
  Color? color,
  double size = 24,
  FontWeight fontWeight = FontWeight.w700,
}) {
  final trimmed = name.trim();
  if (hasMappedIcon(trimmed)) {
    return Icon(resolveIcon(trimmed), color: color, size: size);
  }

  final fallback = trimmed.isEmpty ? '🏷️' : trimmed;
  return Text(
    fallback,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: size * 0.9,
      height: 1,
      color: color,
      fontWeight: fontWeight,
    ),
  );
}
