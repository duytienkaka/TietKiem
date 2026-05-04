import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../l10n/l10n.dart';
import '../../../../shared/finance_enums.dart';
import '../../../../shared/services/bank_notification_parser.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../../transaction/presentation/screens/transaction_form_screen.dart';
import '../../../transaction/presentation/widgets/transaction_tile.dart';
import '../../data/services/viet_qr_payload_builder.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/entities/scanned_account_qr.dart';
import '../providers/wallet_provider.dart';
import 'account_qr_scanner_screen.dart';
import 'wallet_screen.dart';

class WalletDetailScreen extends ConsumerWidget {
  const WalletDetailScreen({super.key, required this.walletId});

  final String walletId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletProvider);
    final transactionsAsync = ref.watch(transactionProvider);
    final categories = ref.watch(categoryProvider).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.walletDetails)),
      body: AsyncValueView(
        value: walletsAsync,
        data: (wallets) => AsyncValueView(
          value: transactionsAsync,
          data: (transactions) {
            final wallet = wallets
                .where((item) => item.id == walletId)
                .firstOrNull;
            if (wallet == null) {
              return Center(child: Text(context.l10n.unknownWallet));
            }

            final relatedTransactions =
                transactions
                    .where(
                      (item) =>
                          item.walletId == wallet.id ||
                          item.targetWalletId == wallet.id,
                    )
                    .toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            final income = relatedTransactions
                .where(
                  (item) =>
                      item.walletId == wallet.id &&
                      item.type == TransactionType.income,
                )
                .fold<double>(0, (sum, item) => sum + item.amount);
            final expense = relatedTransactions
                .where(
                  (item) =>
                      item.walletId == wallet.id &&
                      item.type == TransactionType.expense,
                )
                .fold<double>(0, (sum, item) => sum + item.amount);

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                AppCard(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(wallet.color),
                      Color(wallet.color).withValues(alpha: 0.88),
                      const Color(0xFF171B39),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.16,
                            ),
                            child: Icon(
                              resolveIcon(wallet.icon),
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              wallet.type.label(context),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        wallet.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.availableBalance,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.84),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatCurrency(context, wallet.balance),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _WalletInsightCard(
                        title: context.l10n.income,
                        value: formatCurrency(context, income),
                        icon: Icons.south_west_rounded,
                        color: const Color(0xFF16B364),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _WalletInsightCard(
                        title: context.l10n.expense,
                        value: formatCurrency(context, expense),
                        icon: Icons.north_east_rounded,
                        color: const Color(0xFFE11D48),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _WalletInsightCard(
                        title: context.l10n.totalTransactions,
                        value: relatedTransactions.length.toString(),
                        icon: Icons.receipt_long_rounded,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _WalletInsightCard(
                        title: context.l10n.color,
                        value:
                            '#${wallet.color.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                        icon: Icons.palette_outlined,
                        color: Color(wallet.color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    children: [
                      _ActionRow(
                        icon: Icons.add_rounded,
                        title: context.l10n.addTransaction,
                        subtitle: context.l10n.addTransactionFromWallet(
                          wallet.name,
                        ),
                        onTap: () => showTransactionEntrySheet(
                          context,
                          initialWalletId: wallet.id,
                        ),
                      ),
                      const Divider(height: 20),
                      _ActionRow(
                        icon: Icons.edit_rounded,
                        title: context.l10n.editWalletTitle,
                        subtitle: context.l10n.editWalletSubtitle,
                        onTap: () => showWalletSheet(context, wallet: wallet),
                      ),
                      const Divider(height: 20),
                      _ActionRow(
                        icon: Icons.delete_outline_rounded,
                        title: context.l10n.deleteWalletAction,
                        subtitle: context.l10n.deleteWalletActionSubtitle,
                        destructive: true,
                        onTap: () =>
                            _confirmDeleteWallet(context, ref, wallet.id),
                      ),
                    ],
                  ),
                ),
                if (wallet.type == WalletType.bank) ...[
                  const SizedBox(height: 16),
                  _AccountInfoSection(wallet: wallet),
                ],
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.recentActivity,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.walletRecentTransactionsSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (relatedTransactions.isEmpty)
                        Text(
                          context.l10n.transactionsWillAppear,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        )
                      else
                        ...relatedTransactions.take(5).map((transaction) {
                          final category = categories
                              .where(
                                (item) => item.id == transaction.categoryId,
                              )
                              .firstOrNull;
                          final targetWallet = wallets
                              .where(
                                (item) => item.id == transaction.targetWalletId,
                              )
                              .firstOrNull;
                          return TransactionTile(
                            transaction: transaction,
                            wallet: wallet,
                            targetWallet: targetWallet,
                            category: category,
                          );
                        }),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDeleteWallet(
    BuildContext context,
    WidgetRef ref,
    String walletId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteWalletAction),
        content: Text(context.l10n.deleteWalletPrompt),
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
      await ref.read(walletProvider.notifier).deleteWallet(walletId);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizeError(context, error))));
      }
    }
  }
}

class _WalletInsightCard extends StatelessWidget {
  const _WalletInsightCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: destructive ? color : null,
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
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _AccountInfoSection extends ConsumerWidget {
  const _AccountInfoSection({required this.wallet});

  final Wallet wallet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complete =
        (wallet.bankName?.isNotEmpty ?? false) &&
        (wallet.accountNumber?.isNotEmpty ?? false) &&
        (wallet.accountHolder?.isNotEmpty ?? false);
    final generatedQr = complete
        ? const VietQrPayloadBuilder().build(
            bankName: wallet.bankName!,
            accountNumber: wallet.accountNumber!,
            accountHolder: wallet.accountHolder!,
            paymentNote: wallet.paymentNote,
          )
        : null;
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primaryContainer,
                      scheme.surfaceContainerHighest,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.account_balance_rounded, color: scheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.accountInfo,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            complete
                                ? context.l10n.accountInfoReady
                                : context.l10n.accountInfoIncomplete,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _showAccountInfoSheet(context, ref, wallet),
                      icon: const Icon(Icons.edit_note_rounded),
                      label: Text(_manualUpdateLabel(context)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _scanAndOpenEditor(context, ref, wallet),
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: Text(_scanQrLabel(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _InfoTile(
                label: context.l10n.bankName,
                value: wallet.bankName ?? context.l10n.notConfiguredYet,
              ),
              if (wallet.bankAliases?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                _InfoTile(
                  label: _bankAliasesLabel(context),
                  value: wallet.bankAliases!,
                ),
              ],
              const SizedBox(height: 10),
              _InfoTile(
                label: context.l10n.accountNumber,
                value: wallet.accountNumber ?? context.l10n.notConfiguredYet,
              ),
              const SizedBox(height: 10),
              _InfoTile(
                label: context.l10n.accountHolder,
                value: wallet.accountHolder ?? context.l10n.notConfiguredYet,
              ),
              if (wallet.paymentNote?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                _InfoTile(
                  label: context.l10n.paymentNote,
                  value: wallet.paymentNote!,
                ),
              ],
              if (generatedQr != null || complete) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        context.l10n.transactionQr,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 12),
                      if (generatedQr != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: QrImageView(
                            data: generatedQr,
                            version: QrVersions.auto,
                            size: 220,
                          ),
                        ),
                      if (generatedQr == null)
                        Text(
                          _unsupportedBankQrHint(context),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _scanAndOpenEditor(
    BuildContext context,
    WidgetRef ref,
    Wallet wallet,
  ) async {
    final scanned = await showAccountQrScanner(context);
    if (!context.mounted || scanned == null) {
      return;
    }
    await _showAccountInfoSheet(
      context,
      ref,
      wallet,
      initialScan: scanned,
      initialQrPayload: scanned.rawValue,
    );
  }

  Future<void> _showAccountInfoSheet(
    BuildContext context,
    WidgetRef ref,
    Wallet wallet, {
    ScannedAccountQr? initialScan,
    String? initialQrPayload,
  }) async {
    final bankNameController = TextEditingController(
      text: initialScan?.bankName ?? wallet.bankName ?? '',
    );
    final bankAliasesController = TextEditingController(
      text: wallet.bankAliases ?? '',
    );
    final accountNumberController = TextEditingController(
      text: initialScan?.accountNumber ?? wallet.accountNumber ?? '',
    );
    final accountHolderController = TextEditingController(
      text: initialScan?.accountHolder ?? wallet.accountHolder ?? '',
    );
    final paymentNoteController = TextEditingController(
      text: initialScan?.paymentNote ?? wallet.paymentNote ?? '',
    );
    final parser = const BankNotificationParser();
    var saving = false;
    final qrPayload = initialQrPayload ?? wallet.qrPayload;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.updateAccountInfo,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _accountInfoSheetSubtitle(context),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bankNameController,
                  decoration: InputDecoration(labelText: context.l10n.bankName),
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: bankNameController,
                  builder: (context, value, _) {
                    final presets = parser.aliasPresetsForBank(value.text.trim());
                    if (presets.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _bankAliasPresetLabel(context),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: presets.map((preset) {
                            return ActionChip(
                              label: Text(preset),
                              onPressed: () {
                                final current = bankAliasesController.text
                                    .split(RegExp(r'[,;\n]+'))
                                    .map((item) => item.trim())
                                    .where((item) => item.isNotEmpty)
                                    .toSet();
                                current.add(preset);
                                bankAliasesController.text = current.join(', ');
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bankAliasesController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: _bankAliasesLabel(context),
                    helperText: _bankAliasesHint(context),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: accountNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: context.l10n.accountNumber,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: accountHolderController,
                  decoration: InputDecoration(
                    labelText: context.l10n.accountHolder,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: paymentNoteController,
                  decoration: InputDecoration(
                    labelText: context.l10n.paymentNote,
                  ),
                ),
                const SizedBox(height: 18),
                AppButton(
                  label: context.l10n.save,
                  icon: Icons.check_rounded,
                  isLoading: saving,
                  onPressed: saving
                      ? null
                      : () async {
                          setSheetState(() => saving = true);
                          try {
                            await ref
                                .read(walletProvider.notifier)
                                .saveWallet(
                                  id: wallet.id,
                                  name: wallet.name,
                                  type: wallet.type,
                                  balance: wallet.balance,
                                  color: wallet.color,
                                  icon: wallet.icon,
                                  bankName: bankNameController.text,
                                  bankAliases: bankAliasesController.text,
                                  accountNumber: accountNumberController.text,
                                  accountHolder: accountHolderController.text,
                                  paymentNote: paymentNoteController.text,
                                  qrPayload: qrPayload,
                                );
                            if (sheetContext.mounted) {
                              Navigator.of(sheetContext).pop();
                            }
                          } catch (error) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(localizeError(context, error)),
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
    );

    bankNameController.dispose();
    bankAliasesController.dispose();
    accountNumberController.dispose();
    accountHolderController.dispose();
    paymentNoteController.dispose();
  }
}

String _bankAliasesLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Alias ngân hàng'
        : 'Bank aliases';

String _bankAliasesHint(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Ví dụ: VCB, Vietcombank, VCBDigibank. Mỗi alias cách nhau bằng dấu phẩy hoặc xuống dòng.'
        : 'Example: VCB, Vietcombank, VCBDigibank. Separate aliases with commas or new lines.';

String _bankAliasPresetLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Alias gợi ý'
        : 'Suggested aliases';

String _manualUpdateLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Cập nhật thường'
        : 'Manual update';

String _scanQrLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Quét QR'
        : 'Scan QR';

String _accountInfoSheetSubtitle(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Điền tay thông tin tài khoản hoặc quét QR để tự động lấy dữ liệu. QR hiển thị trong ví sẽ được ứng dụng tự tạo.'
        : 'Fill account information manually or scan a QR to auto-populate the fields.';

String _unsupportedBankQrHint(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Ứng dụng chưa tự tạo được VietQR cho ngân hàng này. Hãy kiểm tra lại tên ngân hàng.'
        : 'The app cannot generate a VietQR payload for this bank yet. Please check the bank name.';

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
