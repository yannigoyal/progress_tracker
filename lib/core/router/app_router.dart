import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/backup/backup_screen.dart';
import '../../features/dsa_tracker/dsa_tracker_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/more/more_screen.dart';
import '../../features/project/project_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/stats/stats_screen.dart';
import '../../features/today/today_screen.dart';
import '../../features/vault/vault_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _ScaffoldWithNavBar(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const TodayScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stats',
              builder: (context, state) => const StatsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/more',
              builder: (context, state) => const MoreScreen(),
              routes: [
                GoRoute(
                  path: 'dsa',
                  builder: (context, state) => const DsaTrackerScreen(),
                ),
                GoRoute(
                  path: 'projects',
                  builder: (context, state) => const ProjectScreen(),
                ),
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => const SettingsScreen(),
                ),
                GoRoute(
                  path: 'backup',
                  builder: (context, state) => const BackupScreen(),
                ),
                GoRoute(
                  path: 'vault',
                  builder: (context, state) => const VaultScreen(),
                  routes: [
                    GoRoute(
                      path: 'entry/:entryId',
                      builder: (context, state) => VaultEntryScreen(
                        entryId: state.pathParameters['entryId'],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class _ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell shell;

  const _ScaffoldWithNavBar({required this.shell});

  @override
  Widget build(BuildContext context) {
    final navTheme = NavigationBarTheme.of(context);
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBarTheme(
        data: navTheme.copyWith(
          indicatorColor: primaryColor.withAlpha(28),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            final baseTheme = navTheme.iconTheme?.resolve(states);
            return (baseTheme ?? const IconThemeData()).copyWith(
              color: selected ? primaryColor : baseTheme?.color,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            final baseStyle =
                navTheme.labelTextStyle?.resolve(states) ??
                Theme.of(context).textTheme.labelMedium ??
                const TextStyle();
            return baseStyle.copyWith(
              color: selected ? primaryColor : baseStyle.color,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.today_outlined),
              selectedIcon: Icon(Icons.today),
              label: 'Today',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.more_horiz_outlined),
              selectedIcon: Icon(Icons.more_horiz),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}
