import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/wallet/presentation/providers/wallet_provider.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/finance_enums.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/screen_top_header.dart';
import '../../../../shared/widgets/section_header.dart';
import '../providers/notification_import_provider.dart';
import '../../domain/entities/notification_import.dart';

class DetectedTransactionsScreen extends ConsumerStatefulWidget {
  const DetectedTransactionsScreen({super.key});

  @override
  ConsumerState<DetectedTransactionsScreen> createState() =>
      _DetectedTransactionsScreenState();
}

class _DetectedTransactionsScreenState
    extends ConsumerState<DetectedTransactionsScreen> {
  NotificationImportStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final importsAsync = ref.watch(notificationImportProvider);
    final wallets = ref.watch(walletProvider).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text(_detectedListTitle(context))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: AsyncValueView(
            value: importsAsync,
            data: (imports) {
              final filtered = _filter == null
                  ? imports
                  : imports.where((item) => item.status == _filter).toList();
              return ListView(
                children: [
                  ScreenTopHeader(
                    eyebrow: context.l10n.moreTab,
                    title: _detectedListTitle(context),
                    subtitle: _detectedListSubtitle(context),
                    icon: Icons.mark_email_unread_rounded,
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: _detectedFilterTitle(context),
                          subtitle: _detectedFilterSubtitle(context),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _FilterChip(
                              label: context.l10n.all,
                              selected: _filter == null,
                              onTap: () => setState(() => _filter = null),
                            ),
                            for (final status in NotificationImportStatus.values)
                              _FilterChip(
                                label: _statusLabel(context, status),
                                selected: _filter == status,
                                onTap: () => setState(() => _filter = status),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (filtered.isEmpty)
                    EmptyState(
                      title: _emptyDetectedTitle(context),
                      message: _emptyDetectedSubtitle(context),
                      icon: Icons.notifications_none_rounded,
                    )
                  else
                    Column(
                      children: [
                        for (var index = 0; index < filtered.length; index++) ...[
                          _DetectedImportCard(
                            entry: filtered[index],
                            walletName: wallets
                                    .where((wallet) => wallet.id == filtered[index].walletId)
                                    .firstOrNull
                                    ?.name ??
                                context.l10n.unknownWallet,
                            onReview: () => ref
                                .read(notificationImportProvider.notifier)
                                .reopenImport(filtered[index].id),
                            onDismiss: () => ref
                                .read(notificationImportProvider.notifier)
                                .dismissImport(filtered[index].id),
                            onQuickAdd: () async {
                              final success = await ref
                                  .read(notificationImportProvider.notifier)
                                  .quickConfirmImport(filtered[index].id);
                              if (!context.mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? _quickAddSuccess(context)
                                        : _quickAddFailed(context),
                                  ),
                                ),
                              );
                            },
                            onOpenTransaction: filtered[index].createdTransactionId == null
                                ? null
                                : () => context.pushNamed(
                                      'transactionDetail',
                                      pathParameters: {
                                        'id': filtered[index].createdTransactionId!,
                                      },
                                    ),
                          ),
                          if (index != filtered.length - 1)
                            const SizedBox(height: 12),
                        ],
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DetectedImportCard extends StatelessWidget {
  const _DetectedImportCard({
    required this.entry,
    required this.walletName,
    required this.onReview,
    required this.onDismiss,
    required this.onQuickAdd,
    required this.onOpenTransaction,
  });

  final NotificationImportEntry entry;
  final String walletName;
  final VoidCallback onReview;
  final VoidCallback onDismiss;
  final VoidCallback onQuickAdd;
  final VoidCallback? onOpenTransaction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  entry.inferredType == TransactionType.income
                      ? Icons.south_west_rounded
                      : Icons.north_east_rounded,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.bankName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      walletName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: entry.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formatCurrency(context, entry.amount),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            formatDateTime(context, entry.detectedAt.toLocal()),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          if (entry.body?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              entry.body!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (entry.status == NotificationImportStatus.pending)
                FilledButton.icon(
                  onPressed: onQuickAdd,
                  icon: const Icon(Icons.add_task_rounded),
                  label: Text(_quickAddLabel(context)),
                ),
              if (entry.status != NotificationImportStatus.pending)
                OutlinedButton.icon(
                  onPressed: onReview,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(_reviewLabel(context)),
                ),
              if (entry.status == NotificationImportStatus.pending)
                OutlinedButton.icon(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.visibility_off_rounded),
                  label: Text(_dismissLabel(context)),
                ),
              if (onOpenTransaction != null)
                FilledButton.icon(
                  onPressed: onOpenTransaction,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: Text(_openTransactionLabel(context)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final NotificationImportStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (status) {
      NotificationImportStatus.pending => const Color(0xFFF59E0B),
      NotificationImportStatus.accepted => const Color(0xFF16A34A),
      NotificationImportStatus.dismissed => scheme.outline,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(context, status),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

String _detectedListTitle(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Giao dịch phát hiện'
        : 'Detected transactions';

String _detectedListSubtitle(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Xem lại các giao dịch app phát hiện từ thông báo ngân hàng, kể cả những mục bạn đã bỏ qua.'
        : 'Review transactions detected from bank notifications, including the ones you dismissed earlier.';

String _detectedFilterTitle(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Bộ lọc'
        : 'Filters';

String _detectedFilterSubtitle(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Lọc theo trạng thái xử lý'
        : 'Filter by review status';

String _emptyDetectedTitle(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Chưa có giao dịch phát hiện'
        : 'No detected transactions yet';

String _emptyDetectedSubtitle(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Khi app nhận diện được thông báo ngân hàng, các mục sẽ hiện ở đây để bạn xem lại.'
        : 'Detected bank notifications will appear here for review.';

String _statusLabel(BuildContext context, NotificationImportStatus status) {
  final isVi = Localizations.localeOf(context).languageCode == 'vi';
  return switch (status) {
    NotificationImportStatus.pending => isVi ? 'Chờ xác nhận' : 'Pending',
    NotificationImportStatus.accepted => isVi ? 'Đã thêm' : 'Accepted',
    NotificationImportStatus.dismissed => isVi ? 'Đã bỏ qua' : 'Dismissed',
  };
}

String _reviewLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Xem lại'
        : 'Review';

String _dismissLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Bỏ qua'
        : 'Dismiss';

String _openTransactionLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Mở giao dịch'
        : 'Open transaction';

String _quickAddLabel(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Thêm nhanh'
        : 'Quick add';

String _quickAddSuccess(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Đã thêm giao dịch vào ví.'
        : 'Transaction added to the wallet.';

String _quickAddFailed(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'vi'
        ? 'Chưa thể thêm nhanh. Ví này chưa có danh mục phù hợp.'
        : 'Quick add is unavailable because the wallet has no matching category.';
