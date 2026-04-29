import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LineChartLast30Days extends StatelessWidget {
  final List<int> data;

  const LineChartLast30Days({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final today = DateTime.now();
    final counts = data.length == 30 ? data : List<int>.filled(30, 0);
    const maxY = 10.0;

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 29,
          minY: 0,
          maxY: maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((spot) {
                final index = spot.x.toInt();
                final date = today.subtract(Duration(days: 29 - index));
                return LineTooltipItem(
                  '${DateFormat('MMM d').format(date)}\n${counts[index]} logs',
                  TextStyle(
                    color: theme.colorScheme.onInverseSurface,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
          ),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (_) => FlLine(
              color: theme.colorScheme.outlineVariant.withAlpha(80),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 2,
                getTitlesWidget: (value, _) {
                  return Text(
                    value.toInt().toString(),
                    style: theme.textTheme.labelSmall,
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 5,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index > 29 || index % 5 != 0) {
                    return const SizedBox.shrink();
                  }
                  final date = today.subtract(Duration(days: 29 - index));
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('d MMM').format(date),
                      style: theme.textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                30,
                (index) => FlSpot(
                  index.toDouble(),
                  counts[index].clamp(0, 10).toDouble(),
                ),
              ),
              isCurved: true,
              color: primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: primary.withAlpha(30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
