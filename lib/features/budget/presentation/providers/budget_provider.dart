import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/providers/app_preferences_provider.dart';
import '../../domain/entities/budget.dart';

final budgetProvider = AsyncNotifierProvider<BudgetNotifier, List<Budget>>(
  BudgetNotifier.new,
);

class BudgetNotifier extends AsyncNotifier<List<Budget>> {
  static const storageKey = 'budget.rules';

  SharedPreferences? _prefs;

  @override
  Future<List<Budget>> build() async {
    _prefs = await ref.watch(sharedPreferencesProvider.future);
    return _loadBudgets(_prefs!);
  }

  Future<void> saveBudget({
    required String categoryId,
    required String monthKey,
    required double amount,
  }) async {
    final current = state.valueOrNull ?? await build();
    final next = [...current];
    final index = next.indexWhere(
      (budget) => budget.categoryId == categoryId && budget.monthKey == monthKey,
    );

    if (amount <= 0) {
      if (index != -1) {
        next.removeAt(index);
      }
    } else if (index == -1) {
      next.add(
        Budget(
          categoryId: categoryId,
          monthKey: monthKey,
          amount: amount,
        ),
      );
    } else {
      next[index] = next[index].copyWith(amount: amount);
    }

    state = AsyncData(next);
    await _saveBudgets(next);
  }

  List<Budget> _loadBudgets(SharedPreferences prefs) {
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Budget.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveBudgets(List<Budget> budgets) async {
    final prefs = _prefs ?? await ref.read(sharedPreferencesProvider.future);
    _prefs = prefs;
    final raw = jsonEncode(budgets.map((budget) => budget.toJson()).toList());
    await prefs?.setString(storageKey, raw);
  }

  Future<void> replaceAll(List<Budget> budgets) async {
    state = AsyncData(budgets);
    await _saveBudgets(budgets);
  }
}
