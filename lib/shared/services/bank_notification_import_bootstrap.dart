import 'dart:async';
import 'dart:developer' as developer;

import 'package:drift/drift.dart' as drift;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart' as db;
import '../../core/database/database_provider.dart';
import '../finance_enums.dart';
import '../models/bank_notification_event.dart';
import '../../features/transaction/domain/entities/finance_transaction.dart';
import '../../features/transaction/domain/repositories/transaction_repository.dart';
import '../../features/transaction/presentation/providers/transaction_provider.dart';
import 'wallet_bootstrap_service.dart';
import 'bank_notification_parser.dart';
import 'bank_notification_platform_service.dart';
import 'local_notification_service.dart';

final bankNotificationImportBootstrapProvider = Provider<void>((ref) {
  final bootstrap = BankNotificationImportBootstrap(
    database: ref.watch(appDatabaseProvider),
    platform: ref.watch(bankNotificationPlatformServiceProvider),
    localNotifications: ref.watch(localNotificationServiceProvider),
    transactionRepository: ref.watch(transactionRepositoryProvider),
    walletBootstrapService: ref.watch(walletBootstrapServiceProvider),
  );
  ref.onDispose(bootstrap.dispose);
  unawaited(bootstrap.initialize());
});

class BankNotificationImportBootstrap with WidgetsBindingObserver {
  BankNotificationImportBootstrap({
    required db.AppDatabase database,
    required BankNotificationPlatformService platform,
    required LocalNotificationService localNotifications,
    required TransactionRepository transactionRepository,
    required WalletBootstrapService walletBootstrapService,
  })  : _database = database,
        _platform = platform,
        _localNotifications = localNotifications,
        _transactionRepository = transactionRepository,
        _walletBootstrapService = walletBootstrapService;

  static const _uuid = Uuid();

  final db.AppDatabase _database;
  final BankNotificationPlatformService _platform;
  final LocalNotificationService _localNotifications;
  final TransactionRepository _transactionRepository;
  final WalletBootstrapService _walletBootstrapService;
  final BankNotificationParser _parser = const BankNotificationParser();

  static const Duration _transferMatchWindow = Duration(minutes: 2);

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
    developer.log(
      'notification_event package=${event.packageName} text=${event.combinedText}',
      name: 'BankNotification',
    );
    final wallets = await _database.walletDao.getWallets();
    final bankWallets = wallets.where(_isConfiguredBankWallet).toList();
    if (bankWallets.isEmpty) {
      developer.log(
        'notification_skipped reason=no_configured_bank_wallet',
        name: 'BankNotification',
      );
      return;
    }

    final parsed = _parser.parse(event);
    if (parsed == null) {
      developer.log(
        'notification_skipped reason=parse_failed',
        name: 'BankNotification',
      );
      return;
    }
    developer.log(
      'notification_parsed bank=${parsed.bankSignature.canonicalName} amount=${parsed.amount} type=${parsed.inferredType.name}',
      name: 'BankNotification',
    );

    final existing = await _database.notificationImportDao.getBySourceKey(
      event.sourceKey,
    );
    if (existing != null) {
      developer.log(
        'notification_skipped reason=duplicate',
        name: 'BankNotification',
      );
      return;
    }

    final wallet = _matchWallet(parsed, event.combinedText, bankWallets);
    if (wallet == null) {
      developer.log(
        'notification_unmatched walletKeywords=${bankWallets.map((item) => _walletKeywords(item).join(",")).join("|")}',
        name: 'BankNotification',
      );
    } else {
      developer.log(
        'notification_matched wallet=${wallet.name}',
        name: 'BankNotification',
      );
    }

    final importId = _uuid.v4();
    await _database.notificationImportDao.upsertImport(
      db.NotificationImportsCompanion.insert(
        id: importId,
        sourceKey: event.sourceKey,
        packageName: event.packageName,
        bankName: parsed.bankSignature.canonicalName,
        walletId: drift.Value(wallet?.id),
        amount: parsed.amount.toDouble(),
        inferredType: parsed.inferredType.name,
        title: drift.Value(event.title),
        body: drift.Value(event.body ?? event.subText),
        status: 'pending',
        detectedAt: event.postedAt,
      ),
    );
    developer.log(
      'notification_saved status=pending wallet=${wallet?.name ?? "unmatched"}',
      name: 'BankNotification',
    );

    if (wallet != null) {
      final counterpart = await _findTransferCounterpart(
        currentImportId: importId,
        walletId: wallet.id,
        amount: parsed.amount,
        inferredType: parsed.inferredType,
        detectedAt: event.postedAt,
      );
      if (counterpart != null) {
        await _createTransferFromPair(
          currentImportId: importId,
          currentWalletId: wallet.id,
          currentType: parsed.inferredType,
          currentAmount: parsed.amount.toDouble(),
          currentTitle: event.title,
          currentBody: event.body ?? event.subText,
          currentDetectedAt: event.postedAt,
          counterpart: counterpart,
        );
        return;
      }

      final autoCategory = await _ensureAutoCategory(wallet.id, parsed.inferredType);
      if (autoCategory != null && parsed.amount > 0) {
        await _createDirectTransaction(
          importId: importId,
          walletId: wallet.id,
          type: parsed.inferredType,
          categoryId: autoCategory.id,
          amount: parsed.amount.toDouble(),
          note: _buildNotificationNote(
            title: event.title,
            body: event.body ?? event.subText,
          ),
          createdAt: event.postedAt,
        );
        return;
      }
    }

    if (_lifecycleState != AppLifecycleState.resumed) {
      await _localNotifications.showDetectedTransactionPrompt(
        bankName: parsed.bankSignature.canonicalName,
        amount: parsed.amount,
        languageCode:
            WidgetsBinding.instance.platformDispatcher.locale.languageCode,
      );
      developer.log(
        'notification_local_prompt_shown bank=${parsed.bankSignature.canonicalName} amount=${parsed.amount}',
        name: 'BankNotification',
      );
    }
  }

  Future<db.Category?> _firstCategoryFor(
    String walletId,
    TransactionType type,
  ) async {
    final categories = await _database.categoryDao.getCategoriesForScope(walletId);
    final matches = categories
        .where((item) => item.type == type.name && item.deletedAt == null)
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return matches.firstOrNull;
  }

  Future<db.Category?> _ensureAutoCategory(
    String walletId,
    TransactionType type,
  ) async {
    var category = await _firstCategoryFor(walletId, type);
    if (category != null) {
      return category;
    }
    await _walletBootstrapService.ensureDefaultCategories(walletId);
    category = await _firstCategoryFor(walletId, type);
    if (category == null) {
      developer.log(
        'notification_auto_create_blocked reason=no_category wallet=$walletId type=${type.name}',
        name: 'BankNotification',
      );
    }
    return category;
  }

  Future<db.NotificationImport?> _findTransferCounterpart({
    required String currentImportId,
    required String walletId,
    required int amount,
    required TransactionType inferredType,
    required DateTime detectedAt,
  }) async {
    final recent = await _database.notificationImportDao.getRecentImports(
      detectedAt.subtract(_transferMatchWindow),
    );
    final oppositeType = inferredType == TransactionType.income
        ? TransactionType.expense
        : inferredType == TransactionType.expense
            ? TransactionType.income
            : null;
    if (oppositeType == null) {
      return null;
    }

    for (final item in recent) {
      if (item.id == currentImportId ||
          item.walletId == null ||
          item.walletId == walletId ||
          item.amount.round() != amount ||
          item.inferredType != oppositeType.name ||
          item.status == 'dismissed') {
        continue;
      }
      final delta = detectedAt.difference(item.detectedAt).abs();
      if (delta <= _transferMatchWindow) {
        return item;
      }
    }
    return null;
  }

  Future<void> _createDirectTransaction({
    required String importId,
    required String walletId,
    required TransactionType type,
    required String categoryId,
    required double amount,
    required String? note,
    required DateTime createdAt,
  }) async {
    final transactionId = _uuid.v4();
    await _transactionRepository.saveTransaction(
      FinanceTransaction(
        id: transactionId,
        workspaceId: walletId,
        type: type,
        amount: amount,
        walletId: walletId,
        categoryId: categoryId,
        note: note,
        status: TransactionStatus.verified,
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
    );

    final existing = await _database.notificationImportDao.getById(importId);
    if (existing == null) {
      return;
    }
    await _database.notificationImportDao.upsertImport(
      db.NotificationImportsCompanion(
        id: drift.Value(existing.id),
        sourceKey: drift.Value(existing.sourceKey),
        packageName: drift.Value(existing.packageName),
        bankName: drift.Value(existing.bankName),
        walletId: drift.Value(existing.walletId),
        amount: drift.Value(existing.amount),
        inferredType: drift.Value(existing.inferredType),
        title: drift.Value(existing.title),
        body: drift.Value(existing.body),
        status: const drift.Value('accepted'),
        detectedAt: drift.Value(existing.detectedAt),
        handledAt: drift.Value(DateTime.now().toUtc()),
        createdTransactionId: drift.Value(transactionId),
      ),
    );
  }

  Future<void> _createTransferFromPair({
    required String currentImportId,
    required String currentWalletId,
    required TransactionType currentType,
    required double currentAmount,
    required String? currentTitle,
    required String? currentBody,
    required DateTime currentDetectedAt,
    required db.NotificationImport counterpart,
  }) async {
    final sourceWalletId = currentType == TransactionType.expense
        ? currentWalletId
        : counterpart.walletId!;
    final targetWalletId = currentType == TransactionType.income
        ? currentWalletId
        : counterpart.walletId!;
    final transactionId = _uuid.v4();

    if (counterpart.createdTransactionId?.isNotEmpty == true) {
      await _transactionRepository.deleteTransaction(counterpart.createdTransactionId!);
    }

    await _transactionRepository.saveTransaction(
      FinanceTransaction(
        id: transactionId,
        workspaceId: sourceWalletId,
        type: TransactionType.transfer,
        amount: currentAmount,
        walletId: sourceWalletId,
        targetWalletId: targetWalletId,
        categoryId: 'transfer',
        note: _buildTransferNote(currentBody, currentTitle),
        status: TransactionStatus.verified,
        createdAt: currentDetectedAt,
        updatedAt: currentDetectedAt,
      ),
    );

    final currentImport = await _database.notificationImportDao.getById(currentImportId);
    if (currentImport != null) {
      await _database.notificationImportDao.upsertImport(
        db.NotificationImportsCompanion(
          id: drift.Value(currentImport.id),
          sourceKey: drift.Value(currentImport.sourceKey),
          packageName: drift.Value(currentImport.packageName),
          bankName: drift.Value(currentImport.bankName),
          walletId: drift.Value(currentImport.walletId),
          amount: drift.Value(currentImport.amount),
          inferredType: drift.Value(TransactionType.transfer.name),
          title: drift.Value(currentImport.title),
          body: drift.Value(currentImport.body),
          status: const drift.Value('accepted'),
          detectedAt: drift.Value(currentImport.detectedAt),
          handledAt: drift.Value(DateTime.now().toUtc()),
          createdTransactionId: drift.Value(transactionId),
        ),
      );
    }

    await _database.notificationImportDao.upsertImport(
      db.NotificationImportsCompanion(
        id: drift.Value(counterpart.id),
        sourceKey: drift.Value(counterpart.sourceKey),
        packageName: drift.Value(counterpart.packageName),
        bankName: drift.Value(counterpart.bankName),
        walletId: drift.Value(counterpart.walletId),
        amount: drift.Value(counterpart.amount),
        inferredType: drift.Value(TransactionType.transfer.name),
        title: drift.Value(counterpart.title),
        body: drift.Value(counterpart.body),
        status: const drift.Value('accepted'),
        detectedAt: drift.Value(counterpart.detectedAt),
        handledAt: drift.Value(DateTime.now().toUtc()),
        createdTransactionId: drift.Value(transactionId),
      ),
    );
  }

  String? _buildNotificationNote({String? title, String? body}) {
    final values = [title?.trim(), body?.trim()]
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList();
    if (values.isEmpty) {
      return null;
    }
    return values.join(' | ');
  }

  String _buildTransferNote(String? body, String? title) {
    final note = _buildNotificationNote(title: title, body: body);
    if (note == null || note.isEmpty) {
      return 'Chuyển tiền giữa các ngân hàng';
    }
    return 'Chuyển tiền giữa các ngân hàng | $note';
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
