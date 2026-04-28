import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/l10n.dart';
import '../../../../shared/finance_enums.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/skeleton_box.dart';
import '../../../../shared/widgets/wallet_card.dart';
import '../../domain/entities/wallet.dart';
import '../providers/wallet_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.walletsTitle)),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: AsyncValueView(
          value: walletsAsync,
          loadingBuilder: (_) => const _WalletsLoadingState(),
          data: (wallets) {
            final totalBalance =
                wallets.fold<double>(0, (sum, wallet) => sum + wallet.balance);

            return ListView(
              padding: const EdgeInsets.only(bottom: 120),
              children: [
                SectionHeader(
                  title: context.l10n.allWallets,
                  subtitle: context.l10n.walletsTotal(
                    wallets.length,
                    formatCurrency(context, totalBalance),
                  ),
                  actionLabel: context.l10n.add,
                  onAction: () => showWalletSheet(context),
                ),
                const SizedBox(height: 14),
                if (wallets.isEmpty)
                  EmptyState(
                    title: context.l10n.noWalletsCreated,
                    message: context.l10n.addCashBankSavingWallet,
                    icon: Icons.account_balance_wallet_rounded,
                    actionLabel: context.l10n.createWallet,
                    onAction: () => showWalletSheet(context),
                  )
                else
                  ...wallets.map(
                    (wallet) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: ValueKey(wallet.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        onDismissed: (_) =>
                            _deleteWallet(context, ref, wallet.id),
                        child: WalletCard(
                          wallet: wallet,
                          compact: true,
                          onTap: () => showWalletSheet(context, wallet: wallet),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _deleteWallet(
    BuildContext context,
    WidgetRef ref,
    String walletId,
  ) async {
    try {
      await ref.read(walletProvider.notifier).deleteWallet(walletId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.walletDeleted)),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizeError(context, error))),
        );
      }
    }
  }
}

class _WalletsLoadingState extends StatelessWidget {
  const _WalletsLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        const SkeletonBox(width: 180, height: 24),
        const SizedBox(height: 8),
        const SkeletonBox(width: 220, height: 14),
        const SizedBox(height: 18),
        for (var index = 0; index < 3; index++) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 320;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SkeletonBox(
                          height: narrow ? 36 : 40,
                          width: narrow ? 36 : 40,
                          shape: BoxShape.circle,
                        ),
                        const Spacer(),
                        SkeletonBox(
                          width: narrow ? 62 : 72,
                          height: narrow ? 24 : 28,
                          borderRadius: 999,
                        ),
                      ],
                    ),
                    SizedBox(height: narrow ? 12 : 16),
                    SkeletonBox(width: narrow ? 108 : 120, height: narrow ? 16 : 18),
                    const SizedBox(height: 8),
                    SkeletonBox(width: narrow ? 82 : 90, height: 14),
                    SizedBox(height: narrow ? 14 : 18),
                    SkeletonBox(width: narrow ? 122 : 140, height: narrow ? 22 : 26),
                  ],
                );
              },
            ),
          ),
          if (index != 2) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

Future<void> showWalletSheet(BuildContext context, {Wallet? wallet}) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => WalletSheet(wallet: wallet),
    ),
  );
}

class WalletSheet extends ConsumerStatefulWidget {
  const WalletSheet({super.key, this.wallet});

  final Wallet? wallet;

  @override
  ConsumerState<WalletSheet> createState() => _WalletSheetState();
}

class _WalletSheetState extends ConsumerState<WalletSheet> {
  static const _colors = [0xFFE11976, 0xFF2E90FA, 0xFF7A5AF8, 0xFF16B364];
  static const _icons = ['account_balance_wallet', 'account_balance', 'savings'];

  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late WalletType _type;
  late int _color;
  late String _icon;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final wallet = widget.wallet;
    _nameController = TextEditingController(text: wallet?.name ?? '');
    _balanceController = TextEditingController(
      text: wallet == null ? '0' : wallet.balance.toStringAsFixed(2),
    );
    _type = wallet?.type ?? WalletType.cash;
    _color = wallet?.color ?? _colors.first;
    _icon = wallet?.icon ?? _icons.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    final viewPaddingBottom = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          widget.wallet == null
              ? context.l10n.createWalletTitle
              : context.l10n.editWalletTitle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                autofocus: widget.wallet == null,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: context.l10n.walletName),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _balanceController,
                decoration: InputDecoration(labelText: context.l10n.openingBalance),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<WalletType>(
                initialValue: _type,
                decoration: InputDecoration(labelText: context.l10n.walletType),
                items: WalletType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label(context)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _type = value);
                  }
                },
              ),
              const SizedBox(height: 14),
              _ChoiceLabel(title: context.l10n.color),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _colors.map((color) {
                  final selected = _color == color;
                  return GestureDetector(
                    onTap: () => setState(() => _color = color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? Colors.black : Colors.white,
                          width: selected ? 2.5 : 0,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check_rounded, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              _ChoiceLabel(title: context.l10n.icon),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _icons.map((icon) {
                  final selected = _icon == icon;
                  return ChoiceChip(
                    label: Text(localizeIconLabel(context, icon)),
                    selected: selected,
                    avatar: Icon(_resolveWalletIcon(icon)),
                    onSelected: (_) => setState(() => _icon = icon),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          16 + viewPaddingBottom + viewInsetsBottom,
        ),
        child: SafeArea(
          top: false,
          child: AppButton(
            label: widget.wallet == null
                ? context.l10n.createWallet
                : context.l10n.saveChanges,
            icon: Icons.account_balance_wallet_rounded,
            isLoading: _saving,
            onPressed: _save,
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final balance = double.tryParse(_balanceController.text.trim());
    if (balance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.enterValidOpeningBalance)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(walletProvider.notifier).saveWallet(
            id: widget.wallet?.id,
            name: _nameController.text,
            type: _type,
            balance: balance,
            color: _color,
            icon: _icon,
          );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizeError(context, error))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  IconData _resolveWalletIcon(String icon) => switch (icon) {
        'account_balance_wallet' => Icons.account_balance_wallet_rounded,
        'account_balance' => Icons.account_balance_rounded,
        'savings' => Icons.savings_rounded,
        _ => Icons.wallet_rounded,
      };
}

class _ChoiceLabel extends StatelessWidget {
  const _ChoiceLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
