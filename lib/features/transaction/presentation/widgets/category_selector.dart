import 'package:flutter/material.dart';

import '../../../category/domain/entities/category.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/app_icon.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 10,
      runSpacing: 12,
      children: categories.map((category) {
        final selected = category.id == selectedId;
        return GestureDetector(
          onTap: () => onSelected(category.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 74,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? scheme.primaryContainer : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? scheme.primary.withValues(alpha: 0.38)
                    : scheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 180),
                  scale: selected ? 1.04 : 1,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: selected
                        ? Colors.white
                        : scheme.surfaceContainerHighest,
                    child: Icon(
                      resolveIcon(category.icon),
                      size: 18,
                      color: selected ? scheme.primary : const Color(0xFF667085),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category.displayName(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
