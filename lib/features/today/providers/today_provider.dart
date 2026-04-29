import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/log_entry.dart';
import '../../../core/providers/isar_provider.dart';
import '../data/today_repository.dart';

final todayRepositoryProvider = Provider<TodayRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return TodayRepository(isar);
});

// ── Today's logs ──────────────────────────────────────────────────────────────

class TodayLogsNotifier extends AsyncNotifier<List<LogEntry>> {
  @override
  Future<List<LogEntry>> build() async {
    final repository = ref.watch(todayRepositoryProvider);
    return repository.fetchToday();
  }

  Future<void> addLog(LogEntry entry) async {
    final repository = ref.read(todayRepositoryProvider);
    await repository.saveLog(entry);
    await _reloadToday(repository);
  }

  Future<void> deleteLog(int id) async {
    final repository = ref.read(todayRepositoryProvider);
    await repository.deleteLog(id);
    await _reloadToday(repository);
  }

  Future<void> updateLog(LogEntry entry) async {
    final repository = ref.read(todayRepositoryProvider);
    await repository.saveLog(entry);
    await _reloadToday(repository);
  }

  Future<void> _reloadToday(TodayRepository repository) async {
    state = AsyncValue.data(await repository.fetchToday());
  }
}

final todayLogsProvider =
    AsyncNotifierProvider<TodayLogsNotifier, List<LogEntry>>(
      TodayLogsNotifier.new,
    );

final readingBookNameSuggestionsProvider = FutureProvider<List<String>>((
  ref,
) async {
  ref.watch(todayLogsProvider);
  final repository = ref.watch(todayRepositoryProvider);
  return repository.fetchReadingBookNames();
});

// ── Day counter: how many unique days have been tracked ───────────────────────

final dayNumberProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(todayRepositoryProvider);
  ref.watch(todayLogsProvider); // refresh when today changes
  return repository.fetchTrackedDayCount();
});
