import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/l10n.dart';
import '../../../../shared/finance_enums.dart';
import '../../../../shared/utils/currency_input_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/screen_top_header.dart';
import '../../../../shared/widgets/skeleton_box.dart';
import '../../../category/domain/entities/category.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../transaction/domain/entities/finance_transaction.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../domain/entities/budget.dart';
import '../providers/budget_provider.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  String? _selectedMonthKey;

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionProvider);
    final categoriesAsync = ref.watch(categoryProvider);
    final budgetsAsync = ref.watch(budgetProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.budgetsTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: AsyncValueView(
            value: transactionsAsync,
            loadingBuilder: (_) => const _BudgetScreenLoadingState(),
            data: (transactions) => AsyncValueView(
              value: categoriesAsync,
              loadingBuilder: (_) => const _BudgetScreenLoadingState(),
              data: (categories) => AsyncValueView(
                value: budgetsAsync,
                loadingBuilder: (_) => const _BudgetScreenLoadingState(),
                data: (budgets) {
                  final monthKeys =
                      transactions
                          .map((item) => _monthKey(item.createdAt))
                          .toSet()
                          .toList()
                        ..sort((a, b) => b.compareTo(a));
                  _selectedMonthKey ??= monthKeys.isNotEmpty
                      ? monthKeys.first
                      : _monthKey(DateTime.now());
                  final activeMonthKey = _selectedMonthKey!;

                  final budgetsForMonth = budgets
                      .where((budget) => budget.monthKey == activeMonthKey)
                      .toList();
                  final expenseCategories = categories
                      .where(
                        (category) => category.type == TransactionType.expense,
                      )
                      .toList();

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 120),
                    children: [
                      ScreenTopHeader(
                        eyebrow: context.l10n.budgetsTitle,
                        title: context.l10n.budgetsTitle,
                        subtitle: context.l10n.budgetsSubtitle,
                        icon: Icons.account_balance_wallet_rounded,
                        actionLabel: context.l10n.setBudget,
                        onAction: () => _showBudgetEditor(
                          context,
                          categories: expenseCategories,
                          budgets: budgets,
                          monthKey: activeMonthKey,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                                onTap: () =>
                                    setState(() => _selectedMonthKey = key),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Theme.of(context).colorScheme.primary
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
                      if (monthKeys.isNotEmpty) const SizedBox(height: 16),
                      if (budgetsForMonth.isEmpty)
                        EmptyState(
                          title: context.l10n.noBudgetsYet,
                          message: context.l10n.createBudgetHint,
                          icon: Icons.savings_rounded,
                          actionLabel: context.l10n.setBudget,
                          onAction: () => _showBudgetEditor(
                            context,
                            categories: expenseCategories,
                            budgets: budgets,
                            monthKey: activeMonthKey,
                          ),
                        )
                      else
                        Column(
                          children: [
                            for (final budget in budgetsForMonth) ...[
                              if (expenseCategories
                                      .where(
                                        (category) =>
                                            category.id == budget.categoryId,
                                      )
                                      .firstOrNull
                                  case final category?)
                                _BudgetProgressCard(
                                  budget: budget,
                                  spent: _spentForBudget(
                                    budget,
                                    transactions: transactions,
                                  ),
                                  category: category,
                                  onEdit: () => _showBudgetEditor(
                                    context,
                                    categories: expenseCategories,
                                    budgets: budgets,
                                    monthKey: activeMonthKey,
                                    initialCategoryId: category.id,
                                  ),
                                ),
                              if (budget != budgetsForMonth.last)
                                const SizedBox(height: 10),
                            ],
                          ],
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

  double _spentForBudget(
    Budget budget, {
    required List<FinanceTransaction> transactions,
  }) {
    return transactions
        .where(
          (transaction) =>
              transaction.type == TransactionType.expense &&
              transaction.categoryId == budget.categoryId &&
              _monthKey(transaction.createdAt) == budget.monthKey,
        )
        .fold<double>(0, (sum, item) => sum + item.amount);
  }

  String _monthKey(DateTime value) {
    final utc = value.toUtc();
    final month = utc.month.toString().padLeft(2, '0');
    return '${utc.year}-$month';
  }

  Future<void> _showBudgetEditor(
    BuildContext context, {
    required List<Category> categories,
    required List<Budget> budgets,
    required String monthKey,
    String? initialCategoryId,
  }) async {
    if (categories.isEmpty) {
      return;
    }

    final controller = TextEditingController();
    final amountFocusNode = FocusNode();
    var selectedCategoryId = initialCategoryId ?? categories.first.id;
    final existingBudget = budgets
        .where(
          (budget) =>
              budget.categoryId == selectedCategoryId &&
              budget.monthKey == monthKey,
        )
        .firstOrNull;
    if (existingBudget != null) {
      applyCurrencyEditingValue(controller, existingBudget.amount.round());
    }

    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              16 + mediaQuery.viewInsets.bottom,
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                final budgetForCategory = budgets
                    .where(
                      (budget) =>
                          budget.categoryId == selectedCategoryId &&
                          budget.monthKey == monthKey,
                    )
                    .firstOrNull;
                return AppCard(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.setBudget,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: selectedCategoryId,
                          decoration: InputDecoration(
                            labelText: context.l10n.category,
                            prefixIcon: const Icon(Icons.category_rounded),
                          ),
                          items: categories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category.id,
                                  child: Text(category.displayName(context)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setModalState(() {
                              selectedCategoryId = value;
                              final nextBudget = budgets
                                  .where(
                                    (budget) =>
                                        budget.categoryId == value &&
                                        budget.monthKey == monthKey,
                                  )
                                  .firstOrNull;
                              if (nextBudget == null) {
                                amountFocusNode.unfocus();
                                controller.clear();
                              } else {
                                amountFocusNode.unfocus();
                                applyCurrencyEditingValue(
                                  controller,
                                  nextBudget.amount.round(),
                                );
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: controller,
                          focusNode: amountFocusNode,
                          keyboardType: TextInputType.number,
                          inputFormatters: const [
                            VietnameseCurrencyInputFormatter(),
                          ],
                          decoration: InputDecoration(
                            labelText: context.l10n.budgetAmount,
                            hintText: context.l10n.monthlyBudgetHint,
                            prefixIcon: const Icon(Icons.payments_rounded),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (budgetForCategory != null)
                              TextButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  ref
                                      .read(budgetProvider.notifier)
                                      .saveBudget(
                                        categoryId: selectedCategoryId,
                                        monthKey: monthKey,
                                        amount: 0,
                                      );
                                  Navigator.of(context).pop();
                                },
                                child: Text(context.l10n.remove),
                              ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                final amount = parseVietnameseCurrency(
                                  controller.text,
                                ).toDouble();
                                ref
                                    .read(budgetProvider.notifier)
                                    .saveBudget(
                                      categoryId: selectedCategoryId,
                                      monthKey: monthKey,
                                      amount: amount,
                                    );
                                Navigator.of(context).pop();
                              },
                              child: Text(context.l10n.saveChanges),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
    amountFocusNode.dispose();
    controller.dispose();
  }
}

class _BudgetProgressCard extends StatelessWidget {
  const _BudgetProgressCard({
    required this.budget,
    required this.spent,
    required this.category,
    required this.onEdit,
  });

  final Budget budget;
  final double spent;
  final Category category;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final progress = budget.amount <= 0 ? 0 : (spent / budget.amount);
    final clamped = progress.clamp(0, 1).toDouble();
    final exceeded = spent > budget.amount;
    final remaining = budget.amount - spent;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category.displayName(context),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(onPressed: onEdit, child: Text(context.l10n.edit)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '${context.l10n.spentLabel}: ${formatCurrency(context, spent)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                '${context.l10n.budgetAmount}: ${formatCurrency(context, budget.amount)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: clamped,
              minHeight: 8,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                exceeded ? const Color(0xFFF04438) : const Color(0xFF2E90FA),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            exceeded
                ? context.l10n.budgetExceeded
                : '${context.l10n.remainingLabel}: ${formatCurrency(context, remaining)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: exceeded
                  ? const Color(0xFFF04438)
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetScreenLoadingState extends StatelessWidget {
  const _BudgetScreenLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        const ScreenTopHeaderSkeleton(showAction: true),
        const SizedBox(height: 16),
        for (var index = 0; index < 3; index++) ...[
          AppCard(
            padding: const EdgeInsets.all(14),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 160, height: 18),
                SizedBox(height: 10),
                SkeletonBox(width: 220, height: 12),
                SizedBox(height: 12),
                SkeletonBox(height: 8, borderRadius: 999),
                SizedBox(height: 10),
                SkeletonBox(width: 140, height: 12),
              ],
            ),
          ),
          if (index != 2) const SizedBox(height: 10),
        ],
      ],
    );
  }
}
