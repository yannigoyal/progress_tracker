import 'dart:convert';

import '../../../core/models/custom_activity.dart';
import '../../../core/models/log_entry.dart';
import '../../../core/models/project.dart';
import '../../settings/data/custom_activity_icon_storage.dart';

/// JSON snapshot of local data before encryption.
class BackupSnapshot {
  final List<LogEntry> logs;
  final List<Project> projects;
  final List<CustomActivity> customActivities;

  const BackupSnapshot({
    required this.logs,
    required this.projects,
    this.customActivities = const [],
  });

  Future<String> toJsonString({CustomActivityIconStorage? iconStorage}) async {
    final storage = iconStorage ?? CustomActivityIconStorage();
    final activitiesJson = await Future.wait(
      customActivities.map((a) => _customActivityToJson(a, storage)),
    );

    return jsonEncode({
      'logs': logs.map(_logToJson).toList(),
      'projects': projects.map(_projectToJson).toList(),
      'customActivities': activitiesJson,
    });
  }

  static BackupSnapshot fromJsonString(String jsonString) {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final logsJson = decoded['logs'] as List<dynamic>? ?? [];
    final projectsJson = decoded['projects'] as List<dynamic>? ?? [];
    final activitiesJson = decoded['customActivities'] as List<dynamic>? ?? [];

    return BackupSnapshot(
      logs: logsJson
          .map((e) => _logFromJson(e as Map<String, dynamic>))
          .whereType<LogEntry>()
          .toList(),
      projects: projectsJson
          .map((e) => _projectFromJson(e as Map<String, dynamic>))
          .whereType<Project>()
          .toList(),
      customActivities: activitiesJson
          .map((e) => _customActivityFromJson(e as Map<String, dynamic>))
          .whereType<CustomActivity>()
          .toList(),
    );
  }

  Future<void> restoreCustomIcons(CustomActivityIconStorage storage) async {
    for (final activity in customActivities) {
      final b64 = activity.backupIconBase64;
      if (b64 != null && b64.isNotEmpty) {
        await storage.restoreFromBase64(activity.id, b64);
        activity.customIconPath = storage.relativePathForId(activity.id);
      }
    }
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

  static Future<Map<String, dynamic>> _customActivityToJson(
    CustomActivity activity,
    CustomActivityIconStorage storage,
  ) async {
    final map = <String, dynamic>{
      'isarId': activity.id,
      'name': activity.name,
      'iconCodePoint': activity.iconCodePoint,
      'colorValue': activity.colorValue,
      'enabledFields': activity.enabledFields,
      'sortOrder': activity.sortOrder,
      'numberUseCounter': activity.numberUseCounter,
      'fieldLabelsJson': activity.fieldLabelsJson,
      if (activity.customIconPath != null)
        'customIconPath': activity.customIconPath,
    };
    if (activity.hasCustomIcon) {
      final b64 = await storage.readBase64(activity.customIconPath);
      if (b64 != null) map['customIconBase64'] = b64;
    }
    return map;
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

  static CustomActivity? _customActivityFromJson(Map<String, dynamic> data) {
    final id = _readInt(data['isarId']);
    final name = data['name'] as String?;
    final iconCodePoint = _readInt(data['iconCodePoint']);
    final colorValue = _readInt(data['colorValue']);
    final sortOrder = _readInt(data['sortOrder']);
    final fields = data['enabledFields'];

    if (id == null ||
        name == null ||
        iconCodePoint == null ||
        colorValue == null ||
        sortOrder == null ||
        fields is! List) {
      return null;
    }

    final activity = CustomActivity()
      ..id = id
      ..name = name
      ..iconCodePoint = iconCodePoint
      ..colorValue = colorValue
      ..enabledFields = fields.whereType<String>().toList()
      ..sortOrder = sortOrder
      ..numberUseCounter = data['numberUseCounter'] as bool? ?? false
      ..fieldLabelsJson = data['fieldLabelsJson'] as String? ?? '{}'
      ..customIconPath = data['customIconPath'] as String?;

    activity.backupIconBase64 = data['customIconBase64'] as String?;
    return activity;
  }

  static int? _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }
}
