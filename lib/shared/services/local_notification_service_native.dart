import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/category/domain/entities/category.dart';
import '../../features/recurring/domain/entities/recurring_rule.dart';

final localNotificationServiceProvider = Provider<LocalNotificationService>(
  (ref) => LocalNotificationService(),
);

class LocalNotificationService {
  LocalNotificationService();

  static const _channelId = 'recurring_reminders';
  static const _channelName = 'Recurring reminders';
  static const _channelDescription = 'Reminders for recurring transactions and bills';
  static const _bankChannelId = 'bank_transaction_review';
  static const _bankChannelName = 'Bank transaction review';
  static const _bankChannelDescription =
      'Prompts to review detected banking notifications before saving them';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz_data.initializeTimeZones();
    final timezone = await FlutterTimezone.getLocalTimezone();
    try {
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.local);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _plugin.initialize(
      settings: settings,
    );
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    await initialize();

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final macos = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();

    final androidGranted = await android?.requestNotificationsPermission() ?? true;
    final iosGranted = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;
    final macGranted = await macos?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;

    return androidGranted && iosGranted && macGranted;
  }

  Future<void> syncRecurringNotifications({
    required List<RecurringRule> rules,
    required List<Category> categories,
    required String languageCode,
    required bool enabled,
  }) async {
    await initialize();
    await cancelRecurringNotifications();

    if (!enabled) {
      return;
    }

    final activeRules = rules.where((rule) => rule.isActive).toList();
    for (final rule in activeRules) {
      await _plugin.zonedSchedule(
        id: _notificationId(rule.id),
        title: _titleFor(rule, categories, languageCode),
        body: _bodyFor(rule, categories, languageCode),
        scheduledDate: tz.TZDateTime.from(rule.nextRunAt, tz.local),
        notificationDetails: NotificationDetails(
          android: const AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'recurring:${rule.id}',
      );
    }
  }

  Future<void> cancelRecurringNotifications() async {
    await initialize();
    await _plugin.cancelAll();
  }

  Future<void> showDetectedTransactionPrompt({
    required String bankName,
    required int amount,
    required String languageCode,
  }) async {
    await initialize();
    final title = languageCode == 'vi'
        ? 'PhĂ¡t hiá»‡n giao dá»‹ch má»›i'
        : 'New transaction detected';
    final body = languageCode == 'vi'
        ? '$bankName â€¢ ${amount.toStringAsFixed(0)} VND. Má»Ÿ app Ä‘á»ƒ xĂ¡c nháº­n.'
        : '$bankName â€¢ ${amount.toStringAsFixed(0)} VND. Open the app to confirm.';
    await _plugin.show(
      id: _bankNotificationId(bankName, amount),
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _bankChannelId,
          _bankChannelName,
          channelDescription: _bankChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'bank_notification_review',
    );
  }

  int _notificationId(String ruleId) {
    return ruleId.hashCode & 0x7fffffff;
  }

  int _bankNotificationId(String bankName, int amount) {
    return ('bank:$bankName:$amount').hashCode & 0x7fffffff;
  }

  String _titleFor(
    RecurringRule rule,
    List<Category> categories,
    String languageCode,
  ) {
    final category = categories.where((item) => item.id == rule.categoryId).firstOrNull;
    final categoryName = category?.name.toLowerCase().trim();
    final isBills = categoryName == 'bills';
    if (languageCode == 'vi') {
      if (isBills) {
        return 'Nháº¯c hĂ³a Ä‘Æ¡n';
      }
      return rule.type.name == 'income' ? 'Nháº¯c thu Ä‘á»‹nh ká»³' : 'Nháº¯c chi Ä‘á»‹nh ká»³';
    }
    if (isBills) {
      return 'Bill reminder';
    }
    return rule.type.name == 'income' ? 'Recurring income reminder' : 'Recurring expense reminder';
  }

  String _bodyFor(
    RecurringRule rule,
    List<Category> categories,
    String languageCode,
  ) {
    final category = categories.where((item) => item.id == rule.categoryId).firstOrNull;
    final categoryName = category?.name ?? 'transaction';
    if (languageCode == 'vi') {
      return 'Sáº¯p Ä‘áº¿n háº¡n ${_localizeCategory(categoryName, languageCode)}: ${rule.amount.toStringAsFixed(0)} VND';
    }
    return 'Upcoming ${_localizeCategory(categoryName, languageCode)}: ${rule.amount.toStringAsFixed(0)} VND';
  }

  String _localizeCategory(String raw, String languageCode) {
    final key = raw.toLowerCase();
    if (languageCode == 'vi') {
      return switch (key) {
        'salary' => 'lÆ°Æ¡ng',
        'gift' => 'quĂ  táº·ng',
        'bonus' => 'thÆ°á»Ÿng',
        'food' => 'Äƒn uá»‘ng',
        'transport' => 'di chuyá»ƒn',
        'shopping' => 'mua sáº¯m',
        'bills' => 'hĂ³a Ä‘Æ¡n',
        'health' => 'sá»©c khá»e',
        _ => raw,
      };
    }
    return raw;
  }
}

