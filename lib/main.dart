import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';
import 'shared/models/app_preferences_state.dart';
import 'shared/providers/app_lock_provider.dart';
import 'shared/providers/app_preferences_provider.dart';
import 'shared/screens/app_lock_screen.dart';
import 'shared/services/sync_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];
  if (supabaseUrl == null || supabaseKey == null) {
    throw Exception('Missing Supabase configuration in .env');
  }
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );
  runApp(const ProviderScope(child: FinanceApp()));
}

class FinanceApp extends ConsumerWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncBootstrapProvider);
    final router = ref.watch(appRouterProvider);
    final preferences = ref.watch(appPreferencesProvider).valueOrNull ??
        const AppPreferencesState.defaults();
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'Tiet Kiem',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: preferences.darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      locale: preferences.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        final lockRequired = ref.watch(appLockRequiredProvider);
        return Stack(
          children: [
            content,
            if (lockRequired) const Positioned.fill(child: AppLockScreen()),
          ],
        );
      },
      routerConfig: router,
    );
  }
}
