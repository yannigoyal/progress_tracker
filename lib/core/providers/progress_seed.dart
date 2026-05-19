import 'package:isar/isar.dart';

import '../models/log_entry.dart';
import 'seed_data.dart';

Future<void> seedInitialData(Isar isar) async {
  final count = await isar.logEntrys.count();
  if (count == 0) {
    await seedIfEmpty(isar);
  }
}
