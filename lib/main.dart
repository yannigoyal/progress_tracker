import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/db/isar_service.dart';
import 'core/providers/isar_provider.dart';
import 'core/providers/progress_seed.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isar = await IsarService.open();
  await seedInitialData(isar);

  runApp(
    ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: const DailyLogApp(),
    ),
  );
}

class DailyLogApp extends ConsumerWidget {
  const DailyLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'DailyLog',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
