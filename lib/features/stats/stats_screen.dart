import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/category.dart';
import '../../util/string_constant.dart';
import 'providers/stats_provider.dart';
import 'widgets/contribution_heatmap.dart';
import 'widgets/weekly_bar_chart.dart';

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
          surfaceTintColor: Colors.transparent,
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
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
                      emoji: '🏆',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Heatmap ──────────────────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ContributionHeatmap(data: data.heatmapData),
                ),
              ),
              const SizedBox(height: 24),

              // ── Weekly bar chart ─────────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.last7Days,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      WeeklyBarChart(counts: data.weeklyLogCounts),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Category totals ──────────────────────────────────────
              Text(AppStrings.totals, style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              ...Category.values.map(
                (cat) => _CategoryStatRow(
                  category: cat,
                  value: data.categoryTotals[cat] ?? 0,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  final String label;
  final int value;
  final String emoji;

  const _StreakCard({
    required this.label,
    required this.value,
    required this.emoji,
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

  const _CategoryStatRow({required this.category, required this.value});

  String get _unit => switch (category) {
    Category.dsa => AppStrings.unitProblemsSolved,
    Category.content => AppStrings.unitVideosUploaded,
    Category.workout => AppStrings.unitTotalRepsOrSeconds,
    Category.reading => AppStrings.unitPagesRead,
    Category.learning => AppStrings.unitNotes,
    Category.misc => AppStrings.unitNotes,
    Category.project => AppStrings.unitSessionsLogged,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: category.surfaceColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(category.icon, color: category.color, size: 18),
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
                Text('$value $_unit', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            '$value',
            style: theme.textTheme.titleMedium?.copyWith(color: category.color),
          ),
        ],
      ),
    );
  }
}
