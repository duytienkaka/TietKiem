import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../features/transaction/presentation/providers/transaction_provider.dart';
import '../../features/wallet/presentation/providers/wallet_provider.dart';
import '../../l10n/l10n.dart';
import '../models/app_preferences_state.dart';
import '../providers/app_preferences_provider.dart';
import '../services/picked_image_storage.dart';
import '../widgets/animated_reveal.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/async_value_view.dart';
import '../widgets/profile_header.dart';
import '../widgets/section_header.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(appPreferencesProvider);
    final walletsAsync = ref.watch(walletProvider);
    final transactionsAsync = ref.watch(transactionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.profileTitle)),
      body: AsyncValueView(
        value: preferencesAsync,
        data: (preferences) => AsyncValueView(
          value: walletsAsync,
          data: (wallets) => AsyncValueView(
            value: transactionsAsync,
            data: (transactions) {
              final totalBalance = wallets.fold<double>(
                0,
                (sum, wallet) => sum + wallet.balance,
              );

              return SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    AnimatedReveal(
                      child: AppCard(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFE11976), Color(0xFF7B3FF2), Color(0xFF151B36)],
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                        child: Column(
                          children: [
                            ProfileHeader(
                              name: preferences.profileName,
                              email: preferences.profileEmail,
                              avatarPath: preferences.avatarPath,
                              onAvatarTap: () => _changeAvatar(context, ref),
                            ),
                            const SizedBox(height: 20),
                            AppButton(
                              label: context.l10n.editProfile,
                              expanded: false,
                              icon: Icons.edit_rounded,
                              onPressed: () => _showEditProfileSheet(
                                context,
                                ref,
                                preferences,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedReveal(
                      delay: const Duration(milliseconds: 40),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              title: context.l10n.quickOverview,
                              subtitle: context.l10n.financeSnapshot,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _ProfileStatCard(
                                    icon: Icons.account_balance_wallet_rounded,
                                    label: context.l10n.totalBalance,
                                    value: formatCurrency(context, totalBalance),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _ProfileStatCard(
                                    icon: Icons.receipt_long_rounded,
                                    label: context.l10n.totalTransactions,
                                    value: '${transactions.length}',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedReveal(
                      delay: const Duration(milliseconds: 80),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(title: context.l10n.personalInformation),
                            const SizedBox(height: 16),
                            _InfoTile(
                              icon: Icons.person_rounded,
                              label: context.l10n.fullName,
                              value: preferences.profileName,
                            ),
                            const SizedBox(height: 14),
                            _InfoTile(
                              icon: Icons.mail_rounded,
                              label: context.l10n.emailOptional,
                              value: preferences.profileEmail.trim().isEmpty
                                  ? context.l10n.notUpdatedYet
                                  : preferences.profileEmail,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _changeAvatar(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final selection = await showModalBottomSheet<_AvatarSelection>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded),
                title: Text(context.l10n.camera),
                onTap: () => Navigator.of(sheetContext).pop(_AvatarSelection.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: Text(context.l10n.gallery),
                onTap: () => Navigator.of(sheetContext).pop(_AvatarSelection.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: Text(context.l10n.removeAvatar),
                onTap: () => Navigator.of(sheetContext).pop(_AvatarSelection.remove),
              ),
            ],
          ),
        ),
      ),
    );

    if (!context.mounted) {
      return;
    }

    if (selection == null) {
      return;
    }

    if (selection == _AvatarSelection.remove) {
      await ref.read(appPreferencesProvider.notifier).updateAvatar(null);
      return;
    }

    final file = await picker.pickImage(
      source: selection == _AvatarSelection.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 1080,
    );
    if (file == null) {
      return;
    }

    final savedPath = await savePickedImage(file);
    await ref.read(appPreferencesProvider.notifier).updateAvatar(savedPath);
  }

  Future<void> _showEditProfileSheet(
    BuildContext context,
    WidgetRef ref,
    AppPreferencesState preferences,
  ) async {
    final nameController = TextEditingController(text: preferences.profileName);
    final emailController = TextEditingController(text: preferences.profileEmail);
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: 20 + MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.editProfile,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: context.l10n.fullName),
                validator: (value) => value == null || value.trim().isEmpty
                    ? context.l10n.fullNameRequired
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(labelText: context.l10n.emailOptional),
              ),
              const SizedBox(height: 18),
              AppButton(
                label: context.l10n.save,
                icon: Icons.check_rounded,
                onPressed: () async {
                  if (formKey.currentState?.validate() != true) {
                    return;
                  }
                  await ref.read(appPreferencesProvider.notifier).updateProfile(
                        name: nameController.text,
                        email: emailController.text,
                      );
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );

    nameController.dispose();
    emailController.dispose();
  }
}

enum _AvatarSelection { camera, gallery, remove }

class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
