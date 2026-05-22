import 'package:flutter/material.dart';

import '../theme/color_utils.dart';
import '../../util/string_constant.dart';

enum Category { dsa, content, workout, reading, learning, misc, project, custom }

extension CategoryX on Category {
  String get label => switch (this) {
    Category.dsa => AppStrings.dsaFormTitle,
    Category.content => AppStrings.contentLabel,
    Category.workout => AppStrings.workoutFormTitle,
    Category.reading => AppStrings.readingFormTitle,
    Category.learning => AppStrings.learningFormTitle,
    Category.misc => AppStrings.miscLabel,
    Category.project => AppStrings.projectFormTitle,
    Category.custom => AppStrings.customLabel,
  };

  String get emoji => switch (this) {
    Category.dsa => '💻',
    Category.content => '🎬',
    Category.workout => '💪',
    Category.reading => '📚',
    Category.learning => '🧠',
    Category.misc => '📝',
    Category.project => '📁',
    Category.custom => '✨',
  };

  IconData get icon => switch (this) {
    Category.dsa => Icons.code,
    Category.content => Icons.videocam_outlined,
    Category.workout => Icons.fitness_center,
    Category.reading => Icons.menu_book_outlined,
    Category.learning => Icons.lightbulb_outline,
    Category.misc => Icons.notes,
    Category.project => Icons.folder_outlined,
    Category.custom => Icons.tune_rounded,
  };

  Color color(BuildContext context) => switch (this) {
    Category.dsa => context.categoryDsa,
    Category.content => context.categoryContent,
    Category.workout => context.categoryWorkout,
    Category.reading => context.categoryReading,
    Category.learning => context.categoryLearning,
    Category.misc => context.categoryMisc,
    Category.project => context.categoryProject,
    Category.custom => context.categoryCustom,
  };

  Color surfaceColor(BuildContext context) => color(context).withAlpha(26);
}
