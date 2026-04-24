import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/dsa_tracker/dsa_tracker_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/stats/stats_screen.dart';
import '../../features/today/today_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _ScaffoldWithNavBar(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/', builder: (_, __) => const TodayScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/stats', builder: (_, __) => const StatsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/dsa', builder: (_, __) => const DsaTrackerScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/settings', builder: (_, __) => const SettingsScreen()),
        ]),
      ],
    ),
  ],
);

class _ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell shell;

  const _ScaffoldWithNavBar({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(
          i,
          initialLocation: i == shell.currentIndex,
        ),
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
            icon: Icon(Icons.code_outlined),
            selectedIcon: Icon(Icons.code),
            label: 'DSA',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
