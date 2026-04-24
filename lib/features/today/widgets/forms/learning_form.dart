import 'package:flutter/material.dart';

import '../../../../core/models/category.dart';
import '../../../../core/models/log_entry.dart';
import 'form_shell.dart';

class LearningForm extends StatefulWidget {
  final void Function(LogEntry) onSave;
  final LogEntry? existingLog;

  const LearningForm({super.key, required this.onSave, this.existingLog});

  @override
  State<LearningForm> createState() => _LearningFormState();
}

class _LearningFormState extends State<LearningForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _noteCtrl;
  late final Set<String> _selectedTags;

  static const _availableTags = [
    'Flutter', 'Dart', 'DSA', 'AI', 'Web3', 'Backend',
    'System Design', 'DevOps', 'iOS', 'Android', 'Web', 'Math',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.existingLog?.payload ?? {};
    _noteCtrl = TextEditingController(text: p['note'] as String? ?? '');
    _selectedTags = Set<String>.from(
        (p['tags'] as List?)?.cast<String>() ?? []);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final entry = (widget.existingLog ?? LogEntry())
      ..category = Category.learning
      ..createdAt = widget.existingLog?.createdAt ?? DateTime.now().toUtc()
      ..payload = {
        'note': _noteCtrl.text.trim(),
        'tags': _selectedTags.toList(),
      };
    widget.onSave(entry);
  }

  @override
  Widget build(BuildContext context) {
    return FormShell(
      title: 'Learning',
      category: Category.learning,
      onSave: _submit,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'What did you learn? *',
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Text('Tags', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _availableTags.map((tag) {
                final selected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: selected,
                  selectedColor: Category.learning.color.withAlpha(40),
                  checkmarkColor: Category.learning.color,
                  onSelected: (_) => setState(() {
                    selected
                        ? _selectedTags.remove(tag)
                        : _selectedTags.add(tag);
                  }),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
