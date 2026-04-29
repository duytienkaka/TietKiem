import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/l10n.dart';
import '../../../../shared/finance_enums.dart';
import '../../../../shared/services/supabase_remote_data_source.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/screen_top_header.dart';
import '../../../../shared/widgets/skeleton_box.dart';
import '../../../../shared/widgets/wallet_card.dart';
import '../../../../shared/utils/currency_input_formatter.dart';
import '../../domain/entities/wallet.dart';
import '../providers/wallet_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: AsyncValueView(
            value: walletsAsync,
            loadingBuilder: (_) => const _WalletsLoadingState(),
            data: (wallets) {
              final totalBalance = wallets.fold<double>(
                0,
                (sum, wallet) => sum + wallet.balance,
              );

              return ListView(
                padding: const EdgeInsets.only(bottom: 120),
                children: [
                  ScreenTopHeader(
                    eyebrow: context.l10n.walletsTitle,
                    title: context.l10n.allWallets,
                    subtitle: context.l10n.walletsTotal(
                      wallets.length,
                      formatCurrency(context, totalBalance),
                    ),
                    icon: Icons.account_balance_wallet_rounded,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () => showWalletSheet(context),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(context.l10n.add),
                    ),
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
                              color: Theme.of(
                                context,
                              ).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          onDismissed: (_) =>
                              _deleteWallet(context, ref, wallet.id),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              WalletCard(
                                wallet: wallet,
                                compact: true,
                                onTap: () =>
                                    showWalletSheet(context, wallet: wallet),
                              ),
                              const SizedBox(height: 8),
                              FilledButton.tonalIcon(
                                onPressed: () => _showInviteWalletSheet(
                                  context,
                                  ref,
                                  wallet,
                                ),
                                icon: const Icon(
                                  Icons.person_add_alt_1_rounded,
                                ),
                                label: Text(context.l10n.inviteUser),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.walletDeleted)));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizeError(context, error))));
      }
    }
  }

  Future<void> _showInviteWalletSheet(
    BuildContext context,
    WidgetRef ref,
    Wallet wallet,
  ) async {
    final controller = TextEditingController();
    var inviting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      barrierColor: Colors.black.withValues(alpha: 0.36),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                20 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.inviteUserTitle(wallet.name),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.inviteUserSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.emailAddress,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: context.l10n.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: inviting
                            ? null
                            : () async {
                                final email = controller.text
                                    .trim()
                                    .toLowerCase();
                                if (email.isEmpty) {
                                  return;
                                }
                                setSheetState(() => inviting = true);
                                try {
                                  await ref
                                      .read(supabaseRemoteDataSourceProvider)
                                      .inviteUserToWallet(
                                        walletId: wallet.id,
                                        email: email,
                                      );
                                  if (sheetContext.mounted) {
                                    Navigator.of(sheetContext).pop();
                                  }
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          context.l10n.invitationSent(email),
                                        ),
                                      ),
                                    );
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
                                    setSheetState(() => inviting = false);
                                  }
                                }
                              },
                        icon: inviting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(context.l10n.inviteUser),
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

    controller.dispose();
  }
}

class _WalletsLoadingState extends StatelessWidget {
  const _WalletsLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        const ScreenTopHeaderSkeleton(showAction: true),
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
                    SkeletonBox(
                      width: narrow ? 108 : 120,
                      height: narrow ? 16 : 18,
                    ),
                    const SizedBox(height: 8),
                    SkeletonBox(width: narrow ? 82 : 90, height: 14),
                    SizedBox(height: narrow ? 14 : 18),
                    SkeletonBox(
                      width: narrow ? 122 : 140,
                      height: narrow ? 22 : 26,
                    ),
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
  static const _icons = [
    'account_balance_wallet',
    'account_balance',
    'savings',
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  final FocusNode _balanceFocusNode = FocusNode();
  late WalletType _type;
  late int _color;
  late String _icon;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final wallet = widget.wallet;
    _nameController = TextEditingController(text: wallet?.name ?? '');
    _balanceController = wallet == null
        ? TextEditingController()
        : TextEditingController.fromValue(
            currencyEditingValueFromInt(wallet.balance.round()),
          );
    _type = wallet?.type ?? WalletType.cash;
    _color = wallet?.color ?? _colors.first;
    _icon = wallet?.icon ?? _icons.first;
  }

  @override
  void dispose() {
    _balanceFocusNode.unfocus();
    _nameController.dispose();
    _balanceController.dispose();
    _balanceFocusNode.dispose();
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _nameController,
                        autofocus: widget.wallet == null,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: context.l10n.walletName,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _balanceController,
                        focusNode: _balanceFocusNode,
                        decoration: InputDecoration(
                          labelText: context.l10n.openingBalance,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [VietnameseCurrencyInputFormatter()],
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _save(),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<WalletType>(
                        initialValue: _type,
                        decoration: InputDecoration(
                          labelText: context.l10n.walletType,
                        ),
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
                                  color: selected
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Theme.of(context).colorScheme.surface,
                                  width: selected ? 2.5 : 0,
                                ),
                              ),
                              child: selected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                    )
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
                            label: Text(
                              localizeIconLabel(context, icon),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
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
            ),
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
    final balance = parseVietnameseCurrency(
      _balanceController.text.trim(),
    ).toDouble();
    if (_balanceController.text.trim().isEmpty && widget.wallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.enterValidOpeningBalance)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      FocusScope.of(context).unfocus();
      await ref
          .read(walletProvider.notifier)
          .saveWallet(
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
