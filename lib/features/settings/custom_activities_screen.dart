import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/custom_activity.dart';
import '../../core/models/log_field_kind.dart';
import '../today/widgets/activity_icon.dart';
import '../../util/string_constant.dart';
import 'custom_activity_editor_screen.dart';
import 'providers/custom_activity_provider.dart';

class CustomActivitiesScreen extends ConsumerWidget {
  const CustomActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(customActivitiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.customActivitiesTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CustomActivityEditorScreen(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      body: activitiesAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.customActivitiesEmptyTitle,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Text(
                      AppStrings.customActivitiesEmptySubtitle,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: activities.length,
            onReorder: (oldIndex, newIndex) async {
              if (newIndex > oldIndex) newIndex--;
              final list = List<CustomActivity>.from(activities);
              final item = list.removeAt(oldIndex);
              list.insert(newIndex, item);
              await ref
                  .read(customActivityRepositoryProvider)
                  .updateSortOrders(list.map((a) => a.id).toList());
            },
            itemBuilder: (context, index) {
              final activity = activities[index];
              return _ActivityRow(
                key: ValueKey(activity.id),
                activity: activity,
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CustomActivityEditorScreen(existing: activity),
                  ),
                ),
                onDelete: () => _confirmDelete(context, ref, activity),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(AppStrings.genericScreenError(e))),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CustomActivity activity,
  ) async {
    final repo = ref.read(customActivityRepositoryProvider);
    final logCount = await repo.countLogsForActivity(activity.id);
    final message = logCount > 0
        ? '${AppStrings.deleteCustomActivityMessage}\n\n$logCount log(s) use this activity.'
        : AppStrings.deleteCustomActivityMessage;

    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteCustomActivityTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await repo.delete(activity.id);
  }
}

class _ActivityRow extends StatelessWidget {
  final CustomActivity activity;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActivityRow({
    required super.key,
    required this.activity,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: SizedBox(
          width: 40,
          height: 40,
          child: Center(child: ActivityIcon(activity: activity, size: 28)),
        ),
        title: Text(activity.name),
        subtitle: Text(
          activity.enabledFields.map(LogFieldKind.label).join(', '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: onDelete,
            ),
            const Icon(Icons.drag_handle),
          ],
        ),
      ),
    );
  }
}
