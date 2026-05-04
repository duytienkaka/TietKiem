import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/category/presentation/screens/category_management_screen.dart';
import '../../features/transaction/presentation/providers/notification_import_provider.dart';
import '../../features/transaction/presentation/screens/home_screen.dart';
import '../../features/transaction/presentation/screens/detected_transactions_screen.dart';
import '../../features/transaction/presentation/screens/transaction_detail_screen.dart';
import '../../features/transaction/presentation/screens/statistics_screen.dart';
import '../../features/transaction/presentation/screens/transaction_form_screen.dart';
import '../../features/transaction/presentation/screens/transaction_screen.dart';
import '../../features/wallet/presentation/screens/wallet_detail_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../l10n/l10n.dart';
import '../../shared/screens/more_screen.dart';
import '../../shared/screens/profile_screen.dart';
import '../../shared/screens/settings_screen.dart';
import '../../shared/widgets/animated_fab.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
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
        ],
      ),
      GoRoute(
        path: '/wallets/:id',
        name: 'walletDetail',
        pageBuilder: (context, state) => _slideFadePage(
          state: state,
          child: WalletDetailScreen(walletId: state.pathParameters['id']!),
        ),
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
        path: '/transactions/:id/edit',
        name: 'editTransaction',
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
            transactionId: state.pathParameters['id'],
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
      GoRoute(
        path: '/settings/categories',
        name: 'categoryManagement',
        pageBuilder: (context, state) => _slideFadePage(
          state: state,
          child: const CategoryManagementScreen(),
        ),
      ),
      GoRoute(
        path: '/more/detected-transactions',
        name: 'detectedTransactions',
        pageBuilder: (context, state) => _slideFadePage(
          state: state,
          child: const DetectedTransactionsScreen(),
        ),
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

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(pendingNotificationImportCountProvider);
    final destinations = [
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
      ('/more', context.l10n.moreTab, Icons.widgets_rounded),
    ];
    final location = GoRouterState.of(context).uri.toString();
    final index = destinations.indexWhere((item) => item.$1 == location);
    final showFab = location != '/wallets' && location != '/more';

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
                    selectedIcon: item.$1 == '/more' && pendingCount > 0
                        ? _BadgedNavIcon(
                            icon: item.$3,
                            count: pendingCount,
                            selected: true,
                          )
                        : null,
                    icon: item.$1 == '/more' && pendingCount > 0
                        ? _BadgedNavIcon(
                            icon: item.$3,
                            count: pendingCount,
                            selected: false,
                          )
                        : Icon(item.$3),
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

class _BadgedNavIcon extends StatelessWidget {
  const _BadgedNavIcon({
    required this.icon,
    required this.count,
    required this.selected,
  });

  final IconData icon;
  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        Positioned(
          right: -4,
          top: -2,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFE11D48),
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : Theme.of(context).colorScheme.surface,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
