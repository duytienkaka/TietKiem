import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/category/domain/entities/category.dart';
import '../../features/category/presentation/providers/category_provider.dart';
import '../../features/transaction/domain/entities/notification_import.dart';
import '../../features/transaction/presentation/providers/notification_import_provider.dart';
import '../../features/wallet/domain/entities/wallet.dart';
import '../../features/wallet/presentation/providers/wallet_provider.dart';
import '../../l10n/l10n.dart';
import '../finance_enums.dart';

class BankNotificationPromptHost extends ConsumerStatefulWidget {
  const BankNotificationPromptHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<BankNotificationPromptHost> createState() =>
      _BankNotificationPromptHostState();
}

class _BankNotificationPromptHostState
    extends ConsumerState<BankNotificationPromptHost> {
  bool _dialogVisible = false;
  String? _activeImportId;
  int _lastPendingCount = 0;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<NotificationImportEntry>>>(
      notificationImportProvider,
      (_, next) {
        final imports = (next.valueOrNull ?? const <NotificationImportEntry>[])
            .where(
              (item) =>
                  item.status == NotificationImportStatus.pending,
            )
            .toList();
        if (imports.length > _lastPendingCount && mounted) {
          final count = imports.length;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_pendingDetectedSnack(context, count)),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        _lastPendingCount = imports.length;
        if (_dialogVisible || imports.isEmpty) {
          return;
        }
        final promptable = imports.where(
          (item) => item.walletId != null && item.amount > 0,
        );
        if (promptable.isEmpty) {
          return;
        }
        final nextImport = promptable.firstWhere(
          (item) => item.id != _activeImportId,
          orElse: () => promptable.first,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _dialogVisible) {
            return;
          }
          _showPrompt(nextImport);
        });
      },
    );

    return widget.child;
  }

  Future<void> _showPrompt(NotificationImportEntry entry) async {
    final navigator = Navigator.maybeOf(context, rootNavigator: true);
    if (navigator == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _dialogVisible) {
          return;
        }
        _showPrompt(entry);
      });
      return;
    }
    final walletId = entry.walletId;
    if (walletId == null) {
      return;
    }
    final wallets = ref.read(walletProvider).valueOrNull ?? const <Wallet>[];
    final wallet = wallets.where((item) => item.id == walletId).firstOrNull;
    if (wallet == null) {
      await ref.read(notificationImportProvider.notifier).dismissImport(entry.id);
      return;
    }

    _dialogVisible = true;
    _activeImportId = entry.id;
    final noteController = TextEditingController(
      text: entry.body?.trim().isNotEmpty == true
          ? entry.body!.trim()
          : entry.title?.trim() ?? '',
    );
    var selectedType = entry.inferredType;
    var categories = _categoriesFor(wallet.id, selectedType);
    var selectedCategoryId = categories.firstOrNull?.id;
    try {
      await showDialog<void>(
        context: navigator.context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              categories = _categoriesFor(wallet.id, selectedType);
              selectedCategoryId = categories.any(
                (item) => item.id == selectedCategoryId,
              )
                  ? selectedCategoryId
                  : categories.firstOrNull?.id;

              return AlertDialog(
                title: Text(_detectedTransactionTitle(context)),
                content: SizedBox(
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _detectedTransactionSubtitle(context),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        label: context.l10n.bankName,
                        value: entry.bankName,
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(label: context.l10n.wallet, value: wallet.name),
                      const SizedBox(height: 8),
                      _InfoRow(
                        label: context.l10n.amountLabel,
                        value: formatCurrency(context, entry.amount),
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<TransactionType>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(
                            value: TransactionType.income,
                            label: Text(context.l10n.income),
                            icon: const Icon(Icons.south_west_rounded),
                          ),
                          ButtonSegment(
                            value: TransactionType.expense,
                            label: Text(context.l10n.expense),
                            icon: const Icon(Icons.north_east_rounded),
                          ),
                        ],
                        selected: {selectedType},
                        onSelectionChanged: (selection) {
                          setModalState(() {
                            selectedType = selection.first;
                            categories = _categoriesFor(wallet.id, selectedType);
                            selectedCategoryId = categories.firstOrNull?.id;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      if (categories.isEmpty)
                        Text(
                          context.l10n.noCategoriesForWallet,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        )
                      else
                        DropdownButtonFormField<String>(
                          initialValue: selectedCategoryId,
                          decoration: InputDecoration(
                            labelText: context.l10n.category,
                          ),
                          items: categories
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item.id,
                                  child: Text(item.displayName(context)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setModalState(() => selectedCategoryId = value),
                        ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: noteController,
                        minLines: 2,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: context.l10n.note,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await ref
                          .read(notificationImportProvider.notifier)
                          .dismissImport(entry.id);
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
                    child: Text(_dismissDetectedTransaction(context)),
                  ),
                  FilledButton.icon(
                    onPressed: categories.isEmpty || selectedCategoryId == null
                        ? null
                        : () async {
                            await ref
                                .read(notificationImportProvider.notifier)
                                .confirmImport(
                                  id: entry.id,
                                  type: selectedType,
                                  walletId: wallet.id,
                                  categoryId: selectedCategoryId!,
                                  note: noteController.text.trim(),
                                );
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          },
                    icon: const Icon(Icons.check_circle_rounded),
                    label: Text(_confirmDetectedTransaction(context)),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      noteController.dispose();
      _dialogVisible = false;
      _activeImportId = null;
    }
  }

  List<Category> _categoriesFor(String walletId, TransactionType type) {
    final categories = ref.read(categoryProvider).valueOrNull ?? const <Category>[];
    return categories
        .where(
          (item) =>
              item.workspaceId == walletId &&
              item.type == type &&
              item.id != 'transfer',
        )
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 86,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

String _detectedTransactionTitle(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Phát hiện giao dịch mới'
        : 'New transaction detected';

String _detectedTransactionSubtitle(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Đã tìm thấy một thông báo ngân hàng khớp với ví của bạn. Hãy xác nhận trước khi lưu.'
        : 'A banking notification matched one of your wallets. Please confirm before saving it.';

String _dismissDetectedTransaction(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Bỏ qua'
        : 'Dismiss';

String _confirmDetectedTransaction(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Thêm giao dịch'
        : 'Add transaction';

String _pendingDetectedSnack(BuildContext context, int count) {
  final isVi = Localizations.localeOf(context).languageCode == 'vi';
  if (isVi) {
    return count == 1
        ? 'Bạn đang có 1 giao dịch phát hiện mới.'
        : 'Bạn đang có $count giao dịch phát hiện mới.';
  }
  return count == 1
      ? 'You have 1 new detected transaction.'
      : 'You have $count new detected transactions.';
}
