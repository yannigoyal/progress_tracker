import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:isar/isar.dart';

import '../models/category.dart';
import '../models/log_entry.dart';
import 'seed_data.dart';

const _progressImportVersion = 3;

Future<void> seedInitialData(Isar isar) async {
  final count = await isar.logEntrys.count();
  final existingProgressCount = await isar.logEntrys
      .filter()
      .payloadJsonContains('"importVersion":$_progressImportVersion')
      .count();

  if (existingProgressCount > 0) return;

  final progressEntries = await _loadProgressEntries();
  if (progressEntries.isNotEmpty) {
    await isar.writeTxn(() async {
      if (count > 0) {
        await isar.logEntrys.clear();
      }
      await isar.logEntrys.putAll(progressEntries);
    });
    return;
  }

  if (count == 0) {
    await seedIfEmpty(isar);
  }
}

Future<List<LogEntry>> _loadProgressEntries() async {
  try {
    final raw = await rootBundle.loadString('PROGRESS.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return _parseProgressJson(decoded);
  } catch (_) {
    return const <LogEntry>[];
  }
}

List<LogEntry> _parseProgressJson(Map<String, dynamic> data) {
  final journal = data['journal'];
  if (journal is! Map<String, dynamic>) return const <LogEntry>[];

  final days = journal['days'];
  if (days is! List) return const <LogEntry>[];

  final entries = <LogEntry>[];
  for (final day in days) {
    if (day is! Map<String, dynamic>) continue;

    final dayNumber = (day['day_number'] as num?)?.toInt();
    final dateString = day['date'] as String?;
    final dayDate = dateString != null
        ? DateTime.tryParse(dateString)?.toLocal()
        : null;
    final rawEntries = day['entries'];

    if (dayNumber == null ||
        dayDate == null ||
        rawEntries is! Map<String, dynamic>) {
      continue;
    }

    final baseDate = DateTime(dayDate.year, dayDate.month, dayDate.day);
    entries.addAll(_buildDsaEntries(dayNumber, baseDate, rawEntries['dsa']));
    entries.addAll(
      _buildContentEntries(
        dayNumber,
        baseDate,
        rawEntries['long_video'],
        false,
      ),
    );
    entries.addAll(
      _buildContentEntries(
        dayNumber,
        baseDate,
        rawEntries['short_video'],
        true,
      ),
    );
    entries.addAll(
      _buildWorkoutEntries(dayNumber, baseDate, rawEntries['workout']),
    );
    entries.addAll(
      _buildReadingEntries(dayNumber, baseDate, rawEntries['reading']),
    );
    entries.addAll(_buildMiscEntries(dayNumber, baseDate, rawEntries['misc']));
  }

  return entries;
}

List<LogEntry> _buildDsaEntries(
  int dayNumber,
  DateTime baseDate,
  Object? rawList,
) {
  if (rawList is! List) return const <LogEntry>[];

  final entries = <LogEntry>[];
  for (var i = 0; i < rawList.length; i++) {
    final item = rawList[i];
    if (item is! Map<String, dynamic>) continue;

    final tasks = _stringList(item['tasks']);
    final notes = _optionalString(item['notes']);
    final github = _optionalString(item['github']);
    final detailLines = <String>[
      ...tasks,
      if (notes != null) notes,
      if (github != null) github,
    ];

    entries.add(
      LogEntry()
        ..category = Category.dsa
        ..createdAt = baseDate.add(Duration(hours: 9, minutes: i * 12)).toUtc()
        ..payload = {
          'problemNumber': (item['problem_number'] as num?)?.toInt(),
          'problemName':
              _optionalString(item['problem']) ?? 'Day $dayNumber DSA',
          'topic': 'Daily Progress',
          'approach': tasks.isNotEmpty ? tasks.join(', ') : 'Tracked',
          'status': 'Tracked',
          if (detailLines.isNotEmpty) 'note': detailLines.join('\n'),
          'kind': 'daily_progress',
          'importVersion': _progressImportVersion,
          'dayNumber': dayNumber,
        },
    );
  }
  return entries;
}

List<LogEntry> _buildContentEntries(
  int dayNumber,
  DateTime baseDate,
  Object? rawList,
  bool isShort,
) {
  if (rawList is! List) return const <LogEntry>[];

  final entries = <LogEntry>[];
  for (var i = 0; i < rawList.length; i++) {
    final item = rawList[i];
    if (item is! Map<String, dynamic>) continue;

    entries.add(
      LogEntry()
        ..category = Category.content
        ..createdAt = baseDate
            .add(Duration(hours: isShort ? 14 : 16, minutes: i * 10))
            .toUtc()
        ..payload = {
          'platform': isShort ? 'Shorts' : 'YouTube',
          'title':
              _optionalString(item['title']) ??
              'Day $dayNumber ${isShort ? 'Short' : 'Long'} Video',
          'status': _normaliseStatus(_optionalString(item['status'])),
          'kind': 'daily_progress',
          'importVersion': _progressImportVersion,
          'dayNumber': dayNumber,
          'videoType': isShort ? 'short_video' : 'long_video',
        },
    );
  }
  return entries;
}

List<LogEntry> _buildWorkoutEntries(
  int dayNumber,
  DateTime baseDate,
  Object? rawList,
) {
  if (rawList is! List) return const <LogEntry>[];

  final entries = <LogEntry>[];
  for (var i = 0; i < rawList.length; i++) {
    final item = rawList[i];
    if (item is! Map<String, dynamic>) continue;

    final sets = item['sets'];
    final durationSeconds = (item['duration_seconds'] as num?)?.toInt();
    entries.add(
      LogEntry()
        ..category = Category.workout
        ..createdAt = baseDate.add(Duration(hours: 7, minutes: i * 15)).toUtc()
        ..payload = {
          'exercise': _titleCase(
            _optionalString(item['exercise']) ?? 'Workout',
          ),
          if (item['reps'] != null) 'count': (item['reps'] as num).toInt(),
          if (durationSeconds case final value?) 'duration': value,
          'sets': sets is List ? sets.length : (sets as num?)?.toInt() ?? 1,
          if (sets is List) 'setBreakdown': sets,
          'kind': 'daily_progress',
          'importVersion': _progressImportVersion,
          'dayNumber': dayNumber,
        },
    );
  }
  return entries;
}

List<LogEntry> _buildReadingEntries(
  int dayNumber,
  DateTime baseDate,
  Object? rawList,
) {
  if (rawList is! List) return const <LogEntry>[];

  final entries = <LogEntry>[];
  for (var i = 0; i < rawList.length; i++) {
    final item = rawList[i];
    if (item is! Map<String, dynamic>) continue;

    final extraNote = _optionalString(item['note']);
    entries.add(
      LogEntry()
        ..category = Category.reading
        ..createdAt = baseDate.add(Duration(hours: 21, minutes: i * 10)).toUtc()
        ..payload = {
          'bookName': _optionalString(item['book']) ?? 'Reading',
          'pagesRead': (item['pages'] as num?)?.toInt(),
          if (extraNote case final value?) 'quote': value,
          'kind': 'daily_progress',
          'importVersion': _progressImportVersion,
          'dayNumber': dayNumber,
        },
    );
  }
  return entries;
}

List<LogEntry> _buildMiscEntries(
  int dayNumber,
  DateTime baseDate,
  Object? rawList,
) {
  if (rawList is! List) return const <LogEntry>[];

  final entries = <LogEntry>[];
  for (var i = 0; i < rawList.length; i++) {
    final item = rawList[i];
    if (item is! Map<String, dynamic>) continue;

    final note = _optionalString(item['note']);
    if (note == null || note.isEmpty) continue;

    entries.add(
      LogEntry()
        ..category = Category.misc
        ..createdAt = baseDate.add(Duration(hours: 22, minutes: i * 6)).toUtc()
        ..payload = {
          'title': 'Day $dayNumber Note',
          'note': note,
          'kind': 'daily_progress',
          'importVersion': _progressImportVersion,
          'dayNumber': dayNumber,
        },
    );
  }
  return entries;
}

List<String> _stringList(Object? raw) {
  if (raw is! List) return const <String>[];
  return raw
      .map((item) => item?.toString().trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList();
}

String? _optionalString(Object? value) {
  final string = value?.toString().trim();
  return string == null || string.isEmpty ? null : string;
}

String _normaliseStatus(String? raw) {
  if (raw == null) return 'Logged';
  final lower = raw.toLowerCase();
  if (lower.contains('uploaded')) return 'Uploaded';
  if (lower.contains('edited')) return 'Edited';
  if (lower.contains('made')) return 'Made';
  if (lower.contains('script')) return raw;
  return raw;
}

String _titleCase(String value) {
  return value
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
