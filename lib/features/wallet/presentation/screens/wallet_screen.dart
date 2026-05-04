import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/l10n.dart';
import '../../../../shared/finance_enums.dart';
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
              final bankCount = wallets
                  .where((wallet) => wallet.type == WalletType.bank)
                  .length;
              final cashCount = wallets
                  .where((wallet) => wallet.type == WalletType.cash)
                  .length;

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
                  AppButton(
                    label: context.l10n.createWallet,
                    icon: Icons.add_rounded,
                    expanded: false,
                    onPressed: () => showWalletSheet(context),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _WalletOverviewCard(
                          title: context.l10n.totalBalance,
                          value: formatCurrency(context, totalBalance),
                          icon: Icons.savings_rounded,
                          accent: const Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _WalletOverviewCard(
                          title: context.l10n.accountWallets,
                          value: bankCount.toString(),
                          icon: Icons.account_balance_rounded,
                          accent: const Color(0xFF16B364),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _WalletOverviewCard(
                    title: context.l10n.cashWallets,
                    value: cashCount.toString(),
                    icon: Icons.payments_rounded,
                    accent: const Color(0xFFE11D48),
                    compact: true,
                  ),
                  const SizedBox(height: 16),
                  if (wallets.isEmpty)
                    EmptyState(
                      title: context.l10n.noWalletsCreated,
                      message: context.l10n.createWalletStart,
                      icon: Icons.account_balance_wallet_rounded,
                      actionLabel: context.l10n.createWallet,
                      onAction: () => showWalletSheet(context),
                    )
                  else ...[
                    Text(
                      context.l10n.walletPortfolio,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.walletPortfolioSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...wallets.map(
                      (wallet) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: WalletCard(
                          wallet: wallet,
                          compact: true,
                          onTap: () => context.pushNamed(
                            'walletDetail',
                            pathParameters: {'id': wallet.id},
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WalletOverviewCard extends StatelessWidget {
  const _WalletOverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    this.compact = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  style:
                      (compact
                              ? Theme.of(context).textTheme.titleMedium
                              : Theme.of(context).textTheme.titleLarge)
                          ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
        const SkeletonBox(height: 56, borderRadius: 18),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(child: SkeletonBox(height: 90, borderRadius: 22)),
            SizedBox(width: 12),
            Expanded(child: SkeletonBox(height: 90, borderRadius: 22)),
          ],
        ),
        const SizedBox(height: 12),
        const SkeletonBox(height: 90, borderRadius: 22),
        const SizedBox(height: 16),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SkeletonBox(height: 40, width: 40, shape: BoxShape.circle),
                    Spacer(),
                    SkeletonBox(width: 72, height: 28, borderRadius: 999),
                  ],
                ),
                SizedBox(height: 16),
                SkeletonBox(width: 120, height: 18),
                SizedBox(height: 8),
                SkeletonBox(width: 90, height: 14),
                SizedBox(height: 18),
                SkeletonBox(width: 140, height: 26),
              ],
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
  static const _icons = ['account_balance_wallet', 'account_balance'];

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
    _type = wallet?.type == WalletType.saving
        ? WalletType.bank
        : wallet?.type ?? WalletType.cash;
    _color = wallet?.color ?? 0xFFE11976;
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
                        items: const [WalletType.cash, WalletType.bank]
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
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Color(_color),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '#${_color.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _ColorSlider(
                              label: 'R',
                              value: _channelValue(Color(_color).r),
                              activeColor: Colors.red,
                              onChanged: (value) =>
                                  _updateColor(red: value.round()),
                            ),
                            _ColorSlider(
                              label: 'G',
                              value: _channelValue(Color(_color).g),
                              activeColor: Colors.green,
                              onChanged: (value) =>
                                  _updateColor(green: value.round()),
                            ),
                            _ColorSlider(
                              label: 'B',
                              value: _channelValue(Color(_color).b),
                              activeColor: Colors.blue,
                              onChanged: (value) =>
                                  _updateColor(blue: value.round()),
                            ),
                          ],
                        ),
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
            bankName: widget.wallet?.bankName,
            bankAliases: widget.wallet?.bankAliases,
            accountNumber: widget.wallet?.accountNumber,
            accountHolder: widget.wallet?.accountHolder,
            paymentNote: widget.wallet?.paymentNote,
            qrImagePath: widget.wallet?.qrImagePath,
            qrPayload: widget.wallet?.qrPayload,
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

  void _updateColor({int? red, int? green, int? blue}) {
    final current = Color(_color);
    setState(() {
      _color = Color.fromARGB(
        255,
        red ?? _channelInt(current.r),
        green ?? _channelInt(current.g),
        blue ?? _channelInt(current.b),
      ).toARGB32();
    });
  }

  double _channelValue(double value) => _channelInt(value).toDouble();

  int _channelInt(double value) => (value * 255).round().clamp(0, 255);

  IconData _resolveWalletIcon(String icon) => switch (icon) {
    'account_balance_wallet' => Icons.account_balance_wallet_rounded,
    'account_balance' => Icons.account_balance_rounded,
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

class _ColorSlider extends StatelessWidget {
  const _ColorSlider({
    required this.label,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  final String label;
  final double value;
  final Color activeColor;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 18,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: activeColor,
              thumbColor: activeColor,
              overlayColor: activeColor.withValues(alpha: 0.16),
            ),
            child: Slider(value: value, min: 0, max: 255, onChanged: onChanged),
          ),
        ),
        SizedBox(
          width: 34,
          child: Text(
            value.round().toString(),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
