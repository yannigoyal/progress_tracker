import 'package:isar/isar.dart';

import '../../../core/models/log_entry.dart';
import '../../../core/models/project.dart';

class SettingsExportData {
  final List<LogEntry> logs;
  final List<Project> projects;

  const SettingsExportData({required this.logs, required this.projects});
}

class SettingsRepository {
  final Isar _isar;

  const SettingsRepository(this._isar);

  Future<SettingsExportData> fetchExportData() async {
    final logs = await _isar.logEntrys
        .where()
        .createdAtBetween(
          DateTime.fromMillisecondsSinceEpoch(0),
          DateTime(2100),
        )
        .sortByCreatedAtDesc()
        .findAll();
    final projects = await _isar.projects
        .where()
        .sortByCreatedAtDesc()
        .findAll();

    return SettingsExportData(logs: logs, projects: projects);
  }

  Future<void> clearLogs() async {
    await _isar.writeTxn(() => _isar.logEntrys.clear());
  }
}
