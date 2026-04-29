import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../providers/app_lock_provider.dart';
import '../providers/app_preferences_provider.dart';
import '../widgets/app_button.dart';

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  final _pinController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(appPreferencesProvider).valueOrNull;
    final scheme = Theme.of(context).colorScheme;
    final name = preferences?.profileName ?? 'Alex Tran';

    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.38),
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE11976), Color(0xFF7B3FF2), Color(0xFF151B36)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.24),
                        blurRadius: 36,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _initials(name),
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          context.l10n.unlockApp,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.enterPinContinue,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.82),
                              ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _pinController,
                          autofocus: true,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: scheme.onSurface,
                                letterSpacing: 10,
                              ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white,
                            hintText: '• • • •',
                            errorText: _errorText,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          ),
                          onChanged: (value) {
                            if (_errorText != null) {
                              setState(() => _errorText = null);
                            }
                            if (value.length == 4) {
                              _unlock();
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        AppButton(
                          label: context.l10n.unlock,
                          icon: Icons.lock_open_rounded,
                          onPressed: _unlock,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _unlock() {
    final preferences = ref.read(appPreferencesProvider).valueOrNull;
    if (_pinController.text == preferences?.pinCode) {
      ref.read(appLockSessionProvider.notifier).unlock();
      return;
    }
    setState(() {
      _errorText = context.l10n.invalidPin;
      _pinController.clear();
    });
  }

  String _initials(String value) {
    final words = value.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (words.isEmpty) {
      return 'PL';
    }
    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }
    return '${words.first.substring(0, 1)}${words.last.substring(0, 1)}'.toUpperCase();
  }
}
