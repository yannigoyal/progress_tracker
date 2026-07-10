import 'package:isar/isar.dart';

import '../../../core/models/category.dart';
import '../../../core/models/log_entry.dart';

class BooksRepository {
  final Isar _isar;

  const BooksRepository(this._isar);

  Future<List<LogEntry>> fetchReadingLogsWithTakeaways() async {
    final logs = await _isar.logEntrys
        .where()
        .categoryIndexEqualTo(Category.reading.index)
        .sortByCreatedAtDesc()
        .findAll();

    return logs.where((log) {
      final quote = (log.payload['quote'] as String?)?.trim();
      return quote != null && quote.isNotEmpty;
    }).toList();
  }
}
