import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/l10n.dart';
import '../../../../shared/services/supabase_remote_data_source.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUp = false;
  bool _submitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: Stack(
        children: [
          const _AuthBackdrop(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
                    _AuthHero(
                      title: _isSignUp
                          ? context.l10n.signUpTitle
                          : context.l10n.signInTitle,
                      subtitle: _isSignUp
                          ? context.l10n.signUpSubtitle
                          : context.l10n.signInSubtitle,
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.84),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF101828,
                                ).withValues(alpha: 0.08),
                                blurRadius: 32,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(22),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ModeSwitcher(
                                    isSignUp: _isSignUp,
                                    onChanged: (value) {
                                      setState(() => _isSignUp = value);
                                    },
                                  ),
                                  const SizedBox(height: 22),
                                  Text(
                                    _isSignUp
                                        ? 'Tạo tài khoản để đồng bộ dữ liệu trên nhiều thiết bị'
                                        : 'Đăng nhập để tiếp tục theo dõi ví và giao dịch của bạn',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF111827),
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    context.l10n.authHeroSubtitle,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF667085),
                                      height: 1.45,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  _TrustPanel(isSignUp: _isSignUp),
                                  const SizedBox(height: 18),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [
                                      AutofillHints.username,
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      hintText: 'you@example.com',
                                      prefixIcon: Icon(
                                        Icons.mail_outline_rounded,
                                      ),
                                    ),
                                    validator: (value) {
                                      final email = value?.trim() ?? '';
                                      if (email.isEmpty) {
                                        return context.l10n.emailRequired;
                                      }
                                      final valid = RegExp(
                                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                      ).hasMatch(email);
                                      if (!valid) {
                                        return context.l10n.emailInvalid;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    onFieldSubmitted: (_) => _submit(),
                                    decoration: InputDecoration(
                                      labelText: context.l10n.password,
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          );
                                        },
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if ((value ?? '').isEmpty) {
                                        return context.l10n.passwordRequired;
                                      }
                                      if ((value ?? '').length < 6) {
                                        return context.l10n.passwordMinLength;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 22),
                                  AppButton(
                                    label: _isSignUp
                                        ? context.l10n.signUpAction
                                        : context.l10n.signInAction,
                                    icon: _isSignUp
                                        ? Icons.person_add_alt_1_rounded
                                        : Icons.login_rounded,
                                    isLoading: _submitting,
                                    onPressed: _submit,
                                  ),
                                  const SizedBox(height: 12),
                                  Center(
                                    child: TextButton(
                                      onPressed: _submitting
                                          ? null
                                          : () {
                                              setState(
                                                () => _isSignUp = !_isSignUp,
                                              );
                                            },
                                      child: Text(
                                        _isSignUp
                                            ? 'Đã có tài khoản? Đăng nhập'
                                            : 'Chưa có tài khoản? Đăng ký',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _AuthFooter(
                      text: _isSignUp
                          ? 'Sau khi đăng ký, bạn có thể tạo ví riêng hoặc được mời vào ví chia sẻ.'
                          : 'Dữ liệu vẫn hiển thị tức thì từ local database, đồng bộ được thực hiện nền.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    final remote = ref.read(supabaseRemoteDataSourceProvider);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      if (_isSignUp) {
        await remote.signUp(email: email, password: password);
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.signUpSuccess)));
        setState(() => _isSignUp = false);
      } else {
        await remote.signIn(email: email, password: password);
      }
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizeAuthError(context, error))),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF7F8FC), Color(0xFFF9FAFB), Color(0xFFF2F4F7)],
            ),
          ),
        ),
        Positioned(
          top: -80,
          left: -30,
          child: _GlowOrb(
            size: 220,
            colors: const [Color(0xFF2E90FA), Color(0xFF7A5AF8)],
          ),
        ),
        Positioned(
          top: 120,
          right: -70,
          child: _GlowOrb(
            size: 240,
            colors: const [Color(0xFFE11976), Color(0xFFF79009)],
          ),
        ),
        Positioned(
          bottom: -90,
          left: 40,
          child: _GlowOrb(
            size: 260,
            colors: const [Color(0xFF16B364), Color(0xFF2E90FA)],
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}

class _AuthHero extends StatelessWidget {
  const _AuthHero({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E90FA), Color(0xFF7A5AF8)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiết Kiệm',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quản lý tài chính cá nhân, offline-first và đồng bộ an toàn',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF667085),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF475467),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher({required this.isSignUp, required this.onChanged});

  final bool isSignUp;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeChip(
              selected: !isSignUp,
              icon: Icons.login_rounded,
              label: context.l10n.signInTitle,
              onTap: () => onChanged(false),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _ModeChip(
              selected: isSignUp,
              icon: Icons.person_add_alt_1_rounded,
              label: context.l10n.signUpTitle,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF101828).withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? const Color(0xFF1D4ED8)
                    : const Color(0xFF667085),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: selected
                        ? const Color(0xFF111827)
                        : const Color(0xFF667085),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustPanel extends StatelessWidget {
  const _TrustPanel({required this.isSignUp});

  final bool isSignUp;

  @override
  Widget build(BuildContext context) {
    final items = isSignUp
        ? const [
            (
              Icons.offline_bolt_rounded,
              'Lưu cục bộ ngay lập tức, không chờ mạng',
              Color(0xFF2E90FA),
            ),
            (
              Icons.groups_rounded,
              'Có thể được mời vào ví chia sẻ sau khi đăng ký',
              Color(0xFF16B364),
            ),
          ]
        : const [
            (
              Icons.sync_rounded,
              'Đồng bộ nền với Supabase trên nhiều thiết bị',
              Color(0xFF7A5AF8),
            ),
            (
              Icons.lock_rounded,
              'Truy cập dữ liệu theo quyền của từng ví',
              Color(0xFFE11976),
            ),
          ];

    return Column(
      children: [
        for (final item in items) ...[
          _TrustItem(icon: item.$1, text: item.$2, color: item.$3),
          if (item != items.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF475467),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthFooter extends StatelessWidget {
  const _AuthFooter({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF667085),
          height: 1.45,
        ),
      ),
    );
  }
}
