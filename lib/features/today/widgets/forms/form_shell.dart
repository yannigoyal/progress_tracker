import 'package:flutter/material.dart';

import '../../../../core/models/category.dart';
import '../../../../util/string_constant.dart';

/// Shared wrapper for all log entry forms.
class FormShell extends StatelessWidget {
  final String title;
  final Category category;
  final VoidCallback onSave;
  final bool isSaving;
  final Widget child;

  const FormShell({
    super.key,
    required this.title,
    required this.category,
    required this.onSave,
    required this.child,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Handle
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Title row
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: category.surfaceColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(category.icon, color: category.color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: theme.textTheme.titleLarge),
            ],
          ),
        ),
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        // Scrollable form body
        Flexible(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: child,
          ),
        ),
        // Save button
        Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: ElevatedButton(
            onPressed: isSaving ? null : onSave,
            style: ElevatedButton.styleFrom(backgroundColor: category.color),
            child: isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(AppStrings.saveLog),
          ),
        ),
      ],
    );
  }
}
