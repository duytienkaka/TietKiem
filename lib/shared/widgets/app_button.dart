import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.expanded = true,
    this.isLoading = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expanded;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = FilledButton.styleFrom(
      minimumSize: Size(expanded ? double.infinity : 0, 58),
      maximumSize: Size(expanded ? double.infinity : double.infinity, 58),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );

    if (icon == null && !isLoading) {
      return FilledButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: Text(label),
      );
    }

    return FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : icon == null
              ? const SizedBox.shrink()
              : Icon(icon, size: 20),
      label: Text(label),
    );
  }
}
