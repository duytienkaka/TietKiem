import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../l10n/l10n.dart';
import '../../../../shared/finance_enums.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../../transaction/presentation/screens/transaction_form_screen.dart';
import '../../../transaction/presentation/widgets/transaction_tile.dart';
import '../../domain/entities/wallet.dart';
import '../providers/wallet_provider.dart';
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

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.accountInfo,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      complete
                          ? context.l10n.accountInfoReady
                          : context.l10n.accountInfoIncomplete,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showAccountInfoSheet(context, ref, wallet),
                icon: const Icon(Icons.edit_rounded),
                label: Text(context.l10n.updateAccountInfo),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoTile(
            label: context.l10n.bankName,
            value: wallet.bankName ?? context.l10n.notConfiguredYet,
          ),
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
          if (complete) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    context.l10n.transactionQr,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: QrImageView(
                      data: jsonEncode({
                        'app': 'TietKiem',
                        'walletId': wallet.id,
                        'walletName': wallet.name,
                        'bankName': wallet.bankName,
                        'accountNumber': wallet.accountNumber,
                        'accountHolder': wallet.accountHolder,
                        'paymentNote': wallet.paymentNote,
                      }),
                      version: QrVersions.auto,
                      size: 220,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showAccountInfoSheet(
    BuildContext context,
    WidgetRef ref,
    Wallet wallet,
  ) async {
    final bankNameController = TextEditingController(
      text: wallet.bankName ?? '',
    );
    final accountNumberController = TextEditingController(
      text: wallet.accountNumber ?? '',
    );
    final accountHolderController = TextEditingController(
      text: wallet.accountHolder ?? '',
    );
    final paymentNoteController = TextEditingController(
      text: wallet.paymentNote ?? '',
    );
    var saving = false;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.updateAccountInfo,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bankNameController,
                  decoration: InputDecoration(labelText: context.l10n.bankName),
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
                                  accountNumber: accountNumberController.text,
                                  accountHolder: accountHolderController.text,
                                  paymentNote: paymentNoteController.text,
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
    accountNumberController.dispose();
    accountHolderController.dispose();
    paymentNoteController.dispose();
  }
}

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
