import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_preferences_state.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

final appPreferencesProvider = AsyncNotifierProvider<AppPreferencesNotifier,
    AppPreferencesState>(AppPreferencesNotifier.new);

class AppPreferencesNotifier extends AsyncNotifier<AppPreferencesState> {
  static const _languageCodeKey = 'prefs.languageCode';
  static const _darkModeKey = 'prefs.darkModeEnabled';
  static const _notificationsKey = 'prefs.notificationsEnabled';
  static const _appLockKey = 'prefs.appLockEnabled';
  static const _pinCodeKey = 'prefs.pinCode';
  static const _profileNameKey = 'prefs.profileName';
  static const _profileEmailKey = 'prefs.profileEmail';
  static const _avatarPathKey = 'prefs.avatarPath';

  SharedPreferences? _prefs;

  @override
  Future<AppPreferencesState> build() async {
    _prefs = await ref.watch(sharedPreferencesProvider.future);
    final prefs = _prefs!;
    return AppPreferencesState(
      languageCode: prefs.getString(_languageCodeKey) ?? 'vi',
      darkModeEnabled: prefs.getBool(_darkModeKey) ?? false,
      notificationsEnabled: prefs.getBool(_notificationsKey) ?? true,
      appLockEnabled: prefs.getBool(_appLockKey) ?? false,
      pinCode: prefs.getString(_pinCodeKey),
      profileName: prefs.getString(_profileNameKey) ?? 'Alex Tran',
      profileEmail: prefs.getString(_profileEmailKey) ?? 'alex@pocketledger.app',
      avatarPath: prefs.getString(_avatarPathKey),
    );
  }

  Future<void> updateLanguage(String languageCode) =>
      _save((current) => current.copyWith(languageCode: languageCode));

  Future<void> updateDarkMode(bool enabled) =>
      _save((current) => current.copyWith(darkModeEnabled: enabled));

  Future<void> updateNotifications(bool enabled) =>
      _save((current) => current.copyWith(notificationsEnabled: enabled));

  Future<void> updateAppLock(bool enabled) =>
      _save((current) => current.copyWith(appLockEnabled: enabled));

  Future<void> updatePinCode(String? pinCode) => _save(
        (current) => current.copyWith(
          pinCode: pinCode,
          clearPin: pinCode == null || pinCode.isEmpty,
        ),
      );

  Future<void> updateProfile({
    required String name,
    required String email,
  }) {
    return _save(
      (current) => current.copyWith(
        profileName: name.trim(),
        profileEmail: email.trim(),
      ),
    );
  }

  Future<void> updateAvatar(String? avatarPath) {
    return _save(
      (current) => current.copyWith(
        avatarPath: avatarPath,
        clearAvatar: avatarPath == null,
      ),
    );
  }

  Future<void> replaceState(AppPreferencesState next) async {
    state = AsyncData(next);

    final SharedPreferences prefs =
        _prefs ?? await ref.read(sharedPreferencesProvider.future);
    _prefs = prefs;
    await prefs.setString(_languageCodeKey, next.languageCode);
    await prefs.setBool(_darkModeKey, next.darkModeEnabled);
    await prefs.setBool(_notificationsKey, next.notificationsEnabled);
    await prefs.setBool(_appLockKey, next.appLockEnabled);
    if (next.pinCode == null || next.pinCode!.isEmpty) {
      await prefs.remove(_pinCodeKey);
    } else {
      await prefs.setString(_pinCodeKey, next.pinCode!);
    }
    await prefs.setString(_profileNameKey, next.profileName);
    await prefs.setString(_profileEmailKey, next.profileEmail);

    if (next.avatarPath == null || next.avatarPath!.isEmpty) {
      await prefs.remove(_avatarPathKey);
    } else {
      await prefs.setString(_avatarPathKey, next.avatarPath!);
    }
  }

  Future<void> _save(
    AppPreferencesState Function(AppPreferencesState current) transform,
  ) async {
    final current = state.valueOrNull ?? const AppPreferencesState.defaults();
    final next = transform(current);
    await replaceState(next);
  }
}
