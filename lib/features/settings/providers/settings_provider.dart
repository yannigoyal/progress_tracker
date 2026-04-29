import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/isar_provider.dart';
import '../data/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return SettingsRepository(isar);
});

final settingsExportProvider = FutureProvider.autoDispose<SettingsExportData>((
  ref,
) async {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.fetchExportData();
});

class SettingsDataNotifier extends AutoDisposeNotifier<void> {
  @override
  void build() {}

  Future<void> clearLogs() async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.clearLogs();
  }
}

final settingsDataNotifierProvider =
    NotifierProvider.autoDispose<SettingsDataNotifier, void>(
      SettingsDataNotifier.new,
    );
