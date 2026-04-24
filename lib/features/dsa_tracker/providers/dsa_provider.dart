import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/models/category.dart';
import '../../../core/models/log_entry.dart';
import '../../../core/providers/isar_provider.dart';
import '../data/blind75_problems.dart';

class DsaProblemStatus {
  final DsaProblem problem;
  final bool isSolved;
  final List<LogEntry> attempts;
  final bool hasTrackerProgress;

  const DsaProblemStatus({
    required this.problem,
    required this.isSolved,
    required this.attempts,
    required this.hasTrackerProgress,
  });
}

final dsaTrackerProvider = FutureProvider.autoDispose<List<DsaProblemStatus>>((
  ref,
) async {
  final isar = ref.watch(isarProvider);

  final dsaLogs = await isar.logEntrys
      .where()
      .categoryIndexEqualTo(Category.dsa.index)
      .findAll();

  // Group by lowercased problem name for fuzzy matching
  final Map<String, List<LogEntry>> byName = {};
  for (final log in dsaLogs) {
    final name = (log.payload['problemName'] as String? ?? '')
        .trim()
        .toLowerCase();
    if (name.isNotEmpty) (byName[name] ??= []).add(log);
  }

  return blind75Problems.map((prob) {
    final key = prob.name.toLowerCase();
    final attempts = byName[key] ?? [];
    final isSolved = attempts.any((l) => l.payload['status'] == 'Solved');
    final hasTrackerProgress = attempts.any(
      (l) => l.payload['kind'] == 'tracker_progress',
    );
    return DsaProblemStatus(
      problem: prob,
      isSolved: isSolved,
      attempts: attempts,
      hasTrackerProgress: hasTrackerProgress,
    );
  }).toList();
});

final dsaSolvedCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final statuses = await ref.watch(dsaTrackerProvider.future);
  return statuses.where((s) => s.isSolved).length;
});
