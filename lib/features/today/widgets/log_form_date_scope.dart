import 'package:flutter/material.dart';

class LogFormDateScope extends InheritedWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const LogFormDateScope({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    required super.child,
  });

  static LogFormDateScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LogFormDateScope>();

  @override
  bool updateShouldNotify(LogFormDateScope oldWidget) =>
      selectedDate != oldWidget.selectedDate;
}
