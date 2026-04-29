import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/l10n.dart';
import '../../../../shared/finance_enums.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/screen_top_header.dart';
import '../../../../shared/widgets/skeleton_box.dart';
import '../../../category/domain/entities/category.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../transaction/presentation/screens/transaction_form_screen.dart';
import '../../domain/entities/recurring_rule.dart';
import '../providers/recurring_provider.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringAsync = ref.watch(recurringProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.recurringTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: AsyncValueView(
            value: recurringAsync,
            loadingBuilder: (_) => const _RecurringScreenLoadingState(),
            data: (rules) => AsyncValueView(
              value: categoriesAsync,
              loadingBuilder: (_) => const _RecurringScreenLoadingState(),
              data: (categories) => ListView(
                padding: const EdgeInsets.only(bottom: 120),
                children: [
                  ScreenTopHeader(
                    eyebrow: context.l10n.recurringTitle,
                    title: context.l10n.recurringTitle,
                    subtitle: context.l10n.recurringSubtitle,
                    icon: Icons.autorenew_rounded,
                    actionLabel: context.l10n.add,
                    onAction: () => showTransactionEntrySheet(
                      context,
                      initialType: TransactionType.expense,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (rules.isEmpty)
                    EmptyState(
                      title: context.l10n.noRecurringYet,
                      message: context.l10n.createRecurringHint,
                      icon: Icons.repeat_rounded,
                      actionLabel: context.l10n.add,
                      onAction: () => showTransactionEntrySheet(
                        context,
                        initialType: TransactionType.expense,
                      ),
                    )
                  else
                    _RecurringRuleList(
                      rules: rules,
                      categories: categories,
                      onToggle: (id, isActive) => ref
                          .read(recurringProvider.notifier)
                          .toggleRule(id, isActive),
                      onDelete: (id) =>
                          ref.read(recurringProvider.notifier).deleteRule(id),
                    ),
                ],
              ),
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
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
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
                                .where(
                                  (category) => category.id == rule.categoryId,
                                )
                                .firstOrNull
                                ?.displayName(context) ??
                            context.l10n.unknown,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
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
                        '${context.l10n.nextRunLabel}: '
                        '${formatDateTime(context, rule.nextRunAt)} - '
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
          if (rule != rules.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _RecurringScreenLoadingState extends StatelessWidget {
  const _RecurringScreenLoadingState();

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
                SkeletonBox(width: 140, height: 16),
                SizedBox(height: 10),
                SkeletonBox(width: 220, height: 12),
                SizedBox(height: 12),
                SkeletonBox(width: 180, height: 12),
              ],
            ),
          ),
          if (index != 2) const SizedBox(height: 10),
        ],
      ],
    );
  }
}
