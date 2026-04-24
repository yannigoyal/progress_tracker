import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/models/log_entry.dart';
import '../../../core/providers/isar_provider.dart';

// ── Today's logs ──────────────────────────────────────────────────────────────

class TodayLogsNotifier extends AsyncNotifier<List<LogEntry>> {
  @override
  Future<List<LogEntry>> build() async {
    final isar = ref.watch(isarProvider);
    return _fetchToday(isar);
  }

  Future<List<LogEntry>> _fetchToday(Isar isar) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).toUtc();
    final end = start.add(const Duration(days: 1));
    return isar.logEntrys
        .where()
        .createdAtBetween(start, end)
        .sortByCreatedAt()
        .findAll();
  }

  Future<void> addLog(LogEntry entry) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.logEntrys.put(entry));
    ref.invalidateSelf();
  }

  Future<void> deleteLog(int id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.logEntrys.delete(id));
    ref.invalidateSelf();
  }

  Future<void> updateLog(LogEntry entry) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.logEntrys.put(entry));
    ref.invalidateSelf();
  }
}

final todayLogsProvider =
    AsyncNotifierProvider<TodayLogsNotifier, List<LogEntry>>(
  TodayLogsNotifier.new,
);

// ── Day counter: how many unique days have been tracked ───────────────────────

final dayNumberProvider = FutureProvider<int>((ref) async {
  final isar = ref.watch(isarProvider);
  ref.watch(todayLogsProvider); // refresh when today changes
  final all = await isar.logEntrys
      .where()
      .createdAtBetween(DateTime.fromMillisecondsSinceEpoch(0), DateTime(2100))
      .findAll();
  final uniqueDays = all.map((l) {
    final local = l.createdAt.toLocal();
    return DateTime(local.year, local.month, local.day);
  }).toSet();
  final todayDate = () {
    final t = DateTime.now();
    return DateTime(t.year, t.month, t.day);
  }();
  return uniqueDays.contains(todayDate)
      ? uniqueDays.length
      : uniqueDays.length + 1;
});
