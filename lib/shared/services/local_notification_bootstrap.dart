import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/category/presentation/providers/category_provider.dart';
import '../../features/recurring/presentation/providers/recurring_provider.dart';
import '../providers/app_preferences_provider.dart';
import 'local_notification_service.dart';

final localNotificationBootstrapProvider = Provider<void>((ref) {
  final service = ref.watch(localNotificationServiceProvider);
  final preferences = ref.watch(appPreferencesProvider).valueOrNull;
  final categories = ref.watch(categoryProvider).valueOrNull;
  final rules = ref.watch(recurringProvider).valueOrNull;

  unawaited(service.initialize());

  if (preferences != null && categories != null && rules != null) {
    unawaited(
      service.syncRecurringNotifications(
        rules: rules,
        categories: categories,
        languageCode: preferences.languageCode,
        enabled: preferences.notificationsEnabled,
      ),
    );
  }
});
