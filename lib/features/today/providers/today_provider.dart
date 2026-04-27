import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/models/category.dart';
import '../../../core/models/log_entry.dart';
import '../../../core/models/project.dart';
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
    await _putLog(isar, entry);
    await _reloadToday(isar);
  }

  Future<void> deleteLog(int id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.logEntrys.delete(id));
    await _reloadToday(isar);
  }

  Future<void> updateLog(LogEntry entry) async {
    final isar = ref.read(isarProvider);
    await _putLog(isar, entry);
    await _reloadToday(isar);
  }

  Future<void> _putLog(Isar isar, LogEntry entry) async {
    if (entry.category != Category.project) {
      await isar.writeTxn(() => isar.logEntrys.put(entry));
      return;
    }

    await _putProjectLog(isar, entry);
  }

  Future<void> _putProjectLog(Isar isar, LogEntry entry) async {
    final payload = entry.payload;
    final name = (payload['projectName'] as String? ?? '').trim();
    if (name.isEmpty) {
      await isar.writeTxn(() => isar.logEntrys.put(entry));
      return;
    }

    final existingId = payload['projectId'] as int?;
    Project? project = existingId == null
        ? null
        : await isar.projects.get(existingId);
    project ??= await isar.projects
        .filter()
        .nameEqualTo(name, caseSensitive: false)
        .findFirst();

    await isar.writeTxn(() async {
      project ??= Project()
        ..name = name
        ..description = ''
        ..status = ProjectStatus.active
        ..createdAt = entry.createdAt.toLocal();

      if (project!.name != name) {
        project!.name = name;
      }

      final projectId = await isar.projects.put(project!);
      entry.payload = {
        ...payload,
        'projectId': projectId,
        'projectName': project!.name,
      };
      await isar.logEntrys.put(entry);
    });
  }

  Future<void> _reloadToday(Isar isar) async {
    state = AsyncValue.data(await _fetchToday(isar));
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
