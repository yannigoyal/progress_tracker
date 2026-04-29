import 'package:flutter/material.dart';

import '../../util/colors.dart';
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
    Category.dsa => AppColors.categoryDsa,
    Category.content => AppColors.categoryContent,
    Category.workout => AppColors.categoryWorkout,
    Category.reading => AppColors.categoryReading,
    Category.learning => AppColors.categoryLearning,
    Category.misc => AppColors.categoryMisc,
    Category.project => AppColors.categoryProject,
  };

  Color get surfaceColor => switch (this) {
    Category.dsa => AppColors.categoryDsa.withAlpha(26),
    Category.content => AppColors.categoryContent.withAlpha(26),
    Category.workout => AppColors.categoryWorkout.withAlpha(26),
    Category.reading => AppColors.categoryReading.withAlpha(26),
    Category.learning => AppColors.categoryLearning.withAlpha(26),
    Category.misc => AppColors.categoryMisc.withAlpha(26),
    Category.project => AppColors.categoryProject.withAlpha(26),
  };
}
