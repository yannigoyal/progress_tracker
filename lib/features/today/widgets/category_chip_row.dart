import 'package:flutter/material.dart';

import '../../../core/models/category.dart';
import '../../../core/models/log_entry.dart';

class CategoryChipRow extends StatelessWidget {
  final List<LogEntry> logs;

  const CategoryChipRow({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final counts = <Category, int>{};
    for (final l in logs) {
      counts[l.category] = (counts[l.category] ?? 0) + 1;
    }

    final active =
        Category.values.where((c) => counts.containsKey(c)).toList();

    if (active.isEmpty) return const SizedBox(height: 8);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: active.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = active[i];
          final count = counts[cat]!;
          return _CategoryChip(category: cat, count: count);
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final Category category;
  final int count;

  const _CategoryChip({required this.category, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: category.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: category.color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(
            '${category.label} $count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: category.color,
            ),
          ),
        ],
      ),
    );
  }
}
