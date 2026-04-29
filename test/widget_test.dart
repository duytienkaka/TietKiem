import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tietkiem/main.dart';
import 'package:tietkiem/shared/providers/supabase_client_provider.dart';

void main() {
  testWidgets('app boots', (tester) async {
    final client = SupabaseClient('https://example.supabase.co', 'anon-key');
    addTearDown(() {
      client.auth.stopAutoRefresh();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseClientProvider.overrideWithValue(client),
        ],
        child: const FinanceApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(MaterialApp), findsOneWidget);
  }, skip: true);
}
