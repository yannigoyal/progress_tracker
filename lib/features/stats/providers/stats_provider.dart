import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/category.dart';
import '../../../core/models/log_entry.dart';
import '../../../core/providers/isar_provider.dart';
import '../../../util/string_constant.dart';
import '../data/stats_repository.dart';

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return StatsRepository(isar);
});

class CategoryStats {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastLogged;

  const CategoryStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastLogged,
  });
}

class StatsData {
  final int currentStreak;
  final int longestStreak;
  final Map<DateTime, int> heatmapData;
  final Map<Category, int> categoryTotals;
  final Map<Category, int> categoryLogCounts;
  final List<int> last30DaysData;
  final List<WorkoutPR> topWorkoutPRs;
  final Map<Category, CategoryStats> categoryStats;

  const StatsData({
    required this.currentStreak,
    required this.longestStreak,
    required this.heatmapData,
    required this.categoryTotals,
    required this.categoryLogCounts,
    required this.last30DaysData,
    required this.topWorkoutPRs,
    required this.categoryStats,
  });
}

class WorkoutPR {
  final String exercise;
  final int value;
  final bool isDuration; // true => seconds, false => reps

  const WorkoutPR({
    required this.exercise,
    required this.value,
    required this.isDuration,
  });
}

class StatsNotifier extends AsyncNotifier<StatsData> {
  @override
  Future<StatsData> build() async {
    final repository = ref.watch(statsRepositoryProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final allLogs = await repository.fetchAllLogs();

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

    // Heatmap: last 365 days
    final heatmapData = {
      for (var i = 364; i >= 0; i--)
        today.subtract(Duration(days: i)):
            byDay[today.subtract(Duration(days: i))]?.length ?? 0,
    };

    // Specialised category totals
    final totals = {for (final c in Category.values) c: 0};
    final logCounts = {for (final c in Category.values) c: 0};
    for (final log in allLogs) {
      logCounts[log.category] = logCounts[log.category]! + 1;
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

    // Last 30 days, oldest → newest
    final last30DaysData = [
      for (var i = 29; i >= 0; i--)
        byDay[today.subtract(Duration(days: i))]?.length ?? 0,
    ];

    // Top-3 workout PRs: for each exercise, take the max of count or duration
    final Map<String, int> maxPerExercise = {};
    final Map<String, bool> isDurationMap = {};
    for (final log in allLogs.where((l) => l.category == Category.workout)) {
      final p = log.payload;
      final ex = (p['exercise'] as String?) ?? '';
      final val = ((p['count'] ?? p['duration']) as int?) ?? 0;
      final isDur = p['duration'] != null;
      if (ex.isEmpty) continue;
      final prev = maxPerExercise[ex] ?? 0;
      if (val > prev) {
        maxPerExercise[ex] = val;
        isDurationMap[ex] = isDur;
      }
    }
    final topWorkoutPRs =
        (maxPerExercise.entries
                .map(
                  (e) => WorkoutPR(
                    exercise: e.key,
                    value: e.value,
                    isDuration: isDurationMap[e.key] ?? false,
                  ),
                )
                .toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .take(3)
            .toList();
    // Per-category streaks and last-logged
    final Map<Category, Set<DateTime>> daysPerCategory = {
      for (final c in Category.values) c: <DateTime>{},
    };
    final Map<Category, DateTime?> lastLoggedMap = {
      for (final c in Category.values) c: null,
    };
    for (final log in allLogs) {
      final local = log.createdAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      daysPerCategory[log.category]?.add(day);
      final prev = lastLoggedMap[log.category];
      if (prev == null || log.createdAt.isAfter(prev)) {
        lastLoggedMap[log.category] = log.createdAt;
      }
    }

    final Map<Category, CategoryStats> categoryStats = {};
    for (final c in Category.values) {
      final days = (daysPerCategory[c] ?? {}).toList()..sort();

      // current streak for this category
      int cur = 0;
      DateTime check = today;
      while ((daysPerCategory[c] ?? {}).contains(check)) {
        cur++;
        check = check.subtract(const Duration(days: 1));
      }

      // longest streak
      int longest = cur;
      int run = 0;
      DateTime? prevDay;
      for (final day in days) {
        if (prevDay == null || day.difference(prevDay).inDays == 1) {
          run++;
        } else {
          run = 1;
        }
        if (run > longest) longest = run;
        prevDay = day;
      }

      categoryStats[c] = CategoryStats(
        currentStreak: cur,
        longestStreak: longest,
        lastLogged: lastLoggedMap[c],
      );
    }

    return StatsData(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      heatmapData: heatmapData,
      categoryTotals: totals,
      categoryLogCounts: logCounts,
      last30DaysData: last30DaysData,
      topWorkoutPRs: topWorkoutPRs,
      categoryStats: categoryStats,
    );
  }
}

final statsProvider = AsyncNotifierProvider<StatsNotifier, StatsData>(
  StatsNotifier.new,
);
