import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bank_notification_event.dart';

final bankNotificationPlatformServiceProvider =
    Provider<BankNotificationPlatformService>(
  (ref) => const BankNotificationPlatformService(),
);

class BankNotificationPlatformService {
  const BankNotificationPlatformService();

  static const _methodChannel = MethodChannel(
    'tietkiem/bank_notifications/methods',
  );
  static const _eventChannel = EventChannel(
    'tietkiem/bank_notifications/events',
  );

  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<bool> hasAccess() async {
    if (!isSupported) {
      return false;
    }
    final value = await _methodChannel.invokeMethod<bool>('isAccessGranted');
    return value ?? false;
  }

  Future<void> openAccessSettings() async {
    if (!isSupported) {
      return;
    }
    await _methodChannel.invokeMethod<void>('openAccessSettings');
  }

  Future<List<BankNotificationEvent>> consumePendingEvents() async {
    if (!isSupported) {
      return const [];
    }
    final events = await _methodChannel.invokeMethod<List<Object?>>(
      'consumePendingEvents',
    );
    return (events ?? const <Object?>[])
        .whereType<Map<Object?, Object?>>()
        .map(BankNotificationEvent.fromJson)
        .toList();
  }

  Stream<BankNotificationEvent> watchEvents() {
    if (!isSupported) {
      return const Stream.empty();
    }
    return _eventChannel.receiveBroadcastStream().map((event) {
      final payload = event as Map<Object?, Object?>;
      return BankNotificationEvent.fromJson(payload);
    });
  }
}
