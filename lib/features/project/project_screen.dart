import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/project.dart';
import '../../util/colors.dart';
import '../../util/string_constant.dart';
import '../dsa_tracker/providers/dsa_provider.dart';
import '../history/providers/history_provider.dart';
import '../stats/providers/stats_provider.dart';
import '../today/providers/today_provider.dart';
import 'providers/project_provider.dart';
import 'widgets/project_session_form.dart';

class ProjectScreen extends ConsumerWidget {
  const ProjectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.projectScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddProjectDialog(context, ref),
          ),
        ],
      ),
      body: projectsAsync.when(
        data: (projects) => projects.isEmpty
            ? _EmptyState(onAdd: () => _showAddProjectDialog(context, ref))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: projects.length,
                itemBuilder: (_, i) => _ProjectCard(
                  project: projects[i],
                  onTap: () => _openSessionForm(context, ref, projects[i]),
                  onStatusTap: () => _cycleStatus(ref, projects[i]),
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(AppStrings.errorWithDetails(e))),
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.projectDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: AppStrings.projectName,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: AppStrings.description,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                ref
                    .read(projectNotifierProvider.notifier)
                    .addProject(nameCtrl.text.trim(), descCtrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text(AppStrings.create),
          ),
        ],
      ),
    );
  }

  void _openSessionForm(BuildContext context, WidgetRef ref, Project project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (sheetCtx) => ProjectSessionForm(
        project: project,
        onSave: (whatDone, whatLearnt) async {
          await ref
              .read(projectNotifierProvider.notifier)
              .addSession(project, whatDone, whatLearnt);
          _refreshLogDependents(ref);
          if (!sheetCtx.mounted || !context.mounted) return;
          Navigator.pop(sheetCtx);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.sessionLogged)),
          );
        },
      ),
    );
  }

  void _cycleStatus(WidgetRef ref, Project project) {
    final next = switch (project.status) {
      ProjectStatus.active => ProjectStatus.paused,
      ProjectStatus.paused => ProjectStatus.completed,
      ProjectStatus.completed => ProjectStatus.active,
    };
    ref.read(projectNotifierProvider.notifier).updateStatus(project.id, next);
  }

  void _refreshLogDependents(WidgetRef ref) {
    ref.invalidate(todayLogsProvider);
    ref.invalidate(dayNumberProvider);
    ref.invalidate(historyProvider);
    ref.invalidate(statsProvider);
    ref.invalidate(dsaTrackerProvider);
    ref.invalidate(dsaSolvedCountProvider);
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            AppStrings.projectEmptyEmoji,
            style: TextStyle(fontSize: 72),
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.projectEmptyTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.projectEmptySubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text(AppStrings.newProject),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onStatusTap;

  const _ProjectCard({
    required this.project,
    required this.onTap,
    required this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = switch (project.status) {
      ProjectStatus.active => AppColors.success,
      ProjectStatus.paused => AppColors.warning,
      ProjectStatus.completed => AppColors.primary,
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onStatusTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor, width: 1),
                      ),
                      child: Text(
                        project.status.name.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (project.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  project.description,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                AppStrings.createdOn(_formatDate(project.createdAt)),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d).inDays;
    if (diff == 0) return AppStrings.today;
    if (diff == 1) return AppStrings.yesterday;
    if (diff < 7) return AppStrings.daysAgo(diff);
    return '${d.day}/${d.month}/${d.year}';
  }
}
