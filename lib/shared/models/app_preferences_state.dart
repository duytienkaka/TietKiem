import 'package:flutter/material.dart';

@immutable
class AppPreferencesState {
  const AppPreferencesState({
    required this.languageCode,
    required this.darkModeEnabled,
    required this.notificationsEnabled,
    required this.appLockEnabled,
    required this.aiAssistantEnabled,
    required this.pinCode,
    required this.openAiApiKey,
    required this.profileName,
    required this.profileEmail,
    this.avatarPath,
  });

  const AppPreferencesState.defaults()
    : languageCode = 'vi',
      darkModeEnabled = false,
      notificationsEnabled = true,
      appLockEnabled = false,
      aiAssistantEnabled = false,
      pinCode = null,
      openAiApiKey = null,
      profileName = '',
      profileEmail = '',
      avatarPath = null;

  final String languageCode;
  final bool darkModeEnabled;
  final bool notificationsEnabled;
  final bool appLockEnabled;
  final bool aiAssistantEnabled;
  final String? pinCode;
  final String? openAiApiKey;
  final String profileName;
  final String profileEmail;
  final String? avatarPath;

  Locale get locale => Locale(languageCode);

  AppPreferencesState copyWith({
    String? languageCode,
    bool? darkModeEnabled,
    bool? notificationsEnabled,
    bool? appLockEnabled,
    bool? aiAssistantEnabled,
    String? pinCode,
    String? openAiApiKey,
    String? profileName,
    String? profileEmail,
    String? avatarPath,
    bool clearAvatar = false,
    bool clearPin = false,
    bool clearOpenAiApiKey = false,
  }) {
    return AppPreferencesState(
      languageCode: languageCode ?? this.languageCode,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      aiAssistantEnabled: aiAssistantEnabled ?? this.aiAssistantEnabled,
      pinCode: clearPin ? null : pinCode ?? this.pinCode,
      openAiApiKey: clearOpenAiApiKey
          ? null
          : openAiApiKey ?? this.openAiApiKey,
      profileName: profileName ?? this.profileName,
      profileEmail: profileEmail ?? this.profileEmail,
      avatarPath: clearAvatar ? null : avatarPath ?? this.avatarPath,
    );
  }
}
