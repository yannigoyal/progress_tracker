import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/category.dart';
import '../../../core/models/log_entry.dart';
import '../../../core/providers/isar_provider.dart';
import '../../../util/string_constant.dart';
import '../data/history_repository.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return HistoryRepository(isar);
});

// ── Filter state ──────────────────────────────────────────────────────────────

final historySearchProvider = StateProvider<String>((ref) => '');
final historyCategoryFilterProvider = StateProvider<Category?>((ref) => null);

// ── Grouped day model ─────────────────────────────────────────────────────────

class DayLogs {
  final DateTime date;
  final List<LogEntry> logs;

  DayLogs({required this.date, required this.logs});

  List<LogEntry> get actualLogs =>
      logs.where((log) => !_isPlaceholder(log)).toList();

  int get actualCount => actualLogs.length;

  String get summary {
    final parts = <String>[];
    final byCat = <Category, List<LogEntry>>{};
    for (final l in actualLogs) {
      (byCat[l.category] ??= []).add(l);
    }

    if (byCat[Category.dsa] case final dsa? when dsa.isNotEmpty) {
      parts.add(AppStrings.historyDsaSummary(dsa.length));
    }
    if (byCat[Category.content] case final c? when c.isNotEmpty) {
      parts.add(AppStrings.historyVideoSummary(c.length));
    }
    if (byCat[Category.workout] case final w? when w.isNotEmpty) {
      final reps = w.fold(0, (s, l) => s + ((l.payload['count'] ?? 0) as int));
      parts.add(
        reps > 0
            ? AppStrings.historyRepsSummary(reps)
            : AppStrings.historyWorkoutSummary(w.length),
      );
    }
    if (byCat[Category.reading] case final r? when r.isNotEmpty) {
      final pages = r.fold(
        0,
        (s, l) => s + ((l.payload['pagesRead'] ?? 0) as int),
      );
      parts.add(AppStrings.historyPagesSummary(pages));
    }
    final noteCount =
        (byCat[Category.learning]?.length ?? 0) +
        (byCat[Category.misc]?.length ?? 0);
    if (noteCount > 0) {
      parts.add(AppStrings.historyNotesSummary(noteCount));
    }
    if (byCat[Category.project] case final p? when p.isNotEmpty) {
      parts.add(AppStrings.historyProjectSummary(p.length));
    }
    return parts.isEmpty ? AppStrings.historyNoTrackedWork : parts.join(' · ');
  }

  bool _isPlaceholder(LogEntry log) {
    final payload = log.payload;
    if (payload['placeholder'] == true) return true;

    final note = (payload['note'] as String?)?.trim().toLowerCase();
    return note != null &&
        note.startsWith(AppStrings.noPrefix) &&
        note.endsWith(AppStrings.activityLoggedSuffix);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final historyProvider = FutureProvider.autoDispose<List<DayLogs>>((ref) async {
  final repository = ref.watch(historyRepositoryProvider);
  final query = ref.watch(historySearchProvider);
  final categoryFilter = ref.watch(historyCategoryFilterProvider);

  List<LogEntry> all = await repository.fetchLogs(
    categoryFilter: categoryFilter,
  );

  // Search filter
  if (query.isNotEmpty) {
    final q = query.toLowerCase();
    all = all.where((l) {
      return l.displayTitle.toLowerCase().contains(q) ||
          l.displaySubtitle.toLowerCase().contains(q) ||
          l.payloadJson.toLowerCase().contains(q);
    }).toList();
  }

  // Group by local date
  final Map<DateTime, List<LogEntry>> byDay = {};
  for (final l in all) {
    final local = l.createdAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    (byDay[day] ??= []).add(l);
  }

  final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
  return days.map((d) => DayLogs(date: d, logs: byDay[d]!)).toList();
});

class HistoryLogNotifier extends AutoDisposeNotifier<void> {
  @override
  void build() {}

  Future<void> deleteLog(int id) async {
    final repository = ref.read(historyRepositoryProvider);
    await repository.deleteLog(id);
  }
}

final historyLogNotifierProvider =
    NotifierProvider.autoDispose<HistoryLogNotifier, void>(
      HistoryLogNotifier.new,
    );
