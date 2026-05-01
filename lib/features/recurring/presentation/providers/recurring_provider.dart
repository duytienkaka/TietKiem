import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/finance_enums.dart';
import '../../../../shared/providers/app_preferences_provider.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../domain/entities/recurring_rule.dart';

final recurringProvider =
    AsyncNotifierProvider<RecurringNotifier, List<RecurringRule>>(
  RecurringNotifier.new,
);

final recurringProcessorProvider = FutureProvider<void>((ref) async {
  await ref.read(recurringProvider.notifier).processDueTransactions();
});

class RecurringNotifier extends AsyncNotifier<List<RecurringRule>> {
  static const storageKey = 'recurring.rules';

  SharedPreferences? _prefs;

  @override
  Future<List<RecurringRule>> build() async {
    _prefs = await ref.watch(sharedPreferencesProvider.future);
    return _loadRules(_prefs!);
  }

  Future<void> saveRule({
    String? id,
    required TransactionType type,
    required double amount,
    required String walletId,
    required String categoryId,
    required TransactionStatus status,
    required RecurringInterval interval,
    String? note,
    DateTime? nextRunAt,
    bool isActive = true,
  }) async {
    final current = state.valueOrNull ?? await build();
    final now = DateTime.now();
    final ruleId = id ?? const Uuid().v4();
    final resolvedNext = nextRunAt ?? _nextRunAt(now, interval);
    final index = current.indexWhere((rule) => rule.id == ruleId);

    final nextRule = RecurringRule(
      id: ruleId,
      type: type,
      amount: amount,
      walletId: walletId,
      categoryId: categoryId,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
      status: status,
      interval: interval,
      nextRunAt: resolvedNext,
      isActive: isActive,
      createdAt: index == -1 ? now : current[index].createdAt,
      lastRunAt: index == -1 ? null : current[index].lastRunAt,
    );

    final next = [...current];
    if (index == -1) {
      next.add(nextRule);
    } else {
      next[index] = nextRule;
    }

    state = AsyncData(next);
    await _saveRules(next);
  }

  Future<void> deleteRule(String id) async {
    final current = state.valueOrNull ?? await build();
    final next = current.where((rule) => rule.id != id).toList();
    state = AsyncData(next);
    await _saveRules(next);
  }

  Future<void> toggleRule(String id, bool isActive) async {
    final current = state.valueOrNull ?? await build();
    final next = current
        .map(
          (rule) => rule.id == id ? rule.copyWith(isActive: isActive) : rule,
        )
        .toList();
    state = AsyncData(next);
    await _saveRules(next);
  }

  Future<void> processDueTransactions({DateTime? now}) async {
    final current = state.valueOrNull ?? await build();
    if (current.isEmpty) {
      return;
    }

    final timestamp = now ?? DateTime.now();
    final updated = [...current];
    var didUpdate = false;

    for (var index = 0; index < updated.length; index++) {
      final rule = updated[index];
      if (!rule.isActive) {
        continue;
      }

      var nextRunAt = rule.nextRunAt;
      DateTime? lastRun;

      while (!nextRunAt.isAfter(timestamp)) {
        await ref.read(transactionProvider.notifier).saveTransaction(
              id: null,
              type: rule.type,
              amount: rule.amount,
              walletId: rule.walletId,
              categoryId: rule.categoryId,
              note: rule.note,
              imagePath: null,
              status: rule.status,
              createdAt: nextRunAt,
            );

        lastRun = nextRunAt;
        nextRunAt = _nextRunAt(nextRunAt, rule.interval);
      }

      if (lastRun != null) {
        updated[index] = rule.copyWith(
          nextRunAt: nextRunAt,
          lastRunAt: lastRun,
        );
        didUpdate = true;
      }
    }

    if (didUpdate) {
      state = AsyncData(updated);
      await _saveRules(updated);
    }
  }

  List<RecurringRule> _loadRules(SharedPreferences prefs) {
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(RecurringRule.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveRules(List<RecurringRule> rules) async {
    final prefs = _prefs ?? await ref.read(sharedPreferencesProvider.future);
    _prefs = prefs;
    final raw = jsonEncode(rules.map((rule) => rule.toJson()).toList());
    await prefs?.setString(storageKey, raw);
  }

  Future<void> replaceAll(List<RecurringRule> rules) async {
    state = AsyncData(rules);
    await _saveRules(rules);
  }

  DateTime _nextRunAt(DateTime base, RecurringInterval interval) {
    return switch (interval) {
      RecurringInterval.weekly => base.add(const Duration(days: 7)),
      RecurringInterval.monthly => _addMonths(base, 1),
    };
  }

  DateTime _addMonths(DateTime base, int months) {
    final nextMonthIndex = base.month - 1 + months;
    final year = base.year + (nextMonthIndex ~/ 12);
    final month = (nextMonthIndex % 12) + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = base.day.clamp(1, lastDay);
    return DateTime(year, month, day, base.hour, base.minute);
  }
}
