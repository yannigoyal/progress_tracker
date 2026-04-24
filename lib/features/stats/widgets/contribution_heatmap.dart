import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../util/string_constant.dart';

/// GitHub-style contribution heatmap for the last 90 days.
class ContributionHeatmap extends StatelessWidget {
  final Map<DateTime, int> data;

  const ContributionHeatmap({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Build 13 complete weeks ending today
    // Start at Monday of the week 12 weeks ago
    final dayOfWeek = todayDate.weekday; // 1=Mon, 7=Sun
    final startDate = todayDate.subtract(
      Duration(days: dayOfWeek - 1 + 12 * 7),
    );

    final weeks = <List<DateTime?>>[];
    DateTime cursor = startDate;
    while (!cursor.isAfter(todayDate)) {
      final week = <DateTime?>[];
      for (var d = 0; d < 7; d++) {
        final day = cursor.add(Duration(days: d));
        week.add(day.isAfter(todayDate) ? null : day);
      }
      weeks.add(week);
      cursor = cursor.add(const Duration(days: 7));
    }

    final maxCount = data.values.fold(0, (m, v) => v > m ? v : m);
    final primary = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.contributionHeatmapTitle,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day-of-week labels
            Column(
              children: AppStrings.contributionHeatmapWeekdayLabels
                  .map(
                    (label) => SizedBox(
                      height: 13,
                      child: Text(
                        label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 9,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(width: 4),
            // Heatmap grid
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: weeks.reversed.map((week) {
                    // Month label — show on first day of month in this column
                    String? monthLabel;
                    for (final day in week) {
                      if (day != null && day.day == 1) {
                        monthLabel = DateFormat('MMM').format(day);
                        break;
                      }
                    }
                    return Column(
                      children: [
                        SizedBox(
                          height: 12,
                          child: monthLabel != null
                              ? Text(
                                  monthLabel,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 9,
                                  ),
                                )
                              : null,
                        ),
                        ...week.map((day) {
                          if (day == null) {
                            return const SizedBox(width: 11, height: 13);
                          }
                          final count = data[day] ?? 0;
                          final intensity = maxCount > 0
                              ? count / maxCount
                              : 0.0;
                          final color = count == 0
                              ? theme.colorScheme.surfaceContainerHighest
                              : Color.lerp(
                                  primary.withAlpha(60),
                                  primary,
                                  intensity,
                                )!;
                          return Tooltip(
                            message: AppStrings.contributionTooltip(
                              DateFormat('MMM d').format(day),
                              count,
                            ),
                            child: Container(
                              width: 11,
                              height: 11,
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
