import 'package:flutter/widgets.dart';

TextEditingValue wrapSelection(
  TextEditingValue value, {
  required String left,
  required String right,
}) {
  final text = value.text;
  final sel = value.selection;
  if (!sel.isValid) return value;

  final start = sel.start;
  final end = sel.end;
  final a = start < end ? start : end;
  final b = start < end ? end : start;

  final selected = text.substring(a, b);
  final replacement = '$left$selected$right';
  final nextText = text.replaceRange(a, b, replacement);

  if (a == b) {
    // Cursor between markers.
    final cursor = a + left.length;
    return value.copyWith(
      text: nextText,
      selection: TextSelection.collapsed(offset: cursor),
      composing: TextRange.empty,
    );
  }

  return value.copyWith(
    text: nextText,
    selection: TextSelection(baseOffset: a, extentOffset: a + replacement.length),
    composing: TextRange.empty,
  );
}

TextEditingValue prefixSelectedLines(
  TextEditingValue value, {
  required String prefix,
  bool numbered = false,
}) {
  final text = value.text;
  final sel = value.selection;
  if (!sel.isValid) return value;

  final start = sel.start;
  final end = sel.end;
  final a = start < end ? start : end;
  final b = start < end ? end : start;

  int lineStart(int index) {
    final i = text.lastIndexOf('\n', index - 1);
    return i == -1 ? 0 : i + 1;
  }

  int lineEnd(int index) {
    final i = text.indexOf('\n', index);
    return i == -1 ? text.length : i;
  }

  final blockStart = lineStart(a);
  final blockEnd = lineEnd(b);
  final block = text.substring(blockStart, blockEnd);

  final lines = block.split('\n');
  var n = 1;
  final nextLines = lines.map((line) {
    if (line.trim().isEmpty) return line;
    if (numbered) {
      return '${n++}. $line';
    }
    return '$prefix$line';
  }).toList();

  final replacement = nextLines.join('\n');
  final nextText = text.replaceRange(blockStart, blockEnd, replacement);

  // Keep selection spanning the replaced block.
  return value.copyWith(
    text: nextText,
    selection: TextSelection(baseOffset: blockStart, extentOffset: blockStart + replacement.length),
    composing: TextRange.empty,
  );
}

