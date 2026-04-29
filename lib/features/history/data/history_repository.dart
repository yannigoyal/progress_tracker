import 'package:isar/isar.dart';

import '../../../core/models/category.dart';
import '../../../core/models/log_entry.dart';

class HistoryRepository {
  final Isar _isar;

  const HistoryRepository(this._isar);

  Future<List<LogEntry>> fetchLogs({Category? categoryFilter}) {
    if (categoryFilter != null) {
      return _isar.logEntrys
          .where()
          .categoryIndexEqualTo(categoryFilter.index)
          .sortByCreatedAtDesc()
          .findAll();
    }

    return _isar.logEntrys
        .where()
        .createdAtBetween(
          DateTime.fromMillisecondsSinceEpoch(0),
          DateTime(2100),
        )
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<void> deleteLog(int id) async {
    await _isar.writeTxn(() => _isar.logEntrys.delete(id));
  }
}
