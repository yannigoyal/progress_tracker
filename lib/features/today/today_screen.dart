import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/category.dart';
import '../../core/models/custom_activity.dart';
import '../../core/theme/color_utils.dart';
import '../../util/string_constant.dart';
import '../dsa_tracker/providers/dsa_provider.dart';
import '../history/providers/history_provider.dart';
import '../project/providers/project_provider.dart';
import '../stats/providers/stats_provider.dart';
import '../settings/providers/category_order_provider.dart';
import 'providers/today_provider.dart';
import 'widgets/add_log_bottom_sheet.dart';
import 'widgets/category_chip_row.dart';
import 'widgets/custom_activity_picker_sheet.dart';
import 'widgets/log_list_view.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(todayLogsProvider);
    final dayAsync = ref.watch(dayNumberProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(todayLogsProvider.future),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Header ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    dayAsync.when(
                      data: (d) => Text(
                        AppStrings.todayScreenDay(d),
                        style: theme.textTheme.displayLarge,
                      ),
                      loading: () => Text(
                        AppStrings.todayScreenLoadingDay,
                        style: theme.textTheme.displayLarge,
                      ),
                      error: (error, stackTrace) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('EEE, d MMM').format(DateTime.now()),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            // ── Category chips ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: CategoryChipRow(logs: logsAsync.valueOrNull ?? []),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ── Log list / empty state ───────────────────────────────────
            logsAsync.when(
              data: (logs) => logs.isEmpty
                  ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(),
                    )
                  : LogListView(logs: logs),
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    AppStrings.genericScreenError(e),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryPicker(context, ref),
        tooltip: AppStrings.todayScreenAddLogTooltip,
        child: const Icon(Icons.add, size: 26),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    final categories =
        ref.read(categoryOrderProvider).valueOrNull ?? Category.values;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.transparent,
      builder: (sheetCtx) => AddLogBottomSheet(
        categories: categories,
        onCategorySelected: (category) {
          Navigator.of(sheetCtx).pop();
          if (category == Category.custom) {
            _showCustomActivityPicker(context, ref);
          } else {
            _showLogForm(context, ref, category);
          }
        },
      ),
    );
  }

  void _showCustomActivityPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.transparent,
      builder: (pickerCtx) => CustomActivityPickerSheet(
        onSelected: (activity) {
          Navigator.of(pickerCtx).pop();
          _showLogForm(
            context,
            ref,
            Category.custom,
            customActivity: activity,
          );
        },
      ),
    );
  }

  void _showLogForm(
    BuildContext context,
    WidgetRef ref,
    Category category, {
    CustomActivity? customActivity,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.transparent,
      builder: (formCtx) => LogFormSheet(
        category: category,
        customActivity: customActivity,
        onSave: (entry) async {
          Navigator.of(formCtx).pop();
          HapticFeedback.lightImpact();
          await ref.read(todayLogsProvider.notifier).addLog(entry);
          _refreshLogDependents(ref);
        },
      ),
    );
  }

  void _refreshLogDependents(WidgetRef ref) {
    ref.invalidate(dayNumberProvider);
    ref.invalidate(historyProvider);
    ref.invalidate(projectsProvider);
    ref.invalidate(statsProvider);
    ref.invalidate(dsaTrackerProvider);
    ref.invalidate(dsaSolvedCountProvider);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            AppStrings.todayScreenEmptyEmoji,
            style: TextStyle(fontSize: 72),
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.todayScreenEmptyTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.todayScreenEmptySubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
