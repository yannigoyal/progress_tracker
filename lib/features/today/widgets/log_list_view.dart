import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/category.dart';
import '../../../core/models/log_entry.dart';
import '../../../util/colors.dart';
import '../../../util/string_constant.dart';
import '../../dsa_tracker/providers/dsa_provider.dart';
import '../../history/providers/history_provider.dart';
import '../../project/providers/project_provider.dart';
import '../../stats/providers/stats_provider.dart';
import '../providers/today_provider.dart';
import 'add_log_bottom_sheet.dart';

class LogListView extends StatelessWidget {
  final List<LogEntry> logs;

  const LogListView({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    // Group by category (preserving enum order)
    final Map<Category, List<LogEntry>> grouped = {};
    for (final log in logs) {
      (grouped[log.category] ??= []).add(log);
    }
    final orderedCats = Category.values
        .where((c) => grouped.containsKey(c))
        .toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => _CategorySection(
          category: orderedCats[i],
          logs: grouped[orderedCats[i]]!,
        ),
        childCount: orderedCats.length,
      ),
    );
  }
}

// ── Category section (collapsible) ───────────────────────────────────────────

class _CategorySection extends StatefulWidget {
  final Category category;
  final List<LogEntry> logs;

  const _CategorySection({required this.category, required this.logs});

  @override
  State<_CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<_CategorySection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cat = widget.category;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cat.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 15),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    cat.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: cat.color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: cat.surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${widget.logs.length}',
                      style: TextStyle(
                        fontSize: 11,
                        color: cat.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _expanded ? 0 : -0.25,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.colorScheme.onSurface.withAlpha(100),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: Column(
              children: widget.logs
                  .map<Widget>((log) => _LogItem(log: log))
                  .toList(),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Individual log item ───────────────────────────────────────────────────────

class _LogItem extends ConsumerWidget {
  final LogEntry log;

  const _LogItem({required this.log});

  bool get _isJournalEntry =>
      log.category == Category.misc &&
      (log.payload['kind'] as String?) == 'daily_progress';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cat = log.category;

    return Dismissible(
      key: ValueKey(log.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: AppColors.white, size: 20),
            SizedBox(height: 2),
            Text(
              AppStrings.delete,
              style: TextStyle(color: AppColors.white, fontSize: 10),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text(AppStrings.deleteLogTitle),
            content: Text(AppStrings.deleteLogMessage(log.displayTitle)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(AppStrings.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  AppStrings.delete,
                  style: TextStyle(color: AppColors.danger),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        await ref.read(todayLogsProvider.notifier).deleteLog(log.id);
        _refreshLogDependents(ref);
      },
      child: GestureDetector(
        onTap: () => _openEdit(context, ref),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              // Category dot
              Container(
                width: 3,
                height: 36,
                decoration: BoxDecoration(
                  color: cat.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.displayTitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: _isJournalEntry ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (log.displaySubtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        log.displaySubtitle,
                        style: theme.textTheme.bodySmall,
                        maxLines: _isJournalEntry ? 3 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('HH:mm').format(log.createdAt.toLocal()),
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEdit(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => LogFormSheet(
        category: log.category,
        existingLog: log,
        onSave: (updated) async {
          Navigator.of(context).pop();
          await ref.read(todayLogsProvider.notifier).updateLog(updated);
          _refreshLogDependents(ref);
        },
      ),
    );
  }
}

void _refreshLogDependents(WidgetRef ref) {
  ref.invalidate(dayNumberProvider);
  ref.invalidate(historyProvider);
  ref.invalidate(projectsProvider);
  ref.invalidate(statsProvider);
  ref.invalidate(dsaTrackerProvider);
  ref.invalidate(dsaSolvedCountProvider);
}
