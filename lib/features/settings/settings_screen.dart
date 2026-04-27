import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../core/models/category.dart';
import '../../core/models/log_entry.dart';
import '../../core/models/project.dart';
import '../../core/providers/isar_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../util/string_constant.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text(AppStrings.settingsScreenTitle),
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Appearance ─────────────────────────────────────────
                _SectionHeader(title: AppStrings.appearance),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.theme,
                          style: theme.textTheme.labelLarge,
                        ),
                        const SizedBox(height: 12),
                        SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.dark,
                              icon: Icon(Icons.dark_mode_outlined, size: 16),
                              label: Text(AppStrings.dark),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              icon: Icon(Icons.light_mode_outlined, size: 16),
                              label: Text(AppStrings.light),
                            ),
                            ButtonSegment(
                              value: ThemeMode.system,
                              icon: Icon(Icons.contrast_outlined, size: 16),
                              label: Text(AppStrings.system),
                            ),
                          ],
                          selected: {themeMode},
                          onSelectionChanged: (s) =>
                              ref.read(themeModeProvider.notifier).state =
                                  s.first,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Data ───────────────────────────────────────────────
                _SectionHeader(title: AppStrings.data),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.upload_outlined),
                        title: const Text(AppStrings.exportDataAsJson),
                        subtitle: const Text(AppStrings.saveAllLogsToJson),
                        trailing: const Icon(Icons.chevron_right, size: 18),
                        onTap: () => _exportData(context, ref),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── About ──────────────────────────────────────────────
                _SectionHeader(title: AppStrings.about),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Text(
                          AppStrings.aboutEmoji,
                          style: TextStyle(fontSize: 20),
                        ),
                        title: const Text(AppStrings.appName),
                        subtitle: const Text(AppStrings.appVersionSubtitle),
                      ),
                      Divider(
                        height: 1,
                        indent: 56,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFF87171),
                        ),
                        title: const Text(
                          AppStrings.clearAllData,
                          style: TextStyle(color: Color(0xFFF87171)),
                        ),
                        onTap: () => _confirmClear(context, ref),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final isar = ref.read(isarProvider);
    final logs = await isar.logEntrys
        .where()
        .createdAtBetween(
          DateTime.fromMillisecondsSinceEpoch(0),
          DateTime(2100),
        )
        .sortByCreatedAtDesc()
        .findAll();
    final projects = await isar.projects
        .where()
        .sortByCreatedAtDesc()
        .findAll();
    final export = {
      'app': AppStrings.appName,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'progress': _progressSummary(logs, projects),
      'projects': projects.map((p) => _projectToExport(p, logs)).toList(),
      'history': _historyToExport(logs),
    };
    final jsonStr = const JsonEncoder.withIndent('  ').convert(export);

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.exportDataTitle),
        content: SingleChildScrollView(
          child: SelectableText(
            jsonStr,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.clearAllDataTitle),
        content: const Text(AppStrings.clearAllDataMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              AppStrings.deleteAll,
              style: TextStyle(color: Color(0xFFF87171)),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.logEntrys.clear());
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.allDataCleared),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Map<String, Object> _progressSummary(
    List<LogEntry> logs,
    List<Project> projects,
  ) {
    final days = logs.map((log) {
      final local = log.createdAt.toLocal();
      return DateTime(local.year, local.month, local.day);
    }).toSet();

    return {
      'totalEntries': logs.length,
      'trackedDays': days.length,
      'totalProjects': projects.length,
      'activeProjects': projects
          .where((project) => project.status == ProjectStatus.active)
          .length,
      'byCategory': {
        for (final category in Category.values)
          category.name: logs.where((log) => log.category == category).length,
      },
    };
  }

  Map<String, Object?> _projectToExport(Project project, List<LogEntry> logs) {
    final entries = logs
        .where((log) => _isProjectEntry(log, project))
        .map(_logToExport)
        .toList();

    return {
      'id': project.id,
      'name': project.name,
      'description': project.description,
      'status': project.status.name,
      'createdAt': project.createdAt.toLocal().toIso8601String(),
      'entries': entries,
    };
  }

  List<Map<String, Object?>> _historyToExport(List<LogEntry> logs) {
    final byDay = <DateTime, List<LogEntry>>{};
    for (final log in logs) {
      final local = log.createdAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      (byDay[day] ??= []).add(log);
    }

    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final day in days)
        {
          'date': _dateKey(day),
          'entries': byDay[day]!.map(_logToExport).toList(),
        },
    ];
  }

  Map<String, Object?> _logToExport(LogEntry log) {
    final subtitle = log.displaySubtitle;
    return {
      'id': log.id,
      'createdAt': log.createdAt.toLocal().toIso8601String(),
      'category': log.category.name,
      'title': log.displayTitle,
      if (subtitle.isNotEmpty) 'subtitle': subtitle,
      'payload': log.payload,
    };
  }

  bool _isProjectEntry(LogEntry log, Project project) {
    if (log.category != Category.project) return false;
    final payload = log.payload;
    if (payload['projectId'] == project.id) return true;
    final projectName = (payload['projectName'] as String?)?.trim();
    return projectName != null &&
        projectName.toLowerCase() == project.name.trim().toLowerCase();
  }

  String _dateKey(DateTime date) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)}';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(letterSpacing: 1.2),
      ),
    );
  }
}
