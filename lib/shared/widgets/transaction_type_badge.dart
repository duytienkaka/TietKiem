import 'package:flutter/material.dart';

import '../finance_enums.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';

class TransactionTypeBadge extends StatelessWidget {
  const TransactionTypeBadge(this.type, {super.key});

  final TransactionType type;

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (type) {
      TransactionType.income => (context.l10n.income, AppTheme.income, const Color(0xFFE8FFF3)),
      TransactionType.expense => (context.l10n.expense, AppTheme.expense, const Color(0xFFFFEBEA)),
      TransactionType.transfer => (context.l10n.transfer, AppTheme.transfer, const Color(0xFFEAF4FF)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
