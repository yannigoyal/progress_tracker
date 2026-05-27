import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/category.dart';
import '../../../core/models/custom_activity.dart';
import '../../../core/models/log_entry.dart';
import '../../../shared/widgets/formatted_markdown_text.dart';
import '../../settings/providers/custom_activity_provider.dart';
import '../../../core/theme/color_utils.dart';
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
                      color: cat.surfaceColor(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(cat.icon, color: cat.color(context), size: 15),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    cat.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: cat.color(context),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: cat.surfaceColor(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${widget.logs.length}',
                      style: TextStyle(
                        fontSize: 11,
                        color: cat.color(context),
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
    final p = log.payload;

    String? markdownSubtitle() {
      // Prefer raw payload text for markdown rendering. displaySubtitle often
      // flattens multi-line text (joins with ' · '), losing bullets.
      if ((p['kind'] as String?) == 'daily_progress') {
        final note = (p['note'] as String?)?.trim();
        final quote = (p['quote'] as String?)?.trim();
        final source = note?.isNotEmpty == true ? note! : (quote ?? '');
        return source.trim().isEmpty ? null : source;
      }

      return switch (cat) {
        Category.reading => (p['quote'] as String?)?.trim(),
        Category.learning => (p['note'] as String?)?.trim(),
        Category.misc => (p['note'] as String?)?.trim(),
        Category.project => () {
            final done = (p['whatDone'] as String?)?.trim() ?? '';
            final learnt = (p['whatLearnt'] as String?)?.trim() ?? '';
            if (done.isEmpty && learnt.isEmpty) return null;
            if (done.isEmpty) return learnt;
            if (learnt.isEmpty) return done;
            return '$done\n\n$learnt';
          }(),
        Category.custom => (p['note'] as String?)?.trim(),
        _ => null,
      };
    }

    final noteBody = markdownSubtitle();
    final meta = log.displaySubtitle;
    final showNote = noteBody != null &&
        noteBody.isNotEmpty &&
        (noteBody.contains('\n') || noteBody.trim() != log.displayTitle.trim());
    final previewLines = _isJournalEntry
        ? 3
        : (showNote && noteBody.contains('\n') ? 3 : 1);

    // If the title itself is derived from the note's first line (e.g. Learning,
    // Misc daily progress), showing the note preview would repeat that first
    // line. In that case, use the category label as title.
    final titleText = (showNote &&
            (cat == Category.learning ||
                cat == Category.misc ||
                (p['kind'] as String?) == 'daily_progress'))
        ? cat.label
        : log.displayTitle;

    return Dismissible(
      key: ValueKey(log.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: context.danger,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: context.white, size: 20),
            const SizedBox(height: 2),
            Text(
              AppStrings.delete,
              style: TextStyle(color: context.white, fontSize: 10),
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
                child: Text(
                  AppStrings.delete,
                  style: TextStyle(color: context.danger),
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
                  color: cat.color(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleText,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: _isJournalEntry ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showNote) ...[
                      const SizedBox(height: 2),
                      FormattedMarkdownText(
                        noteBody,
                        maxPreviewLines: previewLines,
                      ),
                    ],
                    if (meta.isNotEmpty &&
                        (cat == Category.learning || !showNote)) ...[
                      const SizedBox(height: 2),
                      Text(
                        meta,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
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

  Future<void> _openEdit(BuildContext context, WidgetRef ref) async {
    CustomActivity? customActivity;
    if (log.category == Category.custom) {
      final id = log.payload['customActivityId'];
      if (id is int) {
        customActivity = await ref
            .read(customActivityRepositoryProvider)
            .getById(id);
      }
    }

    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.transparent,
      builder: (_) => LogFormSheet(
        category: log.category,
        customActivity: customActivity,
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
