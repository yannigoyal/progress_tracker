import 'package:flutter/material.dart';

import '../../../util/string_constant.dart';

/// Preset + user tags with add-new flow (Learning and custom activity forms).
class TagsInputField extends StatefulWidget {
  final List<String> presetTags;
  final List<String> userTags;
  final Set<String> selectedTags;
  final ValueChanged<Set<String>> onSelectedChanged;
  final Future<void> Function(String tag) onAddUserTag;
  final Future<void> Function(String tag)? onRemoveUserTag;
  final Color? chipColor;

  const TagsInputField({
    super.key,
    required this.presetTags,
    required this.userTags,
    required this.selectedTags,
    required this.onSelectedChanged,
    required this.onAddUserTag,
    this.onRemoveUserTag,
    this.chipColor,
  });

  @override
  State<TagsInputField> createState() => _TagsInputFieldState();
}

class _TagsInputFieldState extends State<TagsInputField> {
  final _tagCtrl = TextEditingController();

  @override
  void dispose() {
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _addTag() async {
    final tag = _tagCtrl.text.trim();
    if (tag.isEmpty) return;
    await widget.onAddUserTag(tag);
    _tagCtrl.clear();
    final next = Set<String>.from(widget.selectedTags)..add(tag);
    widget.onSelectedChanged(next);
  }

  List<String> get _allTags {
    final seen = <String>{};
    final out = <String>[];
    for (final t in [...widget.presetTags, ...widget.userTags]) {
      final key = t.toLowerCase();
      if (seen.add(key)) out.add(t);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final chipColor = widget.chipColor ?? Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.tags, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _allTags.map((tag) {
            final selected = widget.selectedTags.contains(tag);
            final isUser = widget.userTags.any(
              (t) => t.toLowerCase() == tag.toLowerCase(),
            );
            if (isUser && widget.onRemoveUserTag != null) {
              return InputChip(
                label: Text(tag),
                selected: selected,
                onSelected: (_) {
                  final next = Set<String>.from(widget.selectedTags);
                  selected ? next.remove(tag) : next.add(tag);
                  widget.onSelectedChanged(next);
                },
                onDeleted: () async {
                  await widget.onRemoveUserTag!(tag);
                  final next = Set<String>.from(widget.selectedTags)..remove(tag);
                  widget.onSelectedChanged(next);
                  if (mounted) setState(() {});
                },
              );
            }
            return FilterChip(
              label: Text(tag),
              selected: selected,
              selectedColor: chipColor.withAlpha(40),
              checkmarkColor: chipColor,
              onSelected: (_) {
                final next = Set<String>.from(widget.selectedTags);
                selected ? next.remove(tag) : next.add(tag);
                widget.onSelectedChanged(next);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.learningAddTag,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagCtrl,
                decoration: const InputDecoration(
                  labelText: AppStrings.addTagHint,
                  isDense: true,
                ),
                textCapitalization: TextCapitalization.words,
                onSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _addTag,
              child: const Text(AppStrings.addTag),
            ),
          ],
        ),
      ],
    );
  }
}
