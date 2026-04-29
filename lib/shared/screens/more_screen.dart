import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';
import '../widgets/app_card.dart';
import '../widgets/screen_top_header.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_MoreItem>[
      _MoreItem(
        title: context.l10n.calculator,
        subtitle: 'Tính nhanh số tiền trước khi tạo giao dịch',
        icon: Icons.calculate_rounded,
        accent: const Color(0xFF2E90FA),
        onTap: () => context.push('/more/calculator'),
      ),
      _MoreItem(
        title: context.l10n.recurringTitle,
        subtitle: 'Quản lý các khoản thu chi lặp lại theo chu kỳ',
        icon: Icons.autorenew_rounded,
        accent: const Color(0xFF16B364),
        onTap: () => context.push('/more/recurring'),
      ),
      _MoreItem(
        title: context.l10n.budgetsTitle,
        subtitle: 'Theo dõi hạn mức chi tiêu theo từng danh mục',
        icon: Icons.account_balance_wallet_rounded,
        accent: const Color(0xFFE11976),
        onTap: () => context.push('/more/budgets'),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              const ScreenTopHeader(
                eyebrow: 'Khác',
                title: 'Tiện ích mở rộng',
                subtitle:
                    'Các công cụ bổ sung để quản lý tài chính thuận tiện hơn',
                icon: Icons.grid_view_rounded,
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _MoreCard(item: item);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreCard extends StatelessWidget {
  const _MoreCard({required this.item});

  final _MoreItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      onTap: item.onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: item.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(item.icon, color: item.accent, size: 26),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_outward_rounded,
                color: scheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
          const Spacer(),
          Text(
            item.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            item.subtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreItem {
  const _MoreItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
}
