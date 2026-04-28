import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../core/error/app_exception.dart';
import '../features/category/domain/entities/category.dart';
import '../l10n/generated/app_localizations.dart';
import '../shared/finance_enums.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

String localeName(BuildContext context) {
  final locale = Localizations.localeOf(context);
  if (locale.countryCode?.isNotEmpty ?? false) {
    return '${locale.languageCode}_${locale.countryCode}';
  }
  return locale.languageCode;
}

String formatCurrency(BuildContext context, num value) {
  final formatter = NumberFormat.decimalPattern(localeName(context));
  return '${formatter.format(value)} đ';
}

String formatDateTime(BuildContext context, DateTime value) {
  return DateFormat('dd/MM/yyyy, HH:mm', localeName(context)).format(value);
}

String formatMonthYear(BuildContext context, DateTime value) {
  return DateFormat('MMM yyyy', localeName(context)).format(value);
}

extension WalletTypeL10n on WalletType {
  String label(BuildContext context) => switch (this) {
        WalletType.cash => context.l10n.walletTypeCash,
        WalletType.bank => context.l10n.walletTypeBank,
        WalletType.saving => context.l10n.walletTypeSaving,
      };
}

extension TransactionTypeL10n on TransactionType {
  String label(BuildContext context) => switch (this) {
        TransactionType.income => context.l10n.income,
        TransactionType.expense => context.l10n.expense,
        TransactionType.transfer => context.l10n.transfer,
      };
}

extension TransactionStatusL10n on TransactionStatus {
  String label(BuildContext context) => switch (this) {
        TransactionStatus.pending => context.l10n.pending,
        TransactionStatus.verified => context.l10n.verified,
        TransactionStatus.review => context.l10n.review,
      };
}

extension CategoryL10n on Category {
  String displayName(BuildContext context) => switch (id) {
        'salary' => context.l10n.categorySalary,
        'gift' => context.l10n.categoryGift,
        'bonus' => context.l10n.categoryBonus,
        'transfer' => context.l10n.categoryTransfer,
        'food' => context.l10n.categoryFood,
        'transport' => context.l10n.categoryTransport,
        'shopping' => context.l10n.categoryShopping,
        'bills' => context.l10n.categoryBills,
        'health' => context.l10n.categoryHealth,
        _ => name,
      };
}

String localizeIconLabel(BuildContext context, String icon) => switch (icon) {
      'account_balance_wallet' => context.l10n.iconWallet,
      'account_balance' => context.l10n.iconBank,
      'savings' => context.l10n.iconSavings,
      _ => icon,
    };

String localizeError(BuildContext context, Object error) {
  final message = error is AppException ? error.message : error.toString();
  return switch (message) {
    'Wallet name is required.' => context.l10n.walletNameRequired,
    'This wallet has transactions and cannot be deleted.' =>
      context.l10n.walletHasTransactionsCannotDelete,
    'Amount must be greater than zero.' => context.l10n.amountMustBeGreaterThanZero,
    'Select a target wallet for transfer.' => context.l10n.selectTargetWallet,
    'Transfer wallets must be different.' => context.l10n.transferWalletsDifferent,
    'Source wallet not found.' => context.l10n.sourceWalletNotFound,
    'Target wallet not found.' => context.l10n.targetWalletNotFound,
    _ => message,
  };
}
