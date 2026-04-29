import 'package:flutter_test/flutter_test.dart';
import 'package:tietkiem/features/ai/data/services/finance_ai_service.dart';
import 'package:tietkiem/features/category/domain/entities/category.dart';
import 'package:tietkiem/features/transaction/domain/entities/finance_transaction.dart';
import 'package:tietkiem/features/wallet/domain/entities/wallet.dart';
import 'package:tietkiem/shared/finance_enums.dart';

void main() {
  final service = FinanceAiService(enabled: false, apiKey: null);
  final wallets = [
    Wallet(
      id: 'cash',
      name: 'Ví tiền mặt',
      type: WalletType.cash,
      balance: 0,
      color: 0,
      icon: 'account_balance_wallet',
      createdAt: DateTime(2026),
    ),
    Wallet(
      id: 'bank',
      name: 'VCB',
      type: WalletType.bank,
      balance: 0,
      color: 0,
      icon: 'account_balance',
      createdAt: DateTime(2026),
    ),
  ];
  final categories = [
    const Category(
      id: 'food',
      name: 'Ăn uống',
      type: TransactionType.expense,
      icon: 'restaurant',
    ),
    const Category(
      id: 'salary',
      name: 'Lương',
      type: TransactionType.income,
      icon: 'payments',
    ),
  ];

  test('local natural language parsing extracts amount, wallet, and category', () async {
    final draft = await service.parseNaturalLanguage(
      input: 'ăn trưa 45k từ ví tiền mặt',
      categories: categories,
      wallets: wallets,
      fallbackType: TransactionType.expense,
      languageCode: 'vi',
    );

    expect(draft.type, TransactionType.expense);
    expect(draft.amount, 45000);
    expect(draft.walletId, 'cash');
    expect(draft.categoryId, 'food');
  });

  test('local monthly summary returns usable fallback content', () async {
    final summary = await service.summarizeMonth(
      transactions: [
        FinanceTransaction(
          id: '1',
          type: TransactionType.income,
          amount: 10000000,
          walletId: 'bank',
          categoryId: 'salary',
          status: TransactionStatus.verified,
          createdAt: DateTime(2026, 4, 1),
        ),
        FinanceTransaction(
          id: '2',
          type: TransactionType.expense,
          amount: 250000,
          walletId: 'cash',
          categoryId: 'food',
          status: TransactionStatus.verified,
          createdAt: DateTime(2026, 4, 2),
        ),
      ],
      categories: categories,
      month: DateTime(2026, 4),
      languageCode: 'vi',
    );

    expect(summary.headline.isNotEmpty, isTrue);
    expect(summary.summary.contains('2026'), isTrue);
    expect(summary.bullets, isNotEmpty);
  });
}
