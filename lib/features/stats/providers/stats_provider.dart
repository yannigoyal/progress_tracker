import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/models/category.dart';
import '../../../core/models/log_entry.dart';
import '../../../core/providers/isar_provider.dart';
import '../../../util/string_constant.dart';

class StatsData {
  final int currentStreak;
  final int longestStreak;
  final Map<DateTime, int> heatmapData;
  final Map<Category, int> categoryTotals;
  final List<int> weeklyLogCounts;

  const StatsData({
    required this.currentStreak,
    required this.longestStreak,
    required this.heatmapData,
    required this.categoryTotals,
    required this.weeklyLogCounts,
  });
}

class StatsNotifier extends AsyncNotifier<StatsData> {
  @override
  Future<StatsData> build() async {
    final isar = ref.watch(isarProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final allLogs = await isar.logEntrys
        .where()
        .createdAtBetween(
          DateTime.fromMillisecondsSinceEpoch(0),
          DateTime(2100),
        )
        .findAll();

    // Group by local date
    final Map<DateTime, List<LogEntry>> byDay = {};
    for (final log in allLogs) {
      final local = log.createdAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      (byDay[day] ??= []).add(log);
    }

    // Current streak
    int currentStreak = 0;
    DateTime check = today;
    while (byDay.containsKey(check)) {
      currentStreak++;
      check = check.subtract(const Duration(days: 1));
    }

    // Longest streak
    int longestStreak = currentStreak;
    int runStreak = 0;
    DateTime? prev;
    for (final day in (byDay.keys.toList()..sort())) {
      if (prev == null || day.difference(prev).inDays == 1) {
        runStreak++;
      } else {
        runStreak = 1;
      }
      if (runStreak > longestStreak) longestStreak = runStreak;
      prev = day;
    }

    // Heatmap: last 90 days
    final heatmapData = {
      for (var i = 89; i >= 0; i--)
        today.subtract(Duration(days: i)):
            byDay[today.subtract(Duration(days: i))]?.length ?? 0,
    };

    // Specialised category totals
    final totals = {for (final c in Category.values) c: 0};
    for (final log in allLogs) {
      final p = log.payload;
      switch (log.category) {
        case Category.dsa:
          if (p['status'] == AppStrings.solved) {
            totals[Category.dsa] = totals[Category.dsa]! + 1;
          }
        case Category.content:
          final statuses =
              (p['statuses'] as List?)?.whereType<String>().toList() ??
              [if (p['status'] != null) p['status'] as String];
          if (statuses.contains(AppStrings.contentStatusUploaded)) {
            totals[Category.content] = totals[Category.content]! + 1;
          }
        case Category.workout:
          totals[Category.workout] =
              totals[Category.workout]! +
              ((p['count'] ?? p['duration'] ?? 0) as int);
        case Category.reading:
          totals[Category.reading] =
              totals[Category.reading]! + ((p['pagesRead'] ?? 0) as int);
        case Category.learning:
          totals[Category.learning] = totals[Category.learning]! + 1;
        case Category.misc:
          totals[Category.misc] = totals[Category.misc]! + 1;
        case Category.project:
          totals[Category.project] = totals[Category.project]! + 1;
      }
    }

    // Weekly counts: last 7 days, oldest → newest
    final weeklyLogCounts = [
      for (var i = 6; i >= 0; i--)
        byDay[today.subtract(Duration(days: i))]?.length ?? 0,
    ];

    return StatsData(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      heatmapData: heatmapData,
      categoryTotals: totals,
      weeklyLogCounts: weeklyLogCounts,
    );
  }
}

final statsProvider = AsyncNotifierProvider<StatsNotifier, StatsData>(
  StatsNotifier.new,
);
