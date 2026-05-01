import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/budget/domain/entities/budget.dart';
import '../../features/budget/presentation/providers/budget_provider.dart';
import '../../features/category/domain/entities/category.dart';
import '../../features/category/presentation/providers/category_provider.dart';
import '../../features/goal/domain/entities/savings_goal.dart';
import '../../features/goal/presentation/providers/savings_goal_provider.dart';
import '../../features/recurring/domain/entities/recurring_rule.dart';
import '../../features/recurring/presentation/providers/recurring_provider.dart';
import '../../features/transaction/domain/entities/finance_transaction.dart';
import '../../features/transaction/presentation/providers/transaction_provider.dart';
import '../../features/transaction/presentation/widgets/calculator_bottom_sheet.dart';
import '../../features/wallet/domain/entities/wallet.dart';
import '../../features/wallet/presentation/providers/wallet_provider.dart';
import '../../l10n/l10n.dart';
import '../finance_enums.dart';
import '../utils/currency_input_formatter.dart';
import '../widgets/app_card.dart';
import '../widgets/async_value_view.dart';
import '../widgets/empty_state.dart';
import '../widgets/screen_top_header.dart';
import '../widgets/section_header.dart';
import '../widgets/skeleton_box.dart';

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  String? _selectedMonthKey;

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionProvider);
    final categoriesAsync = ref.watch(categoryProvider);
    final walletsAsync = ref.watch(walletProvider);
    final goalsAsync = ref.watch(savingsGoalProvider);
    final recurringAsync = ref.watch(recurringProvider);
    final budgetsAsync = ref.watch(budgetProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: AsyncValueView(
            value: transactionsAsync,
            loadingBuilder: (_) => const _MoreLoadingState(),
            data: (transactions) => AsyncValueView(
              value: categoriesAsync,
              loadingBuilder: (_) => const _MoreLoadingState(),
              data: (categories) => AsyncValueView(
                value: walletsAsync,
                loadingBuilder: (_) => const _MoreLoadingState(),
                data: (wallets) => AsyncValueView(
                  value: goalsAsync,
                  loadingBuilder: (_) => const _MoreLoadingState(),
                  data: (goals) => AsyncValueView(
                    value: recurringAsync,
                    loadingBuilder: (_) => const _MoreLoadingState(),
                    data: (rules) => AsyncValueView(
                      value: budgetsAsync,
                      loadingBuilder: (_) => const _MoreLoadingState(),
                      data: (budgets) {
                      final monthKeys = {
                        for (final item in transactions) _monthKey(item.createdAt),
                        for (final item in budgets) item.monthKey,
                      }.toList()
                        ..sort((a, b) => b.compareTo(a));
                      _selectedMonthKey ??=
                          monthKeys.isNotEmpty ? monthKeys.first : _monthKey(DateTime.now());
                      final activeMonthKey = _selectedMonthKey ?? _monthKey(DateTime.now());
                      final expenseByCategory = _buildExpenseByCategory(
                        transactions,
                        monthKey: activeMonthKey,
                      );
                      final budgetsForMonth = budgets
                          .where((budget) => budget.monthKey == activeMonthKey)
                          .toList();
                      final goalWalletIds = goals.map((goal) => goal.walletId).toSet();
                      final linkedWallets = wallets
                          .where((wallet) => goalWalletIds.contains(wallet.id))
                          .toList();

                      return ListView(
                        padding: const EdgeInsets.only(bottom: 120),
                        children: [
                          ScreenTopHeader(
                            eyebrow: context.l10n.moreTab,
                            title: context.l10n.moreTitle,
                            subtitle: context.l10n.moreSubtitle,
                            icon: Icons.widgets_rounded,
                          ),
                          const SizedBox(height: 16),
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SectionHeader(
                                  title: context.l10n.savingsGoalsTitle,
                                  subtitle: context.l10n.savingsGoalsSubtitle,
                                  actionLabel: context.l10n.addGoal,
                                  onAction: wallets.isEmpty
                                      ? null
                                      : () => _showGoalEditor(
                                            context,
                                            wallets: wallets,
                                          ),
                                ),
                                const SizedBox(height: 12),
                                if (wallets.isEmpty)
                                  EmptyState(
                                    title: context.l10n.noWalletsYet,
                                    message: context.l10n.createWalletStart,
                                    icon: Icons.flag_rounded,
                                  )
                                else if (goals.isEmpty)
                                  EmptyState(
                                    title: context.l10n.noSavingsGoalsYet,
                                    message: context.l10n.createSavingsGoalHint,
                                    icon: Icons.flag_rounded,
                                    actionLabel: context.l10n.addGoal,
                                    onAction: () => _showGoalEditor(
                                      context,
                                      wallets: wallets,
                                    ),
                                  )
                                else
                                  Column(
                                    children: [
                                      for (var index = 0; index < goals.length; index++) ...[
                                        _SavingsGoalCard(
                                          goal: goals[index],
                                          wallet: linkedWallets
                                              .where((wallet) => wallet.id == goals[index].walletId)
                                              .firstOrNull,
                                          onEdit: () => _showGoalEditor(
                                            context,
                                            wallets: wallets,
                                            initialGoal: goals[index],
                                          ),
                                          onDelete: () => ref
                                              .read(savingsGoalProvider.notifier)
                                              .deleteGoal(goals[index].id),
                                        ),
                                        if (index != goals.length - 1)
                                          const SizedBox(height: 10),
                                      ],
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
                                SectionHeader(
                                  title: context.l10n.toolsSection,
                                  subtitle: context.l10n.toolsSectionSubtitle,
                                ),
                                const SizedBox(height: 12),
                                _UtilityTile(
                                  icon: Icons.calculate_rounded,
                                  title: context.l10n.calculator,
                                  subtitle: context.l10n.calculatorHint,
                                  actionLabel: context.l10n.openCalculator,
                                  onTap: () async {
                                    final result = await showAmountCalculatorSheet(context);
                                    if (!context.mounted || result == null) {
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          formatCurrency(context, result),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SectionHeader(
                                  title: context.l10n.recurringTitle,
                                  subtitle: context.l10n.automationSectionSubtitle,
                                  actionLabel: context.l10n.add,
                                  onAction: () => _showRecurringEditor(
                                    context,
                                    wallets: wallets,
                                    categories: categories,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (rules.isEmpty)
                                  EmptyState(
                                    title: context.l10n.noRecurringYet,
                                    message: context.l10n.createRecurringHint,
                                    icon: Icons.repeat_rounded,
                                    actionLabel: context.l10n.add,
                                    onAction: () => _showRecurringEditor(
                                      context,
                                      wallets: wallets,
                                      categories: categories,
                                    ),
                                  )
                                else
                                  Column(
                                    children: [
                                      for (var index = 0; index < rules.length; index++) ...[
                                        _RecurringRuleCard(
                                          rule: rules[index],
                                          categories: categories,
                                          wallets: wallets,
                                          onEdit: () => _showRecurringEditor(
                                            context,
                                            wallets: wallets,
                                            categories: categories,
                                            initialRule: rules[index],
                                          ),
                                          onToggle: (value) => ref
                                              .read(recurringProvider.notifier)
                                              .toggleRule(rules[index].id, value),
                                          onDelete: () => ref
                                              .read(recurringProvider.notifier)
                                              .deleteRule(rules[index].id),
                                        ),
                                        if (index != rules.length - 1)
                                          const SizedBox(height: 10),
                                      ],
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
                                SectionHeader(
                                  title: context.l10n.budgetsTitle,
                                  subtitle: context.l10n.planningSectionSubtitle,
                                  actionLabel: context.l10n.setBudget,
                                  onAction: () => _showBudgetEditor(
                                    context,
                                    categories: categories,
                                    budgets: budgetsForMonth,
                                    monthKey: activeMonthKey,
                                  ),
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
                                        final selected = key == activeMonthKey;
                                        return _MonthPill(
                                          label: formatMonthYear(context, date),
                                          selected: selected,
                                          onTap: () => setState(() => _selectedMonthKey = key),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                if (budgetsForMonth.isEmpty)
                                  EmptyState(
                                    title: context.l10n.noBudgetsYet,
                                    message: context.l10n.createBudgetHint,
                                    icon: Icons.savings_rounded,
                                    actionLabel: context.l10n.setBudget,
                                    onAction: () => _showBudgetEditor(
                                      context,
                                      categories: categories,
                                      budgets: budgetsForMonth,
                                      monthKey: activeMonthKey,
                                    ),
                                  )
                                else
                                  Column(
                                    children: [
                                      for (var index = 0;
                                          index < budgetsForMonth.length;
                                          index++) ...[
                                        _BudgetProgressCard(
                                          budget: budgetsForMonth[index],
                                          spent: expenseByCategory[
                                                  budgetsForMonth[index].categoryId] ??
                                              0,
                                          category: categories.firstWhere(
                                            (item) =>
                                                item.id == budgetsForMonth[index].categoryId,
                                            orElse: () => Category(
                                              id: budgetsForMonth[index].categoryId,
                                              name: context.l10n.unknown,
                                              type: TransactionType.expense,
                                              icon: 'category',
                                              workspaceId: '',
                                              createdAt: DateTime.now(),
                                              updatedAt: DateTime.now(),
                                            ),
                                          ),
                                          onEdit: () => _showBudgetEditor(
                                            context,
                                            categories: categories,
                                            budgets: budgetsForMonth,
                                            monthKey: activeMonthKey,
                                            initialCategoryId:
                                                budgetsForMonth[index].categoryId,
                                          ),
                                        ),
                                        if (index != budgetsForMonth.length - 1)
                                          const SizedBox(height: 10),
                                      ],
                                    ],
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
          ),
        ),
      ),
    );
  }

  Map<String, double> _buildExpenseByCategory(
    List<FinanceTransaction> transactions, {
    required String monthKey,
  }) {
    final expenseByCategory = <String, double>{};
    for (final transaction in transactions) {
      if (transaction.type != TransactionType.expense) {
        continue;
      }
      if (_monthKey(transaction.createdAt) != monthKey) {
        continue;
      }
      expenseByCategory.update(
        transaction.categoryId,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }
    return expenseByCategory;
  }

  Future<void> _showGoalEditor(
    BuildContext context, {
    required List<Wallet> wallets,
    SavingsGoal? initialGoal,
  }) async {
    if (wallets.isEmpty) {
      return;
    }

    final titleController = TextEditingController(text: initialGoal?.title ?? '');
    final amountController = TextEditingController();
    final noteController = TextEditingController(text: initialGoal?.note ?? '');
    var walletId = initialGoal?.walletId ?? wallets.first.id;
    var targetDate = initialGoal?.targetDate ?? DateTime.now().add(const Duration(days: 90));

    if (initialGoal != null) {
      applyCurrencyEditingValue(amountController, initialGoal.targetAmount.round());
    }

    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 8,
                bottom: 20 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      initialGoal == null
                          ? context.l10n.createSavingsGoal
                          : context.l10n.editSavingsGoal,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.savingsGoalEditorHint,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: context.l10n.goalName,
                        prefixIcon: const Icon(Icons.flag_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: walletId,
                      decoration: InputDecoration(
                        labelText: context.l10n.wallet,
                        prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
                      ),
                      items: wallets
                          .map(
                            (wallet) => DropdownMenuItem(
                              value: wallet.id,
                              child: Text(wallet.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() => walletId = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        VietnameseCurrencyInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: context.l10n.targetAmount,
                        prefixIcon: const Icon(Icons.savings_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: targetDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (picked != null) {
                          setModalState(() => targetDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: context.l10n.targetDate,
                          prefixIcon: const Icon(Icons.event_rounded),
                        ),
                        child: Text(formatDateTime(context, targetDate).split(',').first),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: context.l10n.note,
                        prefixIcon: const Icon(Icons.notes_rounded),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        if (initialGoal != null)
                          TextButton(
                            onPressed: () async {
                              await ref
                                  .read(savingsGoalProvider.notifier)
                                  .deleteGoal(initialGoal.id);
                              if (sheetContext.mounted) {
                                Navigator.of(sheetContext).pop();
                              }
                            },
                            child: Text(context.l10n.delete),
                          ),
                        const Spacer(),
                        FilledButton(
                          onPressed: () async {
                            final title = titleController.text.trim();
                            final amount =
                                parseVietnameseCurrency(amountController.text).toDouble();
                            if (title.isEmpty || amount <= 0) {
                              return;
                            }
                            await ref.read(savingsGoalProvider.notifier).saveGoal(
                                  id: initialGoal?.id,
                                  title: title,
                                  walletId: walletId,
                                  targetAmount: amount,
                                  targetDate: targetDate,
                                  note: noteController.text,
                                );
                            if (sheetContext.mounted) {
                              Navigator.of(sheetContext).pop();
                            }
                          },
                          child: Text(
                            initialGoal == null
                                ? context.l10n.createGoalAction
                                : context.l10n.saveChanges,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
  }

  Future<void> _showBudgetEditor(
    BuildContext context, {
    required List<Category> categories,
    required List<Budget> budgets,
    required String monthKey,
    String? initialCategoryId,
  }) async {
    final expenseCategories = categories
        .where((category) =>
            category.type == TransactionType.expense && category.id != 'transfer')
        .toList();
    if (expenseCategories.isEmpty) {
      return;
    }

    final controller = TextEditingController();
    var selectedCategoryId = initialCategoryId ?? expenseCategories.first.id;
    final existingBudget = budgets
        .where(
          (budget) =>
              budget.categoryId == selectedCategoryId && budget.monthKey == monthKey,
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
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final budgetForCategory = budgets
              .where(
                (budget) =>
                    budget.categoryId == selectedCategoryId &&
                    budget.monthKey == monthKey,
              )
              .firstOrNull;
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 8,
                bottom: 20 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.setBudget,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategoryId,
                      decoration: InputDecoration(
                        labelText: context.l10n.category,
                        prefixIcon: const Icon(Icons.category_rounded),
                      ),
                      items: expenseCategories
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
                            controller.clear();
                          } else {
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
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        VietnameseCurrencyInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: context.l10n.budgetAmount,
                        hintText: context.l10n.monthlyBudgetHint,
                        prefixIcon: const Icon(Icons.payments_rounded),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        if (budgetForCategory != null)
                          TextButton(
                            onPressed: () {
                              ref.read(budgetProvider.notifier).saveBudget(
                                    categoryId: selectedCategoryId,
                                    monthKey: monthKey,
                                    amount: 0,
                                  );
                              Navigator.of(sheetContext).pop();
                            },
                            child: Text(context.l10n.remove),
                          ),
                        const Spacer(),
                        FilledButton(
                          onPressed: () {
                            final amount =
                                parseVietnameseCurrency(controller.text).toDouble();
                            ref.read(budgetProvider.notifier).saveBudget(
                                  categoryId: selectedCategoryId,
                                  monthKey: monthKey,
                                  amount: amount,
                                );
                            Navigator.of(sheetContext).pop();
                          },
                          child: Text(context.l10n.saveChanges),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    controller.dispose();
  }

  Future<void> _showRecurringEditor(
    BuildContext context, {
    required List<Wallet> wallets,
    required List<Category> categories,
    RecurringRule? initialRule,
  }) async {
    if (wallets.isEmpty) {
      return;
    }

    final amountController = TextEditingController();
    final noteController = TextEditingController(text: initialRule?.note ?? '');
    var type = initialRule?.type ?? TransactionType.expense;
    var walletId = initialRule?.walletId ?? wallets.first.id;
    var interval = initialRule?.interval ?? RecurringInterval.monthly;
    var status = initialRule?.status ?? TransactionStatus.pending;
    var isActive = initialRule?.isActive ?? true;

    List<Category> availableCategories() => categories
        .where((category) => category.type == type && category.id != 'transfer')
        .toList();

    var categoryId = initialRule?.categoryId ??
        availableCategories().firstOrNull?.id;
    if (initialRule != null) {
      applyCurrencyEditingValue(amountController, initialRule.amount.round());
    }

    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final currentCategories = availableCategories();
          if (!currentCategories.any((item) => item.id == categoryId)) {
            categoryId = currentCategories.firstOrNull?.id;
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 8,
                bottom: 20 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      initialRule == null
                          ? context.l10n.recurringTitle
                          : context.l10n.edit,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TransactionType>(
                      initialValue: type,
                      decoration: InputDecoration(
                        labelText: context.l10n.transactionTypeLabel,
                        prefixIcon: const Icon(Icons.swap_vert_rounded),
                      ),
                      selectedItemBuilder: (context) => [
                        Text(context.l10n.expense),
                        Text(context.l10n.income),
                      ],
                      items: [
                        DropdownMenuItem(
                          value: TransactionType.expense,
                          child: Text(context.l10n.expense),
                        ),
                        DropdownMenuItem(
                          value: TransactionType.income,
                          child: Text(context.l10n.income),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setModalState(() {
                          type = value;
                          categoryId = availableCategories().firstOrNull?.id;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        VietnameseCurrencyInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: context.l10n.amountLabel,
                        prefixIcon: const Icon(Icons.payments_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: walletId,
                      decoration: InputDecoration(
                        labelText: context.l10n.wallet,
                        prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
                      ),
                      items: wallets
                          .map(
                            (wallet) => DropdownMenuItem(
                              value: wallet.id,
                              child: Text(wallet.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() => walletId = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: categoryId,
                      decoration: InputDecoration(
                        labelText: context.l10n.category,
                        prefixIcon: const Icon(Icons.category_rounded),
                      ),
                      items: currentCategories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category.id,
                              child: Text(category.displayName(context)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() => categoryId = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<RecurringInterval>(
                      initialValue: interval,
                      decoration: InputDecoration(
                        labelText: context.l10n.repeatEvery,
                        prefixIcon: const Icon(Icons.repeat_rounded),
                      ),
                      items: RecurringInterval.values
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.label(context)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() => interval = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TransactionStatus>(
                      initialValue: status,
                      decoration: InputDecoration(
                        labelText: context.l10n.status,
                        prefixIcon: const Icon(Icons.verified_user_rounded),
                      ),
                      items: TransactionStatus.values
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.label(context)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() => status = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: context.l10n.note,
                        prefixIcon: const Icon(Icons.notes_rounded),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: isActive,
                      onChanged: (value) => setModalState(() => isActive = value),
                      title: Text(context.l10n.enableRecurring),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () async {
                          final amount =
                              parseVietnameseCurrency(amountController.text).toDouble();
                          if (amount <= 0 || categoryId == null) {
                            return;
                          }
                          await ref.read(recurringProvider.notifier).saveRule(
                                id: initialRule?.id,
                                type: type,
                                amount: amount,
                                walletId: walletId,
                                categoryId: categoryId!,
                                status: status,
                                interval: interval,
                                note: noteController.text,
                                nextRunAt: initialRule?.nextRunAt,
                                isActive: isActive,
                              );
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                        child: Text(
                          initialRule == null
                              ? context.l10n.add
                              : context.l10n.saveChanges,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    amountController.dispose();
    noteController.dispose();
  }
}

class _UtilityTile extends StatelessWidget {
  const _UtilityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
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
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: onTap,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
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
            color:
                selected ? scheme.primary : scheme.outlineVariant.withValues(alpha: 0.5),
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

class _SavingsGoalCard extends StatelessWidget {
  const _SavingsGoalCard({
    required this.goal,
    required this.wallet,
    required this.onEdit,
    required this.onDelete,
  });

  final SavingsGoal goal;
  final Wallet? wallet;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final currentBalance = wallet?.balance ?? 0;
    final progress = goal.targetAmount <= 0 ? 0 : currentBalance / goal.targetAmount;
    final clamped = progress.clamp(0, 1).toDouble();
    final remaining = (goal.targetAmount - currentBalance).clamp(0, double.infinity);
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0 && remaining > 0;
    final perDay = daysLeft > 0 && remaining > 0 ? remaining / daysLeft : 0.0;
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.flag_rounded, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wallet?.name ?? context.l10n.unknownWallet,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(context.l10n.edit),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(context.l10n.delete),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GoalMetric(
                  label: context.l10n.savedAmount,
                  value: formatCurrency(context, currentBalance),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GoalMetric(
                  label: context.l10n.targetAmount,
                  value: formatCurrency(context, goal.targetAmount),
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: clamped,
              minHeight: 9,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverdue ? const Color(0xFFF04438) : const Color(0xFF17B26A),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _GoalInfoChip(
                icon: Icons.event_rounded,
                label:
                    '${context.l10n.deadlineLabel}: ${formatDateTime(context, goal.targetDate).split(',').first}',
              ),
              _GoalInfoChip(
                icon: Icons.pie_chart_rounded,
                label: '${(clamped * 100).round()}%',
              ),
              if (remaining > 0)
                _GoalInfoChip(
                  icon: isOverdue ? Icons.warning_rounded : Icons.trending_up_rounded,
                  label: isOverdue
                      ? context.l10n.goalOverdue
                      : '${context.l10n.dailyNeeded}: ${formatCurrency(context, perDay)}',
                ),
            ],
          ),
          if (goal.note?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Text(
              goal.note!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GoalMetric extends StatelessWidget {
  const _GoalMetric({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _GoalInfoChip extends StatelessWidget {
  const _GoalInfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecurringRuleCard extends StatelessWidget {
  const _RecurringRuleCard({
    required this.rule,
    required this.categories,
    required this.wallets,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final RecurringRule rule;
  final List<Category> categories;
  final List<Wallet> wallets;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final category = categories
        .where((item) => item.id == rule.categoryId)
        .firstOrNull;
    final wallet = wallets.where((item) => item.id == rule.walletId).firstOrNull;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                  category?.displayName(context) ?? context.l10n.unknown,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(context, rule.amount),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${wallet?.name ?? context.l10n.wallet} | '
                  '${formatDateTime(context, rule.nextRunAt)} | '
                  '${rule.interval.label(context)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Switch.adaptive(
                value: rule.isActive,
                onChanged: onToggle,
              ),
              IconButton(
                onPressed: onEdit,
                tooltip: context.l10n.edit,
                icon: const Icon(Icons.edit_rounded),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: context.l10n.delete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ],
      ),
    );
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
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: onEdit,
                child: Text(context.l10n.edit),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${context.l10n.spentLabel}: ${formatCurrency(context, spent)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${context.l10n.budgetAmount}: ${formatCurrency(context, budget.amount)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: clamped,
              minHeight: 8,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
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

class _MoreLoadingState extends StatelessWidget {
  const _MoreLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: const [
        ScreenTopHeaderSkeleton(),
        SizedBox(height: 16),
        _SectionSkeleton(lines: 1),
        SizedBox(height: 16),
        _SectionSkeleton(lines: 3),
        SizedBox(height: 16),
        _SectionSkeleton(lines: 3),
      ],
    );
  }
}

class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton({required this.lines});

  final int lines;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 140, height: 18),
          const SizedBox(height: 8),
          const SkeletonBox(width: 220, height: 14),
          const SizedBox(height: 14),
          for (var index = 0; index < lines; index++) ...[
            const SkeletonBox(height: 56, borderRadius: 18),
            if (index != lines - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

String _monthKey(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  return '${value.year}-$month';
}
