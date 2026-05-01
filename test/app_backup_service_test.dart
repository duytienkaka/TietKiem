import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tietkiem/core/database/app_database.dart' as db;
import 'package:tietkiem/features/budget/presentation/providers/budget_provider.dart';
import 'package:tietkiem/features/goal/presentation/providers/savings_goal_provider.dart';
import 'package:tietkiem/features/recurring/presentation/providers/recurring_provider.dart';
import 'package:tietkiem/shared/services/app_backup_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppBackupService.restoreBackup', () {
    late db.AppDatabase database;
    late SharedPreferences prefs;
    late AppBackupService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      prefs = await SharedPreferences.getInstance();
      database = db.AppDatabase(NativeDatabase.memory());
      service = AppBackupService(
        database: database,
        sharedPreferences: Future<SharedPreferences>.value(prefs),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('restores database tables and local preference-backed collections', () async {
      final rawBackup = jsonEncode({
        'schemaVersion': 1,
        'exportedAt': '2026-05-01T00:00:00.000Z',
        'preferences': {
          'languageCode': 'vi',
          'darkModeEnabled': true,
          'notificationsEnabled': false,
          'appLockEnabled': true,
          'pinCode': '2580',
          'profileName': 'Nguyen Van A',
          'profileEmail': 'a@example.com',
          'avatarPath': '/tmp/avatar.png',
        },
        'wallets': [
          {
            'id': 'wallet-1',
            'workspaceId': 'workspace-1',
            'name': 'Ví tiền mặt',
            'type': 'cash',
            'balance': 2500000,
            'color': 4280391411,
            'icon': 'wallet',
            'createdAt': '2026-04-01T08:00:00.000Z',
            'updatedAt': '2026-04-01T08:00:00.000Z',
            'deletedAt': null,
          },
        ],
        'categories': [
          {
            'id': 'category-1',
            'workspaceId': 'workspace-1',
            'name': 'Ăn uống',
            'type': 'expense',
            'icon': 'restaurant',
            'createdAt': '2026-04-01T08:00:00.000Z',
            'updatedAt': '2026-04-01T08:00:00.000Z',
            'deletedAt': null,
          },
        ],
        'transactions': [
          {
            'id': 'transaction-1',
            'workspaceId': 'workspace-1',
            'type': 'expense',
            'amount': 45000,
            'walletId': 'wallet-1',
            'targetWalletId': null,
            'categoryId': 'category-1',
            'note': 'Ăn trưa',
            'imagePath': null,
            'status': 'verified',
            'createdAt': '2026-04-02T05:30:00.000Z',
            'updatedAt': '2026-04-02T05:30:00.000Z',
            'deletedAt': null,
          },
        ],
        'budgets': [
          {
            'categoryId': 'category-1',
            'monthKey': '2026-04',
            'amount': 3000000,
          },
        ],
        'goals': [
          {
            'id': 'goal-1',
            'title': 'Quỹ du lịch',
            'walletId': 'wallet-1',
            'targetAmount': 12000000,
            'targetDate': '2026-12-31T00:00:00.000Z',
            'createdAt': '2026-04-01T08:00:00.000Z',
            'note': 'Đi Đà Lạt',
          },
        ],
        'recurringRules': [
          {
            'id': 'rule-1',
            'type': 'expense',
            'amount': 250000,
            'walletId': 'wallet-1',
            'categoryId': 'category-1',
            'note': 'Tiền điện thoại',
            'status': 'pending',
            'interval': 'monthly',
            'nextRunAt': '2026-05-20T07:00:00.000Z',
            'isActive': true,
            'createdAt': '2026-04-20T07:00:00.000Z',
            'lastRunAt': null,
          },
        ],
      });

      final result = await service.restoreBackup(rawBackup);

      expect(result.walletCount, 1);
      expect(result.categoryCount, 1);
      expect(result.transactionCount, 1);
      expect(result.preferences?.profileName, 'Nguyen Van A');
      expect(result.budgets.single.amount, 3000000);
      expect(result.goals.single.title, 'Quỹ du lịch');
      expect(result.recurringRules.single.note, 'Tiền điện thoại');

      final wallets = await database.walletDao.getWallets();
      final categories = await database.categoryDao.getCategories();
      final transactions = await database.transactionDao.getTransactions();

      expect(wallets, hasLength(1));
      expect(wallets.single.name, 'Ví tiền mặt');
      expect(categories, hasLength(1));
      expect(categories.single.name, 'Ăn uống');
      expect(transactions, hasLength(1));
      expect(transactions.single.note, 'Ăn trưa');

      final storedBudgets = jsonDecode(
        prefs.getString(BudgetNotifier.storageKey)!,
      ) as List<dynamic>;
      final storedGoals = jsonDecode(
        prefs.getString(SavingsGoalNotifier.storageKey)!,
      ) as List<dynamic>;
      final storedRecurring = jsonDecode(
        prefs.getString(RecurringNotifier.storageKey)!,
      ) as List<dynamic>;

      expect(storedBudgets, hasLength(1));
      expect(storedBudgets.single['amount'], 3000000);
      expect(storedGoals, hasLength(1));
      expect(storedGoals.single['title'], 'Quỹ du lịch');
      expect(storedRecurring, hasLength(1));
      expect(storedRecurring.single['interval'], 'monthly');
    });
  });
}
