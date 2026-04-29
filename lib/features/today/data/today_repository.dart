import 'package:isar/isar.dart';

import '../../../core/models/category.dart';
import '../../../core/models/log_entry.dart';
import '../../../core/models/project.dart';

class TodayRepository {
  final Isar _isar;

  const TodayRepository(this._isar);

  Future<List<LogEntry>> fetchToday() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).toUtc();
    final end = start.add(const Duration(days: 1));
    return _isar.logEntrys
        .where()
        .createdAtBetween(start, end)
        .sortByCreatedAt()
        .findAll();
  }

  Future<void> saveLog(LogEntry entry) async {
    if (entry.category != Category.project) {
      await _isar.writeTxn(() => _isar.logEntrys.put(entry));
      return;
    }

    await _saveProjectLog(entry);
  }

  Future<void> deleteLog(int id) async {
    await _isar.writeTxn(() => _isar.logEntrys.delete(id));
  }

  Future<List<String>> fetchReadingBookNames() async {
    final logs = await _isar.logEntrys
        .where()
        .categoryIndexEqualTo(Category.reading.index)
        .sortByCreatedAtDesc()
        .findAll();

    final seen = <String>{};
    final names = <String>[];
    for (final log in logs) {
      final name = (log.payload['bookName'] as String? ?? '').trim();
      if (name.isEmpty) continue;

      final key = name.toLowerCase();
      if (seen.add(key)) {
        names.add(name);
      }
    }

    return names;
  }

  Future<int> fetchTrackedDayCount() async {
    final all = await _isar.logEntrys
        .where()
        .createdAtBetween(
          DateTime.fromMillisecondsSinceEpoch(0),
          DateTime(2100),
        )
        .findAll();

    final uniqueDays = all.map((log) {
      final local = log.createdAt.toLocal();
      return DateTime(local.year, local.month, local.day);
    }).toSet();

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return uniqueDays.contains(todayDate)
        ? uniqueDays.length
        : uniqueDays.length + 1;
  }

  Future<void> _saveProjectLog(LogEntry entry) async {
    final payload = entry.payload;
    final name = (payload['projectName'] as String? ?? '').trim();
    if (name.isEmpty) {
      await _isar.writeTxn(() => _isar.logEntrys.put(entry));
      return;
    }

    final existingId = payload['projectId'] as int?;
    Project? project = existingId == null
        ? null
        : await _isar.projects.get(existingId);
    project ??= await _isar.projects
        .filter()
        .nameEqualTo(name, caseSensitive: false)
        .findFirst();

    await _isar.writeTxn(() async {
      project ??= Project()
        ..name = name
        ..description = ''
        ..status = ProjectStatus.active
        ..createdAt = entry.createdAt.toLocal();

      if (project!.name != name) {
        project!.name = name;
      }

      final projectId = await _isar.projects.put(project!);
      entry.payload = {
        ...payload,
        'projectId': projectId,
        'projectName': project!.name,
      };
      await _isar.logEntrys.put(entry);
    });
  }
}
