import 'dart:convert';

import '../../../core/models/log_entry.dart';
import '../../../core/models/project.dart';

/// JSON snapshot of local data before encryption.
class BackupSnapshot {
  final List<LogEntry> logs;
  final List<Project> projects;

  const BackupSnapshot({required this.logs, required this.projects});

  String toJsonString() {
    return jsonEncode({
      'logs': logs.map(_logToJson).toList(),
      'projects': projects.map(_projectToJson).toList(),
    });
  }

  static BackupSnapshot fromJsonString(String jsonString) {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final logsJson = decoded['logs'] as List<dynamic>? ?? [];
    final projectsJson = decoded['projects'] as List<dynamic>? ?? [];

    return BackupSnapshot(
      logs: logsJson
          .map((e) => _logFromJson(e as Map<String, dynamic>))
          .whereType<LogEntry>()
          .toList(),
      projects: projectsJson
          .map((e) => _projectFromJson(e as Map<String, dynamic>))
          .whereType<Project>()
          .toList(),
    );
  }

  static Map<String, dynamic> _logToJson(LogEntry log) {
    return {
      'isarId': log.id,
      'createdAt': log.createdAt.toUtc().toIso8601String(),
      'categoryIndex': log.categoryIndex,
      'payloadJson': log.payloadJson,
    };
  }

  static Map<String, dynamic> _projectToJson(Project project) {
    return {
      'isarId': project.id,
      'name': project.name,
      'description': project.description,
      'statusIndex': project.statusIndex,
      'createdAt': project.createdAt.toUtc().toIso8601String(),
    };
  }

  static LogEntry? _logFromJson(Map<String, dynamic> data) {
    final id = _readInt(data['isarId']);
    final createdAtRaw = data['createdAt'] as String?;
    final categoryIndex = _readInt(data['categoryIndex']);
    final payloadJson = data['payloadJson'] as String?;

    if (id == null ||
        createdAtRaw == null ||
        categoryIndex == null ||
        payloadJson == null) {
      return null;
    }

    final createdAt = DateTime.tryParse(createdAtRaw);
    if (createdAt == null) return null;

    return LogEntry()
      ..id = id
      ..createdAt = createdAt.toUtc()
      ..categoryIndex = categoryIndex
      ..payloadJson = payloadJson;
  }

  static Project? _projectFromJson(Map<String, dynamic> data) {
    final id = _readInt(data['isarId']);
    final statusIndex = _readInt(data['statusIndex']);
    final createdAtRaw = data['createdAt'] as String?;
    final name = data['name'] as String?;
    final description = data['description'] as String?;

    if (id == null ||
        statusIndex == null ||
        createdAtRaw == null ||
        name == null ||
        description == null) {
      return null;
    }

    final createdAt = DateTime.tryParse(createdAtRaw);
    if (createdAt == null) return null;

    return Project()
      ..id = id
      ..name = name
      ..description = description
      ..statusIndex = statusIndex
      ..createdAt = createdAt.toUtc();
  }

  static int? _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }
}
