import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';
import 'shared/models/app_preferences_state.dart';
import 'shared/providers/app_lock_provider.dart';
import 'shared/providers/app_preferences_provider.dart';
import 'shared/services/bank_notification_import_bootstrap.dart';
import 'shared/screens/app_lock_screen.dart';
import 'shared/services/local_notification_bootstrap.dart';
import 'shared/widgets/bank_notification_prompt_host.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: FinanceApp()));
}

class FinanceApp extends ConsumerWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localNotificationBootstrapProvider);
    ref.watch(bankNotificationImportBootstrapProvider);
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
        return BankNotificationPromptHost(
          child: Stack(
            children: [
              content,
              if (lockRequired) const Positioned.fill(child: AppLockScreen()),
            ],
          ),
        );
      },
      routerConfig: router,
    );
  }
}
