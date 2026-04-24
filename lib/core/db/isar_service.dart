import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/log_entry.dart';

class IsarService {
  IsarService._();

  static Isar? _instance;

  static Future<Isar> open() async {
    if (_instance != null && _instance!.isOpen) return _instance!;
    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      [LogEntrySchema],
      directory: dir.path,
      name: 'daily_log',
    );
    return _instance!;
  }
}
