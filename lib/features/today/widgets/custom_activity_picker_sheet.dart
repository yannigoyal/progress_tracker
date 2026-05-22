import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/custom_activity.dart';
import '../../../core/theme/color_utils.dart';
import '../../../util/string_constant.dart';
import '../../settings/custom_activity_editor_screen.dart';
import '../../settings/providers/custom_activity_provider.dart';
import 'activity_icon.dart';

class CustomActivityPickerSheet extends ConsumerWidget {
  final void Function(CustomActivity activity) onSelected;

  const CustomActivityPickerSheet({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(customActivitiesProvider);
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
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.customPickerTitle,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          activitiesAsync.when(
            data: (activities) {
              if (activities.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      const Text(AppStrings.customActivitiesEmptyTitle),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.customActivitiesEmptySubtitle,
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => _openEditor(context),
                        icon: const Icon(Icons.add),
                        label: const Text(AppStrings.addCustomActivity),
                      ),
                    ],
                  ),
                );
              }

              final tiles = <Widget>[
                ...activities.map((activity) => _ActivityTile(
                      activity: activity,
                      onTap: () => onSelected(activity),
                    )),
                _AddActivityTile(onTap: () => _openEditor(context)),
              ];

              return GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                physics: const NeverScrollableScrollPhysics(),
                children: tiles,
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
            error: (e, _) => Text(AppStrings.genericScreenError(e)),
          ),
        ],
      ),
    );
  }

  void _openEditor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CustomActivityEditorScreen()),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final CustomActivity activity;
  final VoidCallback onTap;

  const _ActivityTile({required this.activity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: activity.color.withAlpha(26),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: activity.color.withAlpha(60)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ActivityIcon(activity: activity, size: 28),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                activity.name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: activity.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddActivityTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddActivityTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ThemePalette.primary.withAlpha(80),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: ThemePalette.primary, size: 32),
            const SizedBox(height: 6),
            Text(
              AppStrings.addActivityTile,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ThemePalette.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
