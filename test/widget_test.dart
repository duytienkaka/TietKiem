import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tietkiem/main.dart';

void main() {
  testWidgets('app boots', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FinanceApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
