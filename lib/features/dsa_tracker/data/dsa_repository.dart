import 'package:isar/isar.dart';

import '../../../core/models/category.dart';
import '../../../core/models/log_entry.dart';
import '../../../util/string_constant.dart';
import 'blind75_problems.dart';

class DsaRepository {
  final Isar _isar;

  const DsaRepository(this._isar);

  Future<List<LogEntry>> fetchDsaLogs() {
    return _isar.logEntrys
        .where()
        .categoryIndexEqualTo(Category.dsa.index)
        .findAll();
  }

  Future<void> removeTrackerProgress(Iterable<int> logIds) async {
    final ids = logIds.toList();
    if (ids.isEmpty) return;

    await _isar.writeTxn(() async {
      for (final id in ids) {
        await _isar.logEntrys.delete(id);
      }
    });
  }

  Future<void> addTrackerProgress(DsaProblem problem) async {
    final entry = LogEntry()
      ..category = Category.dsa
      ..createdAt = DateTime.now().toUtc()
      ..payload = {
        'problemNumber': problem.id,
        'problemName': problem.name,
        'topic': problem.topic,
        'approach': AppStrings.trackerMarked,
        'status': AppStrings.solved,
        'kind': 'tracker_progress',
      };

    await _isar.writeTxn(() => _isar.logEntrys.put(entry));
  }
}
