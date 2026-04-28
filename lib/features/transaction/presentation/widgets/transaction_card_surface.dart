import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_card.dart';

class TransactionCardSurface extends StatelessWidget {
  const TransactionCardSurface({
    super.key,
    required this.transactionId,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  final String transactionId;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding,
      child: child,
    );
  }
}
