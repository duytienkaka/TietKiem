import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_preferences_provider.dart';

final appLockSessionProvider =
    NotifierProvider<AppLockSessionNotifier, bool>(AppLockSessionNotifier.new);

final appLockRequiredProvider = Provider<bool>((ref) {
  final preferences = ref.watch(appPreferencesProvider).valueOrNull;
  final unlocked = ref.watch(appLockSessionProvider);
  return preferences?.appLockEnabled == true &&
      (preferences?.pinCode?.isNotEmpty ?? false) &&
      !unlocked;
});

class AppLockSessionNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void unlock() => state = true;

  void lock() => state = false;
}
