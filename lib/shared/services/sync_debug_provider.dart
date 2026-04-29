import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_provider.dart';

final syncQueueDebugProvider = FutureProvider<List<Map<String, Object?>>>((ref) async {
  final database = ref.watch(appDatabaseProvider);
  final jobs = await database.syncQueueDao.getPendingQueue();
  return jobs
      .map(
        (job) => <String, Object?>{
          'id': job.id,
          'scopeId': job.workspaceId,
          'tableKey': job.tableKey,
          'recordId': job.recordId,
          'attemptCount': job.attemptCount,
          'lastError': job.lastError,
          'createdAt': job.createdAt.toIso8601String(),
          'lastTriedAt': job.lastTriedAt?.toIso8601String(),
        },
      )
      .toList();
});
