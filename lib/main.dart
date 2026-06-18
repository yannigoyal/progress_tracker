import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'core/db/isar_service.dart';
import 'core/providers/firebase_provider.dart';
import 'core/providers/isar_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/backup/providers/backup_provider.dart';
import 'util/string_constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isar = await IsarService.open();
  final firebaseStatus = await _initializeFirebase();

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        firebaseInitStatusProvider.overrideWithValue(firebaseStatus),
      ],
      child: const VaultlogApp(),
    ),
  );
}

Future<FirebaseInitStatus> _initializeFirebase() async {
  const firebaseEnabled = true;
  if (!firebaseEnabled) {
    return const FirebaseInitStatus.unavailable(
      'Firebase disabled. Run with --dart-define=VAULTLOG_FIREBASE_ENABLED=true to enable backup.',
    );
  }

  try {
    await Firebase.initializeApp();
    return const FirebaseInitStatus.available();
  } on PlatformException catch (error) {
    debugPrint('Firebase initialization skipped: ${error.message}');
    return FirebaseInitStatus.unavailable(error);
  } catch (error) {
    debugPrint('Firebase initialization skipped: $error');
    return FirebaseInitStatus.unavailable(error);
  }
}

class VaultlogApp extends ConsumerWidget {
  const VaultlogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(backupControllerProvider.select((_) => null));
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: AppStrings.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
