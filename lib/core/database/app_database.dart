import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';
part 'wallet_dao.dart';
part 'transaction_dao.dart';
part 'category_dao.dart';

class Wallets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  RealColumn get balance => real()();
  IntColumn get color => integer()();
  TextColumn get icon => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  RealColumn get amount => real()();
  TextColumn get walletId => text().references(Wallets, #id)();
  TextColumn get targetWalletId => text().nullable().references(Wallets, #id)();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get note => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get icon => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [Wallets, Transactions, Categories], daos: [
  WalletDao,
  TransactionDao,
  CategoryDao,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement('PRAGMA foreign_keys = ON');
          await _seedCategories();
        },
        onUpgrade: (m, from, to) async {
          await customStatement('PRAGMA foreign_keys = OFF');
          await m.createAll();
          await customStatement('PRAGMA foreign_keys = ON');
          await _seedCategories();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          if (details.wasCreated) {
            await _seedCategories();
          }
        },
      );

  Future<void> _seedCategories() async {
    const defaultCategories = [
      ('salary', 'Salary', 'income', 'work'),
      ('gift', 'Gift', 'income', 'redeem'),
      ('bonus', 'Bonus', 'income', 'stars'),
      ('transfer', 'Transfer', 'expense', 'swap_horiz'),
      ('food', 'Food', 'expense', 'restaurant'),
      ('transport', 'Transport', 'expense', 'directions_car'),
      ('shopping', 'Shopping', 'expense', 'shopping_bag'),
      ('bills', 'Bills', 'expense', 'receipt_long'),
      ('health', 'Health', 'expense', 'favorite'),
    ];

    await batch((batch) {
      for (final category in defaultCategories) {
        batch.insert(
          categories,
          CategoriesCompanion.insert(
            id: category.$1,
            name: category.$2,
            type: category.$3,
            icon: category.$4,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  Future<void> resetFinanceData() async {
    await transaction(() async {
      await delete(transactions).go();
      await delete(wallets).go();
      await delete(categories).go();
      await _seedCategories();
    });
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'pocket_ledger',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.dart.js'),
    ),
  );
}
