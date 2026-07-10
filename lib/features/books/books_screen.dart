import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/log_entry.dart';
import '../../core/theme/color_utils.dart';
import '../../util/string_constant.dart';
import '../history/history_detail_screen.dart';
import '../history/providers/history_provider.dart';
import 'providers/books_provider.dart';
import 'widgets/book_takeaway_card.dart';
import 'widgets/colored_books_icon.dart';

class BooksScreen extends ConsumerWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text(AppStrings.booksScreenTitle),
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: context.transparent,
          ),
          booksAsync.when(
            data: (groups) {
              if (groups.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _BooksEmptyState(),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(top: index == 0 ? 4 : 12),
                        child: _BookGroupTile(
                          group: groups[index],
                          startCardIndex: _startCardIndex(groups, index),
                          onOpenLog: (log) => _openLogDetail(context, log),
                        ),
                      );
                    },
                    childCount: groups.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text(AppStrings.errorWithDetails(error))),
            ),
          ),
        ],
      ),
    );
  }

  int _startCardIndex(List<BookGroup> groups, int groupIndex) {
    var index = 0;
    for (var i = 0; i < groupIndex; i++) {
      index += groups[i].logs.length;
    }
    return index;
  }

  void _openLogDetail(BuildContext context, LogEntry log) {
    final local = log.createdAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HistoryDetailScreen(
          dayLogs: DayLogs(date: day, logs: [log]),
        ),
      ),
    );
  }
}

class _BookGroupTile extends StatefulWidget {
  final BookGroup group;
  final int startCardIndex;
  final ValueChanged<LogEntry> onOpenLog;

  const _BookGroupTile({
    required this.group,
    required this.startCardIndex,
    required this.onOpenLog,
  });

  @override
  State<_BookGroupTile> createState() => _BookGroupTileState();
}

class _BookGroupTileState extends State<_BookGroupTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final group = widget.group;

    return Material(
      color: context.bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ColoredBooksIcon(bookName: group.bookName),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.bookName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.booksTakeawayCount(group.logs.length),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeIn,
            sizeCurve: Curves.easeInOut,
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 220),
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  for (var i = 0; i < group.logs.length; i++)
                    Padding(
                      padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
                      child: _TakeawayCardForLog(
                        log: group.logs[i],
                        cardIndex: widget.startCardIndex + i,
                        onTap: () => widget.onOpenLog(group.logs[i]),
                      ),
                    ),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _TakeawayCardForLog extends StatelessWidget {
  final LogEntry log;
  final int cardIndex;
  final VoidCallback onTap;

  const _TakeawayCardForLog({
    required this.log,
    required this.cardIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final quote = (log.payload['quote'] as String?)?.trim() ?? '';
    return BookTakeawayCard(
      quote: quote,
      date: log.createdAt,
      cardIndex: cardIndex,
      onTap: onTap,
    );
  }
}

class _BooksEmptyState extends StatelessWidget {
  const _BooksEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📖', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              AppStrings.booksEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.booksEmptySubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
