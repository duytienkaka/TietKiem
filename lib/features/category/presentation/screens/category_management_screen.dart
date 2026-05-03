import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/l10n.dart';
import '../../../../shared/finance_enums.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../providers/category_provider.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState
    extends ConsumerState<CategoryManagementScreen> {
  String? _walletId;
  TransactionType _type = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.categoryManagement)),
      floatingActionButton: _walletId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showCategoryEditorSheet(context),
              icon: const Icon(Icons.add_rounded),
              label: Text(context.l10n.addCategory),
            ),
      body: AsyncValueView(
        value: walletsAsync,
        data: (wallets) {
          if (_walletId == null && wallets.isNotEmpty) {
            _walletId = wallets.first.id;
          }
          if (wallets.isEmpty) {
            return EmptyState(
              title: context.l10n.noWalletsCreated,
              message: context.l10n.createWalletStart,
              icon: Icons.account_balance_wallet_rounded,
            );
          }

          return AsyncValueView(
            value: categoriesAsync,
            data: (_) {
              final selectedWallet = wallets
                  .where((item) => item.id == _walletId)
                  .firstOrNull;
              final categories = ref
                  .read(categoryProvider.notifier)
                  .categoriesForWallet(_walletId!, type: _type);

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.categoryManagement,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.categoryManagementSubtitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _walletId,
                          decoration: InputDecoration(
                            labelText: context.l10n.wallet,
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
                            if (value == null) {
                              return;
                            }
                            setState(() => _walletId = value);
                          },
                        ),
                        const SizedBox(height: 14),
                        SegmentedButton<TransactionType>(
                          segments: [
                            ButtonSegment(
                              value: TransactionType.expense,
                              label: Text(context.l10n.expense),
                              icon: const Icon(Icons.arrow_upward_rounded),
                            ),
                            ButtonSegment(
                              value: TransactionType.income,
                              label: Text(context.l10n.income),
                              icon: const Icon(Icons.arrow_downward_rounded),
                            ),
                          ],
                          selected: {_type},
                          onSelectionChanged: (value) {
                            setState(() => _type = value.first);
                          },
                        ),
                        if (selectedWallet != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    context.l10n.categoryScopeWallet(
                                      selectedWallet.name,
                                    ),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (categories.isEmpty)
                    EmptyState(
                      title: context.l10n.noCategoriesYet,
                      message: context.l10n.addCategoryHint,
                      icon: Icons.category_rounded,
                      actionLabel: context.l10n.addCategory,
                      onAction: () => _showCategoryEditorSheet(context),
                    )
                  else
                    ...categories.map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: buildAdaptiveIcon(
                                  category.icon,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.displayName(context),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      category.type.label(context),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _confirmDeleteCategory(
                                  context,
                                  category.id,
                                  category.displayName(context),
                                ),
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showCategoryEditorSheet(BuildContext context) async {
    final nameController = TextEditingController();
    final iconController = TextEditingController(text: '🏷️');
    var saving = false;
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              20 + MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.addCategory,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.addCategorySubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: context.l10n.categoryName,
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return context.l10n.categoryNameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: iconController,
                    decoration: InputDecoration(
                      labelText: context.l10n.categoryEmojiIcon,
                      hintText: context.l10n.categoryEmojiHint,
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return context.l10n.categoryIconRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  AppButton(
                    label: context.l10n.save,
                    icon: Icons.check_rounded,
                    isLoading: saving,
                    onPressed: saving
                        ? null
                        : () async {
                            if (formKey.currentState?.validate() != true ||
                                _walletId == null) {
                              return;
                            }
                            setSheetState(() => saving = true);
                            try {
                              await ref
                                  .read(categoryProvider.notifier)
                                  .saveCategory(
                                    walletId: _walletId!,
                                    name: nameController.text,
                                    type: _type,
                                    icon: iconController.text,
                                  );
                              if (sheetContext.mounted) {
                                Navigator.of(sheetContext).pop();
                              }
                            } catch (error) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      localizeError(context, error),
                                    ),
                                  ),
                                );
                              }
                            } finally {
                              if (sheetContext.mounted) {
                                setSheetState(() => saving = false);
                              }
                            }
                          },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    nameController.dispose();
    iconController.dispose();
  }

  Future<void> _confirmDeleteCategory(
    BuildContext context,
    String categoryId,
    String label,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.delete),
        content: Text(context.l10n.deleteCategoryPrompt(label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref.read(categoryProvider.notifier).deleteCategory(categoryId);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizeError(context, error))));
      }
    }
  }
}
