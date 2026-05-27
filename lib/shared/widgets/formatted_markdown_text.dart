import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class FormattedMarkdownText extends StatelessWidget {
  final String text;

  /// If set, shows a compact preview (Text-based) instead of full Markdown
  /// layout. Use this in list rows to avoid overflow from [MarkdownBody].
  final int? maxPreviewLines;

  const FormattedMarkdownText(
    this.text, {
    super.key,
    this.maxPreviewLines,
  });

  /// Converts stored markdown into readable plain text for list previews.
  static String toPreviewPlain(String markdown) {
    final lines = markdown.split('\n');
    final out = <String>[];

    for (final line in lines) {
      var t = line.trimRight();
      if (t.trim().isEmpty) {
        out.add('');
        continue;
      }

      final trimmedLeft = t.trimLeft();
      if (trimmedLeft.startsWith('- [ ] ')) {
        t = '☐ ${trimmedLeft.substring(6)}';
      } else if (trimmedLeft.startsWith('- ')) {
        t = '• ${trimmedLeft.substring(2)}';
      } else {
        t = trimmedLeft;
      }

      // Strip common inline markers for compact preview.
      t = t.replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1');
      t = t.replaceAllMapped(
        RegExp(r'(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)'),
        (m) => m.group(1)!,
      );
      t = t.replaceAll('~~', '');

      out.add(t);
    }

    return out.join('\n').trimRight();
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = text.trimRight();
    if (trimmed.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    // List / row previews: Text with maxLines (bullets as • / ☐). MarkdownBody
    // does not respect tight max-height and overflows internally.
    if (maxPreviewLines != null) {
      final preview = toPreviewPlain(trimmed);
      return Text(
        preview,
        style: theme.textTheme.bodySmall,
        maxLines: maxPreviewLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Full view (detail screens): render markdown.
    final style = MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: theme.textTheme.bodyMedium,
      listBullet: theme.textTheme.bodyMedium,
      listIndent: 24,
      h1: theme.textTheme.titleLarge,
      h2: theme.textTheme.titleMedium,
      h3: theme.textTheme.titleSmall,
      code: theme.textTheme.bodyMedium?.copyWith(
        fontFamily: 'monospace',
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
      ),
    );

    return MarkdownBody(
      data: trimmed,
      selectable: false,
      styleSheet: style,
      softLineBreak: true,
      onTapLink: (_, __, ___) {},
    );
  }
}
