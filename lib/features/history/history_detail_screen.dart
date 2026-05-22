import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models/category.dart';
import '../../core/models/log_entry.dart';
import '../../util/string_constant.dart';
import 'providers/history_provider.dart';

class HistoryDetailScreen extends StatelessWidget {
  final DayLogs dayLogs;

  const HistoryDetailScreen({super.key, required this.dayLogs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logs = dayLogs.actualLogs;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.historyDetailTitle)),
      body: logs.isEmpty
          ? const Center(child: Text(AppStrings.historyDetailEmpty))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(dayLogs.date),
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(dayLogs.summary, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                ...logs.map((log) => _LogDetailCard(log: log)),
              ],
            ),
    );
  }
}

class _LogDetailCard extends StatelessWidget {
  final LogEntry log;

  const _LogDetailCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = log.category;
    final details = _detailRows(log);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: category.surfaceColor(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color(context),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    category.label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: category.color(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  DateFormat('HH:mm').format(log.createdAt.toLocal()),
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              log.displayTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (log.displaySubtitle.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(log.displaySubtitle, style: theme.textTheme.bodyMedium),
            ],
            if (details.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...details.map((row) => _DetailRowView(row: row)),
            ],
          ],
        ),
      ),
    );
  }

  List<_DetailRow> _detailRows(LogEntry log) {
    final p = log.payload;
    final rows = <_DetailRow>[];

    void add(String label, Object? value) {
      final text = _valueText(value);
      if (text == null || text.isEmpty) return;
      rows.add(_DetailRow(label, text));
    }

    switch (log.category) {
      case Category.dsa:
        add('Problem', p['problemNumber']);
        add('Topic', p['topic']);
        add('Approach', p['approach']);
        add('Status', p['status']);
        add('Notes', p['note']);
      case Category.content:
        add('Platform', p['platform']);
        add('Status', p['statuses'] ?? p['status']);
        add('Type', p['videoType']);
      case Category.workout:
        add('Exercise', p['exercise']);
        add('Duration', p['duration']);
        add('Breakdown', p['setBreakdown']);
      case Category.reading:
      case Category.learning:
        add('Tags', p['tags']);
      case Category.misc:
        add('Note', p['note']);
      case Category.project:
        add('Project', p['projectName']);
        add('Learned', p['whatLearnt']);
      case Category.custom:
        add('Activity', p['customActivityName']);
        add('Title', p['title']);
        add('Note', p['note']);
        add('Amount', p['number']);
        add('Duration (min)', p['durationMinutes']);
        add('Tags', p['tags']);
    }

    return rows;
  }

  String? _valueText(Object? value) {
    if (value == null) return null;
    if (value is List) return value.map((item) => item.toString()).join(', ');
    return value.toString().trim();
  }
}

class _DetailRow {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);
}

class _DetailRowView extends StatelessWidget {
  final _DetailRow row;

  const _DetailRowView({required this.row});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            row.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(row.value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
