import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/models/category.dart';
import '../../../core/models/log_entry.dart';
import '../../../core/providers/isar_provider.dart';
import '../data/blind75_problems.dart';

/// Suggestions for problem names:
/// - Blind 75 names (static)
/// - Distinct problem names from previously saved DSA logs (dynamic)
final dsaNameSuggestionsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final isar = ref.watch(isarProvider);

  final logs = await isar.logEntrys
      .where()
      .categoryIndexEqualTo(Category.dsa.index)
      .sortByCreatedAtDesc()
      .findAll();

  final seen = <String>{};
  final out = <String>[];

  void addName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final key = trimmed.toLowerCase();
    if (seen.add(key)) out.add(trimmed);
  }

  // Prefer recent user-entered names first.
  for (final log in logs) {
    final name = (log.payload['problemName'] as String? ?? '');
    addName(name);
    if (out.length >= 200) break;
  }

  // Then include Blind 75 names not already present.
  for (final p in blind75Problems) {
    addName(p.name);
    if (out.length >= 400) break;
  }

  return out;
});

