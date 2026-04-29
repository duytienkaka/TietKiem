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
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/skeleton_box.dart';
import '../../../../shared/widgets/state_transition_switcher.dart';
import '../../../ai/domain/entities/monthly_spending_summary.dart';
import '../../../ai/presentation/providers/finance_ai_provider.dart';
import '../../../category/domain/entities/category.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../../domain/entities/finance_transaction.dart';
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
  bool _summaryLoading = false;
  String? _summaryMonthKey;
  MonthlySpendingSummary? _monthlySummary;

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
                  final monthKeys =
                      transactions
                          .map((item) => _monthKey(item.createdAt))
                          .toSet()
                          .toList()
                        ..sort((a, b) => b.compareTo(a));
                  _selectedMonthKey ??= monthKeys.isNotEmpty
                      ? monthKeys.first
                      : null;
                  final activeMonthKey =
                      _selectedMonthKey ?? _monthKey(DateTime.now());

                  final scopedTransactions = _selectedMonthKey == null
                      ? transactions
                      : transactions.where((item) {
                          return _monthKey(item.createdAt) == _selectedMonthKey;
                        }).toList();

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
                  final switcherKey = ValueKey(
                    _selectedMonthKey ?? 'all-months',
                  );
                  final drilldownTransactions = scopedTransactions
                      .take(5)
                      .toList();
                  final selectedDate = _selectedMonthKey == null
                      ? null
                      : DateTime.parse('${_selectedMonthKey!}-01');
                  final previousKey = selectedDate == null
                      ? null
                      : _monthKey(
                          DateTime(selectedDate.year, selectedDate.month - 1),
                        );
                  final previousTransactions = previousKey == null
                      ? <FinanceTransaction>[]
                      : transactions
                            .where(
                              (item) =>
                                  _monthKey(item.createdAt) == previousKey,
                            )
                            .toList();
                  final previousExpense = previousTransactions
                      .where((item) => item.type == TransactionType.expense)
                      .fold<double>(0, (sum, item) => sum + item.amount);
                  final topCategoryEntry = expenseByCategory.entries
                      .fold<MapEntry<String, double>?>(
                        null,
                        (current, entry) =>
                            current == null || entry.value > current.value
                            ? entry
                            : current,
                      );

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 120),
                    children: [
                      ScreenTopHeader(
                        eyebrow: context.l10n.statisticsTitle,
                        title: context.l10n.insights,
                        subtitle: context.l10n.quickVisualOverview,
                        icon: Icons.pie_chart_rounded,
                      ),
                      const SizedBox(height: 12),
                      if (monthKeys.isNotEmpty)
                        SizedBox(
                          height: 42,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: monthKeys.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final key = monthKeys[index];
                              final date = DateTime.parse('$key-01');
                              final selected = _selectedMonthKey == key;
                              return GestureDetector(
                                onTap: () => setState(() {
                                  _selectedMonthKey = key;
                                  _summaryMonthKey = null;
                                  _monthlySummary = null;
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppTheme.primary
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    formatMonthYear(context, date),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: selected
                                              ? Colors.white
                                              : const Color(0xFF344054),
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
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
                                                    .where(
                                                      (category) =>
                                                          category.id ==
                                                          topCategoryEntry.key,
                                                    )
                                                    .firstOrNull
                                                    ?.displayName(context) ??
                                                context.l10n.unknown,
                                      subtitle: topCategoryEntry == null
                                          ? context
                                                .l10n
                                                .addIncomeExpenseToReports
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
                      if (reportTransactions.isNotEmpty)
                        const SizedBox(height: 16),
                      StateTransitionSwitcher(
                        child: reportTransactions.isEmpty
                            ? EmptyState(
                                key: ValueKey(
                                  "stats-empty-${_selectedMonthKey ?? 'all'}",
                                ),
                                title: context.l10n.noDataToChart,
                                message: context.l10n.addIncomeExpenseToReports,
                                icon: Icons.pie_chart_outline_rounded,
                              )
                            : AnimatedSwitcher(
                                duration: const Duration(milliseconds: 240),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.02, 0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Column(
                                  key: switcherKey,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _MetricCard(
                                            title: context.l10n.income,
                                            value: formatCurrency(
                                              context,
                                              totalIncome,
                                            ),
                                            color: AppTheme.income,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _MetricCard(
                                            title: context.l10n.expense,
                                            value: formatCurrency(
                                              context,
                                              totalExpense,
                                            ),
                                            color: AppTheme.expense,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _MetricCard(
                                            title: context.l10n.net,
                                            value: formatCurrency(
                                              context,
                                              balanceDelta,
                                            ),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            context.l10n.expenseBreakdown,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleLarge,
                                          ),
                                          const SizedBox(height: 18),
                                          SizedBox(
                                            height: 260,
                                            child: RepaintBoundary(
                                              child: PieChart(
                                                PieChartData(
                                                  sectionsSpace: 4,
                                                  centerSpaceRadius: 56,
                                                  pieTouchData: PieTouchData(
                                                    enabled: true,
                                                  ),
                                                  sections: [
                                                    for (
                                                      var i = 0;
                                                      i < sections.length;
                                                      i++
                                                    )
                                                      PieChartSectionData(
                                                        value:
                                                            sections[i].value,
                                                        title:
                                                            '${((sections[i].value / totalExpense) * 100).round()}%',
                                                        radius: 92,
                                                        color:
                                                            _chartColors[i %
                                                                _chartColors
                                                                    .length],
                                                        titleStyle:
                                                            const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              fontSize: 12,
                                                            ),
                                                      ),
                                                  ],
                                                ),
                                                duration: const Duration(
                                                  milliseconds: 280,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Wrap(
                                            spacing: 10,
                                            runSpacing: 10,
                                            children: [
                                              for (
                                                var i = 0;
                                                i < sections.length;
                                                i++
                                              )
                                                _LegendChip(
                                                  color:
                                                      _chartColors[i %
                                                          _chartColors.length],
                                                  label: categories
                                                      .firstWhere(
                                                        (category) =>
                                                            category.id ==
                                                            sections[i].key,
                                                        orElse: () =>
                                                            categories.first,
                                                      )
                                                      .displayName(context),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    AppCard(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            context.l10n.incomeVsExpense,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleLarge,
                                          ),
                                          const SizedBox(height: 18),
                                          SizedBox(
                                            height: 240,
                                            child: RepaintBoundary(
                                              child: BarChart(
                                                BarChartData(
                                                  alignment: BarChartAlignment
                                                      .spaceAround,
                                                  maxY:
                                                      (totalIncome >
                                                              totalExpense
                                                          ? totalIncome
                                                          : totalExpense) *
                                                      1.2,
                                                  gridData: FlGridData(
                                                    show: true,
                                                    drawVerticalLine: false,
                                                    horizontalInterval:
                                                        ((totalIncome > totalExpense
                                                                    ? totalIncome
                                                                    : totalExpense) /
                                                                4)
                                                            .clamp(
                                                              1,
                                                              double.infinity,
                                                            )
                                                            .toDouble(),
                                                  ),
                                                  borderData: FlBorderData(
                                                    show: false,
                                                  ),
                                                  titlesData: FlTitlesData(
                                                    topTitles: const AxisTitles(
                                                      sideTitles: SideTitles(
                                                        showTitles: false,
                                                      ),
                                                    ),
                                                    rightTitles:
                                                        const AxisTitles(
                                                          sideTitles:
                                                              SideTitles(
                                                                showTitles:
                                                                    false,
                                                              ),
                                                        ),
                                                    leftTitles:
                                                        const AxisTitles(
                                                          sideTitles:
                                                              SideTitles(
                                                                showTitles:
                                                                    false,
                                                              ),
                                                        ),
                                                    bottomTitles: AxisTitles(
                                                      sideTitles: SideTitles(
                                                        showTitles: true,
                                                        getTitlesWidget: (value, meta) {
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets.only(
                                                                  top: 8,
                                                                ),
                                                            child: Text(
                                                              value == 0
                                                                  ? context
                                                                        .l10n
                                                                        .income
                                                                  : context
                                                                        .l10n
                                                                        .expense,
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
                                                          color:
                                                              AppTheme.income,
                                                          width: 30,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    BarChartGroupData(
                                                      x: 1,
                                                      barRods: [
                                                        BarChartRodData(
                                                          toY: totalExpense,
                                                          color:
                                                              AppTheme.expense,
                                                          width: 30,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                duration: const Duration(
                                                  milliseconds: 280,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      SectionHeader(
                        title: context.l10n.aiSummaryTitle,
                        subtitle: context.l10n.aiSummarySubtitle,
                        actionLabel: reportTransactions.isEmpty
                            ? null
                            : context.l10n.generateSummary,
                        onAction: reportTransactions.isEmpty
                            ? null
                            : () => _generateMonthlySummary(
                                context,
                                activeMonthKey: activeMonthKey,
                                month: selectedDate ?? DateTime.now(),
                                transactions: reportTransactions,
                                categories: categories,
                              ),
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        child:
                            _summaryLoading &&
                                _summaryMonthKey == activeMonthKey
                            ? const _AiSummaryLoading()
                            : _monthlySummary != null &&
                                  _summaryMonthKey == activeMonthKey
                            ? _AiSummaryCard(summary: _monthlySummary!)
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reportTransactions.isEmpty
                                        ? context.l10n.noDataToChart
                                        : context.l10n.generateSummary,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    reportTransactions.isEmpty
                                        ? context.l10n.addIncomeExpenseToReports
                                        : context.l10n.aiSummarySubtitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                  if (reportTransactions.isNotEmpty) ...[
                                    const SizedBox(height: 14),
                                    FilledButton.icon(
                                      onPressed: () => _generateMonthlySummary(
                                        context,
                                        activeMonthKey: activeMonthKey,
                                        month: selectedDate ?? DateTime.now(),
                                        transactions: reportTransactions,
                                        categories: categories,
                                      ),
                                      icon: const Icon(
                                        Icons.auto_awesome_rounded,
                                      ),
                                      label: Text(context.l10n.generateSummary),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                      if (drilldownTransactions.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        SectionHeader(
                          title: context.l10n.activityFeed,
                          subtitle: context.l10n.latestMoneyMovements,
                          actionLabel: context.l10n.seeAll,
                          onAction: () => context.goNamed('transactions'),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            for (
                              var index = 0;
                              index < drilldownTransactions.length;
                              index++
                            ) ...[
                              Builder(
                                builder: (context) {
                                  final transaction =
                                      drilldownTransactions[index];
                                  final wallet = wallets
                                      .where(
                                        (item) =>
                                            item.id == transaction.walletId,
                                      )
                                      .firstOrNull;
                                  final targetWallet = wallets
                                      .where(
                                        (item) =>
                                            item.id ==
                                            transaction.targetWalletId,
                                      )
                                      .firstOrNull;
                                  final category = categories
                                      .where(
                                        (item) =>
                                            item.id == transaction.categoryId,
                                      )
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
                                        pathParameters: {'id': transaction.id},
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
                      ],
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

  String _monthKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }

  String _formatDeltaLabel(
    BuildContext context,
    double current,
    double previous,
  ) {
    if (previous <= 0) {
      return context.l10n.noPreviousPeriod;
    }

    final delta = ((current - previous) / previous) * 100;
    final direction = delta > 0
        ? context.l10n.increase
        : delta < 0
        ? context.l10n.decrease
        : context.l10n.same;
    final percent = delta.abs().toStringAsFixed(0);
    return '$direction $percent%';
  }

  Future<void> _generateMonthlySummary(
    BuildContext context, {
    required String activeMonthKey,
    required DateTime month,
    required List<FinanceTransaction> transactions,
    required List<Category> categories,
  }) async {
    final languageCode = Localizations.localeOf(context).languageCode;
    setState(() {
      _summaryLoading = true;
      _summaryMonthKey = activeMonthKey;
    });

    try {
      final summary = await ref
          .read(financeAiServiceProvider)
          .summarizeMonth(
            transactions: transactions,
            categories: categories,
            month: month,
            languageCode: languageCode,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _monthlySummary = summary;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        this.context,
      ).showSnackBar(SnackBar(content: Text(this.context.l10n.tryAgain)));
    } finally {
      if (mounted) {
        setState(() => _summaryLoading = false);
      }
    }
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

class _AiSummaryLoading extends StatelessWidget {
  const _AiSummaryLoading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(width: 180, height: 20),
        SizedBox(height: 10),
        SkeletonBox(width: double.infinity, height: 16),
        SizedBox(height: 8),
        SkeletonBox(width: double.infinity, height: 16),
        SizedBox(height: 14),
        SkeletonBox(width: double.infinity, height: 14),
        SizedBox(height: 8),
        SkeletonBox(width: double.infinity, height: 14),
      ],
    );
  }
}

class _AiSummaryCard extends StatelessWidget {
  const _AiSummaryCard({required this.summary});

  final MonthlySpendingSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                summary.headline,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                summary.usedCloudAi
                    ? context.l10n.aiPowered
                    : context.l10n.localFallback,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          summary.summary,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        if (summary.bullets.isNotEmpty) ...[
          const SizedBox(height: 14),
          for (final bullet in summary.bullets) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    bullet,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            if (bullet != summary.bullets.last) const SizedBox(height: 8),
          ],
        ],
      ],
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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
