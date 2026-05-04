import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart' as db;
import 'package:drift/drift.dart' as drift;
import '../../../../core/database/database_provider.dart';
import '../../../../shared/finance_enums.dart';
import '../../../category/domain/entities/category.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../domain/entities/notification_import.dart';
import 'transaction_provider.dart';

final notificationImportProvider = AsyncNotifierProvider<
    NotificationImportNotifier, List<NotificationImportEntry>>(
  NotificationImportNotifier.new,
);

final pendingNotificationImportCountProvider = Provider<int>((ref) {
  final items = ref.watch(notificationImportProvider).valueOrNull ?? const [];
  return items.where((item) => item.status == NotificationImportStatus.pending).length;
});

class NotificationImportNotifier
    extends AsyncNotifier<List<NotificationImportEntry>> {
  StreamSubscription<List<db.NotificationImport>>? _subscription;

  db.AppDatabase get _database => ref.read(appDatabaseProvider);

  @override
  Future<List<NotificationImportEntry>> build() async {
    await _subscription?.cancel();
    final initial = await _database.notificationImportDao.getImports();
    _subscription = _database.notificationImportDao.watchImports().listen(
      (items) => state = AsyncData(items.map(_mapImport).toList()),
      onError: (Object error, StackTrace stackTrace) {
        state = AsyncError(error, stackTrace);
      },
    );
    ref.onDispose(() => _subscription?.cancel());
    return initial.map(_mapImport).toList();
  }

  List<NotificationImportEntry> pendingImports() {
    return (state.valueOrNull ?? const <NotificationImportEntry>[])
        .where((item) => item.status == NotificationImportStatus.pending)
        .toList();
  }

  Future<void> dismissImport(String id) async {
    final existing = await _database.notificationImportDao.getById(id);
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
        status: const drift.Value('dismissed'),
        detectedAt: drift.Value(existing.detectedAt),
        handledAt: drift.Value(DateTime.now().toUtc()),
        createdTransactionId: drift.Value(existing.createdTransactionId),
      ),
    );
  }

  Future<void> reopenImport(String id) async {
    final existing = await _database.notificationImportDao.getById(id);
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
        status: const drift.Value('pending'),
        detectedAt: drift.Value(existing.detectedAt),
        handledAt: const drift.Value(null),
        createdTransactionId: drift.Value(existing.createdTransactionId),
      ),
    );
  }

  Future<void> confirmImport({
    required String id,
    required TransactionType type,
    required String walletId,
    required String categoryId,
    String? note,
  }) async {
    final existing = await _database.notificationImportDao.getById(id);
    if (existing == null) {
      return;
    }

    await ref.read(transactionProvider.notifier).saveTransaction(
          id: null,
          type: type,
          amount: existing.amount,
          walletId: walletId,
          categoryId: categoryId,
          note: note,
          status: TransactionStatus.verified,
        );

    await _database.notificationImportDao.upsertImport(
      db.NotificationImportsCompanion(
        id: drift.Value(existing.id),
        sourceKey: drift.Value(existing.sourceKey),
        packageName: drift.Value(existing.packageName),
        bankName: drift.Value(existing.bankName),
        walletId: drift.Value(existing.walletId),
        amount: drift.Value(existing.amount),
        inferredType: drift.Value(type.name),
        title: drift.Value(existing.title),
        body: drift.Value(existing.body),
        status: const drift.Value('accepted'),
        detectedAt: drift.Value(existing.detectedAt),
        handledAt: drift.Value(DateTime.now().toUtc()),
        createdTransactionId: const drift.Value(null),
      ),
    );
  }

  Future<bool> quickConfirmImport(String id) async {
    final existing = await _database.notificationImportDao.getById(id);
    if (existing == null) {
      return false;
    }
    final type = TransactionType.values.byName(existing.inferredType);
    final categories = categoriesForWallet(existing.walletId, type);
    final category = categories.firstOrNull;
    if (category == null) {
      return false;
    }
    final fallbackNote = existing.body?.trim().isNotEmpty == true
        ? existing.body!.trim()
        : existing.title?.trim();
    await confirmImport(
      id: id,
      type: type,
      walletId: existing.walletId,
      categoryId: category.id,
      note: fallbackNote,
    );
    return true;
  }

  List<Category> categoriesForWallet(String walletId, TransactionType type) {
    final categories = ref.read(categoryProvider).valueOrNull ?? const <Category>[];
    return categories
        .where(
          (item) =>
              item.workspaceId == walletId &&
              item.type == type &&
              item.id != 'transfer',
        )
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  NotificationImportEntry _mapImport(db.NotificationImport row) {
    return NotificationImportEntry(
      id: row.id,
      sourceKey: row.sourceKey,
      packageName: row.packageName,
      bankName: row.bankName,
      walletId: row.walletId,
      amount: row.amount,
      inferredType: TransactionType.values.byName(row.inferredType),
      title: row.title,
      body: row.body,
      status: NotificationImportStatus.values.byName(row.status),
      detectedAt: row.detectedAt,
      handledAt: row.handledAt,
      createdTransactionId: row.createdTransactionId,
    );
  }
}
