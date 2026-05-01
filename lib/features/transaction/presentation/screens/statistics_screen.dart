import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/finance_enums.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/screen_top_header.dart';
import '../../../../shared/widgets/skeleton_box.dart';
import '../../../../shared/widgets/state_transition_switcher.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_card_surface.dart';
import '../widgets/transaction_tile.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  static const _chartColors = <Color>[
    Color(0xFFE11976),
    Color(0xFF7A5AF8),
    Color(0xFF2E90FA),
    Color(0xFF16B364),
    Color(0xFFF79009),
  ];

  String? _selectedMonthKey;

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionProvider);
    final categoriesAsync = ref.watch(categoryProvider);
    final walletsAsync = ref.watch(walletProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: AsyncValueView(
            value: transactionsAsync,
            loadingBuilder: (_) => const _StatisticsLoadingState(),
            data: (transactions) => AsyncValueView(
              value: categoriesAsync,
              loadingBuilder: (_) => const _StatisticsLoadingState(),
              data: (categories) => AsyncValueView(
                value: walletsAsync,
                loadingBuilder: (_) => const _StatisticsLoadingState(),
                data: (wallets) {
                  final monthKeys = transactions
                      .map((item) => _monthKey(item.createdAt))
                      .toSet()
                      .toList()
                    ..sort((a, b) => b.compareTo(a));
                  _selectedMonthKey ??=
                      monthKeys.isNotEmpty ? monthKeys.first : _monthKey(DateTime.now());
                  final activeMonthKey = _selectedMonthKey ?? _monthKey(DateTime.now());

                  final scopedTransactions = transactions
                      .where((item) => _monthKey(item.createdAt) == activeMonthKey)
                      .toList();
                  final reportTransactions = scopedTransactions
                      .where((item) => item.type != TransactionType.transfer)
                      .toList();

                  final expenseByCategory = <String, double>{};
                  var totalIncome = 0.0;
                  var totalExpense = 0.0;

                  for (final transaction in reportTransactions) {
                    if (transaction.type == TransactionType.income) {
                      totalIncome += transaction.amount;
                    } else {
                      totalExpense += transaction.amount;
                      expenseByCategory.update(
                        transaction.categoryId,
                        (value) => value + transaction.amount,
                        ifAbsent: () => transaction.amount,
                      );
                    }
                  }

                  final sections = expenseByCategory.entries.toList();
                  final balanceDelta = totalIncome - totalExpense;
                  final selectedDate = DateTime.parse('$activeMonthKey-01');
                  final previousKey = _monthKey(
                    DateTime(selectedDate.year, selectedDate.month - 1),
                  );
                  final previousExpense = transactions
                      .where((item) => _monthKey(item.createdAt) == previousKey)
                      .where((item) => item.type == TransactionType.expense)
                      .fold<double>(0, (sum, item) => sum + item.amount);
                  final topCategoryEntry = expenseByCategory.entries.fold<MapEntry<String, double>?>(
                    null,
                    (current, entry) =>
                        current == null || entry.value > current.value ? entry : current,
                  );
                  final drilldownTransactions = scopedTransactions.take(5).toList();

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 120),
                    children: [
                      ScreenTopHeader(
                        eyebrow: context.l10n.statisticsTitle,
                        title: context.l10n.insights,
                        subtitle: context.l10n.quickVisualOverview,
                        icon: Icons.pie_chart_rounded,
                      ),
                      if (monthKeys.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 42,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: monthKeys.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final key = monthKeys[index];
                              final date = DateTime.parse('$key-01');
                              final selected = _selectedMonthKey == key;
                              return _MonthPill(
                                label: formatMonthYear(context, date),
                                selected: selected,
                                onTap: () => setState(() => _selectedMonthKey = key),
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (reportTransactions.isNotEmpty)
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.spendingInsightsTitle,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _InsightTile(
                                      title: context.l10n.topCategory,
                                      value: topCategoryEntry == null
                                          ? context.l10n.noDataToChart
                                          : categories
                                                  .where((category) =>
                                                      category.id == topCategoryEntry.key)
                                                  .firstOrNull
                                                  ?.displayName(context) ??
                                              context.l10n.unknown,
                                      subtitle: topCategoryEntry == null
                                          ? context.l10n.addIncomeExpenseToReports
                                          : formatCurrency(
                                              context,
                                              topCategoryEntry.value,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _InsightTile(
                                      title: context.l10n.comparedToLastPeriod,
                                      value: previousExpense <= 0
                                          ? context.l10n.noPreviousPeriod
                                          : _formatDeltaLabel(
                                              context,
                                              totalExpense,
                                              previousExpense,
                                            ),
                                      subtitle: context.l10n.expense,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      if (reportTransactions.isNotEmpty) const SizedBox(height: 16),
                      StateTransitionSwitcher(
                        child: reportTransactions.isEmpty
                            ? EmptyState(
                                key: ValueKey('stats-empty-$activeMonthKey'),
                                title: context.l10n.noDataToChart,
                                message: context.l10n.addIncomeExpenseToReports,
                                icon: Icons.pie_chart_outline_rounded,
                              )
                            : Column(
                                key: ValueKey('stats-content-$activeMonthKey'),
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _MetricCard(
                                          title: context.l10n.income,
                                          value: formatCurrency(context, totalIncome),
                                          color: AppTheme.income,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _MetricCard(
                                          title: context.l10n.expense,
                                          value: formatCurrency(context, totalExpense),
                                          color: AppTheme.expense,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _MetricCard(
                                          title: context.l10n.net,
                                          value: formatCurrency(context, balanceDelta),
                                          color: balanceDelta >= 0
                                              ? AppTheme.transfer
                                              : AppTheme.expense,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  AppCard(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          context.l10n.expenseBreakdown,
                                          style: Theme.of(context).textTheme.titleLarge,
                                        ),
                                        const SizedBox(height: 18),
                                        SizedBox(
                                          height: 260,
                                          child: PieChart(
                                            PieChartData(
                                              sectionsSpace: 4,
                                              centerSpaceRadius: 56,
                                              sections: [
                                                for (var i = 0; i < sections.length; i++)
                                                  PieChartSectionData(
                                                    value: sections[i].value,
                                                    title:
                                                        '${((sections[i].value / totalExpense) * 100).round()}%',
                                                    radius: 92,
                                                    color: _chartColors[i % _chartColors.length],
                                                    titleStyle: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            duration: const Duration(milliseconds: 280),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: [
                                            for (var i = 0; i < sections.length; i++)
                                              _LegendChip(
                                                color: _chartColors[i % _chartColors.length],
                                                label: categories
                                                        .where((category) =>
                                                            category.id == sections[i].key)
                                                        .firstOrNull
                                                        ?.displayName(context) ??
                                                    context.l10n.unknown,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  AppCard(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          context.l10n.incomeVsExpense,
                                          style: Theme.of(context).textTheme.titleLarge,
                                        ),
                                        const SizedBox(height: 18),
                                        SizedBox(
                                          height: 240,
                                          child: BarChart(
                                            BarChartData(
                                              alignment: BarChartAlignment.spaceAround,
                                              gridData: const FlGridData(show: false),
                                              borderData: FlBorderData(show: false),
                                              titlesData: FlTitlesData(
                                                topTitles: const AxisTitles(
                                                  sideTitles: SideTitles(showTitles: false),
                                                ),
                                                rightTitles: const AxisTitles(
                                                  sideTitles: SideTitles(showTitles: false),
                                                ),
                                                leftTitles: const AxisTitles(
                                                  sideTitles: SideTitles(showTitles: false),
                                                ),
                                                bottomTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    getTitlesWidget: (value, meta) {
                                                      return Padding(
                                                        padding: const EdgeInsets.only(top: 8),
                                                        child: Text(
                                                          value == 0
                                                              ? context.l10n.income
                                                              : context.l10n.expense,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              barGroups: [
                                                BarChartGroupData(
                                                  x: 0,
                                                  barRods: [
                                                    BarChartRodData(
                                                      toY: totalIncome,
                                                      width: 34,
                                                      borderRadius:
                                                          BorderRadius.circular(16),
                                                      color: AppTheme.income,
                                                    ),
                                                  ],
                                                ),
                                                BarChartGroupData(
                                                  x: 1,
                                                  barRods: [
                                                    BarChartRodData(
                                                      toY: totalExpense,
                                                      width: 34,
                                                      borderRadius:
                                                          BorderRadius.circular(16),
                                                      color: AppTheme.expense,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            duration: const Duration(milliseconds: 280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (drilldownTransactions.isNotEmpty)
                                    AppCard(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            context.l10n.transactionsTitle,
                                            style:
                                                Theme.of(context).textTheme.titleLarge,
                                          ),
                                          const SizedBox(height: 12),
                                          for (var index = 0;
                                              index < drilldownTransactions.length;
                                              index++) ...[
                                            Builder(
                                              builder: (context) {
                                                final transaction =
                                                    drilldownTransactions[index];
                                                final wallet = wallets
                                                    .where((item) =>
                                                        item.id == transaction.walletId)
                                                    .firstOrNull;
                                                final targetWallet = wallets
                                                    .where((item) =>
                                                        item.id ==
                                                        transaction.targetWalletId)
                                                    .firstOrNull;
                                                final category = categories
                                                    .where((item) =>
                                                        item.id ==
                                                        transaction.categoryId)
                                                    .firstOrNull;

                                                return TransactionCardSurface(
                                                  transactionId: transaction.id,
                                                  child: TransactionTile(
                                                    transaction: transaction,
                                                    wallet: wallet,
                                                    targetWallet: targetWallet,
                                                    category: category,
                                                    onTap: () => context.pushNamed(
                                                      'transactionDetail',
                                                      pathParameters: {
                                                        'id': transaction.id,
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            if (index != drilldownTransactions.length - 1)
                                              const SizedBox(height: 10),
                                          ],
                                        ],
                                      ),
                                    ),
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

  String _formatDeltaLabel(BuildContext context, double current, double previous) {
    if (previous <= 0) {
      return context.l10n.noPreviousPeriod;
    }
    final delta = ((current - previous) / previous) * 100;
    final prefix = delta >= 0 ? '+' : '';
    return '$prefix${delta.toStringAsFixed(0)}%';
  }
}

class _StatisticsLoadingState extends StatelessWidget {
  const _StatisticsLoadingState();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 380;
        return ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            const ScreenTopHeaderSkeleton(),
            const SizedBox(height: 16),
            if (narrow)
              const Column(
                children: [
                  _MetricSkeletonCard(),
                  SizedBox(height: 10),
                  _MetricSkeletonCard(),
                  SizedBox(height: 10),
                  _MetricSkeletonCard(),
                ],
              )
            else
              const Row(
                children: [
                  Expanded(child: _MetricSkeletonCard()),
                  SizedBox(width: 10),
                  Expanded(child: _MetricSkeletonCard()),
                  SizedBox(width: 10),
                  Expanded(child: _MetricSkeletonCard()),
                ],
              ),
            const SizedBox(height: 18),
            _ChartSkeletonCard(height: narrow ? 220 : 260),
            const SizedBox(height: 16),
            _ChartSkeletonCard(height: narrow ? 200 : 240),
          ],
        );
      },
    );
  }
}

class _MonthPill extends StatelessWidget {
  const _MonthPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
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

class _MetricSkeletonCard extends StatelessWidget {
  const _MetricSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 10, height: 10, shape: BoxShape.circle),
          SizedBox(height: 10),
          SkeletonBox(width: 48, height: 12),
          SizedBox(height: 8),
          SkeletonBox(width: 74, height: 18),
        ],
      ),
    );
  }
}

class _ChartSkeletonCard extends StatelessWidget {
  const _ChartSkeletonCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 150, height: 18),
          const SizedBox(height: 18),
          SkeletonBox(height: height, borderRadius: 18),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

String _monthKey(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  return '${value.year}-$month';
}
