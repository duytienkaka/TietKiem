import 'package:flutter/material.dart';

@immutable
class AppPreferencesState {
  const AppPreferencesState({
    required this.languageCode,
    required this.darkModeEnabled,
    required this.notificationsEnabled,
    required this.appLockEnabled,
    required this.pinCode,
    required this.profileName,
    required this.profileEmail,
    this.avatarPath,
  });

  const AppPreferencesState.defaults()
      : languageCode = 'vi',
        darkModeEnabled = false,
        notificationsEnabled = true,
        appLockEnabled = false,
        pinCode = null,
        profileName = 'Alex Tran',
        profileEmail = 'alex@pocketledger.app',
        avatarPath = null;

  final String languageCode;
  final bool darkModeEnabled;
  final bool notificationsEnabled;
  final bool appLockEnabled;
  final String? pinCode;
  final String profileName;
  final String profileEmail;
  final String? avatarPath;

  Locale get locale => Locale(languageCode);

  AppPreferencesState copyWith({
    String? languageCode,
    bool? darkModeEnabled,
    bool? notificationsEnabled,
    bool? appLockEnabled,
    String? pinCode,
    String? profileName,
    String? profileEmail,
    String? avatarPath,
    bool clearAvatar = false,
    bool clearPin = false,
  }) {
    return AppPreferencesState(
      languageCode: languageCode ?? this.languageCode,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      pinCode: clearPin ? null : pinCode ?? this.pinCode,
      profileName: profileName ?? this.profileName,
      profileEmail: profileEmail ?? this.profileEmail,
      avatarPath: clearAvatar ? null : avatarPath ?? this.avatarPath,
    );
  }

  factory AppPreferencesState.fromJson(Map<String, dynamic> json) {
    return AppPreferencesState(
      languageCode: json['languageCode'] as String? ?? 'vi',
      darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      appLockEnabled: json['appLockEnabled'] as bool? ?? false,
      pinCode: json['pinCode'] as String?,
      profileName: json['profileName'] as String? ?? 'Alex Tran',
      profileEmail: json['profileEmail'] as String? ?? 'alex@pocketledger.app',
      avatarPath: json['avatarPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'languageCode': languageCode,
      'darkModeEnabled': darkModeEnabled,
      'notificationsEnabled': notificationsEnabled,
      'appLockEnabled': appLockEnabled,
      'pinCode': pinCode,
      'profileName': profileName,
      'profileEmail': profileEmail,
      'avatarPath': avatarPath,
    };
  }
}
