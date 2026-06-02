import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import 'custom_activity_field_labels.dart';

part 'custom_activity.g.dart';

@collection
class CustomActivity {
  Id id = Isar.autoIncrement;

  late String name;

  late int iconCodePoint;

  late int colorValue;

  late List<String> enabledFields;

  late int sortOrder;

  /// Relative path under app documents, e.g. `custom_icons/3.png`.
  String? customIconPath;

  /// JSON map of field kind → display label.
  String fieldLabelsJson = '{}';

  /// When true and [LogFieldKind.number] is enabled, log form shows +/- counter.
  bool numberUseCounter = false;

  @ignore
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  @ignore
  Color get color => Color(colorValue);

  @ignore
  CustomActivityFieldLabels get fieldLabels =>
      CustomActivityFieldLabels.fromJsonString(fieldLabelsJson);

  @ignore
  bool get hasCustomIcon =>
      customIconPath != null && customIconPath!.trim().isNotEmpty;

  /// Populated during cloud restore only; written to disk before Isar put.
  @ignore
  String? backupIconBase64;
}
