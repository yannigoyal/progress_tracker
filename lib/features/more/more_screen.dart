import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../util/string_constant.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: const [
          _MoreRow(
            icon: Icons.code_outlined,
            title: AppStrings.dsaTrackerScreenTitle,
            route: '/more/dsa',
          ),
          _MoreRow(
            icon: Icons.folder_outlined,
            title: AppStrings.projectScreenTitle,
            route: '/more/projects',
          ),
          _MoreRow(
            icon: Icons.menu_book_outlined,
            title: AppStrings.booksScreenTitle,
            route: '/more/books',
          ),
          _MoreRow(
            icon: Icons.settings_outlined,
            title: AppStrings.settingsScreenTitle,
            route: '/more/settings',
          ),
          _MoreRow(
            icon: Icons.lock_outline,
            title: AppStrings.vaultScreenTitle,
            route: '/more/vault',
          ),
          _MoreRow(
            icon: Icons.cloud_sync_outlined,
            title: AppStrings.backupScreenTitle,
            route: '/more/backup',
          ),
        ],
      ),
    );
  }
}

class _MoreRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;

  const _MoreRow({
    required this.icon,
    required this.title,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(route),
    );
  }
}
