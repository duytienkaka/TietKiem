import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';

final appDataMaintenanceServiceProvider = Provider<AppDataMaintenanceService>(
  (ref) => AppDataMaintenanceService(ref.read(appDatabaseProvider)),
);

class AppDataMaintenanceService {
  const AppDataMaintenanceService(this._database);

  final AppDatabase _database;

  Future<void> resetFinanceData() => _database.resetFinanceData();
}
