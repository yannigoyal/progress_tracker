import 'dart:convert';

import 'package:isar/isar.dart';

import 'category.dart';

part 'log_entry.g.dart';

@collection
class LogEntry {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime createdAt;

  /// Stores Category.index so we avoid Isar enum-annotation edge cases.
  @Index()
  late int categoryIndex;

  late String payloadJson;

  @ignore
  Category get category => Category.values[categoryIndex];

  set category(Category c) => categoryIndex = c.index;

  @ignore
  Map<String, dynamic> get payload =>
      jsonDecode(payloadJson) as Map<String, dynamic>;

  set payload(Map<String, dynamic> p) => payloadJson = jsonEncode(p);

  // ── Derived display helpers ──────────────────────────────────────────────

  @ignore
  String get displayTitle {
    final p = payload;
    return switch (category) {
      Category.dsa => () {
        final num = p['problemNumber'];
        final name = p['problemName'] as String? ?? '';
        return num != null ? '#$num · $name' : name;
      }(),
      Category.content => p['title'] as String? ?? '',
      Category.workout => () {
        final ex = p['exercise'] as String? ?? '';
        final cnt = p['count'];
        final dur = p['duration'];
        if (cnt != null) return '$ex × $cnt';
        if (dur != null) return '$ex — ${dur}s';
        return ex;
      }(),
      Category.reading => () {
        final book = p['bookName'] as String? ?? '';
        final pages = p['pagesRead'];
        return pages != null ? '$book — $pages pages' : book;
      }(),
      Category.learning => (p['note'] as String? ?? '').split('\n').first,
      Category.misc => () {
        final title = (p['title'] as String?)?.trim();
        if (title != null && title.isNotEmpty) return title;
        return (p['note'] as String? ?? '').split('\n').first;
      }(),
    };
  }

  @ignore
  String get displaySubtitle {
    final p = payload;
    if ((p['kind'] as String?) == 'daily_progress') {
      final note = (p['note'] as String?)?.trim();
      final quote = (p['quote'] as String?)?.trim();
      final source = note?.isNotEmpty == true ? note! : (quote ?? '');
      if (source.isNotEmpty) {
        return source
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .join(' · ');
      }
    }

    return switch (category) {
      Category.dsa => () {
        final parts = <String>[
          if (p['topic'] != null) p['topic'] as String,
          if (p['approach'] != null) p['approach'] as String,
          if (p['status'] != null) p['status'] as String,
        ];
        return parts.join(' · ');
      }(),
      Category.content => () {
        final parts = <String>[
          if (p['platform'] != null) p['platform'] as String,
          if (p['status'] != null) p['status'] as String,
        ];
        return parts.join(' · ');
      }(),
      Category.workout => () {
        final sets = p['sets'];
        return sets != null ? '$sets sets' : '';
      }(),
      Category.reading => () {
        final quote = p['quote'] as String?;
        return quote != null ? '"$quote"' : '';
      }(),
      Category.learning => () {
        final tags = (p['tags'] as List?)?.cast<String>() ?? [];
        return tags.map((t) => '#$t').join(' ');
      }(),
      Category.misc => () {
        final note = (p['note'] as String? ?? '').trim();
        if (note.isEmpty) return '';
        final lines = note
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();
        if ((p['title'] as String?)?.trim().isNotEmpty ?? false) {
          return lines.join(' · ');
        }
        return lines.length <= 1 ? '' : lines.skip(1).join(' · ');
      }(),
    };
  }
}
