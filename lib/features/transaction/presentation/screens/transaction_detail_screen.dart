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
import '../../../../shared/widgets/skeleton_box.dart';
import '../../domain/entities/finance_transaction.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_hero_tags.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionProvider);
    final walletsAsync = ref.watch(walletProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
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
                  : category?.displayName(context) ?? transaction.type.label(context);
              final statusLabel = transaction.status == TransactionStatus.verified
                  ? context.l10n.statusConfirmed
                  : context.l10n.statusUnconfirmed;

              return Scaffold(
                backgroundColor: Colors.transparent,
                body: Material(
                  color: const Color(0xFFF5F6FB),
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        elevation: 0,
                        backgroundColor: accent,
                        expandedHeight: 330,
                        leading: _TopActionButton(
                          icon: Icons.arrow_back_rounded,
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                          background: _HighlightHeader(
                            transactionId: transaction.id,
                            accent: accent,
                            amountText:
                                '$amountPrefix${formatCurrency(context, transaction.amount)}',
                            categoryName: categoryName,
                            iconName: iconName,
                            typeLabel: transaction.type.label(context),
                            statusLabel: statusLabel,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              _InfoCard(
                                transaction: transaction,
                                walletName: wallet?.name ?? context.l10n.unknownWallet,
                                targetWalletName: targetWallet?.name,
                                categoryName: categoryName,
                              ),
                              if ((transaction.note ?? '').trim().isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _SectionCard(
                                  title: context.l10n.note,
                                  child: Text(
                                    transaction.note!.trim(),
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: const Color(0xFF344054),
                                        ),
                                  ),
                                ),
                              ],
                              if (transaction.imagePath?.isNotEmpty == true) ...[
                                const SizedBox(height: 16),
                                _SectionCard(
                                  title: context.l10n.receiptImage,
                                  child: GestureDetector(
                                    onTap: () => _openImagePreview(
                                      context,
                                      transaction.id,
                                      transaction.imagePath!,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: Hero(
                                        tag: transactionImageHeroTag(transaction.id),
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
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
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
        pageBuilder: (context, animation, secondaryAnimation) => _ImagePreviewPage(
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

class _TransactionDetailLoadingState extends StatelessWidget {
  const _TransactionDetailLoadingState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: AppTheme.primary,
            expandedHeight: 330,
            leading: const _TopActionButton(
              icon: Icons.arrow_back_rounded,
              onPressed: null,
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE11976), Color(0xFFB517F1), Color(0xFF151B36)],
                ),
              ),
              child: const SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 72, 24, 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SkeletonBox(height: 76, width: 76, shape: BoxShape.circle),
                      SizedBox(height: 18),
                      SkeletonBox(width: 160, height: 22, borderRadius: 999),
                      SizedBox(height: 10),
                      SkeletonBox(width: 190, height: 36, borderRadius: 16),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SkeletonBox(width: 92, height: 32, borderRadius: 999),
                          SizedBox(width: 8),
                          SkeletonBox(width: 118, height: 32, borderRadius: 999),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                const [
                  _DetailSectionSkeleton(lines: 3),
                  SizedBox(height: 16),
                  _DetailSectionSkeleton(lines: 2),
                  SizedBox(height: 16),
                  _DetailImageSkeleton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightHeader extends StatelessWidget {
  const _HighlightHeader({
    required this.transactionId,
    required this.accent,
    required this.amountText,
    required this.categoryName,
    required this.iconName,
    required this.typeLabel,
    required this.statusLabel,
  });

  final String transactionId;
  final Color accent;
  final String amountText;
  final String categoryName;
  final String iconName;
  final String typeLabel;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent,
            Color.alphaBlend(Colors.white.withValues(alpha: 0.08), accent),
            const Color(0xFF151B36),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 72, 24, 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: transactionIconHeroTag(transactionId),
                transitionOnUserGestures: true,
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Icon(
                    resolveIcon(iconName),
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Hero(
                tag: transactionTitleHeroTag(transactionId),
                transitionOnUserGestures: true,
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    categoryName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.94),
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Hero(
                tag: transactionAmountHeroTag(transactionId),
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
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 10 * (1 - value)),
                    child: child,
                  ),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _HeaderBadge(
                      icon: Icons.tune_rounded,
                      label: typeLabel,
                    ),
                    _HeaderBadge(
                      icon: Icons.verified_rounded,
                      label: statusLabel,
                      heroTag: transactionStatusHeroTag(transactionId),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({
    required this.icon,
    required this.label,
    this.heroTag,
  });

  final IconData icon;
  final String label;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
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
      child: Material(
        color: Colors.transparent,
        child: badge,
      ),
    );
  }
}

class _ImagePreviewPage extends StatelessWidget {
  const _ImagePreviewPage({
    required this.heroTag,
    required this.imagePath,
  });

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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Hero(
                  tag: heroTag,
                  transitionOnUserGestures: true,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Material(
                      color: Colors.transparent,
                      child: InteractiveViewer(
                        minScale: 0.9,
                        maxScale: 4,
                        child: ReceiptImage(
                          source: imagePath,
                          width: double.infinity,
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
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.scale(scale: 0.92 + (0.08 * value), child: child),
                ),
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
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.transaction,
    required this.walletName,
    required this.targetWalletName,
    required this.categoryName,
  });

  final FinanceTransaction transaction;
  final String walletName;
  final String? targetWalletName;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: context.l10n.transactionInformation,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.account_balance_wallet_rounded,
            title: context.l10n.wallet,
            value: walletName,
          ),
          if (transaction.type == TransactionType.transfer) ...[
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.swap_horiz_rounded,
              title: context.l10n.targetWallet,
              value: targetWalletName ?? context.l10n.noTargetWallet,
            ),
          ] else ...[
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.grid_view_rounded,
              title: context.l10n.category,
              value: categoryName,
            ),
          ],
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.schedule_rounded,
            title: context.l10n.dateTime,
            value: formatDateTime(context, transaction.createdAt),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          child,
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
                      SkeletonBox(
                        width: 160 - (index * 12),
                        height: 16,
                      ),
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

class _DetailImageSkeleton extends StatelessWidget {
  const _DetailImageSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 128, height: 18),
          SizedBox(height: 14),
          SkeletonBox(height: 220, borderRadius: 18),
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
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF667085)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF98A2B3),
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF101828),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopActionButton extends StatelessWidget {
  const _TopActionButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: IconButton.filledTonal(
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.16),
            foregroundColor: Colors.white,
          ),
          icon: Icon(icon),
        ),
      ),
    );
  }
}
