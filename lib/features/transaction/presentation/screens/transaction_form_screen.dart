import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../l10n/l10n.dart';
import '../../../../shared/finance_enums.dart';
import '../../../../shared/services/picked_image_storage.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/receipt_image.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/shake_widget.dart';
import '../../../../shared/widgets/skeleton_box.dart';
import '../../../../shared/widgets/smooth_bottom_sheet.dart';
import '../../../../shared/utils/currency_input_formatter.dart';
import '../../../category/domain/entities/category.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../wallet/domain/entities/wallet.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';
import 'bill_qr_scanner_screen.dart';
import '../../domain/entities/finance_transaction.dart';
import '../providers/transaction_provider.dart';
import '../widgets/amount_input.dart';
import '../widgets/category_selector.dart';

Future<void> showTransactionEntrySheet(
  BuildContext context, {
  TransactionType? initialType,
  String? transactionId,
  String? initialWalletId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SmoothBottomSheet(
      child: TransactionEntryView(
        initialType: initialType,
        transactionId: transactionId,
        initialWalletId: initialWalletId,
        embedded: true,
      ),
    ),
  );
}

class TransactionFormScreen extends StatelessWidget {
  const TransactionFormScreen({
    super.key,
    this.initialTypeName,
    this.transactionId,
    this.initialWalletId,
  });

  final String? initialTypeName;
  final String? transactionId;
  final String? initialWalletId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          transactionId == null
              ? context.l10n.newTransaction
              : context.l10n.editTransaction,
        ),
      ),
      body: TransactionEntryView(
        transactionId: transactionId,
        initialWalletId: initialWalletId,
        initialType: initialTypeName == null
            ? null
            : TransactionType.values.byName(initialTypeName!),
      ),
    );
  }
}

class TransactionEntryView extends ConsumerStatefulWidget {
  const TransactionEntryView({
    super.key,
    this.initialType,
    this.transactionId,
    this.initialWalletId,
    this.embedded = false,
  });

  final TransactionType? initialType;
  final String? transactionId;
  final String? initialWalletId;
  final bool embedded;

  @override
  ConsumerState<TransactionEntryView> createState() =>
      _TransactionEntryViewState();
}

class _TransactionEntryViewState extends ConsumerState<TransactionEntryView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _amountFocusNode = FocusNode();
  final _imagePicker = ImagePicker();

  late TransactionType _type;
  TransactionStatus _status = TransactionStatus.pending;
  String? _walletId;
  String? _targetWalletId;
  String? _categoryId;
  String? _imagePath;
  bool _saving = false;
  bool _initialized = false;
  FinanceTransaction? _editingTransaction;
  bool _detailsExpanded = false;
  int _shakeTrigger = 0;
  int _rawAmount = 0;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? TransactionType.expense;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _amountFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _amountFocusNode.unfocus();
    _amountController.dispose();
    _noteController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletProvider);
    final categoriesAsync = ref.watch(categoryProvider);
    final transactions = ref.watch(transactionProvider).valueOrNull ?? [];

    return walletsAsync.when(
      data: (wallets) => categoriesAsync.when(
        data: (categories) {
          _initializeState(
            wallets: wallets,
            categories: categories,
            transactions: transactions,
          );

          if (wallets.isEmpty) {
            return Center(
              child: AppButton(
                label: context.l10n.createWalletContinue,
                icon: Icons.account_balance_wallet_rounded,
                expanded: false,
                onPressed: () => showWalletSheet(context),
              ),
            );
          }

          final availableCategories = categories
              .where(
                (category) =>
                    category.workspaceId == _walletId &&
                    category.type == _type &&
                    category.id != 'transfer',
              )
              .toList();
          final availableTargets = wallets
              .where((item) => item.id != _walletId)
              .toList();
          final mediaQuery = MediaQuery.of(context);
          final safeBottomInset = mediaQuery.viewPadding.bottom;
          final keyboardInset = mediaQuery.viewInsets.bottom;
          final actionAreaHeight = 112 + safeBottomInset;
          _categoryId = _type == TransactionType.transfer
              ? null
              : (availableCategories.any((item) => item.id == _categoryId)
                    ? _categoryId
                    : availableCategories.firstOrNull?.id);
          _targetWalletId = _type == TransactionType.transfer
              ? (availableTargets.any((item) => item.id == _targetWalletId)
                    ? _targetWalletId
                    : availableTargets.firstOrNull?.id)
              : null;

          final sheetBody = SafeArea(
            top: !widget.embedded,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: [
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.fromLTRB(
                          16,
                          widget.embedded ? 8 : 8,
                          16,
                          actionAreaHeight,
                        ),
                        children: [
                          SizedBox(height: widget.embedded ? 4 : 4),
                          _HeaderText(
                            title: _formTitle(context),
                            subtitle: widget.transactionId == null
                                ? context.l10n.coreFieldsFirst
                                : context.l10n.editTransactionSubtitle,
                          ),
                          const SizedBox(height: 14),
                          GestureDetector(
                            onHorizontalDragEnd: (details) {
                              final velocity = details.primaryVelocity ?? 0;
                              if (velocity.abs() < 120) {
                                return;
                              }
                              final types = TransactionType.values;
                              final current = types.indexOf(_type);
                              final next = velocity < 0
                                  ? (current + 1) % types.length
                                  : (current - 1 + types.length) % types.length;
                              _applyType(types[next], categories);
                            },
                            child: ShakeWidget(
                              trigger: _shakeTrigger,
                              child: AppCard(
                                padding: const EdgeInsets.fromLTRB(
                                  18,
                                  18,
                                  18,
                                  16,
                                ),
                                child: Column(
                                  children: [
                                    _TypeStrip(
                                      type: _type,
                                      onChanged: (type) =>
                                          _applyType(type, categories),
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      _headlineForType(context, _type),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 10),
                                    AmountInput(
                                      controller: _amountController,
                                      rawValue: _rawAmount,
                                      focusNode: _amountFocusNode,
                                      onChanged: (value) => _rawAmount = value,
                                      onCalculated: _applyCalculatedAmount,
                                      onFieldSubmitted: (_) => _save(),
                                    ),
                                    const SizedBox(height: 12),
                                    Center(
                                      child: OutlinedButton.icon(
                                        onPressed: _scanBillQr,
                                        icon: const Icon(
                                          Icons.qr_code_scanner_rounded,
                                        ),
                                        label: Text(
                                          Localizations.localeOf(
                                                    context,
                                                  ).languageCode ==
                                                  'vi'
                                              ? 'Quét mã bill'
                                              : 'Scan bill QR',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _CompactSection(
                            title: context.l10n.wallet,
                            subtitle: context.l10n.lastUsedWalletPreselected,
                            child: wallets.length > 1
                                ? Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: wallets.map((wallet) {
                                      final selected = wallet.id == _walletId;
                                      return ChoiceChip(
                                        avatar: Icon(
                                          Icons.account_balance_wallet_rounded,
                                          size: 18,
                                          color: selected
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : null,
                                        ),
                                        label: Text(wallet.name),
                                        selected: selected,
                                        onSelected: (_) => setState(() {
                                          _walletId = wallet.id;
                                          final matches = categories
                                              .where(
                                                (item) =>
                                                    item.workspaceId ==
                                                        wallet.id &&
                                                    item.type == _type &&
                                                    item.id != 'transfer',
                                              )
                                              .toList();
                                          _categoryId =
                                              matches.any(
                                                (item) =>
                                                    item.id == _categoryId,
                                              )
                                              ? _categoryId
                                              : matches.firstOrNull?.id;
                                          if (_type ==
                                              TransactionType.transfer) {
                                            _targetWalletId = wallets
                                                .where(
                                                  (item) =>
                                                      item.id != _walletId,
                                                )
                                                .firstOrNull
                                                ?.id;
                                          }
                                        }),
                                      );
                                    }).toList(),
                                  )
                                : _StaticSelectionChip(
                                    icon: Icons.account_balance_wallet_rounded,
                                    label: wallets.first.name,
                                  ),
                          ),
                          if (_type == TransactionType.transfer) ...[
                            const SizedBox(height: 14),
                            _CompactSection(
                              title: context.l10n.targetWallet,
                              subtitle: context.l10n.tapOnceSwitchDestination,
                              child: availableTargets.length > 1
                                  ? Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: availableTargets.map((wallet) {
                                        return ChoiceChip(
                                          label: Text(wallet.name),
                                          selected:
                                              wallet.id == _targetWalletId,
                                          onSelected: (_) => setState(
                                            () => _targetWalletId = wallet.id,
                                          ),
                                        );
                                      }).toList(),
                                    )
                                  : _StaticSelectionChip(
                                      icon: Icons.swap_horiz_rounded,
                                      label:
                                          availableTargets.firstOrNull?.name ??
                                          context.l10n.noTargetWallet,
                                    ),
                            ),
                          ] else ...[
                            const SizedBox(height: 14),
                            _CompactSection(
                              title: context.l10n.category,
                              subtitle: context.l10n.tapIconChangeInstantly,
                              child: availableCategories.isEmpty
                                  ? Text(
                                      context.l10n.noCategoriesForWallet,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                    )
                                  : CategorySelector(
                                      categories: availableCategories,
                                      selectedId: _categoryId,
                                      onSelected: (value) =>
                                          setState(() => _categoryId = value),
                                    ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          _DetailsCard(
                            expanded: _detailsExpanded,
                            noteText: _noteController.text,
                            hasImage: _imagePath?.isNotEmpty == true,
                            status: _status,
                            onToggle: () => setState(
                              () => _detailsExpanded = !_detailsExpanded,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonFormField<TransactionStatus>(
                                  initialValue: _status,
                                  decoration: InputDecoration(
                                    labelText: context.l10n.status,
                                    prefixIcon: const Icon(
                                      Icons.verified_user_rounded,
                                    ),
                                  ),
                                  items: TransactionStatus.values
                                      .map(
                                        (status) => DropdownMenuItem(
                                          value: status,
                                          child: Text(status.label(context)),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _status = value);
                                    }
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _noteController,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    labelText: context.l10n.note,
                                    hintText: context.l10n.addNoteIfNeeded,
                                    prefixIcon: const Icon(Icons.notes_rounded),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                                const SizedBox(height: 12),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  child:
                                      _imagePath != null &&
                                          _imagePath!.isNotEmpty
                                      ? ClipRRect(
                                          key: ValueKey(_imagePath),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: ReceiptImage(
                                            source: _imagePath!,
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Container(
                                          key: const ValueKey('no-image'),
                                          height: 110,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                          ),
                                          child: Center(
                                            child: Text(
                                              context.l10n.noReceiptAttached,
                                            ),
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          _pickImage(ImageSource.camera),
                                      icon: const Icon(
                                        Icons.photo_camera_rounded,
                                      ),
                                      label: Text(context.l10n.camera),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          _pickImage(ImageSource.gallery),
                                      icon: const Icon(
                                        Icons.photo_library_rounded,
                                      ),
                                      label: Text(context.l10n.gallery),
                                    ),
                                    if (_imagePath != null)
                                      TextButton.icon(
                                        onPressed: () =>
                                            setState(() => _imagePath = null),
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                        ),
                                        label: Text(context.l10n.remove),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  RepaintBoundary(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        12,
                        16,
                        16 +
                            safeBottomInset +
                            (widget.embedded ? keyboardInset : 0),
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 24,
                            offset: const Offset(0, -8),
                          ),
                        ],
                      ),
                      child: AppButton(
                        label: _saving
                            ? context.l10n.saving
                            : _saveLabel(context),
                        icon: Icons.check_circle_rounded,
                        isLoading: _saving,
                        onPressed: _save,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

          return sheetBody;
        },
        loading: () => _TransactionFormLoadingState(embedded: widget.embedded),
        error: (error, _) => ErrorState(
          title: context.l10n.errorTitle,
          message: localizeError(context, error),
        ),
      ),
      loading: () => _TransactionFormLoadingState(embedded: widget.embedded),
      error: (error, _) => ErrorState(
        title: context.l10n.errorTitle,
        message: localizeError(context, error),
      ),
    );
  }

  void _initializeState({
    required List<Wallet> wallets,
    required List<Category> categories,
    required List<FinanceTransaction> transactions,
  }) {
    if (_initialized) {
      if (_walletId == null && wallets.isNotEmpty) {
        _walletId = wallets.first.id;
      }
      return;
    }

    final editing = widget.transactionId == null
        ? null
        : transactions
              .where((item) => item.id == widget.transactionId)
              .firstOrNull;
    _editingTransaction = editing;

    if (editing != null) {
      _type = editing.type;
      _walletId = editing.walletId;
      _targetWalletId = editing.targetWalletId;
      _categoryId = editing.categoryId == 'transfer'
          ? null
          : editing.categoryId;
      _status = editing.status;
      _imagePath = editing.imagePath;
      _noteController.text = editing.note ?? '';
      _applyCalculatedAmount(editing.amount.round());
    } else {
      final latest = transactions.firstOrNull;
      if (widget.initialWalletId != null) {
        _type = widget.initialType ?? TransactionType.expense;
        _walletId = widget.initialWalletId;
        final initialCategories = categories
            .where(
              (item) =>
                  item.workspaceId == _walletId &&
                  item.type == _type &&
                  item.id != 'transfer',
            )
            .toList();
        _categoryId = initialCategories.firstOrNull?.id;
      } else if (latest != null) {
        _type = widget.initialType ?? latest.type;
        _walletId = latest.walletId;
        _targetWalletId = latest.targetWalletId;
        _categoryId = latest.categoryId == 'transfer'
            ? null
            : latest.categoryId;
        _status = latest.status;
      } else {
        _type = widget.initialType ?? TransactionType.expense;
        _walletId = widget.initialWalletId ?? wallets.firstOrNull?.id;
        final initialCategories = categories
            .where((item) => item.type == _type && item.id != 'transfer')
            .toList();
        _categoryId = initialCategories.firstOrNull?.id;
      }
    }
    _detailsExpanded = editing != null;
    _initialized = true;
  }

  void _applyType(TransactionType type, List<Category> categories) {
    setState(() {
      _type = type;
      if (_type == TransactionType.transfer) {
        _categoryId = null;
      } else {
        final matches = categories
            .where((item) => item.type == _type && item.id != 'transfer')
            .toList();
        _categoryId = matches.any((item) => item.id == _categoryId)
            ? _categoryId
            : matches.firstOrNull?.id;
        _targetWalletId = null;
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _imagePicker.pickImage(source: source, imageQuality: 85);
    if (file == null) {
      return;
    }

    final savedPath = await savePickedImage(file);
    setState(() {
      _imagePath = savedPath;
      _detailsExpanded = true;
    });
  }

  Future<void> _scanBillQr() async {
    FocusScope.of(context).unfocus();
    final scanned = await showBillQrScanner(context);
    if (!mounted || scanned == null) {
      return;
    }

    setState(() {
      if (scanned.amount != null && scanned.amount! > 0) {
        _rawAmount = scanned.amount!;
        applyCurrencyEditingValue(_amountController, scanned.amount!);
      }

      final note = scanned.composedNote ?? scanned.rawValue;
      if (note.trim().isNotEmpty) {
        _noteController.text = note.trim();
      }
      _detailsExpanded = true;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() ||
        _rawAmount <= 0 ||
        _walletId == null) {
      setState(() => _shakeTrigger++);
      _amountFocusNode.requestFocus();
      return;
    }
    if (_type != TransactionType.transfer && _categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.selectCategoryToContinue)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      FocusScope.of(context).unfocus();
      await ref
          .read(transactionProvider.notifier)
          .saveTransaction(
            id: _editingTransaction?.id,
            type: _type,
            amount: _rawAmount.toDouble(),
            walletId: _walletId!,
            targetWalletId: _targetWalletId,
            categoryId: _categoryId ?? 'transfer',
            note: _noteController.text,
            imagePath: _imagePath,
            status: _status,
            createdAt: _editingTransaction?.createdAt,
          );
      if (mounted) {
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizeError(context, error))));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _applyCalculatedAmount(int value) {
    final normalized = value < 0 ? 0 : value;
    setState(() {
      _rawAmount = normalized;
      applyCurrencyEditingValue(_amountController, normalized);
    });
    _amountFocusNode.requestFocus();
  }

  String _saveLabel(BuildContext context) => switch (_type) {
    TransactionType.income =>
      _editingTransaction == null
          ? context.l10n.saveIncome
          : context.l10n.updateIncome,
    TransactionType.expense =>
      _editingTransaction == null
          ? context.l10n.saveExpense
          : context.l10n.updateExpense,
    TransactionType.transfer =>
      _editingTransaction == null
          ? context.l10n.saveTransfer
          : context.l10n.updateTransfer,
  };

  String _formTitle(BuildContext context) {
    if (_editingTransaction != null) {
      return context.l10n.editTransaction;
    }
    return switch (_type) {
      TransactionType.income => context.l10n.addIncome,
      TransactionType.expense => context.l10n.addExpense,
      TransactionType.transfer => context.l10n.transfer,
    };
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CompactSection extends StatelessWidget {
  const _CompactSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, subtitle: subtitle),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _TypeStrip extends StatelessWidget {
  const _TypeStrip({required this.type, required this.onChanged});

  final TransactionType type;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TransactionType>(
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
        ButtonSegment(
          value: TransactionType.transfer,
          label: Text(context.l10n.transfer),
          icon: const Icon(Icons.swap_horiz_rounded),
        ),
      ],
      selected: {type},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class _StaticSelectionChip extends StatelessWidget {
  const _StaticSelectionChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({
    required this.expanded,
    required this.noteText,
    required this.hasImage,
    required this.status,
    required this.onToggle,
    required this.child,
  });

  final bool expanded;
  final String noteText;
  final bool hasImage;
  final TransactionStatus status;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final accents = <String>[
      if (status != TransactionStatus.pending) status.label(context),
      if (noteText.trim().isNotEmpty) context.l10n.noteAdded,
      if (hasImage) context.l10n.receiptAttached,
    ];

    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: onToggle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SectionHeader(
                  title: context.l10n.moreDetails,
                  subtitle: accents.isEmpty
                      ? context.l10n.optionalFieldsOutWay
                      : accents.join(' | '),
                ),
              ),
              Icon(
                expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
              ),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

String _headlineForType(BuildContext context, TransactionType type) =>
    switch (type) {
      TransactionType.income => context.l10n.headlineIncome,
      TransactionType.expense => context.l10n.headlineExpense,
      TransactionType.transfer => context.l10n.headlineTransfer,
    };

class _TransactionFormLoadingState extends StatelessWidget {
  const _TransactionFormLoadingState({required this.embedded});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final safeBottomInset = mediaQuery.viewPadding.bottom;

    return SafeArea(
      top: !embedded,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                embedded ? 8 : 8,
                16,
                112 + safeBottomInset,
              ),
              children: [
                SizedBox(height: embedded ? 4 : 4),
                const SkeletonBox(width: 150, height: 28),
                const SizedBox(height: 8),
                const SkeletonBox(width: 240, height: 14),
                const SizedBox(height: 14),
                AppCard(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                  child: const Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SkeletonBox(height: 46, borderRadius: 18),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: SkeletonBox(height: 46, borderRadius: 18),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: SkeletonBox(height: 46, borderRadius: 18),
                          ),
                        ],
                      ),
                      SizedBox(height: 18),
                      SkeletonBox(width: 170, height: 16),
                      SizedBox(height: 12),
                      SkeletonBox(height: 64, borderRadius: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const _FormSectionSkeleton(chipCount: 3, chipWidth: 92),
                const SizedBox(height: 14),
                const _FormSectionSkeleton(chipCount: 6, chipWidth: 74),
                const SizedBox(height: 14),
                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 132, height: 18),
                      SizedBox(height: 8),
                      SkeletonBox(width: 210, height: 14),
                      SizedBox(height: 14),
                      SkeletonBox(height: 52, borderRadius: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
          RepaintBoundary(
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + safeBottomInset),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: const SkeletonBox(height: 58, borderRadius: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSectionSkeleton extends StatelessWidget {
  const _FormSectionSkeleton({
    required this.chipCount,
    required this.chipWidth,
  });

  final int chipCount;
  final double chipWidth;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 88, height: 18),
          const SizedBox(height: 8),
          const SkeletonBox(width: 180, height: 14),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              chipCount,
              (index) => SkeletonBox(
                width: chipWidth + ((index % 2) * 10),
                height: 38,
                borderRadius: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
