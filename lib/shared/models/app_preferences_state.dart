import 'package:flutter/material.dart';

@immutable
class AppPreferencesState {
  const AppPreferencesState({
    required this.languageCode,
    required this.darkModeEnabled,
    required this.notificationsEnabled,
    required this.appLockEnabled,
    required this.profileName,
    required this.profileEmail,
    this.avatarPath,
  });

  const AppPreferencesState.defaults()
      : languageCode = 'vi',
        darkModeEnabled = false,
        notificationsEnabled = true,
        appLockEnabled = false,
        profileName = 'Alex Tran',
        profileEmail = 'alex@pocketledger.app',
        avatarPath = null;

  final String languageCode;
  final bool darkModeEnabled;
  final bool notificationsEnabled;
  final bool appLockEnabled;
  final String profileName;
  final String profileEmail;
  final String? avatarPath;

  Locale get locale => Locale(languageCode);

  AppPreferencesState copyWith({
    String? languageCode,
    bool? darkModeEnabled,
    bool? notificationsEnabled,
    bool? appLockEnabled,
    String? profileName,
    String? profileEmail,
    String? avatarPath,
    bool clearAvatar = false,
  }) {
    return AppPreferencesState(
      languageCode: languageCode ?? this.languageCode,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      profileName: profileName ?? this.profileName,
      profileEmail: profileEmail ?? this.profileEmail,
      avatarPath: clearAvatar ? null : avatarPath ?? this.avatarPath,
    );
  }
}
