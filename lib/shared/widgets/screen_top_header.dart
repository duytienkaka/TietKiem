import 'package:flutter/material.dart';

import 'skeleton_box.dart';

class ScreenTopHeader extends StatelessWidget {
  const ScreenTopHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.eyebrow,
    this.trailing,
    this.actionLabel,
    this.onAction,
    this.showBackButton = false,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? eyebrow;
  final Widget? trailing;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showBackButton;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 420;
        final accent = trailing ??
            _HeaderAccent(
              icon: icon,
              actionLabel: actionLabel,
              onAction: onAction,
            );

        return Container(
          padding: EdgeInsets.fromLTRB(
            narrow ? 14 : 16,
            narrow ? 14 : 16,
            narrow ? 14 : 16,
            narrow ? 14 : 16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFDF2F8), Color(0xFFF5F3FF), Color(0xFFEFF8FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: narrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showBackButton) ...[
                          _HeaderButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: onBack ?? () => Navigator.of(context).maybePop(),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(child: _HeaderTextBlock(title: title, subtitle: subtitle, eyebrow: eyebrow)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.centerRight, child: accent),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showBackButton) ...[
                      _HeaderButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: onBack ?? () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: _HeaderTextBlock(
                        title: title,
                        subtitle: subtitle,
                        eyebrow: eyebrow,
                      ),
                    ),
                    const SizedBox(width: 12),
                    accent,
                  ],
                ),
        );
      },
    );
  }
}

class _HeaderTextBlock extends StatelessWidget {
  const _HeaderTextBlock({
    required this.title,
    required this.subtitle,
    this.eyebrow,
  });

  final String title;
  final String subtitle;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF101828),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: const Color(0xFF344054)),
        ),
      ),
    );
  }
}

class _HeaderAccent extends StatelessWidget {
  const _HeaderAccent({
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    if (actionLabel != null && onAction != null) {
      return FilledButton.icon(
        onPressed: onAction,
        icon: Icon(icon, size: 18),
        label: Text(actionLabel!),
      );
    }

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF344054)),
    );
  }
}

class ScreenTopHeaderSkeleton extends StatelessWidget {
  const ScreenTopHeaderSkeleton({
    super.key,
    this.showBackButton = false,
    this.showAction = false,
  });

  final bool showBackButton;
  final bool showAction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 420;
        return Container(
          padding: EdgeInsets.fromLTRB(
            narrow ? 14 : 16,
            narrow ? 14 : 16,
            narrow ? 14 : 16,
            narrow ? 14 : 16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFDF2F8), Color(0xFFF5F3FF), Color(0xFFEFF8FF)],
            ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showBackButton) ...[
                    const SkeletonBox(width: 44, height: 44, borderRadius: 16),
                    const SizedBox(width: 12),
                  ],
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 96, height: 12, borderRadius: 999),
                        SizedBox(height: 6),
                        SkeletonBox(width: 156, height: 22),
                        SizedBox(height: 6),
                        SkeletonBox(width: double.infinity, height: 12),
                        SizedBox(height: 4),
                        SkeletonBox(width: 190, height: 12),
                      ],
                    ),
                  ),
                  if (!narrow) ...[
                    const SizedBox(width: 12),
                    SkeletonBox(
                      width: 46,
                      height: 46,
                      borderRadius: 16,
                    ),
                  ],
                ],
              ),
              if (narrow) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: SkeletonBox(
                    width: showAction ? 104 : 46,
                    height: 42,
                    borderRadius: 16,
                  ),
                ),
              ] else if (showAction) ...[
                const SizedBox(height: 0),
              ],
            ],
          ),
        );
      },
    );
  }
}
