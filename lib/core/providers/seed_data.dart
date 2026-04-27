import 'dart:math';

import 'package:isar/isar.dart';

import '../models/category.dart';
import '../models/log_entry.dart';

Future<void> seedIfEmpty(Isar isar) async {
  final count = await isar.logEntrys.count();
  if (count > 0) return;

  final now = DateTime.now();
  final rng = Random(42);
  final entries = <LogEntry>[];

  const dsaProblems = [
    {'num': 1, 'name': 'Two Sum', 'topic': 'HashMap'},
    {'num': 15, 'name': '3Sum', 'topic': 'Two Pointers'},
    {
      'num': 121,
      'name': 'Best Time to Buy and Sell Stock',
      'topic': 'Sliding Window',
    },
    {'num': 217, 'name': 'Contains Duplicate', 'topic': 'HashMap'},
    {'num': 238, 'name': 'Product of Array Except Self', 'topic': 'Array'},
    {'num': 53, 'name': 'Maximum Subarray', 'topic': 'DP'},
    {'num': 152, 'name': 'Maximum Product Subarray', 'topic': 'DP'},
    {
      'num': 153,
      'name': 'Find Min in Rotated Sorted Array',
      'topic': 'Binary Search',
    },
    {
      'num': 33,
      'name': 'Search in Rotated Sorted Array',
      'topic': 'Binary Search',
    },
    {'num': 11, 'name': 'Container With Most Water', 'topic': 'Two Pointers'},
    {'num': 42, 'name': 'Trapping Rain Water', 'topic': 'Two Pointers'},
    {'num': 70, 'name': 'Climbing Stairs', 'topic': 'DP'},
    {'num': 198, 'name': 'House Robber', 'topic': 'DP'},
    {'num': 322, 'name': 'Coin Change', 'topic': 'DP'},
    {'num': 139, 'name': 'Word Break', 'topic': 'DP'},
    {'num': 200, 'name': 'Number of Islands', 'topic': 'Graph'},
    {'num': 133, 'name': 'Clone Graph', 'topic': 'Graph'},
    {'num': 207, 'name': 'Course Schedule', 'topic': 'Graph'},
    {'num': 226, 'name': 'Invert Binary Tree', 'topic': 'Trees'},
    {'num': 104, 'name': 'Maximum Depth of Binary Tree', 'topic': 'Trees'},
  ];

  const approaches = [
    'Brute Force',
    'Two Pointers',
    'BFS/DFS',
    'Memoization',
    'Tabulation',
    'Space-Opt',
    'Greedy',
    'Binary Search',
  ];
  const dsaStatuses = ['Solved', 'Revised'];
  const books = [
    'Atomic Habits',
    'Deep Work',
    'The Pragmatic Programmer',
    'Clean Code',
    'System Design Interview',
  ];
  const videoTitles = [
    'Flutter State Management with Riverpod',
    'Building a CRUD App in Flutter',
    'Isar Database Deep Dive',
    'Go Router + Bottom Nav Tutorial',
    'Dart Isolates Explained',
  ];
  const contentStatuses = ['Recorded', 'Edited', 'Uploaded'];
  const exercises = [
    'Pushups',
    'Plank',
    'Squats',
    'Pull-ups',
    'Dips',
    'Lunges',
  ];
  const learningNotes = [
    'Studied Riverpod AsyncNotifier — cleaner than FutureProvider for mutable async state',
    'Explored Dart isolates for offloading CPU-heavy tasks off the main thread',
    'Practiced Dijkstra on paper — key insight: lazy deletion in priority queue',
    'Read about segment trees for range queries. Prefer Fenwick for pure prefix sums.',
    'Isar has a composite index feature — useful for (category, date) lookups',
    'go_router StatefulShellRoute makes nested nav with state retention trivial',
    'Tried Gemini API with streaming — latency is great, need to handle chunk re-assembly',
  ];
  const tagOptions = [
    'Flutter',
    'Dart',
    'DSA',
    'AI',
    'Web3',
    'Backend',
    'System Design',
  ];

  for (var dayOffset = 24; dayOffset >= 1; dayOffset--) {
    final date = DateTime(now.year, now.month, now.day - dayOffset);

    // DSA: 1–3 problems every day
    final dsaCount = 1 + rng.nextInt(3);
    final usedProblems = <int>{};
    for (var i = 0; i < dsaCount; i++) {
      int idx;
      do {
        idx = rng.nextInt(dsaProblems.length);
      } while (usedProblems.contains(idx));
      usedProblems.add(idx);
      final prob = dsaProblems[idx];
      entries.add(
        LogEntry()
          ..category = Category.dsa
          ..createdAt = date
              .add(Duration(hours: 9 + i, minutes: rng.nextInt(50)))
              .toUtc()
          ..payload = {
            'problemNumber': prob['num'],
            'problemName': prob['name'],
            'topic': prob['topic'],
            'approach': approaches[rng.nextInt(approaches.length)],
            'status': dsaStatuses[rng.nextInt(2)],
          },
      );
    }

    // Workout: every other day
    if (dayOffset % 2 == 0) {
      final ex = exercises[rng.nextInt(exercises.length)];
      final isPlank = ex == 'Plank';
      entries.add(
        LogEntry()
          ..category = Category.workout
          ..createdAt = date.add(const Duration(hours: 7, minutes: 30)).toUtc()
          ..payload = {
            'exercise': ex,
            if (isPlank)
              'duration': 30 + rng.nextInt(60)
            else
              'count': 20 + rng.nextInt(30),
            'sets': 2 + rng.nextInt(3),
          },
      );
    }

    // Reading: every 3rd day
    if (dayOffset % 3 == 0) {
      entries.add(
        LogEntry()
          ..category = Category.reading
          ..createdAt = date.add(const Duration(hours: 22)).toUtc()
          ..payload = {
            'bookName': books[rng.nextInt(books.length)],
            'pagesRead': 10 + rng.nextInt(30),
          },
      );
    }

    // Content: every 5th day
    if (dayOffset % 5 == 0) {
      entries.add(
        LogEntry()
          ..category = Category.content
          ..createdAt = date.add(const Duration(hours: 14)).toUtc()
          ..payload = {
            'platform': rng.nextBool() ? 'YouTube' : 'Shorts',
            'title': videoTitles[rng.nextInt(videoTitles.length)],
            'status': contentStatuses[rng.nextInt(contentStatuses.length)],
          },
      );
    }

    // Learning: ~50% chance
    if (rng.nextBool()) {
      final tags = <String>{};
      while (tags.length < 2)
        tags.add(tagOptions[rng.nextInt(tagOptions.length)]);
      entries.add(
        LogEntry()
          ..category = Category.learning
          ..createdAt = date.add(Duration(hours: 11 + rng.nextInt(4))).toUtc()
          ..payload = {
            'note': learningNotes[rng.nextInt(learningNotes.length)],
            'tags': tags.toList(),
          },
      );
    }
  }

  await isar.writeTxn(() => isar.logEntrys.putAll(entries));
}
