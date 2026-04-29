import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';

final syncQueueServiceProvider = Provider<SyncQueueService>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return SyncQueueService(database);
});

class SyncQueueService {
  SyncQueueService(this._database);

  final AppDatabase _database;

  Stream<List<SyncQueueItem>> watchQueue() => _database.syncQueueDao.watchPendingQueue();

  Future<List<SyncQueueItem>> getPendingJobs() => _database.syncQueueDao.getPendingQueue();

  Future<void> enqueueUpsert({
    required String workspaceId,
    required String tableName,
    required String recordId,
    required Map<String, dynamic> payload,
  }) async {
    developer.log(
      'Enqueue upsert for $tableName/$recordId',
      name: 'SyncQueueService',
      error: payload,
    );
    await _database.syncQueueDao.enqueue(
      SyncQueueItemsCompanion.insert(
        id: const Uuid().v4(),
        workspaceId: workspaceId,
        tableKey: tableName,
        recordId: recordId,
        operation: 'upsert',
        payload: jsonEncode(payload),
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> acknowledge(String id) => _database.syncQueueDao.acknowledge(id);

  Map<String, dynamic> decodePayload(String payload) {
    return Map<String, dynamic>.from(jsonDecode(payload) as Map);
  }

  Future<void> markFailure(
    SyncQueueItem item,
    Object error,
  ) {
    return _database.syncQueueDao.markFailure(
      id: item.id,
      attemptCount: item.attemptCount + 1,
      error: error.toString(),
      lastTriedAt: DateTime.now().toUtc(),
    );
  }
}
