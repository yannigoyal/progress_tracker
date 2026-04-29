import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../util/string_constant.dart';

/// GitHub-style contribution heatmap for the last year.
class ContributionHeatmap extends StatefulWidget {
  final Map<DateTime, int> data;

  const ContributionHeatmap({super.key, required this.data});

  @override
  State<ContributionHeatmap> createState() => _ContributionHeatmapState();
}

class _ContributionHeatmapState extends State<ContributionHeatmap> {
  final _scrollController = ScrollController();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _scrollToLatestWeek();
  }

  @override
  void didUpdateWidget(covariant ContributionHeatmap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _scrollToLatestWeek();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todayDate = DateUtils.dateOnly(DateTime.now());
    final firstDay = todayDate.subtract(const Duration(days: 364));
    final startDate = firstDay.subtract(Duration(days: firstDay.weekday - 1));
    final normalizedData = _normalizeData(widget.data);
    final total = normalizedData.values.fold(0, (sum, count) => sum + count);
    final weeks = _buildWeeks(startDate, todayDate);
    final selectedDay =
        _selectedDay ??
        _latestActiveDay(normalizedData, todayDate) ??
        todayDate;
    final selectedCount = normalizedData[selectedDay] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.contributionHeatmapTitle,
                style: theme.textTheme.titleSmall,
              ),
            ),
            Text(
              AppStrings.heatmapMomentumText(total),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 10),
        _SelectedDayPill(day: selectedDay, count: selectedCount),
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
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: weeks.map((week) {
                    final monthLabel = _monthLabel(week);
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
                        ...week.map(
                          (day) => _HeatmapCell(
                            day: day,
                            count: day == null
                                ? 0
                                : normalizedData[DateUtils.dateOnly(day)] ?? 0,
                            isSelected:
                                day != null &&
                                DateUtils.isSameDay(day, selectedDay),
                            colorFor: (count) =>
                                _colorFor(theme, _intensity(count)),
                            onTap: day == null
                                ? null
                                : () => setState(() {
                                    _selectedDay = DateUtils.dateOnly(day);
                                  }),
                          ),
                        ),
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

  void _scrollToLatestWeek() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  List<List<DateTime?>> _buildWeeks(DateTime startDate, DateTime todayDate) {
    final dayCount = todayDate.difference(startDate).inDays + 1;
    final weekCount = (dayCount / 7).ceil();
    return List.generate(
      weekCount,
      (week) => List.generate(7, (day) {
        final date = startDate.add(Duration(days: week * 7 + day));
        return date.isAfter(todayDate) ? null : date;
      }),
    );
  }

  DateTime? _latestActiveDay(Map<DateTime, int> data, DateTime todayDate) {
    final activeDays =
        data.entries
            .where((entry) => !entry.key.isAfter(todayDate) && entry.value > 0)
            .map((entry) => entry.key)
            .toList()
          ..sort();

    return activeDays.isEmpty ? null : activeDays.last;
  }

  Map<DateTime, int> _normalizeData(Map<DateTime, int> source) {
    final normalized = <DateTime, int>{};
    for (final entry in source.entries) {
      final local = entry.key.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      normalized[day] = (normalized[day] ?? 0) + entry.value;
    }
    return normalized;
  }

  String? _monthLabel(List<DateTime?> week) {
    for (final day in week) {
      if (day != null && day.day == 1) return DateFormat('MMM').format(day);
    }
    return null;
  }

  int _intensity(int count) {
    if (count == 0) return 0;
    if (count >= 10) return 4;
    if (count >= 5) return 3;
    if (count >= 2) return 2;
    return 1;
  }

  Color _colorFor(ThemeData theme, int intensity) {
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surfaceContainerHighest;
    return switch (intensity) {
      0 => surface,
      1 => Color.lerp(surface, primary, 0.40)!,
      2 => Color.lerp(surface, primary, 0.58)!,
      3 => Color.lerp(surface, primary, 0.76)!,
      _ => primary,
    };
  }
}

class _HeatmapCell extends StatelessWidget {
  final DateTime? day;
  final int count;
  final bool isSelected;
  final Color Function(int count) colorFor;
  final VoidCallback? onTap;

  const _HeatmapCell({
    required this.day,
    required this.count,
    required this.isSelected,
    required this.colorFor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cell = Container(
      width: 11,
      height: 11,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: colorFor(count),
        borderRadius: BorderRadius.circular(2),
        border: isSelected
            ? Border.all(color: theme.colorScheme.onSurface, width: 1.4)
            : null,
      ),
    );

    if (day == null) return cell;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Tooltip(
        message: AppStrings.contributionTooltip(
          DateFormat('MMM d').format(day!),
          count,
        ),
        child: cell,
      ),
    );
  }
}

class _SelectedDayPill extends StatelessWidget {
  final DateTime day;
  final int count;

  const _SelectedDayPill({required this.day, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        AppStrings.heatmapSelectedDay(
          DateFormat('EEE, MMM d').format(day),
          count,
        ),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
