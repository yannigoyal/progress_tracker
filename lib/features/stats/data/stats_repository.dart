import 'package:isar/isar.dart';

import '../../../core/models/log_entry.dart';

class StatsRepository {
  final Isar _isar;

  const StatsRepository(this._isar);

  Future<List<LogEntry>> fetchAllLogs() {
    return _isar.logEntrys
        .where()
        .createdAtBetween(
          DateTime.fromMillisecondsSinceEpoch(0),
          DateTime(2100),
        )
        .findAll();
  }
}
