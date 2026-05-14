import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/theme_provider.dart';
import '../../core/theme/color_utils.dart';
import '../../util/string_constant.dart';
import '../dsa_tracker/providers/dsa_provider.dart';
import '../history/providers/history_provider.dart';
import '../project/providers/project_provider.dart';
import '../stats/providers/stats_provider.dart';
import '../today/providers/today_provider.dart';
import 'data/dailylog_report_exporter.dart';
import 'providers/settings_provider.dart';

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
            surfaceTintColor: context.transparent,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(14),
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
                              icon: Icon(Icons.dark_mode_outlined, size: 12),
                              label: Text(AppStrings.dark),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              icon: Icon(Icons.light_mode_outlined, size: 12),
                              label: Text(AppStrings.light),
                            ),
                            ButtonSegment(
                              value: ThemeMode.system,
                              icon: Icon(Icons.contrast_outlined, size: 12),
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
                      // ListTile(
                      //   leading: Icon(
                      //     Icons.delete_outline,
                      //     color: context.danger,
                      //   ),
                      //   title: Text(
                      //     AppStrings.clearAllData,
                      //     style: TextStyle(color: context.danger),
                      //   ),
                      //   onTap: () => _confirmClear(context, ref),
                      // ),
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
    try {
      final data = await ref.refresh(settingsExportProvider.future);
      final report = await const DailyLogReportExporter().export(
        logs: data.logs,
        projects: data.projects,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.reportExported(report.displayPath)),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: AppStrings.open,
            onPressed: () => _openExportedReport(context, report),
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.errorWithDetails(error)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: context.danger,
        ),
      );
    }
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
            child: Text(
              AppStrings.deleteAll,
              style: TextStyle(color: context.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(settingsDataNotifierProvider.notifier).clearLogs();
    _refreshLogDependents(ref);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.allDataCleared),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _refreshLogDependents(WidgetRef ref) {
    ref.invalidate(settingsExportProvider);
    ref.invalidate(todayLogsProvider);
    ref.invalidate(dayNumberProvider);
    ref.invalidate(historyProvider);
    ref.invalidate(projectsProvider);
    ref.invalidate(statsProvider);
    ref.invalidate(dsaTrackerProvider);
    ref.invalidate(dsaSolvedCountProvider);
  }

  Future<void> _openExportedReport(
    BuildContext context,
    ExportedReport report,
  ) async {
    try {
      await const DailyLogReportExporter().open(report);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.errorWithDetails(error)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: context.danger,
        ),
      );
    }
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
