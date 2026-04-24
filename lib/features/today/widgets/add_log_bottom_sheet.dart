import 'package:flutter/material.dart';

import '../../../core/models/category.dart';
import '../../../core/models/log_entry.dart';
import '../../../util/string_constant.dart';
import 'forms/content_form.dart';
import 'forms/dsa_form.dart';
import 'forms/learning_form.dart';
import 'forms/misc_form.dart';
import 'forms/project_form.dart';
import 'forms/reading_form.dart';
import 'forms/workout_form.dart';

// ── Category picker sheet ─────────────────────────────────────────────────────

class AddLogBottomSheet extends StatelessWidget {
  final void Function(Category) onCategorySelected;

  const AddLogBottomSheet({super.key, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(AppStrings.addLogSheetTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
            physics: const NeverScrollableScrollPhysics(),
            children: Category.values
                .map(
                  (cat) => _CategoryTile(
                    category: cat,
                    onTap: () => onCategorySelected(cat),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const _CategoryTile({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: category.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: category.color.withAlpha(60), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              category.label,
              style: TextStyle(
                fontSize: 11,
                color: category.color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Form dispatcher sheet ─────────────────────────────────────────────────────

class LogFormSheet extends StatelessWidget {
  final Category category;
  final void Function(LogEntry) onSave;
  final LogEntry? existingLog;

  const LogFormSheet({
    super.key,
    required this.category,
    required this.onSave,
    this.existingLog,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: switch (category) {
        Category.dsa => DsaForm(onSave: onSave, existingLog: existingLog),
        Category.content => ContentForm(
          onSave: onSave,
          existingLog: existingLog,
        ),
        Category.workout => WorkoutForm(
          onSave: onSave,
          existingLog: existingLog,
        ),
        Category.reading => ReadingForm(
          onSave: onSave,
          existingLog: existingLog,
        ),
        Category.learning => LearningForm(
          onSave: onSave,
          existingLog: existingLog,
        ),
        Category.misc => MiscForm(onSave: onSave, existingLog: existingLog),
        Category.project => ProjectForm(
          onSave: onSave,
          existingLog: existingLog,
        ),
      },
    );
  }
}
