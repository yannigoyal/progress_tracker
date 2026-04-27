import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/category.dart';
import '../../core/models/log_entry.dart';
import '../../core/providers/isar_provider.dart';
import '../../util/string_constant.dart';
import '../dsa_tracker/providers/dsa_provider.dart';
import '../stats/providers/stats_provider.dart';
import '../today/providers/today_provider.dart';
import 'history_detail_screen.dart';
import 'providers/history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyProvider);
    final activeFilter = ref.watch(historyCategoryFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text(AppStrings.historyScreenTitle),
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(104),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  children: [
                    // Search bar
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: AppStrings.searchLogs,
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  ref
                                          .read(historySearchProvider.notifier)
                                          .state =
                                      '';
                                },
                              )
                            : null,
                      ),
                      onChanged: (v) =>
                          ref.read(historySearchProvider.notifier).state = v,
                    ),
                    const SizedBox(height: 8),
                    // Category filter chips
                    SizedBox(
                      height: 32,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _FilterChip(
                            label: AppStrings.all,
                            selected: activeFilter == null,
                            onTap: () =>
                                ref
                                        .read(
                                          historyCategoryFilterProvider
                                              .notifier,
                                        )
                                        .state =
                                    null,
                            color: theme.colorScheme.primary,
                          ),
                          ...Category.values.map(
                            (cat) => _FilterChip(
                              label: cat.label,
                              selected: activeFilter == cat,
                              onTap: () =>
                                  ref
                                          .read(
                                            historyCategoryFilterProvider
                                                .notifier,
                                          )
                                          .state =
                                      cat,
                              color: cat.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          historyAsync.when(
            data: (days) => days.isEmpty
                ? const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyHistory(),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _DayCard(dayLogs: days[i]),
                      childCount: days.length,
                    ),
                  ),
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text(AppStrings.errorWithDetails(e))),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? color.withAlpha(40) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? color : color.withAlpha(60)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? color : color.withAlpha(160),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _DayCard extends StatefulWidget {
  final DayLogs dayLogs;

  const _DayCard({required this.dayLogs});

  @override
  State<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<_DayCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = widget.dayLogs.date;
    final isToday = () {
      final now = DateTime.now();
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Card(
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isToday
                                ? AppStrings.historyToday
                                : DateFormat('EEE, d MMM').format(date),
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.dayLogs.summary,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.dayLogs.actualCount}',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              HistoryDetailScreen(dayLogs: widget.dayLogs),
                        ),
                      ),
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      label: const Text(AppStrings.historyViewDetails),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: theme.colorScheme.onSurface.withAlpha(100),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: _LogsList(logs: widget.dayLogs.actualLogs),
                  secondChild: const SizedBox.shrink(),
                  crossFadeState: _expanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogsList extends ConsumerWidget {
  final List<LogEntry> logs;

  const _LogsList({required this.logs});

  bool _isJournalEntry(LogEntry log) =>
      log.category == Category.misc &&
      (log.payload['kind'] as String?) == 'daily_progress';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: 12),
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        const SizedBox(height: 8),
        ...logs.map((log) {
          final cat = log.category;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: cat.surfaceColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(cat.icon, size: 12, color: cat.color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.displayTitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: _isJournalEntry(log) ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (log.displaySubtitle.isNotEmpty)
                        Text(
                          log.displaySubtitle,
                          style: theme.textTheme.bodySmall,
                          maxLines: _isJournalEntry(log) ? 4 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Text(
                  DateFormat('HH:mm').format(log.createdAt.toLocal()),
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: AppStrings.delete,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: theme.colorScheme.error,
                  ),
                  onPressed: () => _confirmDelete(context, ref, log),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    LogEntry log,
  ) async {
    final confirmed = await showDialog<bool>(
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
              style: TextStyle(color: Color(0xFFF87171)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.logEntrys.delete(log.id));

    ref.invalidate(historyProvider);
    ref.invalidate(todayLogsProvider);
    ref.invalidate(dayNumberProvider);
    ref.invalidate(statsProvider);
    ref.invalidate(dsaTrackerProvider);
    ref.invalidate(dsaSolvedCountProvider);
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            AppStrings.historyEmptyEmoji,
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.historyEmptyTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.historyEmptySubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
