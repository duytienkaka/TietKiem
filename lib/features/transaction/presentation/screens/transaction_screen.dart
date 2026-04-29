import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tietkiem/features/transaction/presentation/screens/transaction_form_screen.dart';

import '../../../../l10n/l10n.dart';
import '../../../../shared/finance_enums.dart';
import '../../../../shared/widgets/animated_transaction_item.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/screen_top_header.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/skeleton_box.dart';
import '../../../../shared/widgets/state_transition_switcher.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../category/domain/entities/category.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../recurring/domain/entities/recurring_rule.dart';
import '../../../recurring/presentation/providers/recurring_provider.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_card_surface.dart';
import '../widgets/transaction_tile.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  final TextEditingController _searchController = TextEditingController();
  TransactionType? _selectedType;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionProvider);
    final walletsAsync = ref.watch(walletProvider);
    final categoriesAsync = ref.watch(categoryProvider);
    final recurringAsync = ref.watch(recurringProvider);
    final query = _searchController.text.trim().toLowerCase();
    final categoriesForRecurring = categoriesAsync.valueOrNull ?? [];

    return Scaffold(
      body: SafeArea(
        child: AsyncValueView(
          value: transactionsAsync,
          loadingBuilder: (_) => const _TransactionsLoadingState(),
          data: (transactions) => AsyncValueView(
            value: walletsAsync,
            loadingBuilder: (_) => const _TransactionsLoadingState(),
            data: (wallets) => AsyncValueView(
              value: categoriesAsync,
              loadingBuilder: (_) => const _TransactionsLoadingState(),
              data: (categories) {
                final filtered = transactions.where((transaction) {
                  final category = categories
                      .where((item) => item.id == transaction.categoryId)
                      .firstOrNull;
                  final matchesType =
                      _selectedType == null || transaction.type == _selectedType;
                  final target =
                      '${transaction.note ?? ''} '
                      '${category?.displayName(context) ?? ''}'.toLowerCase();
                  final matchesQuery = query.isEmpty || target.contains(query);
                  return matchesType && matchesQuery;
                }).toList();

                final hasFilters = query.isNotEmpty || _selectedType != null;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.only(bottom: 120),
                    children: [
                      ScreenTopHeader(
                        eyebrow: context.l10n.transactionsTitle,
                        title: context.l10n.activityFeed,
                        subtitle: context.l10n.searchFilterManage,
                        icon: Icons.receipt_long_rounded,
                      ),
                      const SizedBox(height: 16),
                      SectionHeader(
                        title: context.l10n.recurringTitle,
                        subtitle: context.l10n.recurringSubtitle,
                        actionLabel: context.l10n.add,
                        onAction: () => showTransactionEntrySheet(
                          context,
                          initialType: TransactionType.expense,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AsyncValueView(
                        value: recurringAsync,
                        loadingBuilder: (_) => const _RecurringLoadingState(),
                        data: (rules) => rules.isEmpty
                            ? EmptyState(
                                title: context.l10n.noRecurringYet,
                                message: context.l10n.createRecurringHint,
                                icon: Icons.repeat_rounded,
                                actionLabel: context.l10n.add,
                                onAction: () => showTransactionEntrySheet(
                                  context,
                                  initialType: TransactionType.expense,
                                ),
                              )
                            : _RecurringRuleList(
                                rules: rules,
                                categories: categoriesForRecurring,
                                onToggle: (id, isActive) => ref
                                    .read(recurringProvider.notifier)
                                    .toggleRule(id, isActive),
                                onDelete: (id) => ref
                                    .read(recurringProvider.notifier)
                                    .deleteRule(id),
                              ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: context.l10n.searchNoteOrCategory,
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: query.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 42,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _FilterPill(
                              label: context.l10n.all,
                              selected: _selectedType == null,
                              onTap: () => setState(() => _selectedType = null),
                            ),
                            const SizedBox(width: 8),
                            ...TransactionType.values.map(
                              (type) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _FilterPill(
                                  label: type.label(context),
                                  selected: _selectedType == type,
                                  onTap: () => setState(() => _selectedType = type),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (filtered.isEmpty)
                        StateTransitionSwitcher(
                          child: EmptyState(
                            key: const ValueKey('transactions-empty'),
                            title: context.l10n.noMatchingTransactions,
                            message: context.l10n.tryDifferentSearch,
                            icon: Icons.filter_alt_off_rounded,
                            actionLabel: context.l10n.clearFilters,
                            onAction: () {
                              _searchController.clear();
                              setState(() => _selectedType = null);
                            },
                          ),
                        )
                      else ...[
                        Row(
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(opacity: animation, child: child),
                              child: Text(
                                key: ValueKey(
                                  'results-${filtered.length}-${_selectedType?.name ?? 'all'}-$query',
                                ),
                                context.l10n.resultsCount(filtered.length),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            const Spacer(),
                            if (hasFilters)
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _selectedType = null);
                                },
                                child: Text(context.l10n.reset),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        StateTransitionSwitcher(
                          child: Column(
                            key: ValueKey(
                              'transactions-list-${filtered.length}-${_selectedType?.name ?? 'all'}-$query',
                            ),
                            children: [
                              for (var index = 0; index < filtered.length; index++) ...[
                                Builder(
                                  builder: (context) {
                                    final transaction = filtered[index];
                                    final wallet = wallets
                                        .where((item) => item.id == transaction.walletId)
                                        .firstOrNull;
                                    final targetWallet = wallets
                                        .where((item) =>
                                            item.id == transaction.targetWalletId)
                                        .firstOrNull;
                                    final category = categories
                                        .where((item) => item.id == transaction.categoryId)
                                        .firstOrNull;

                                    return AnimatedTransactionItem(
                                      index: index,
                                      child: TransactionCardSurface(
                                        transactionId: transaction.id,
                                        child: TransactionTile(
                                          transaction: transaction,
                                          wallet: wallet,
                                          targetWallet: targetWallet,
                                          category: category,
                                          onTap: () => context.pushNamed(
                                            'transactionDetail',
                                            pathParameters: {'id': transaction.id},
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (index != filtered.length - 1)
                                  const SizedBox(height: 10),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

}

class _RecurringRuleList extends StatelessWidget {
  const _RecurringRuleList({
    required this.rules,
    required this.categories,
    required this.onToggle,
    required this.onDelete,
  });

  final List<RecurringRule> rules;
  final List<Category> categories;
  final void Function(String id, bool isActive) onToggle;
  final void Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final rule in rules) ...[
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(
                    rule.type == TransactionType.income
                        ? Icons.south_west_rounded
                        : Icons.north_east_rounded,
                    size: 18,
                    color: rule.type == TransactionType.income
                        ? const Color(0xFF17B26A)
                        : const Color(0xFFF04438),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categories
                                .where((category) =>
                                    category.id == rule.categoryId)
                                .firstOrNull
                                ?.displayName(context) ??
                            context.l10n.unknown,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatCurrency(context, rule.amount),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${context.l10n.nextRunLabel}: '
                        '${formatDateTime(context, rule.nextRunAt)} • '
                        '${rule.interval.label(context)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Switch.adaptive(
                      value: rule.isActive,
                      onChanged: (value) => onToggle(rule.id, value),
                    ),
                    IconButton(
                      tooltip: context.l10n.delete,
                      onPressed: () => onDelete(rule.id),
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _RecurringLoadingState extends StatelessWidget {
  const _RecurringLoadingState();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonBox(width: 140, height: 16),
          SizedBox(height: 10),
          SkeletonBox(width: 220, height: 12),
          SizedBox(height: 12),
          SkeletonBox(width: 180, height: 12),
        ],
      ),
    );
  }
}

class _TransactionsLoadingState extends StatelessWidget {
  const _TransactionsLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        const ScreenTopHeaderSkeleton(),
        const SizedBox(height: 16),
        Row(
          children: const [
            SkeletonBox(width: 96, height: 18),
            Spacer(),
            SkeletonBox(width: 60, height: 18),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < 5; index++) ...[
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 330;
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: narrow ? 14 : 16,
                  vertical: narrow ? 12 : 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
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
                          SkeletonBox(width: narrow ? 122 : 150, height: 16),
                          const SizedBox(height: 8),
                          SkeletonBox(width: narrow ? 92 : 110, height: 14),
                          const SizedBox(height: 8),
                          SkeletonBox(width: narrow ? 108 : 130, height: 12),
                        ],
                      ),
                    ),
                    SizedBox(width: narrow ? 8 : 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SkeletonBox(width: 18, height: 18, shape: BoxShape.circle),
                        SizedBox(height: narrow ? 8 : 10),
                        SkeletonBox(width: narrow ? 68 : 84, height: 18),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          if (index != 4) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected ? Colors.white : const Color(0xFF344054),
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
