import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tietkiem/features/goal/domain/entities/savings_goal.dart';
import 'package:tietkiem/features/goal/presentation/providers/savings_goal_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SavingsGoalNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('saves, sorts and persists goals', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(savingsGoalProvider.future);

      await container.read(savingsGoalProvider.notifier).saveGoal(
            title: 'Quỹ Tết',
            walletId: 'wallet-1',
            targetAmount: 5000000,
            targetDate: DateTime(2026, 12, 30),
            note: '  ',
          );
      await container.read(savingsGoalProvider.notifier).saveGoal(
            title: 'Du lịch hè',
            walletId: 'wallet-2',
            targetAmount: 8000000,
            targetDate: DateTime(2026, 7, 1),
            note: 'Đà Nẵng',
          );

      final goals = container.read(savingsGoalProvider).requireValue;
      expect(goals, hasLength(2));
      expect(goals.first.title, 'Du lịch hè');
      expect(goals.last.title, 'Quỹ Tết');
      expect(goals.last.note, isNull);

      final prefs = await SharedPreferences.getInstance();
      final stored = jsonDecode(
        prefs.getString(SavingsGoalNotifier.storageKey)!,
      ) as List<dynamic>;
      expect(stored, hasLength(2));
      expect(stored.first['title'], 'Du lịch hè');

      final reloadedContainer = ProviderContainer();
      addTearDown(reloadedContainer.dispose);
      final reloadedGoals = await reloadedContainer.read(savingsGoalProvider.future);
      expect(reloadedGoals, hasLength(2));
      expect(reloadedGoals.first.title, 'Du lịch hè');
    });

    test('updates, deletes and replaces goals', () async {
      final now = DateTime(2026, 5, 1, 9);
      final initialGoal = SavingsGoal(
        id: 'goal-1',
        title: 'Laptop mới',
        walletId: 'wallet-1',
        targetAmount: 20000000,
        targetDate: DateTime(2026, 9, 1),
        createdAt: now,
        note: 'Mua cuối năm',
      );

      SharedPreferences.setMockInitialValues({
        SavingsGoalNotifier.storageKey: jsonEncode([initialGoal.toJson()]),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(savingsGoalProvider.future);

      await container.read(savingsGoalProvider.notifier).saveGoal(
            id: 'goal-1',
            title: 'Laptop mới pro',
            walletId: 'wallet-1',
            targetAmount: 22000000,
            targetDate: DateTime(2026, 10, 1),
            note: 'Bản nâng cấp',
          );

      var goals = container.read(savingsGoalProvider).requireValue;
      expect(goals.single.title, 'Laptop mới pro');
      expect(goals.single.createdAt, now);

      await container.read(savingsGoalProvider.notifier).deleteGoal('goal-1');
      goals = container.read(savingsGoalProvider).requireValue;
      expect(goals, isEmpty);

      await container.read(savingsGoalProvider.notifier).replaceAll([
        SavingsGoal(
          id: 'goal-2',
          title: 'Quỹ xe máy',
          walletId: 'wallet-2',
          targetAmount: 15000000,
          targetDate: DateTime(2026, 8, 15),
          createdAt: now,
        ),
        SavingsGoal(
          id: 'goal-3',
          title: 'Quỹ dự phòng',
          walletId: 'wallet-3',
          targetAmount: 10000000,
          targetDate: DateTime(2026, 7, 15),
          createdAt: now,
        ),
      ]);

      goals = container.read(savingsGoalProvider).requireValue;
      expect(goals.map((goal) => goal.id).toList(), ['goal-3', 'goal-2']);
    });
  });
}
