import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../features/category/domain/entities/category.dart';
import '../../../../features/transaction/domain/entities/finance_transaction.dart';
import '../../../../features/wallet/domain/entities/wallet.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/finance_enums.dart';
import '../../../../shared/widgets/app_icon.dart';
import 'transaction_hero_tags.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.wallet,
    required this.category,
    this.targetWallet,
    this.onTap,
  });

  final FinanceTransaction transaction;
  final Wallet? wallet;
  final Wallet? targetWallet;
  final Category? category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (amountPrefix, amountColor, iconBg) = switch (transaction.type) {
      TransactionType.income => ('+', AppTheme.income, const Color(0xFFE8FFF3)),
      TransactionType.expense => (
        '-',
        AppTheme.expense,
        const Color(0xFFFFEBEA),
      ),
      TransactionType.transfer => (
        '',
        AppTheme.transfer,
        const Color(0xFFEAF4FF),
      ),
    };

    final title = transaction.type == TransactionType.transfer
        ? '${wallet?.name ?? context.l10n.unknown} '
              '-> ${targetWallet?.name ?? context.l10n.unknown}'
        : category?.displayName(context) ?? transaction.type.label(context);
    final statusLabel = transaction.status == TransactionStatus.verified
        ? context.l10n.statusConfirmed
        : context.l10n.statusUnconfirmed;
    final subtitle = (transaction.note ?? '').isNotEmpty
        ? transaction.note!
        : formatDateTime(context, transaction.createdAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            children: [
              Hero(
                tag: transactionIconHeroTag(transaction.id),
                transitionOnUserGestures: true,
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: iconBg,
                  child: buildAdaptiveIcon(
                    transaction.type == TransactionType.transfer
                        ? 'swap_horiz'
                        : category?.icon ?? 'receipt_long',
                    color: amountColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: transactionTitleHeroTag(transaction.id),
                      transitionOnUserGestures: true,
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${wallet?.name ?? context.l10n.unknownWallet} | '
                      '${formatDateTime(context, transaction.createdAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF98A2B3),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Hero(
                      tag: transactionStatusHeroTag(transaction.id),
                      transitionOnUserGestures: true,
                      child: Material(
                        color: Colors.transparent,
                        child: _StatusBadge(
                          label: statusLabel,
                          verified:
                              transaction.status == TransactionStatus.verified,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (transaction.imagePath?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Icon(
                        Icons.photo_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  Hero(
                    tag: transactionAmountHeroTag(transaction.id),
                    transitionOnUserGestures: true,
                    child: Material(
                      color: Colors.transparent,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 110),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            '$amountPrefix${formatCurrency(context, transaction.amount)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: amountColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.verified});

  final String label;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final background = verified
        ? const Color(0xFFE8FFF3)
        : const Color(0xFFFFF4E5);
    final foreground = verified ? AppTheme.income : const Color(0xFFB54708);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified ? Icons.verified_rounded : Icons.hourglass_top_rounded,
            size: 14,
            color: foreground,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
