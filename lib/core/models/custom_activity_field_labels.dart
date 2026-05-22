import 'dart:convert';

import 'log_field_kind.dart';

/// JSON map of [LogFieldKind] keys to user-visible labels on log forms.
class CustomActivityFieldLabels {
  final Map<String, String> labels;

  const CustomActivityFieldLabels(this.labels);

  static const empty = CustomActivityFieldLabels({});

  factory CustomActivityFieldLabels.fromJsonString(String? raw) {
    if (raw == null || raw.isEmpty || raw == '{}') return empty;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return empty;
      final map = <String, String>{};
      for (final entry in decoded.entries) {
        final key = entry.key.toString();
        final value = entry.value?.toString().trim() ?? '';
        if (value.isNotEmpty) map[key] = value;
      }
      return CustomActivityFieldLabels(map);
    } catch (_) {
      return empty;
    }
  }

  String toJsonString() {
    if (labels.isEmpty) return '{}';
    return jsonEncode(labels);
  }

  String labelFor(String kind) {
    return labels[kind]?.trim().isNotEmpty == true
        ? labels[kind]!
        : LogFieldKind.label(kind);
  }

  CustomActivityFieldLabels withDefaultsFor(Iterable<String> enabledFields) {
    final merged = Map<String, String>.from(labels);
    for (final kind in enabledFields) {
      merged.putIfAbsent(kind, () => LogFieldKind.label(kind));
    }
    return CustomActivityFieldLabels(merged);
  }
}
