import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/category/domain/entities/category.dart';
import '../../features/recurring/domain/entities/recurring_rule.dart';

final localNotificationServiceProvider = Provider<LocalNotificationService>(
  (ref) => const LocalNotificationService(),
);

class LocalNotificationService {
  const LocalNotificationService();

  Future<void> initialize() async {}

  Future<bool> requestPermissions() async => false;

  Future<void> syncRecurringNotifications({
    required List<RecurringRule> rules,
    required List<Category> categories,
    required String languageCode,
    required bool enabled,
  }) async {}

  Future<void> cancelRecurringNotifications() async {}

  Future<void> showDetectedTransactionPrompt({
    required String bankName,
    required int amount,
    required String languageCode,
  }) async {}
}
