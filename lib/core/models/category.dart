import 'package:flutter/material.dart';

enum Category { dsa, content, workout, reading, learning, misc }

extension CategoryX on Category {
  String get label => switch (this) {
        Category.dsa => 'DSA / Coding',
        Category.content => 'Content',
        Category.workout => 'Workout',
        Category.reading => 'Reading',
        Category.learning => 'Learning',
        Category.misc => 'Misc',
      };

  String get emoji => switch (this) {
        Category.dsa => '💻',
        Category.content => '🎬',
        Category.workout => '💪',
        Category.reading => '📚',
        Category.learning => '🧠',
        Category.misc => '📝',
      };

  IconData get icon => switch (this) {
        Category.dsa => Icons.code,
        Category.content => Icons.videocam_outlined,
        Category.workout => Icons.fitness_center,
        Category.reading => Icons.menu_book_outlined,
        Category.learning => Icons.lightbulb_outline,
        Category.misc => Icons.notes,
      };

  Color get color => switch (this) {
        Category.dsa => const Color(0xFF6366F1),
        Category.content => const Color(0xFFEC4899),
        Category.workout => const Color(0xFF22C55E),
        Category.reading => const Color(0xFFF59E0B),
        Category.learning => const Color(0xFF14B8A6),
        Category.misc => const Color(0xFF6B7280),
      };

  Color get surfaceColor => switch (this) {
        Category.dsa => const Color(0xFF6366F1).withAlpha(26),
        Category.content => const Color(0xFFEC4899).withAlpha(26),
        Category.workout => const Color(0xFF22C55E).withAlpha(26),
        Category.reading => const Color(0xFFF59E0B).withAlpha(26),
        Category.learning => const Color(0xFF14B8A6).withAlpha(26),
        Category.misc => const Color(0xFF6B7280).withAlpha(26),
      };
}
