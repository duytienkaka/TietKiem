import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/l10n.dart';
import '../../../../shared/finance_enums.dart';
import '../../../../shared/widgets/animated_reveal.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/skeleton_box.dart';
import '../../../../shared/widgets/transaction_type_badge.dart';
import '../../../../shared/widgets/wallet_card.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../recurring/presentation/providers/recurring_provider.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_card_surface.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_form_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final ScrollController _scrollController;
  bool _collapsedHeader = false;
  bool _hasTrackedBalance = false;
  double _previousTotalBalance = 0;
  double _currentTotalBalance = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        final collapsed = _scrollController.hasClients && _scrollController.offset > 18;
        if (collapsed != _collapsedHeader && mounted) {
          setState(() => _collapsedHeader = collapsed);
        }
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(recurringProcessorProvider);
    final walletsAsync = ref.watch(walletProvider);
    final transactionsAsync = ref.watch(transactionProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: AsyncValueView(
            value: walletsAsync,
            loadingBuilder: (_) => const _HomeLoadingState(),
            data: (wallets) => AsyncValueView(
              value: transactionsAsync,
              loadingBuilder: (_) => const _HomeLoadingState(),
              data: (transactions) => AsyncValueView(
                value: categoriesAsync,
                loadingBuilder: (_) => const _HomeLoadingState(),
                data: (categories) {
                  final totalBalance =
                      wallets.fold<double>(0, (sum, item) => sum + item.balance);
                  if (!_hasTrackedBalance) {
                    _hasTrackedBalance = true;
                    _previousTotalBalance = totalBalance;
                    _currentTotalBalance = totalBalance;
                  } else if (totalBalance != _currentTotalBalance) {
                    _previousTotalBalance = _currentTotalBalance;
                    _currentTotalBalance = totalBalance;
                  }
                  final recentTransactions = transactions.take(5).toList();
                  final now = DateTime.now();

                  return ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 120),
                    children: [
                      AnimatedReveal(
                        child: _HomeHeader(
                          greeting: _greetingForHour(context, now.hour),
                          compact: _collapsedHeader,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedReveal(
                        child: SummaryCard(
                          greeting: _greetingForHour(context, now.hour),
                          previousBalance: _previousTotalBalance,
                          currentBalance: _currentTotalBalance,
                          walletCount: wallets.length,
                        ),
                      ),
                      const SizedBox(height: 18),
                      AnimatedReveal(
                        child: SectionHeader(
                          title: context.l10n.quickActions,
                          subtitle: context.l10n.trackCashflowOneTap,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedReveal(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final itemWidth = (constraints.maxWidth - 20) / 3;
                            return Row(
                              children: [
                                Expanded(
                                  child: _QuickActionButton(
                                    label: context.l10n.addIncome,
                                    icon: Icons.arrow_downward_rounded,
                                    color: const Color(0xFFE8FFF3),
                                    foreground: const Color(0xFF17B26A),
                                    minHeight: itemWidth.clamp(104, 136).toDouble(),
                                    onTap: () => showTransactionEntrySheet(
                                      context,
                                      initialType: TransactionType.income,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _QuickActionButton(
                                    label: context.l10n.addExpense,
                                    icon: Icons.arrow_upward_rounded,
                                    color: const Color(0xFFFFEBEA),
                                    foreground: const Color(0xFFF04438),
                                    minHeight: itemWidth.clamp(104, 136).toDouble(),
                                    onTap: () => showTransactionEntrySheet(
                                      context,
                                      initialType: TransactionType.expense,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _QuickActionButton(
                                    label: context.l10n.transfer,
                                    icon: Icons.swap_horiz_rounded,
                                    color: const Color(0xFFEAF4FF),
                                    foreground: const Color(0xFF2E90FA),
                                    minHeight: itemWidth.clamp(104, 136).toDouble(),
                                    onTap: () => showTransactionEntrySheet(
                                      context,
                                      initialType: TransactionType.transfer,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedReveal(
                        child: SectionHeader(
                          title: context.l10n.myWallets,
                          subtitle: context.l10n.swipeBalances,
                          actionLabel: context.l10n.viewAll,
                          onAction: () => context.goNamed('wallets'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (wallets.isEmpty)
                        EmptyState(
                          title: context.l10n.noWalletsYet,
                          message: context.l10n.createWalletStart,
                          icon: Icons.account_balance_wallet_rounded,
                          actionLabel: context.l10n.createWallet,
                          onAction: () => context.goNamed('wallets'),
                        )
                      else
                        AnimatedReveal(
                          child: SizedBox(
                            height: 194,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: wallets.length,
                              separatorBuilder: (_, _) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                return WalletCard(
                                  wallet: wallets[index],
                                  onTap: () => context.goNamed('wallets'),
                                );
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      AnimatedReveal(
                        child: SectionHeader(
                          title: context.l10n.recentActivity,
                          subtitle: context.l10n.latestMoneyMovements,
                          actionLabel: context.l10n.seeAll,
                          onAction: () => context.goNamed('transactions'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (recentTransactions.isEmpty)
                        EmptyState(
                          title: context.l10n.noTransactionsYet,
                          message: context.l10n.transactionsWillAppear,
                          icon: Icons.receipt_long_rounded,
                          actionLabel: context.l10n.addTransaction,
                          onAction: () => showTransactionEntrySheet(context),
                        )
                      else
                        AnimatedReveal(
                          child: Column(
                            children: [
                              for (var index = 0; index < recentTransactions.length; index++) ...[
                                Builder(
                                  builder: (context) {
                                    final transaction = recentTransactions[index];
                                    final wallet = wallets
                                        .where((item) => item.id == transaction.walletId)
                                        .firstOrNull;
                                    final targetWallet = wallets
                                        .where((item) => item.id == transaction.targetWalletId)
                                        .firstOrNull;
                                    final category = categories
                                        .where((item) => item.id == transaction.categoryId)
                                        .firstOrNull;

                                    return TransactionCardSurface(
                                      transactionId: transaction.id,
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              TransactionTypeBadge(transaction.type),
                                              const Spacer(),
                                              if (transaction.imagePath?.isNotEmpty == true)
                                                const Icon(Icons.verified_rounded, size: 18),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          TransactionTile(
                                            transaction: transaction,
                                            wallet: wallet,
                                            targetWallet: targetWallet,
                                            category: category,
                                            onTap: () => context.pushNamed(
                                              'transactionDetail',
                                              pathParameters: {'id': transaction.id},
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                if (index != recentTransactions.length - 1)
                                  const SizedBox(height: 10),
                              ],
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeLoadingState extends StatelessWidget {
  const _HomeLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFDF2F8), Color(0xFFF5F3FF), Color(0xFFEFF8FF)],
            ),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 132, height: 14, borderRadius: 999),
                    SizedBox(height: 10),
                    SkeletonBox(width: 176, height: 24),
                  ],
                ),
              ),
              SizedBox(width: 12),
              SkeletonBox(height: 44, width: 44, shape: BoxShape.circle),
              SizedBox(width: 10),
              SkeletonBox(height: 44, width: 44, borderRadius: 16),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE11976), Color(0xFFB517F1), Color(0xFF6A5AF9)],
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkeletonBox(width: 128, height: 18, borderRadius: 999),
                  Spacer(),
                  SkeletonBox(width: 76, height: 30, borderRadius: 999),
                ],
              ),
              SizedBox(height: 18),
              SkeletonBox(width: 96, height: 14, borderRadius: 999),
              SizedBox(height: 10),
              SkeletonBox(width: 190, height: 38, borderRadius: 16),
              SizedBox(height: 18),
              SkeletonBox(width: 220, height: 14, borderRadius: 999),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SkeletonBox(width: 124, height: 22),
        const SizedBox(height: 8),
        const SkeletonBox(width: 210, height: 14),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(child: _QuickActionSkeleton()),
            SizedBox(width: 10),
            Expanded(child: _QuickActionSkeleton()),
            SizedBox(width: 10),
            Expanded(child: _QuickActionSkeleton()),
          ],
        ),
        const SizedBox(height: 24),
        const SkeletonBox(width: 134, height: 22),
        const SizedBox(height: 8),
        const SkeletonBox(width: 190, height: 14),
        const SizedBox(height: 12),
        SizedBox(
          height: 194,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => const _WalletSkeletonCard(),
          ),
        ),
        const SizedBox(height: 24),
        const SkeletonBox(width: 152, height: 22),
        const SizedBox(height: 8),
        const SkeletonBox(width: 220, height: 14),
        const SizedBox(height: 12),
        for (var index = 0; index < 3; index++) ...[
          const _RecentTransactionSkeleton(),
          if (index != 2) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.greeting,
    required this.compact,
  });

  final String greeting;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _extractInitials(context.l10n.helloUser);
    return Container(
      padding: EdgeInsets.fromLTRB(16, compact ? 12 : 16, 16, compact ? 12 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDF2F8), Color(0xFFF5F3FF), Color(0xFFEFF8FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ) ??
                      const TextStyle(),
                  child: Text(greeting),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: compact ? 2 : 6),
                      Text(
                        context.l10n.helloUser,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: (compact
                                ? theme.textTheme.titleLarge
                                : theme.textTheme.headlineSmall)
                            ?.copyWith(
                              color: const Color(0xFF101828),
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _HeaderAvatarButton(
            tooltip: context.l10n.profileTitle,
            onTap: () => context.pushNamed('profile'),
            child: Container(
              width: compact ? 42 : 46,
              height: compact ? 42 : 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFE0F0), Color(0xFFF7D6FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFE11976),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _HeaderAvatarButton(
            tooltip: context.l10n.settingsTitle,
            onTap: () => context.pushNamed('settings'),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: compact ? 42 : 46,
                  height: compact ? 42 : 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.tune_rounded, color: Color(0xFF344054)),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    scale: compact ? 0.92 : 1,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF04438),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAvatarButton extends StatelessWidget {
  const _HeaderAvatarButton({
    required this.child,
    required this.onTap,
    required this.tooltip,
  });

  final Widget child;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}

class _QuickActionSkeleton extends StatelessWidget {
  const _QuickActionSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 96 || constraints.maxWidth < 92;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: compact ? 12 : 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              SkeletonBox(
                height: compact ? 38 : 44,
                width: compact ? 38 : 44,
                shape: BoxShape.circle,
              ),
              SizedBox(height: compact ? 8 : 10),
              SkeletonBox(width: compact ? 44 : 56, height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _WalletSkeletonCard extends StatelessWidget {
  const _WalletSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDDDFE8), Color(0xFFE8EAF2), Color(0xFFD6DAE8)],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 164;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkeletonBox(
                    height: compact ? 44 : 48,
                    width: compact ? 44 : 48,
                    shape: BoxShape.circle,
                  ),
                  const Spacer(),
                  SkeletonBox(
                    width: compact ? 68 : 74,
                    height: compact ? 24 : 28,
                    borderRadius: 999,
                  ),
                ],
              ),
              SizedBox(height: compact ? 16 : 22),
              SkeletonBox(
                width: compact ? 112 : 120,
                height: compact ? 16 : 18,
              ),
              const SizedBox(height: 8),
              SkeletonBox(
                width: compact ? 82 : 88,
                height: 14,
              ),
              const Spacer(),
              SkeletonBox(
                width: compact ? 136 : 148,
                height: compact ? 24 : 28,
              ),
              SizedBox(height: compact ? 8 : 12),
              SkeletonBox(
                width: compact ? 88 : 96,
                height: 12,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RecentTransactionSkeleton extends StatelessWidget {
  const _RecentTransactionSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 320;
        return Container(
          padding: EdgeInsets.all(narrow ? 14 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  SkeletonBox(
                    width: narrow ? 62 : 72,
                    height: 26,
                    borderRadius: 999,
                  ),
                  const Spacer(),
                  const SkeletonBox(width: 18, height: 18, shape: BoxShape.circle),
                ],
              ),
              SizedBox(height: narrow ? 8 : 10),
              Row(
                children: [
                  SkeletonBox(
                    height: narrow ? 42 : 48,
                    width: narrow ? 42 : 48,
                    shape: BoxShape.circle,
                  ),
                  SizedBox(width: narrow ? 10 : 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: narrow ? 124 : 150, height: 16),
                        const SizedBox(height: 8),
                        SkeletonBox(width: narrow ? 92 : 112, height: 14),
                        const SizedBox(height: 8),
                        SkeletonBox(width: narrow ? 112 : 134, height: 12),
                      ],
                    ),
                  ),
                  SizedBox(width: narrow ? 8 : 12),
                  SkeletonBox(width: narrow ? 64 : 82, height: 18),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

String _greetingForHour(BuildContext context, int hour) {
  if (hour < 12) return context.l10n.greetingMorning;
  if (hour < 18) return context.l10n.greetingAfternoon;
  return context.l10n.greetingEvening;
}

String _extractInitials(String name) {
  final cleaned = name
      .replaceAll(',', ' ')
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (cleaned.isEmpty) {
    return 'U';
  }
  if (cleaned.length == 1) {
    return cleaned.first.characters.first.toUpperCase();
  }
  return '${cleaned[cleaned.length - 2].characters.first}${cleaned.last.characters.first}'
      .toUpperCase();
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.foreground,
    required this.minHeight,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color foreground;
  final double minHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color,
              child: Icon(icon, color: foreground),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
