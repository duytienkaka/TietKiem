import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tietkiem/features/transaction/presentation/widgets/amount_input.dart';
import 'package:tietkiem/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('AmountInput formats pasted values and reports raw amount', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    var lastValue = 0;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('vi'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: Material(
              child: AmountInput(
                controller: controller,
                rawValue: 0,
                onChanged: (value) => lastValue = value,
              ),
            ),
          ),
        ),
      ),
    );

    final field = find.byType(TextFormField);
    expect(field, findsOneWidget);

    await tester.enterText(field, '1000000');
    await tester.pump();

    expect(controller.text, '1.000.000');
    expect(lastValue, 1000000);
    expect(
      controller.selection,
      const TextSelection.collapsed(offset: 9),
    );
    expect(controller.value.composing, TextRange.empty);
  });

  testWidgets('AmountInput remains stable when replacing with a larger pasted value', (
    tester,
  ) async {
    final controller = TextEditingController(text: '1.000');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('vi'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: Material(
              child: AmountInput(
                controller: controller,
                rawValue: 1000,
              ),
            ),
          ),
        ),
      ),
    );

    final field = find.byType(TextFormField);
    await tester.enterText(field, '123456789');
    await tester.pump();

    expect(controller.text, '123.456.789');
    expect(
      controller.selection,
      const TextSelection.collapsed(offset: 11),
    );
    expect(controller.value.composing, TextRange.empty);
  });
}
