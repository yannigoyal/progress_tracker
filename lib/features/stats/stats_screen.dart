import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/category.dart';
import '../../core/theme/color_utils.dart';
import '../../util/string_constant.dart';
import 'providers/stats_provider.dart';
import 'widgets/contribution_heatmap.dart';
import 'widgets/line_chart_last_30_days.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      body: statsAsync.when(
        data: (data) => _StatsBody(data: data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(AppStrings.errorWithDetails(e))),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  final StatsData data;

  const _StatsBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: const Text(AppStrings.statsScreenTitle),
          backgroundColor: theme.scaffoldBackgroundColor,
          surfaceTintColor: context.transparent,
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Streak cards ─────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _StreakCard(
                      label: AppStrings.currentStreak,
                      value: data.currentStreak,
                      emoji: '🔥',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StreakCard(
                      label: AppStrings.longestStreak,
                      value: data.longestStreak,
                      lastLogged: data.overallLastLogged,
                      emoji: '🏆',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Top 3 workout PRs
              // if (data.topWorkoutPRs.isNotEmpty) ...[
              //   Card(
              //     child: Padding(
              //       padding: const EdgeInsets.all(16),
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text('Top 3 PRs', style: theme.textTheme.titleSmall),
              //           const SizedBox(height: 12),
              //           ...data.topWorkoutPRs.map(
              //             (pr) => Padding(
              //               padding: const EdgeInsets.only(bottom: 8),
              //               child: Row(
              //                 children: [
              //                   Expanded(
              //                     child: Text(
              //                       pr.exercise,
              //                       style: theme.textTheme.bodyLarge?.copyWith(
              //                         fontWeight: FontWeight.w500,
              //                       ),
              //                     ),
              //                   ),
              //                   Text(
              //                     pr.isDuration
              //                         ? '${pr.value}s'
              //                         : '${pr.value}',
              //                     style: theme.textTheme.bodyMedium?.copyWith(
              //                       color: theme.colorScheme.primary,
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              //   const SizedBox(height: 16),
              // ],
              _buildContributionHeatmap(),
              const SizedBox(height: 16),

              _buildLineChart(theme),
              const SizedBox(height: 24),

              // ── Category totals ──────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.totals, style: theme.textTheme.titleMedium),
                  Text(AppStrings.noOfLogs, style: theme.textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 12),
              ...Category.values.map(
                (cat) => _CategoryStatRow(
                  category: cat,
                  value: data.categoryTotals[cat] ?? 0,
                  stats: data.categoryStats[cat],
                  logCount: data.categoryLogCounts[cat] ?? 0,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildContributionHeatmap() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ContributionHeatmap(data: data.heatmapData),
      ),
    );
  }

  Widget _buildLineChart(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.last30Days, style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            LineChartLast30Days(data: data.last30DaysData),
          ],
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final String label;
  final int value;
  final String emoji;
  final DateTime? lastLogged;

  const _StreakCard({
    required this.label,
    required this.value,
    required this.emoji,
    this.lastLogged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            if (value > 0)
              Text(
                AppStrings.dayCount(value),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              )
            else if (lastLogged != null)
              Text(
                DateFormat.yMMMd().format(lastLogged!.toLocal()),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              )
            else
              Text(
                AppStrings.dayCount(value),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            const SizedBox(height: 2),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _CategoryStatRow extends StatelessWidget {
  final Category category;
  final int value;
  final dynamic stats;
  final int logCount;

  const _CategoryStatRow({
    required this.category,
    required this.value,
    this.stats,
    this.logCount = 0,
  });

  String get _unit => switch (category) {
    Category.dsa => AppStrings.unitProblemsSolved,
    Category.content => AppStrings.unitVideosUploaded,
    Category.workout => AppStrings.unitTotalRepsOrSeconds,
    Category.reading => AppStrings.unitPagesRead,
    Category.learning => AppStrings.unitLogs,
    Category.misc => AppStrings.unitLogs,
    Category.project => AppStrings.unitSessionsLogged,
    Category.custom => AppStrings.unitLogs,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String subtitle = '';
    if (stats != null) {
      final int longest = stats.longestStreak ?? 0;
      final DateTime? last = stats.lastLogged as DateTime?;
      if (longest > 0) {
        subtitle = 'Longest streak: ${longest} day${longest == 1 ? '' : 's'}';
      } else if (last != null) {
        subtitle = 'Last logged: ${DateFormat.yMMMd().format(last.toLocal())}';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: category.surfaceColor(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              category.icon,
              color: category.color(context),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: theme.textTheme.bodySmall)
                else
                  Text('$value $_unit', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            '$logCount',
            style: theme.textTheme.titleMedium?.copyWith(
              color: category.color(context),
            ),
          ),
        ],
      ),
    );
  }
}
