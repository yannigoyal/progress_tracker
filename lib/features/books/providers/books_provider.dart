import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/log_entry.dart';
import '../../../core/providers/isar_provider.dart';
import '../data/books_repository.dart';

final booksRepositoryProvider = Provider<BooksRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return BooksRepository(isar);
});

class BookGroup {
  final String bookName;
  final List<LogEntry> logs;

  const BookGroup({required this.bookName, required this.logs});
}

final booksProvider = FutureProvider.autoDispose<List<BookGroup>>((ref) async {
  final repository = ref.watch(booksRepositoryProvider);
  final logs = await repository.fetchReadingLogsWithTakeaways();

  final grouped = <String, List<LogEntry>>{};

  for (final log in logs) {
    final rawName = (log.payload['bookName'] as String? ?? '').trim();
    if (rawName.isEmpty) continue;
    final key = rawName.toLowerCase();
    (grouped[key] ??= []).add(log);
  }

  final groups = grouped.entries.map((entry) {
    final sorted = [...entry.value]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final displayName =
        (sorted.first.payload['bookName'] as String? ?? '').trim();
    return BookGroup(bookName: displayName, logs: sorted);
  }).toList()
    ..sort(
      (a, b) => a.bookName.toLowerCase().compareTo(b.bookName.toLowerCase()),
    );

  return groups;
});
