import 'package:flutter/material.dart';

import '../../util/string_constant.dart';
import '../../util/text_format_actions.dart';

class FormattedNoteField extends StatelessWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const FormattedNoteField({
    super.key,
    required this.controller,
    required this.decoration,
    required this.maxLines,
    this.textCapitalization = TextCapitalization.sentences,
    this.keyboardType,
    this.validator,
  });

  void _apply(TextEditingValue Function(TextEditingValue) transform) {
    final next = transform(controller.value);
    controller.value = next;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.onSurfaceVariant;

    Widget tool(IconData icon, String tooltip, VoidCallback onPressed) {
      return IconButton(
        visualDensity: VisualDensity.compact,
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: iconColor),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 2,
          runSpacing: 2,
          children: [
            tool(
              Icons.format_list_bulleted,
              AppStrings.formatBullets,
              () => _apply(
                (v) => prefixSelectedLines(v, prefix: '- '),
              ),
            ),
            tool(
              Icons.format_list_numbered,
              AppStrings.formatNumberedList,
              () => _apply(
                (v) => prefixSelectedLines(v, prefix: '', numbered: true),
              ),
            ),
            tool(
              Icons.check_box_outlined,
              AppStrings.formatCheckbox,
              () => _apply(
                (v) => prefixSelectedLines(v, prefix: '- [ ] '),
              ),
            ),
            const SizedBox(width: 8),
            tool(
              Icons.format_bold,
              AppStrings.formatBold,
              () => _apply((v) => wrapSelection(v, left: '**', right: '**')),
            ),
            tool(
              Icons.format_italic,
              AppStrings.formatItalic,
              () => _apply((v) => wrapSelection(v, left: '*', right: '*')),
            ),
            tool(
              Icons.format_strikethrough,
              AppStrings.formatStrikethrough,
              () => _apply((v) => wrapSelection(v, left: '~~', right: '~~')),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: decoration,
          maxLines: maxLines,
          textCapitalization: textCapitalization,
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }
}

