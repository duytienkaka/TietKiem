import 'package:flutter/material.dart';

import '../../features/wallet/domain/entities/wallet.dart';
import '../../l10n/l10n.dart';
import 'app_icon.dart';

class WalletCard extends StatelessWidget {
  const WalletCard({
    super.key,
    required this.wallet,
    this.onTap,
    this.compact = false,
  });

  final Wallet wallet;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(compact ? 18 : 22);
    final content = Container(
      width: compact ? null : 260,
      padding: EdgeInsets.all(compact ? 16 : 20),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(wallet.color),
            Color(wallet.color).withValues(alpha: 0.86),
            const Color(0xFF1E1B4B),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(wallet.color).withValues(alpha: 0.24),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hasBoundedHeight =
                constraints.hasBoundedHeight && constraints.maxHeight.isFinite;
            final contentHeight = hasBoundedHeight ? constraints.maxHeight : null;
            final isDense = hasBoundedHeight && (contentHeight ?? 0) < (compact ? 148 : 172);
            final showFooter = !compact && (!hasBoundedHeight || (contentHeight ?? 0) >= 168);
            final headerAvatarRadius = compact ? 20.0 : (isDense ? 22.0 : 24.0);
            final sectionGap = compact ? 10.0 : (isDense ? 12.0 : 16.0);
            final amountBottomGap = showFooter ? 10.0 : 0.0;
            final body = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  hasBoundedHeight ? MainAxisAlignment.end : MainAxisAlignment.start,
              mainAxisSize: hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
              children: [
                Text(
                  wallet.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  compact ? context.l10n.availableBalance : context.l10n.primaryAccount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                ),
                if (hasBoundedHeight) const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatCurrency(context, wallet.balance),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                if (showFooter) ...[
                  SizedBox(height: amountBottomGap),
                  Row(
                    children: [
                      Icon(
                        Icons.shield_moon_rounded,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          context.l10n.securedWallet,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.82),
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );

            return ConstrainedBox(
              constraints: hasBoundedHeight
                  ? const BoxConstraints()
                  : BoxConstraints(minHeight: compact ? 132 : 148),
              child: Column(
                mainAxisSize: hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: headerAvatarRadius,
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        child: Icon(resolveIcon(wallet.icon), color: Colors.white),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              wallet.type.label(context),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sectionGap),
                  if (hasBoundedHeight) Expanded(child: body) else body,
                ],
              ),
            );
          },
        ),
      ),
    );

    if (onTap == null) {
      return content;
    }

    return GestureDetector(
      onTap: onTap,
      child: content,
    );
  }
}
