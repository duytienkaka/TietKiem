import 'package:flutter/material.dart';

import 'receipt_image.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.avatarPath,
    this.onAvatarTap,
  });

  final String name;
  final String email;
  final String? avatarPath;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE11976), Color(0xFF6D3DF5)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: ClipOval(
                  child: avatarPath?.isNotEmpty == true
                      ? ReceiptImage(
                          source: avatarPath!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.white.withValues(alpha: 0.14),
                          alignment: Alignment.center,
                          child: Text(
                            _initials(name),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                ),
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Material(
                color: theme.colorScheme.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onAvatarTap,
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          name,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (email.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            email,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  String _initials(String value) {
    final words = value.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (words.isEmpty) {
      return 'PL';
    }
    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }
    return '${words.first.substring(0, 1)}${words.last.substring(0, 1)}'.toUpperCase();
  }
}
