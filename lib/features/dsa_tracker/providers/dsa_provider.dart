import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/log_entry.dart';
import '../../../core/providers/isar_provider.dart';
import '../../../util/string_constant.dart';
import '../data/blind75_problems.dart';
import '../data/dsa_repository.dart';

final dsaRepositoryProvider = Provider<DsaRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return DsaRepository(isar);
});

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
  final repository = ref.watch(dsaRepositoryProvider);
  final dsaLogs = await repository.fetchDsaLogs();

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
    final isSolved = attempts.any(
      (l) => l.payload['status'] == AppStrings.solved,
    );
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

class DsaProgressNotifier extends AutoDisposeNotifier<void> {
  @override
  void build() {}

  Future<void> toggleProgress(DsaProblemStatus status) async {
    final repository = ref.read(dsaRepositoryProvider);

    if (status.isSolved && status.hasTrackerProgress) {
      final trackerAttemptIds = status.attempts
          .where((log) => log.payload['kind'] == 'tracker_progress')
          .map((log) => log.id);

      await repository.removeTrackerProgress(trackerAttemptIds);
    } else if (!status.isSolved) {
      await repository.addTrackerProgress(status.problem);
    }

    ref.invalidate(dsaTrackerProvider);
    ref.invalidate(dsaSolvedCountProvider);
  }
}

final dsaProgressNotifierProvider =
    NotifierProvider.autoDispose<DsaProgressNotifier, void>(
      DsaProgressNotifier.new,
    );
