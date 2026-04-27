import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../util/string_constant.dart';

class LogDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const LogDateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _pickDate(context),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: AppStrings.logDate,
          prefixIcon: Icon(Icons.calendar_today_outlined, size: 18),
          suffixIcon: Icon(Icons.expand_more, size: 18),
        ),
        child: Text(_formattedDate, style: theme.textTheme.bodyLarge),
      ),
    );
  }

  String get _formattedDate {
    final today = DateUtils.dateOnly(DateTime.now());
    final selected = DateUtils.dateOnly(selectedDate);
    if (selected == today) return AppStrings.historyToday;
    return DateFormat('EEE, d MMM yyyy').format(selected);
  }

  Future<void> _pickDate(BuildContext context) async {
    final selected = DateUtils.dateOnly(selectedDate);
    final first = firstDate ?? DateTime(2000);
    final defaultLast = DateUtils.dateOnly(DateTime.now());
    final configuredLast = lastDate == null
        ? defaultLast
        : DateUtils.dateOnly(lastDate!);
    final last = selected.isAfter(configuredLast) ? selected : configuredLast;
    final initial = _clamp(selected, first, last);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );

    if (picked != null) {
      onDateChanged(DateUtils.dateOnly(picked));
    }
  }

  DateTime _clamp(DateTime value, DateTime first, DateTime last) {
    if (value.isBefore(first)) return first;
    if (value.isAfter(last)) return last;
    return value;
  }
}
