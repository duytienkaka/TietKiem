import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/category/domain/entities/category.dart';
import '../../features/category/presentation/providers/category_provider.dart';
import '../../features/transaction/domain/entities/finance_transaction.dart';
import '../../features/transaction/presentation/providers/transaction_provider.dart';
import '../../features/wallet/domain/entities/wallet.dart';
import '../../features/wallet/presentation/providers/wallet_provider.dart';
import '../../l10n/l10n.dart';
import '../models/app_preferences_state.dart';
import '../providers/app_lock_provider.dart';
import '../providers/app_preferences_provider.dart';
import '../services/app_data_maintenance_service.dart';
import '../widgets/animated_reveal.dart';
import '../widgets/app_card.dart';
import '../widgets/async_value_view.dart';
import '../widgets/section_header.dart';
import '../widgets/setting_item.dart';
import '../widgets/skeleton_box.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(appPreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsTitle),
      ),
      body: SafeArea(
        child: AsyncValueView(
          value: preferencesAsync,
          loadingBuilder: (_) => const _SettingsLoadingState(),
          data: (preferences) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              AnimatedReveal(
                child: _SettingsHeroCard(
                  languageLabel: preferences.languageCode == 'vi'
                      ? context.l10n.vietnamese
                      : context.l10n.english,
                  darkModeEnabled: preferences.darkModeEnabled,
                ),
              ),
              const SizedBox(height: 18),
              AnimatedReveal(
                delay: const Duration(milliseconds: 30),
                child: _SettingsSection(
                  title: context.l10n.generalSection,
                  subtitle: context.l10n.generalSectionSubtitle,
                  children: [
                    SettingItem(
                      icon: Icons.language_rounded,
                      title: context.l10n.language,
                      subtitle: preferences.languageCode == 'vi'
                          ? context.l10n.vietnamese
                          : context.l10n.english,
                      onTap: () => _showLanguageSheet(context, ref, preferences.languageCode),
                    ),
                    SettingItem(
                      icon: Icons.payments_rounded,
                      title: context.l10n.currency,
                      subtitle: context.l10n.vndCurrency,
                      trailing: Text('VND', style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AnimatedReveal(
                delay: const Duration(milliseconds: 60),
                child: _SettingsSection(
                  title: context.l10n.appSettingsSection,
                  subtitle: context.l10n.appSettingsSubtitle,
                  children: [
                    SettingItem(
                      icon: Icons.dark_mode_rounded,
                      title: context.l10n.darkMode,
                      subtitle: context.l10n.darkModeSubtitle,
                      trailing: Switch(
                        value: preferences.darkModeEnabled,
                        onChanged: (value) => ref
                            .read(appPreferencesProvider.notifier)
                            .updateDarkMode(value),
                      ),
                    ),
                    SettingItem(
                      icon: Icons.notifications_active_rounded,
                      title: context.l10n.notifications,
                      subtitle: context.l10n.notificationsSubtitle,
                      trailing: Switch(
                        value: preferences.notificationsEnabled,
                        onChanged: (value) => ref
                            .read(appPreferencesProvider.notifier)
                            .updateNotifications(value),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AnimatedReveal(
                delay: const Duration(milliseconds: 90),
                child: _SettingsSection(
                  title: context.l10n.dataSection,
                  subtitle: context.l10n.dataSectionSubtitle,
                  children: [
                    SettingItem(
                      icon: Icons.file_download_outlined,
                      title: context.l10n.exportData,
                      subtitle: context.l10n.exportDataSubtitle,
                      onTap: () => _showExportOptions(context, ref),
                    ),
                    SettingItem(
                      icon: Icons.restart_alt_rounded,
                      title: context.l10n.resetData,
                      subtitle: context.l10n.resetDataSubtitle,
                      onTap: () => _confirmReset(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AnimatedReveal(
                delay: const Duration(milliseconds: 120),
                child: _SettingsSection(
                  title: context.l10n.securitySection,
                  subtitle: context.l10n.securitySectionSubtitle,
                  children: [
                    SettingItem(
                      icon: Icons.lock_rounded,
                      title: context.l10n.appLock,
                      subtitle: context.l10n.appLockSubtitle,
                      trailing: Switch(
                        value: preferences.appLockEnabled,
                        onChanged: (value) =>
                            _handleAppLockToggle(context, ref, preferences, value),
                      ),
                    ),
                    SettingItem(
                      icon: Icons.pin_outlined,
                      title: context.l10n.pinSetup,
                      subtitle: preferences.pinCode?.isNotEmpty == true
                          ? context.l10n.pinConfigured
                          : context.l10n.pinSetupSubtitle,
                      onTap: () => _showPinSetupSheet(
                        context,
                        ref,
                        existingPin: preferences.pinCode,
                      ),
                      trailing: Text(
                        preferences.pinCode?.isNotEmpty == true
                            ? '****'
                            : context.l10n.setPin,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AnimatedReveal(
                delay: const Duration(milliseconds: 150),
                child: _SettingsSection(
                  title: context.l10n.aboutSection,
                  subtitle: context.l10n.aboutSectionSubtitle,
                  children: [
                    SettingItem(
                      icon: Icons.info_outline_rounded,
                      title: context.l10n.appVersion,
                      trailing: Text('1.0.0', style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    SettingItem(
                      icon: Icons.code_rounded,
                      title: context.l10n.developer,
                      trailing: Text(
                        'Tiet Kiem',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLanguageSheet(
    BuildContext context,
    WidgetRef ref,
    String currentLanguageCode,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final options = [
      ('vi', context.l10n.vietnamese),
      ('en', context.l10n.english),
    ];

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
      barrierColor: Colors.black.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.42 : 0.34,
      ),
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Material(
            color: scheme.surface,
            elevation: 18,
            shadowColor: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.36 : 0.18,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: scheme.outlineVariant.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.45 : 0.7,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: scheme.outlineVariant.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.chooseLanguage,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                        style: IconButton.styleFrom(
                          backgroundColor: scheme.surfaceContainerHighest,
                          foregroundColor: scheme.onSurfaceVariant,
                        ),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  for (var index = 0; index < options.length; index++) ...[
                    _LanguageOptionTile(
                      label: options[index].$2,
                      selected: options[index].$1 == currentLanguageCode,
                      onTap: () async {
                        await ref
                            .read(appPreferencesProvider.notifier)
                            .updateLanguage(options[index].$1);
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                    ),
                    if (index != options.length - 1) const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showExportOptions(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.data_object_rounded),
                title: Text(context.l10n.exportJson),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _exportData(context, ref, format: _ExportFormat.json);
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart_rounded),
                title: Text(context.l10n.exportCsv),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _exportData(context, ref, format: _ExportFormat.csv);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportData(
    BuildContext context,
    WidgetRef ref, {
    required _ExportFormat format,
  }) async {
    final wallets = ref.read(walletProvider).valueOrNull ?? const <Wallet>[];
    final transactions =
        ref.read(transactionProvider).valueOrNull ?? const <FinanceTransaction>[];
    final categories = ref.read(categoryProvider).valueOrNull ?? const <Category>[];

    final payload = switch (format) {
      _ExportFormat.json => const JsonEncoder.withIndent('  ').convert({
          'exportedAt': DateTime.now().toIso8601String(),
          'wallets': [
            for (final wallet in wallets)
              {
                'id': wallet.id,
                'name': wallet.name,
                'type': wallet.type.name,
                'balance': wallet.balance,
                'color': wallet.color,
                'icon': wallet.icon,
                'createdAt': wallet.createdAt.toIso8601String(),
              },
          ],
          'transactions': [
            for (final transaction in transactions)
              {
                'id': transaction.id,
                'type': transaction.type.name,
                'amount': transaction.amount,
                'walletId': transaction.walletId,
                'targetWalletId': transaction.targetWalletId,
                'categoryId': transaction.categoryId,
                'note': transaction.note,
                'imagePath': transaction.imagePath,
                'status': transaction.status.name,
                'createdAt': transaction.createdAt.toIso8601String(),
              },
          ],
          'categories': [
            for (final category in categories)
              {
                'id': category.id,
                'name': category.name,
                'type': category.type.name,
                'icon': category.icon,
              },
          ],
        }),
      _ExportFormat.csv => _buildCsv(wallets, transactions, categories),
    };

    if (!context.mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.82,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        format == _ExportFormat.json
                            ? context.l10n.exportJson
                            : context.l10n.exportCsv,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: payload));
                        if (sheetContext.mounted) {
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            SnackBar(content: Text(context.l10n.copiedToClipboard)),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy_rounded),
                      label: Text(context.l10n.copy),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: SelectionArea(
                      child: SingleChildScrollView(
                        child: Text(
                          payload,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            height: 1.45,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildCsv(
    List<Wallet> wallets,
    List<FinanceTransaction> transactions,
    List<Category> categories,
  ) {
    final buffer = StringBuffer()
      ..writeln('wallets')
      ..writeln('id,name,type,balance,color,icon,createdAt');
    for (final wallet in wallets) {
      buffer.writeln(
        '${wallet.id},"${wallet.name}",${wallet.type.name},${wallet.balance},'
        '${wallet.color},"${wallet.icon}",${wallet.createdAt.toIso8601String()}',
      );
    }

    buffer
      ..writeln()
      ..writeln('transactions')
      ..writeln(
        'id,type,amount,walletId,targetWalletId,categoryId,note,imagePath,status,createdAt',
      );
    for (final transaction in transactions) {
      buffer.writeln(
        '${transaction.id},${transaction.type.name},${transaction.amount},'
        '${transaction.walletId},${transaction.targetWalletId ?? ''},'
        '${transaction.categoryId},"${transaction.note ?? ''}",'
        '"${transaction.imagePath ?? ''}",${transaction.status.name},'
        '${transaction.createdAt.toIso8601String()}',
      );
    }

    buffer
      ..writeln()
      ..writeln('categories')
      ..writeln('id,name,type,icon');
    for (final category in categories) {
      buffer.writeln(
        '${category.id},"${category.name}",${category.type.name},"${category.icon}"',
      );
    }
    return buffer.toString();
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.resetData),
        content: Text(context.l10n.resetDataPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.reset),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await ref.read(appDataMaintenanceServiceProvider).resetFinanceData();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.dataResetSuccess)),
      );
    }
  }

  Future<void> _handleAppLockToggle(
    BuildContext context,
    WidgetRef ref,
    AppPreferencesState preferences,
    bool enabled,
  ) async {
    if (!enabled) {
      await ref.read(appPreferencesProvider.notifier).updateAppLock(false);
      ref.read(appLockSessionProvider.notifier).unlock();
      return;
    }

    if (preferences.pinCode?.isEmpty ?? true) {
      final configured = await _showPinSetupSheet(context, ref);
      if (configured != true) {
        return;
      }
    }

    await ref.read(appPreferencesProvider.notifier).updateAppLock(true);
    ref.read(appLockSessionProvider.notifier).lock();
  }

  Future<bool?> _showPinSetupSheet(
    BuildContext context,
    WidgetRef ref, {
    String? existingPin,
  }) {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 8,
            bottom: 20 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.pinSetup,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        existingPin?.isNotEmpty == true
                            ? context.l10n.changePinSubtitle
                            : context.l10n.createPinSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: pinController,
                        maxLength: 4,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: context.l10n.enterPin,
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.length != 4) {
                            return context.l10n.pinMustBe4Digits;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: confirmController,
                        maxLength: 4,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: context.l10n.confirmPin,
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value != pinController.text) {
                            return context.l10n.pinDoesNotMatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: () async {
                          if (formKey.currentState?.validate() != true) {
                            return;
                          }
                          await ref.read(appPreferencesProvider.notifier).updatePinCode(
                                pinController.text,
                              );
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop(true);
                          }
                        },
                        icon: const Icon(Icons.check_rounded),
                        label: Text(context.l10n.save),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      pinController.dispose();
      confirmController.dispose();
    });
  }

}

class _SettingsLoadingState extends StatelessWidget {
  const _SettingsLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 180, height: 24),
                    SizedBox(height: 8),
                    SkeletonBox(width: 220, height: 14),
                  ],
                ),
              ),
              SizedBox(width: 16),
              SkeletonBox(width: 56, height: 56, borderRadius: 18),
            ],
          ),
        ),
        const SizedBox(height: 18),
        for (var index = 0; index < 4; index++) ...[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 120, height: 18),
                SizedBox(height: 8),
                SkeletonBox(width: 180, height: 14),
                SizedBox(height: 16),
                SkeletonBox(height: 56, borderRadius: 18),
                SizedBox(height: 12),
                SkeletonBox(height: 56, borderRadius: 18),
              ],
            ),
          ),
          if (index != 3) const SizedBox(height: 18),
        ],
      ],
    );
  }
}

class _SettingsHeroCard extends StatelessWidget {
  const _SettingsHeroCard({
    required this.languageLabel,
    required this.darkModeEnabled,
  });

  final String languageLabel;
  final bool darkModeEnabled;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF121B37), Color(0xFF5B5FF8), Color(0xFFE11976)],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.settingsHeroTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${context.l10n.language}: $languageLabel - '
                  '${darkModeEnabled ? context.l10n.darkMode : context.l10n.lightMode}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.84),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, subtitle: subtitle),
          const SizedBox(height: 12),
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1) const Divider(height: 20),
          ],
        ],
      ),
    );
  }
}

enum _ExportFormat { json, csv }

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? scheme.primaryContainer.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.5 : 0.9,
              )
            : scheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected
                ? scheme.primary.withValues(alpha: 0.65)
                : scheme.outlineVariant.withValues(alpha: 0.8),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          splashColor: scheme.primary.withValues(alpha: 0.1),
          highlightColor: scheme.primary.withValues(alpha: 0.06),
          hoverColor: scheme.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
                if (selected)
                  Icon(Icons.check_rounded, color: scheme.primary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
