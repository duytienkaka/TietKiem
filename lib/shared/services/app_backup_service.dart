import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/database/app_database.dart' as db;
import '../../core/database/database_provider.dart';
import '../../features/budget/domain/entities/budget.dart' as budget_entity;
import '../../features/budget/presentation/providers/budget_provider.dart';
import '../../features/category/data/models/category_model.dart';
import '../../features/category/domain/entities/category.dart'
    as category_entity;
import '../../features/goal/domain/entities/savings_goal.dart';
import '../../features/goal/presentation/providers/savings_goal_provider.dart';
import '../../features/recurring/domain/entities/recurring_rule.dart';
import '../../features/recurring/presentation/providers/recurring_provider.dart';
import '../../features/transaction/data/models/transaction_model.dart';
import '../../features/transaction/domain/entities/finance_transaction.dart';
import '../../features/wallet/data/models/wallet_model.dart';
import '../../features/wallet/domain/entities/wallet.dart' as wallet_entity;
import '../finance_enums.dart';
import '../models/app_preferences_state.dart';
import '../providers/app_preferences_provider.dart';
import 'backup_file_saver.dart';

final appBackupServiceProvider = Provider<AppBackupService>((ref) {
  return AppBackupService(
    database: ref.watch(appDatabaseProvider),
    sharedPreferences: ref.watch(sharedPreferencesProvider.future),
  );
});

class AppBackupService {
  const AppBackupService({
    required db.AppDatabase database,
    required Future<SharedPreferences> sharedPreferences,
  }) : _database = database,
       _sharedPreferences = sharedPreferences;

  final db.AppDatabase _database;
  final Future<SharedPreferences> _sharedPreferences;

  Future<String> exportBackup({
    required AppPreferencesState preferences,
    List<budget_entity.Budget>? budgetsOverride,
    List<SavingsGoal>? goalsOverride,
    List<RecurringRule>? recurringOverride,
  }) async {
    final wallets = await _loadWallets();
    final categories = await _loadCategories();
    final transactions = await _loadTransactions();
    final prefs = await _sharedPreferences;

    final budgets = budgetsOverride ?? _loadBudgets(prefs);
    final goals = goalsOverride ?? _loadGoals(prefs);
    final recurring = recurringOverride ?? _loadRecurring(prefs);

    final payload = const JsonEncoder.withIndent('  ').convert({
      'schemaVersion': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'preferences': preferences.toJson(),
      'wallets': [for (final wallet in wallets) _walletToJson(wallet)],
      'categories': [
        for (final category in categories) _categoryToJson(category),
      ],
      'transactions': [
        for (final transaction in transactions) _transactionToJson(transaction),
      ],
      'budgets': [for (final budget in budgets) budget.toJson()],
      'goals': [for (final goal in goals) goal.toJson()],
      'recurringRules': [for (final rule in recurring) rule.toJson()],
    });

    final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(
      ':',
      '-',
    );
    return saveBackupFile(
      fileName: 'tietkiem-backup-$timestamp.json',
      contents: payload,
    );
  }

  Future<AppBackupImportResult?> restoreBackupFromPicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;
    final raw = file.bytes != null ? utf8.decode(file.bytes!) : null;
    if (raw == null || raw.trim().isEmpty) {
      throw const FormatException('Backup file is empty.');
    }

    return restoreBackup(raw);
  }

  Future<AppBackupImportResult> restoreBackup(String rawJson) async {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup format.');
    }

    final wallets = (decoded['wallets'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_walletFromJson)
        .toList();
    final categories = (decoded['categories'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_categoryFromJson)
        .toList();
    final transactions = (decoded['transactions'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_transactionFromJson)
        .toList();
    final budgets = (decoded['budgets'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(budget_entity.Budget.fromJson)
        .toList();
    final goals = (decoded['goals'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(SavingsGoal.fromJson)
        .toList();
    final recurring = (decoded['recurringRules'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(RecurringRule.fromJson)
        .toList();
    final preferences = decoded['preferences'] is Map<String, dynamic>
        ? AppPreferencesState.fromJson(
            decoded['preferences'] as Map<String, dynamic>,
          )
        : null;

    await _database.transaction(() async {
      await _database.resetFinanceData();
      for (final wallet in wallets) {
        await _database.walletDao.upsertWallet(
          WalletModel.fromEntity(wallet).toCompanion(),
        );
      }
      for (final category in categories) {
        await _database.categoryDao.upsertCategory(
          CategoryModel.fromEntity(category).toCompanion(),
        );
      }
      for (final transaction in transactions) {
        await _database.transactionDao.upsertTransaction(
          TransactionModel.fromEntity(transaction).toCompanion(),
        );
      }
      await (_database.delete(_database.syncQueueItems)).go();
    });

    final prefs = await _sharedPreferences;
    await prefs.setString(
      BudgetNotifier.storageKey,
      jsonEncode(budgets.map((item) => item.toJson()).toList()),
    );
    await prefs.setString(
      SavingsGoalNotifier.storageKey,
      jsonEncode(goals.map((item) => item.toJson()).toList()),
    );
    await prefs.setString(
      RecurringNotifier.storageKey,
      jsonEncode(recurring.map((item) => item.toJson()).toList()),
    );

    return AppBackupImportResult(
      preferences: preferences,
      budgets: budgets,
      goals: goals,
      recurringRules: recurring,
      walletCount: wallets.length,
      transactionCount: transactions.length,
      categoryCount: categories.length,
    );
  }

  Future<List<wallet_entity.Wallet>> _loadWallets() async {
    final rows =
        await (_database.select(_database.wallets)
              ..where((tbl) => tbl.deletedAt.isNull())
              ..orderBy([(tbl) => drift.OrderingTerm.asc(tbl.createdAt)]))
            .get();
    return rows.map((item) => WalletModel.fromData(item).toEntity()).toList();
  }

  Future<List<category_entity.Category>> _loadCategories() async {
    final rows =
        await (_database.select(_database.categories)
              ..where((tbl) => tbl.deletedAt.isNull())
              ..orderBy([(tbl) => drift.OrderingTerm.asc(tbl.name)]))
            .get();
    return rows.map((item) => CategoryModel.fromData(item).toEntity()).toList();
  }

  Future<List<FinanceTransaction>> _loadTransactions() async {
    final rows =
        await (_database.select(_database.transactions)
              ..where((tbl) => tbl.deletedAt.isNull())
              ..orderBy([(tbl) => drift.OrderingTerm.desc(tbl.createdAt)]))
            .get();
    return rows
        .map((item) => TransactionModel.fromData(item).toEntity())
        .toList();
  }

  List<budget_entity.Budget> _loadBudgets(SharedPreferences prefs) {
    final raw = prefs.getString(BudgetNotifier.storageKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(budget_entity.Budget.fromJson)
        .toList();
  }

  List<RecurringRule> _loadRecurring(SharedPreferences prefs) {
    final raw = prefs.getString(RecurringNotifier.storageKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(RecurringRule.fromJson)
        .toList();
  }

  List<SavingsGoal> _loadGoals(SharedPreferences prefs) {
    final raw = prefs.getString(SavingsGoalNotifier.storageKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(SavingsGoal.fromJson)
        .toList();
  }

  Map<String, dynamic> _walletToJson(wallet_entity.Wallet wallet) {
    return {
      'id': wallet.id,
      'workspaceId': wallet.workspaceId,
      'name': wallet.name,
      'type': wallet.type.name,
      'balance': wallet.balance,
      'color': wallet.color,
      'icon': wallet.icon,
      'bankName': wallet.bankName,
      'bankAliases': wallet.bankAliases,
      'accountNumber': wallet.accountNumber,
      'accountHolder': wallet.accountHolder,
      'paymentNote': wallet.paymentNote,
      'qrImagePath': wallet.qrImagePath,
      'qrPayload': wallet.qrPayload,
      'createdAt': wallet.createdAt.toIso8601String(),
      'updatedAt': wallet.updatedAt.toIso8601String(),
      'deletedAt': wallet.deletedAt?.toIso8601String(),
    };
  }

  wallet_entity.Wallet _walletFromJson(Map<String, dynamic> json) {
    return wallet_entity.Wallet(
      id: json['id'] as String,
      workspaceId: json['workspaceId'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      type: WalletType.values.byName(json['type'] as String),
      balance: (json['balance'] as num).toDouble(),
      color: json['color'] as int,
      icon: json['icon'] as String,
      bankName: json['bankName'] as String?,
      bankAliases: json['bankAliases'] as String?,
      accountNumber: json['accountNumber'] as String?,
      accountHolder: json['accountHolder'] as String?,
      paymentNote: json['paymentNote'] as String?,
      qrImagePath: json['qrImagePath'] as String?,
      qrPayload: json['qrPayload'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(
        json['updatedAt'] as String? ?? json['createdAt'] as String,
      ),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );
  }

  Map<String, dynamic> _categoryToJson(category_entity.Category category) {
    return {
      'id': category.id,
      'workspaceId': category.workspaceId,
      'name': category.name,
      'type': category.type.name,
      'icon': category.icon,
      'createdAt': category.createdAt.toIso8601String(),
      'updatedAt': category.updatedAt.toIso8601String(),
      'deletedAt': category.deletedAt?.toIso8601String(),
    };
  }

  category_entity.Category _categoryFromJson(Map<String, dynamic> json) {
    return category_entity.Category(
      id: json['id'] as String,
      workspaceId: json['workspaceId'] as String,
      name: json['name'] as String,
      type: TransactionType.values.byName(json['type'] as String),
      icon: json['icon'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(
        json['updatedAt'] as String? ?? json['createdAt'] as String,
      ),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );
  }

  Map<String, dynamic> _transactionToJson(FinanceTransaction transaction) {
    return {
      'id': transaction.id,
      'workspaceId': transaction.workspaceId,
      'type': transaction.type.name,
      'amount': transaction.amount,
      'walletId': transaction.walletId,
      'targetWalletId': transaction.targetWalletId,
      'categoryId': transaction.categoryId,
      'note': transaction.note,
      'imagePath': transaction.imagePath,
      'status': transaction.status.name,
      'createdAt': transaction.createdAt.toIso8601String(),
      'updatedAt': transaction.updatedAt.toIso8601String(),
      'deletedAt': transaction.deletedAt?.toIso8601String(),
    };
  }

  FinanceTransaction _transactionFromJson(Map<String, dynamic> json) {
    final type = TransactionType.values.byName(json['type'] as String);
    return FinanceTransaction(
      id: json['id'] as String,
      workspaceId: json['workspaceId'] as String? ?? json['walletId'] as String,
      type: type,
      amount: (json['amount'] as num).toDouble(),
      walletId: json['walletId'] as String,
      targetWalletId: json['targetWalletId'] as String?,
      categoryId: (json['categoryId'] as String?) ?? 'transfer',
      note: json['note'] as String?,
      imagePath: json['imagePath'] as String?,
      status: TransactionStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(
        json['updatedAt'] as String? ?? json['createdAt'] as String,
      ),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );
  }
}

class AppBackupImportResult {
  const AppBackupImportResult({
    required this.preferences,
    required this.budgets,
    required this.goals,
    required this.recurringRules,
    required this.walletCount,
    required this.transactionCount,
    required this.categoryCount,
  });

  final AppPreferencesState? preferences;
  final List<budget_entity.Budget> budgets;
  final List<SavingsGoal> goals;
  final List<RecurringRule> recurringRules;
  final int walletCount;
  final int transactionCount;
  final int categoryCount;
}
