import 'package:flutter/material.dart';

import '../../util/string_constant.dart';

enum Category { dsa, content, workout, reading, learning, misc, project }

extension CategoryX on Category {
  String get label => switch (this) {
    Category.dsa => AppStrings.dsaFormTitle,
    Category.content => AppStrings.contentLabel,
    Category.workout => AppStrings.workoutFormTitle,
    Category.reading => AppStrings.readingFormTitle,
    Category.learning => AppStrings.learningFormTitle,
    Category.misc => AppStrings.miscLabel,
    Category.project => AppStrings.projectFormTitle,
  };

  String get emoji => switch (this) {
    Category.dsa => '💻',
    Category.content => '🎬',
    Category.workout => '💪',
    Category.reading => '📚',
    Category.learning => '🧠',
    Category.misc => '📝',
    Category.project => '📁',
  };

  IconData get icon => switch (this) {
    Category.dsa => Icons.code,
    Category.content => Icons.videocam_outlined,
    Category.workout => Icons.fitness_center,
    Category.reading => Icons.menu_book_outlined,
    Category.learning => Icons.lightbulb_outline,
    Category.misc => Icons.notes,
    Category.project => Icons.folder_outlined,
  };

  Color get color => switch (this) {
    Category.dsa => const Color(0xFF6366F1),
    Category.content => const Color(0xFFEC4899),
    Category.workout => const Color(0xFF22C55E),
    Category.reading => const Color(0xFFF59E0B),
    Category.learning => const Color(0xFF14B8A6),
    Category.misc => const Color(0xFF6B7280),
    Category.project => const Color(0xFF8B5CF6),
  };

  Color get surfaceColor => switch (this) {
    Category.dsa => const Color(0xFF6366F1).withAlpha(26),
    Category.content => const Color(0xFFEC4899).withAlpha(26),
    Category.workout => const Color(0xFF22C55E).withAlpha(26),
    Category.reading => const Color(0xFFF59E0B).withAlpha(26),
    Category.learning => const Color(0xFF14B8A6).withAlpha(26),
    Category.misc => const Color(0xFF6B7280).withAlpha(26),
    Category.project => const Color(0xFF8B5CF6).withAlpha(26),
  };
}
