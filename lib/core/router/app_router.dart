import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/budget/presentation/screens/budget_screen.dart';
import '../../features/recurring/presentation/screens/recurring_screen.dart';
import '../../features/transaction/presentation/screens/calculator_screen.dart';
import '../../features/transaction/presentation/screens/home_screen.dart';
import '../../features/transaction/presentation/screens/statistics_screen.dart';
import '../../features/transaction/presentation/screens/transaction_detail_screen.dart';
import '../../features/transaction/presentation/screens/transaction_form_screen.dart';
import '../../features/transaction/presentation/screens/transaction_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../l10n/l10n.dart';
import '../../shared/providers/auth_session_provider.dart';
import '../../shared/providers/router_refresh_provider.dart';
import '../../shared/screens/loading_screen.dart';
import '../../shared/screens/more_screen.dart';
import '../../shared/screens/profile_screen.dart';
import '../../shared/screens/settings_screen.dart';
import '../../shared/widgets/animated_fab.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authSession = ref.watch(authSessionProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: ref.watch(routerRefreshProvider),
    redirect: (context, state) {
      final isLoading = state.matchedLocation == '/loading';
      final isAuth = state.matchedLocation == '/auth';
      final bootstrapping = authSession.isLoading;

      if (bootstrapping) {
        return isLoading ? null : '/loading';
      }

      final session = authSession.valueOrNull;
      if (session == null) {
        return isAuth ? null : '/auth';
      }

      if (isLoading || isAuth) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/loading',
        name: 'loading',
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const LoadingScreen()),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        pageBuilder: (context, state) =>
            _slideFadePage(state: state, child: const AuthScreen()),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) =>
                _fadePage(state: state, child: const HomeScreen()),
          ),
          GoRoute(
            path: '/transactions',
            name: 'transactions',
            pageBuilder: (context, state) =>
                _fadePage(state: state, child: const TransactionScreen()),
          ),
          GoRoute(
            path: '/statistics',
            name: 'statistics',
            pageBuilder: (context, state) =>
                _fadePage(state: state, child: const StatisticsScreen()),
          ),
          GoRoute(
            path: '/wallets',
            name: 'wallets',
            pageBuilder: (context, state) =>
                _fadePage(state: state, child: const WalletScreen()),
          ),
          GoRoute(
            path: '/more',
            name: 'more',
            pageBuilder: (context, state) =>
                _fadePage(state: state, child: const MoreScreen()),
          ),
          GoRoute(
            path: '/more/calculator',
            name: 'calculator',
            pageBuilder: (context, state) =>
                _slideFadePage(state: state, child: const CalculatorScreen()),
          ),
          GoRoute(
            path: '/more/recurring',
            name: 'recurring',
            pageBuilder: (context, state) =>
                _slideFadePage(state: state, child: const RecurringScreen()),
          ),
          GoRoute(
            path: '/more/budgets',
            name: 'budgets',
            pageBuilder: (context, state) =>
                _slideFadePage(state: state, child: const BudgetScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/transactions/add',
        name: 'addTransaction',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: animation.drive(tween),
                child: child,
              ),
            );
          },
          child: TransactionFormScreen(
            initialTypeName: state.uri.queryParameters['type'],
          ),
        ),
      ),
      GoRoute(
        path: '/transactions/:id',
        name: 'transactionDetail',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 260),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInOutCubic,
            );
            return FadeTransition(
              opacity: curve,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.012),
                  end: Offset.zero,
                ).animate(curve),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.985, end: 1).animate(curve),
                  child: child,
                ),
              ),
            );
          },
          child: TransactionDetailScreen(
            transactionId: state.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) =>
            _slideFadePage(state: state, child: const ProfileScreen()),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) =>
            _slideFadePage(state: state, child: const SettingsScreen()),
      ),
    ],
  );
});

CustomTransitionPage<void> _fadePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    child: child,
  );
}

CustomTransitionPage<void> _slideFadePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInOutCubic,
      );
      return FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curve),
          child: child,
        ),
      );
    },
    child: child,
  );
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final destinations = <(String, String, IconData)>[
      ('/', context.l10n.homeTab, Icons.home_rounded),
      (
        '/transactions',
        context.l10n.transactionsTab,
        Icons.receipt_long_rounded,
      ),
      ('/statistics', context.l10n.statisticsTab, Icons.pie_chart_rounded),
      (
        '/wallets',
        context.l10n.walletsTab,
        Icons.account_balance_wallet_rounded,
      ),
      ('/more', 'Khác', Icons.grid_view_rounded),
    ];
    final location = GoRouterState.of(context).uri.toString();
    final index = destinations.indexWhere((item) {
      if (item.$1 == '/') {
        return location == '/';
      }
      return location == item.$1 || location.startsWith('${item.$1}/');
    });
    final showFab =
        !location.startsWith('/wallets') && !location.startsWith('/more');

    return Scaffold(
      extendBody: true,
      body: child,
      floatingActionButton: showFab
          ? AnimatedFab(
              label: context.l10n.quickAdd,
              icon: Icons.add_rounded,
              onPressed: () => showTransactionEntrySheet(context),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            selectedIndex: index < 0 ? 0 : index,
            destinations: destinations
                .map(
                  (item) => NavigationDestination(
                    icon: Icon(item.$3),
                    label: item.$2,
                  ),
                )
                .toList(),
            onDestinationSelected: (selected) {
              context.go(destinations[selected].$1);
            },
          ),
        ),
      ),
    );
  }
}
