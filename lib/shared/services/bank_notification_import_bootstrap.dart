import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart' as db;
import '../../core/database/database_provider.dart';
import '../finance_enums.dart';
import '../models/bank_notification_event.dart';
import 'bank_notification_parser.dart';
import 'bank_notification_platform_service.dart';
import 'local_notification_service.dart';

final bankNotificationImportBootstrapProvider = Provider<void>((ref) {
  final bootstrap = BankNotificationImportBootstrap(
    database: ref.watch(appDatabaseProvider),
    platform: ref.watch(bankNotificationPlatformServiceProvider),
    localNotifications: ref.watch(localNotificationServiceProvider),
  );
  ref.onDispose(bootstrap.dispose);
  unawaited(bootstrap.initialize());
});

class BankNotificationImportBootstrap with WidgetsBindingObserver {
  BankNotificationImportBootstrap({
    required db.AppDatabase database,
    required BankNotificationPlatformService platform,
    required LocalNotificationService localNotifications,
  })  : _database = database,
        _platform = platform,
        _localNotifications = localNotifications;

  static const _uuid = Uuid();

  final db.AppDatabase _database;
  final BankNotificationPlatformService _platform;
  final LocalNotificationService _localNotifications;
  final BankNotificationParser _parser = const BankNotificationParser();

  StreamSubscription<BankNotificationEvent>? _subscription;
  bool _initialized = false;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;

  Future<void> initialize() async {
    if (_initialized || !_platform.isSupported) {
      return;
    }
    _initialized = true;
    WidgetsBinding.instance.addObserver(this);
    await _consumePending();
    _subscription = _platform.watchEvents().listen(_handleEvent);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    if (state == AppLifecycleState.resumed) {
      unawaited(_consumePending());
    }
  }

  Future<void> _consumePending() async {
    final pending = await _platform.consumePendingEvents();
    for (final event in pending) {
      await _handleEvent(event);
    }
  }

  Future<void> _handleEvent(BankNotificationEvent event) async {
    final wallets = await _database.walletDao.getWallets();
    final bankWallets = wallets.where(_isConfiguredBankWallet).toList();
    if (bankWallets.isEmpty) {
      return;
    }

    final parsed = _parser.parse(event);
    if (parsed == null) {
      return;
    }

    final wallet = _matchWallet(parsed, event.combinedText, bankWallets);
    if (wallet == null) {
      return;
    }

    final existing = await _database.notificationImportDao.getBySourceKey(
      event.sourceKey,
    );
    if (existing != null) {
      return;
    }

    await _database.notificationImportDao.upsertImport(
      db.NotificationImportsCompanion.insert(
        id: _uuid.v4(),
        sourceKey: event.sourceKey,
        packageName: event.packageName,
        bankName: parsed.bankSignature.canonicalName,
        walletId: wallet.id,
        amount: parsed.amount.toDouble(),
        inferredType: parsed.inferredType.name,
        title: drift.Value(event.title),
        body: drift.Value(event.body ?? event.subText),
        status: 'pending',
        detectedAt: event.postedAt,
      ),
    );

    if (_lifecycleState != AppLifecycleState.resumed) {
      await _localNotifications.showDetectedTransactionPrompt(
        bankName: parsed.bankSignature.canonicalName,
        amount: parsed.amount,
        languageCode:
            WidgetsBinding.instance.platformDispatcher.locale.languageCode,
      );
    }
  }

  db.Wallet? _matchWallet(
    ParsedBankNotification parsed,
    String text,
    List<db.Wallet> wallets,
  ) {
    final normalizedText = _parser.normalize(text);
    final normalizedCanonical = _parser.normalize(parsed.bankSignature.canonicalName);
    for (final wallet in wallets) {
      final keywords = _walletKeywords(wallet);
      if (keywords.isEmpty) {
        continue;
      }
      final canonicalMatch = keywords.contains(normalizedCanonical);
      final textMatch = keywords.any(
        (keyword) => keyword.isNotEmpty && normalizedText.contains(keyword),
      );
      if (canonicalMatch || textMatch) {
        return wallet;
      }
    }
    return null;
  }

  Set<String> _walletKeywords(db.Wallet wallet) {
    final values = <String>{};
    if (wallet.bankName?.trim().isNotEmpty ?? false) {
      values.add(_parser.normalize(wallet.bankName!));
    }
    if (wallet.bankAliases?.trim().isNotEmpty ?? false) {
      values.addAll(
        wallet.bankAliases!
            .split(RegExp(r'[,;\n]+'))
            .map(_parser.normalize)
            .where((item) => item.isNotEmpty),
      );
    }
    return values;
  }

  bool _isConfiguredBankWallet(db.Wallet wallet) {
    return wallet.type == WalletType.bank.name &&
        (wallet.bankName?.trim().isNotEmpty ?? false);
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _subscription?.cancel();
  }
}
