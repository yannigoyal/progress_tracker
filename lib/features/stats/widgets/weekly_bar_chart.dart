import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyBarChart extends StatelessWidget {
  /// Counts for the last 7 days, oldest first (index 0 = 6 days ago).
  final List<int> counts;

  const WeeklyBarChart({super.key, required this.counts});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surfaceContainerHighest;
    final maxY = (counts.fold(0, (m, v) => v > m ? v : m) + 2).toDouble();
    final today = DateTime.now();

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          minY: 0,
          barGroups: List.generate(7, (i) {
            final count = counts[i].toDouble();
            final isToday = i == 6;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: count,
                  color: isToday ? primary : primary.withAlpha(120),
                  width: 22,
                  borderRadius: BorderRadius.circular(6),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: surface,
                  ),
                ),
              ],
            );
          }),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (value, _) {
                  final count = counts[value.toInt()];
                  if (count == 0) return const SizedBox.shrink();
                  return Text(
                    '$count',
                    style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withAlpha(180),
                        fontWeight: FontWeight.w600),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) {
                  final day = today.subtract(Duration(days: 6 - value.toInt()));
                  final isToday = value.toInt() == 6;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('EEE').format(day),
                      style: TextStyle(
                        fontSize: 11,
                        color: isToday
                            ? primary
                            : theme.colorScheme.onSurface.withAlpha(120),
                        fontWeight: isToday
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
