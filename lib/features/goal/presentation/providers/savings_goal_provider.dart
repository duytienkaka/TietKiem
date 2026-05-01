import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/providers/app_preferences_provider.dart';
import '../../domain/entities/savings_goal.dart';

final savingsGoalProvider =
    AsyncNotifierProvider<SavingsGoalNotifier, List<SavingsGoal>>(
  SavingsGoalNotifier.new,
);

class SavingsGoalNotifier extends AsyncNotifier<List<SavingsGoal>> {
  static const storageKey = 'savings.goals';

  SharedPreferences? _prefs;

  @override
  Future<List<SavingsGoal>> build() async {
    _prefs = await ref.watch(sharedPreferencesProvider.future);
    return _loadGoals(_prefs!);
  }

  Future<void> saveGoal({
    String? id,
    required String title,
    required String walletId,
    required double targetAmount,
    required DateTime targetDate,
    String? note,
  }) async {
    final current = state.valueOrNull ?? await build();
    final now = DateTime.now();
    final trimmedTitle = title.trim();
    final goalId = id ?? const Uuid().v4();
    final index = current.indexWhere((goal) => goal.id == goalId);

    final nextGoal = SavingsGoal(
      id: goalId,
      title: trimmedTitle,
      walletId: walletId,
      targetAmount: targetAmount,
      targetDate: targetDate,
      createdAt: index == -1 ? now : current[index].createdAt,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
    );

    final next = [...current];
    if (index == -1) {
      next.add(nextGoal);
    } else {
      next[index] = nextGoal;
    }

    next.sort((a, b) => a.targetDate.compareTo(b.targetDate));
    state = AsyncData(next);
    await _saveGoals(next);
  }

  Future<void> deleteGoal(String id) async {
    final current = state.valueOrNull ?? await build();
    final next = current.where((goal) => goal.id != id).toList();
    state = AsyncData(next);
    await _saveGoals(next);
  }

  Future<void> replaceAll(List<SavingsGoal> goals) async {
    final next = [...goals]..sort((a, b) => a.targetDate.compareTo(b.targetDate));
    state = AsyncData(next);
    await _saveGoals(next);
  }

  List<SavingsGoal> _loadGoals(SharedPreferences prefs) {
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(SavingsGoal.fromJson)
          .toList()
        ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveGoals(List<SavingsGoal> goals) async {
    final prefs = _prefs ?? await ref.read(sharedPreferencesProvider.future);
    _prefs = prefs;
    final raw = jsonEncode(goals.map((goal) => goal.toJson()).toList());
    await prefs?.setString(storageKey, raw);
  }
}
