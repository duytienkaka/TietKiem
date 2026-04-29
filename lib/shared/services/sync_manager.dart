import 'dart:async';
import 'dart:developer' as developer;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';
import '../../features/category/data/models/category_model.dart';
import '../../features/transaction/data/models/transaction_model.dart';
import '../../features/wallet/data/models/wallet_model.dart';
import '../providers/auth_session_provider.dart';
import '../providers/supabase_client_provider.dart';
import '../finance_enums.dart';
import 'supabase_remote_data_source.dart';
import 'sync_queue_service.dart';
import 'wallet_bootstrap_service.dart';

final syncManagerProvider = Provider<SyncManager>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final client = ref.watch(supabaseClientProvider);
  final remote = ref.watch(supabaseRemoteDataSourceProvider);
  final queue = ref.watch(syncQueueServiceProvider);
  final bootstrap = ref.watch(walletBootstrapServiceProvider);
  return SyncManager(
    database: database,
    client: client,
    remote: remote,
    queue: queue,
    bootstrap: bootstrap,
  );
});

final syncBootstrapProvider = Provider<void>((ref) {
  final manager = ref.watch(syncManagerProvider);
  final session = ref.watch(authSessionProvider).valueOrNull;

  ref.listen<AsyncValue<Session?>>(authSessionProvider, (_, next) {
    manager.handleSession(next.valueOrNull);
  });

  manager.handleSession(session);
});

class SyncManager {
  SyncManager({
    required AppDatabase database,
    required SupabaseClient client,
    required SupabaseRemoteDataSource remote,
    required SyncQueueService queue,
    required WalletBootstrapService bootstrap,
  })  : _database = database,
        _client = client,
        _remote = remote,
        _queue = queue,
        _bootstrap = bootstrap;

  final AppDatabase _database;
  final SupabaseClient _client;
  final SupabaseRemoteDataSource _remote;
  final SyncQueueService _queue;
  final WalletBootstrapService _bootstrap;

  StreamSubscription<List<SyncQueueItem>>? _queueSubscription;
  final List<RealtimeChannel> _channels = [];
  bool _isSyncing = false;

  void handleSession(Session? session) {
    if (session == null) {
      _disposeRealtime();
      unawaited(_queueSubscription?.cancel());
      _queueSubscription = null;
      return;
    }

    _queueSubscription ??= _queue.watchQueue().listen((_) {
      unawaited(_flushQueue());
    });

    unawaited(_initialSync());
    _subscribeRealtime();
  }

  Future<void> _initialSync() async {
    final wallets = await _remote.fetchWallets();
    for (final row in wallets) {
      await _database.walletDao.upsertWallet(_walletCompanionFromJson(row));
    }

    final walletIds = wallets.map((row) => row['id'] as String).toSet().toList();
    final seenTransactionIds = <String>{};

    for (final walletId in walletIds) {
      final categories = await _remote.fetchCategories(walletId);
      for (final row in categories) {
        await _database.categoryDao.upsertCategory(_categoryCompanionFromJson(row));
      }
      if (categories.isEmpty) {
        await _bootstrap.ensureDefaultCategories(walletId);
      }

      final transactions = await _remote.fetchTransactionsForWallet(walletId);
      for (final row in transactions) {
        final id = row['id'] as String;
        if (!seenTransactionIds.add(id)) {
          continue;
        }
        await _database.transactionDao.upsertTransaction(
          _transactionCompanionFromJson(row),
        );
      }

      final budgets = await _remote.fetchBudgets(walletId);
      for (final row in budgets) {
        await _database.into(_database.budgets).insertOnConflictUpdate(
              _budgetCompanionFromJson(row),
            );
      }
    }

    await _flushQueue();
  }

  void _subscribeRealtime() {
    _disposeRealtime();
    final userId = _remote.currentUserId;
    if (userId == null) {
      return;
    }

    _channels.add(
      _remote.subscribeTable(
        channelKey: 'realtime:wallets',
        table: 'wallets',
        onChange: (payload) {
          final record = payload.newRecord.isNotEmpty
              ? payload.newRecord
              : payload.oldRecord;
          unawaited(_applyRealtimeChange('wallets', record));
        },
      ),
    );

    _channels.add(
      _remote.subscribeTable(
        channelKey: 'realtime:wallet_members:$userId',
        table: 'wallet_members',
        filterColumn: 'user_id',
        filterValue: userId,
        onChange: (_) => unawaited(_initialSync()),
      ),
    );

    for (final table in const ['categories', 'transactions', 'budgets']) {
      _channels.add(
        _remote.subscribeTable(
          channelKey: 'realtime:$table',
          table: table,
          onChange: (payload) {
            final record = payload.newRecord.isNotEmpty
                ? payload.newRecord
                : payload.oldRecord;
            unawaited(_applyRealtimeChange(table, record));
          },
        ),
      );
    }
  }

  Future<void> _applyRealtimeChange(
    String table,
    Map<String, dynamic> row,
  ) async {
    if (row.isEmpty) {
      return;
    }

    switch (table) {
      case 'wallets':
        await _database.walletDao.upsertWallet(_walletCompanionFromJson(row));
      case 'categories':
        await _database.categoryDao.upsertCategory(_categoryCompanionFromJson(row));
      case 'transactions':
        await _database.transactionDao.upsertTransaction(
          _transactionCompanionFromJson(row),
        );
      case 'budgets':
        await _database.into(_database.budgets).insertOnConflictUpdate(
              _budgetCompanionFromJson(row),
            );
    }
  }

  Future<void> _flushQueue() async {
    if (_isSyncing || _remote.currentSession == null) {
      return;
    }

    _isSyncing = true;
    try {
      final jobs = await _queue.getPendingJobs();
      for (final job in jobs) {
        try {
          await _remote.upsert(
            table: job.tableKey,
            payload: _queue.decodePayload(job.payload),
          );
          await _queue.acknowledge(job.id);
        } catch (error) {
          developer.log(
            'Sync queue job failed',
            name: 'SyncManager',
            error: error,
          );
          await _queue.markFailure(job, error);
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  WalletsCompanion _walletCompanionFromJson(Map<String, dynamic> row) {
    return WalletModel(
      id: row['id'] as String,
      workspaceId: row['id'] as String,
      name: row['name'] as String,
      type: WalletType.values.byName(row['type'] as String),
      balance: (row['balance'] as num).toDouble(),
      color: _fromPostgresInt32((row['color'] as num).toInt()),
      icon: row['icon'] as String,
      createdAt: _parseDateTime(row['created_at']),
      updatedAt: _parseDateTime(row['updated_at']),
      deletedAt: _parseNullableDateTime(row['deleted_at']),
    ).toCompanion();
  }

  CategoriesCompanion _categoryCompanionFromJson(Map<String, dynamic> row) {
    return CategoryModel(
      id: row['id'] as String,
      workspaceId: row['wallet_id'] as String,
      name: row['name'] as String,
      type: TransactionType.values.byName(row['type'] as String),
      icon: row['icon'] as String,
      createdAt: _parseDateTime(row['created_at']),
      updatedAt: _parseDateTime(row['updated_at']),
      deletedAt: _parseNullableDateTime(row['deleted_at']),
    ).toCompanion();
  }

  TransactionsCompanion _transactionCompanionFromJson(Map<String, dynamic> row) {
    final walletId = row['wallet_id'] as String;
    return TransactionModel(
      id: row['id'] as String,
      workspaceId: walletId,
      type: TransactionType.values.byName(row['type'] as String),
      amount: (row['amount'] as num).toDouble(),
      walletId: walletId,
      targetWalletId: row['target_wallet_id'] as String?,
      categoryId: row['category_id'] as String? ?? 'transfer',
      note: row['note'] as String?,
      imagePath: row['image_path'] as String?,
      status: TransactionStatus.values.byName(row['status'] as String),
      createdAt: _parseDateTime(row['created_at']),
      updatedAt: _parseDateTime(row['updated_at']),
      deletedAt: _parseNullableDateTime(row['deleted_at']),
    ).toCompanion();
  }

  BudgetsCompanion _budgetCompanionFromJson(Map<String, dynamic> row) {
    return BudgetsCompanion.insert(
      id: row['id'] as String,
      workspaceId: row['wallet_id'] as String,
      categoryId: row['category_id'] as String,
      amount: (row['amount'] as num).toDouble(),
      period: row['period'] as String,
      createdAt: _parseDateTime(row['created_at']),
      updatedAt: _parseDateTime(row['updated_at']),
      deletedAt: Value(_parseNullableDateTime(row['deleted_at'])),
    );
  }

  DateTime _parseDateTime(dynamic value) {
    return DateTime.parse(value as String).toUtc();
  }

  DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.parse(value as String).toUtc();
  }

  int _fromPostgresInt32(int value) {
    return value & 0xFFFFFFFF;
  }

  void _disposeRealtime() {
    for (final channel in _channels) {
      _client.removeChannel(channel);
    }
    _channels.clear();
  }
}
