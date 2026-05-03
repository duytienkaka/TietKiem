import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/finance_enums.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/receipt_image.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/skeleton_box.dart';
import '../../domain/entities/finance_transaction.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_hero_tags.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionProvider);
    final walletsAsync = ref.watch(walletProvider);
    final categoriesAsync = ref.watch(categoryProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: AsyncValueView(
        value: transactionsAsync,
        loadingBuilder: (_) => const _TransactionDetailLoadingState(),
        data: (transactions) => AsyncValueView(
          value: walletsAsync,
          loadingBuilder: (_) => const _TransactionDetailLoadingState(),
          data: (wallets) => AsyncValueView(
            value: categoriesAsync,
            loadingBuilder: (_) => const _TransactionDetailLoadingState(),
            data: (categories) {
              final transaction = transactions
                  .where((item) => item.id == transactionId)
                  .firstOrNull;
              if (transaction == null) {
                return ErrorState(
                  title: context.l10n.errorTitle,
                  message: context.l10n.transactionNotFound,
                );
              }

              final wallet = wallets
                  .where((item) => item.id == transaction.walletId)
                  .firstOrNull;
              final targetWallet = wallets
                  .where((item) => item.id == transaction.targetWalletId)
                  .firstOrNull;
              final category = categories
                  .where((item) => item.id == transaction.categoryId)
                  .firstOrNull;

              final accent = switch (transaction.type) {
                TransactionType.income => AppTheme.income,
                TransactionType.expense => AppTheme.expense,
                TransactionType.transfer => AppTheme.transfer,
              };
              final amountPrefix = transaction.type == TransactionType.expense
                  ? '-'
                  : transaction.type == TransactionType.income
                  ? '+'
                  : '';
              final iconName = transaction.type == TransactionType.transfer
                  ? 'swap_horiz'
                  : category?.icon ?? 'receipt_long';
              final categoryName = transaction.type == TransactionType.transfer
                  ? context.l10n.transfer
                  : category?.displayName(context) ??
                        transaction.type.label(context);

              return SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                _DetailHeader(
                                  transaction: transaction,
                                  accent: accent,
                                  amountText:
                                      '$amountPrefix${formatCurrency(context, transaction.amount)}',
                                  categoryName: categoryName,
                                  iconName: iconName,
                                  onBack: () =>
                                      Navigator.of(context).maybePop(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: _SectionCard(
                                    title: context.l10n.transactionInformation,
                                    child: Column(
                                      children: [
                                        _InfoRow(
                                          icon: Icons
                                              .account_balance_wallet_rounded,
                                          title: context.l10n.wallet,
                                          value:
                                              wallet?.name ??
                                              context.l10n.unknownWallet,
                                        ),
                                        const SizedBox(height: 14),
                                        _InfoRow(
                                          icon:
                                              transaction.type ==
                                                  TransactionType.transfer
                                              ? Icons.swap_horiz_rounded
                                              : Icons.grid_view_rounded,
                                          title:
                                              transaction.type ==
                                                  TransactionType.transfer
                                              ? context.l10n.targetWallet
                                              : context.l10n.category,
                                          value:
                                              transaction.type ==
                                                  TransactionType.transfer
                                              ? targetWallet?.name ??
                                                    context.l10n.noTargetWallet
                                              : categoryName,
                                        ),
                                        const SizedBox(height: 14),
                                        _InfoRow(
                                          icon: Icons.schedule_rounded,
                                          title: context.l10n.dateTime,
                                          value: formatDateTime(
                                            context,
                                            transaction.createdAt,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: _StatusControlCard(
                                    transaction: transaction,
                                    onConfirm:
                                        transaction.status ==
                                            TransactionStatus.verified
                                        ? null
                                        : () => _confirmTransaction(
                                            context,
                                            ref,
                                            transaction,
                                          ),
                                  ),
                                ),
                                if ((transaction.note ?? '').trim().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: _SectionCard(
                                      title: context.l10n.note,
                                      child: Text(
                                        transaction.note!.trim(),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge,
                                      ),
                                    ),
                                  ),
                                if (transaction.imagePath?.isNotEmpty == true)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: _SectionCard(
                                      title: context.l10n.receiptImage,
                                      child: GestureDetector(
                                        onTap: () => _openImagePreview(
                                          context,
                                          transaction.id,
                                          transaction.imagePath!,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          child: Hero(
                                            tag: transactionImageHeroTag(
                                              transaction.id,
                                            ),
                                            transitionOnUserGestures: true,
                                            child: ReceiptImage(
                                              source: transaction.imagePath!,
                                              height: 220,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _confirmTransaction(
    BuildContext context,
    WidgetRef ref,
    FinanceTransaction transaction,
  ) async {
    try {
      await ref
          .read(transactionProvider.notifier)
          .updateTransactionStatus(transaction.id, TransactionStatus.verified);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.transactionConfirmed)),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizeError(context, error))));
      }
    }
  }

  void _openImagePreview(
    BuildContext context,
    String transactionId,
    String imagePath,
  ) {
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.92),
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) =>
            _ImagePreviewPage(
              heroTag: transactionImageHeroTag(transactionId),
              imagePath: imagePath,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curve,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.transaction,
    required this.accent,
    required this.amountText,
    required this.categoryName,
    required this.iconName,
    required this.onBack,
  });

  final FinanceTransaction transaction;
  final Color accent;
  final String amountText;
  final String categoryName;
  final String iconName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accent,
          Color.alphaBlend(Colors.white.withValues(alpha: 0.08), accent),
          const Color(0xFF151B36),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: _TopActionButton(
                  icon: Icons.arrow_back_rounded,
                  onPressed: onBack,
                ),
              ),
              const Spacer(),
              _TransactionStatusBadge(
                status: transaction.status,
                heroTag: transactionStatusHeroTag(transaction.id),
                light: true,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Hero(
            tag: transactionIconHeroTag(transaction.id),
            transitionOnUserGestures: true,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: buildAdaptiveIcon(iconName, color: Colors.white, size: 34),
            ),
          ),
          const SizedBox(height: 16),
          Hero(
            tag: transactionTitleHeroTag(transaction.id),
            transitionOnUserGestures: true,
            child: Material(
              color: Colors.transparent,
              child: Text(
                categoryName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.96),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Hero(
            tag: transactionAmountHeroTag(transaction.id),
            transitionOnUserGestures: true,
            child: Material(
              color: Colors.transparent,
              child: Text(
                amountText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _HeaderTypeBadge(type: transaction.type),
        ],
      ),
    );
  }
}

class _StatusControlCard extends StatelessWidget {
  const _StatusControlCard({
    required this.transaction,
    required this.onConfirm,
  });

  final FinanceTransaction transaction;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: context.l10n.status,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TransactionStatusBadge(status: transaction.status),
          if (onConfirm != null) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onConfirm,
              icon: const Icon(Icons.verified_rounded),
              label: Text(context.l10n.confirmTransaction),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderTypeBadge extends StatelessWidget {
  const _HeaderTypeBadge({required this.type});

  final TransactionType type;

  @override
  Widget build(BuildContext context) {
    final label = type.label(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.tune_rounded, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionStatusBadge extends StatelessWidget {
  const _TransactionStatusBadge({
    required this.status,
    this.heroTag,
    this.light = false,
  });

  final TransactionStatus status;
  final String? heroTag;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final verified = status == TransactionStatus.verified;
    final background = light
        ? Colors.white.withValues(alpha: 0.14)
        : verified
        ? const Color(0xFFE8FFF3)
        : const Color(0xFFFFF4E5);
    final foreground = light
        ? Colors.white
        : verified
        ? AppTheme.income
        : const Color(0xFFB54708);

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified ? Icons.verified_rounded : Icons.hourglass_top_rounded,
            size: 16,
            color: foreground,
          ),
          const SizedBox(width: 6),
          Text(
            verified
                ? context.l10n.statusConfirmed
                : context.l10n.statusUnconfirmed,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (heroTag == null) {
      return badge;
    }

    return Hero(
      tag: heroTag!,
      transitionOnUserGestures: true,
      child: Material(color: Colors.transparent, child: badge),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 20, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopActionButton extends StatelessWidget {
  const _TopActionButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.16),
        foregroundColor: Colors.white,
      ),
      icon: Icon(icon),
    );
  }
}

class _TransactionDetailLoadingState extends StatelessWidget {
  const _TransactionDetailLoadingState();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: const [
          AppCard(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE11976), Color(0xFFB517F1), Color(0xFF151B36)],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    SkeletonBox(height: 44, width: 44, borderRadius: 16),
                    Spacer(),
                    SkeletonBox(width: 118, height: 32, borderRadius: 999),
                  ],
                ),
                SizedBox(height: 18),
                SkeletonBox(height: 76, width: 76, shape: BoxShape.circle),
                SizedBox(height: 18),
                SkeletonBox(width: 160, height: 22, borderRadius: 999),
                SizedBox(height: 10),
                SkeletonBox(width: 190, height: 36, borderRadius: 16),
                SizedBox(height: 16),
                SkeletonBox(width: 92, height: 32, borderRadius: 999),
              ],
            ),
          ),
          SizedBox(height: 16),
          _DetailSectionSkeleton(lines: 3),
          SizedBox(height: 16),
          _DetailSectionSkeleton(lines: 2),
        ],
      ),
    );
  }
}

class _DetailSectionSkeleton extends StatelessWidget {
  const _DetailSectionSkeleton({required this.lines});

  final int lines;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 150, height: 18),
          const SizedBox(height: 14),
          for (var index = 0; index < lines; index++) ...[
            Row(
              children: [
                const SkeletonBox(height: 40, width: 40, borderRadius: 14),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonBox(width: 80, height: 12),
                      const SizedBox(height: 6),
                      SkeletonBox(width: 160 - (index * 12), height: 16),
                    ],
                  ),
                ),
              ],
            ),
            if (index != lines - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _ImagePreviewPage extends StatelessWidget {
  const _ImagePreviewPage({required this.heroTag, required this.imagePath});

  final String heroTag;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.black.withValues(alpha: 0.9)),
            ),
          ),
          SafeArea(
            child: SizedBox.expand(
              child: Hero(
                tag: heroTag,
                transitionOnUserGestures: true,
                child: Material(
                  color: Colors.transparent,
                  child: InteractiveViewer(
                    minScale: 0.9,
                    maxScale: 4,
                    child: SizedBox.expand(
                      child: Center(
                        child: ReceiptImage(
                          source: imagePath,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: IconButton.filledTonal(
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
