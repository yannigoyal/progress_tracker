import 'package:flutter/material.dart';

import '../../../../core/models/category.dart';
import '../../../../core/models/log_entry.dart';
import 'form_shell.dart';

class ContentForm extends StatefulWidget {
  final void Function(LogEntry) onSave;
  final LogEntry? existingLog;

  const ContentForm({super.key, required this.onSave, this.existingLog});

  @override
  State<ContentForm> createState() => _ContentFormState();
}

class _ContentFormState extends State<ContentForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  String _platform = 'YouTube';
  String _status = 'Scripted';

  static const _platforms = ['YouTube', 'Shorts', 'Instagram', 'LinkedIn', 'Other'];
  static const _statuses = ['Scripted', 'Recorded', 'Edited', 'Uploaded'];

  @override
  void initState() {
    super.initState();
    final p = widget.existingLog?.payload ?? {};
    _titleCtrl = TextEditingController(text: p['title'] as String? ?? '');
    if (p['platform'] != null && _platforms.contains(p['platform'])) {
      _platform = p['platform'] as String;
    }
    if (p['status'] != null && _statuses.contains(p['status'])) {
      _status = p['status'] as String;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final entry = (widget.existingLog ?? LogEntry())
      ..category = Category.content
      ..createdAt = widget.existingLog?.createdAt ?? DateTime.now().toUtc()
      ..payload = {
        'platform': _platform,
        'title': _titleCtrl.text.trim(),
        'status': _status,
      };
    widget.onSave(entry);
  }

  @override
  Widget build(BuildContext context) {
    return FormShell(
      title: 'Content Creation',
      category: Category.content,
      onSave: _submit,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _platform,
              decoration: const InputDecoration(labelText: 'Platform'),
              isExpanded: true,
              items: _platforms
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _platform = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title / Topic *'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Text('Progress', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _statuses.map((s) {
                final selected = _status == s;
                return ChoiceChip(
                  label: Text(s),
                  selected: selected,
                  selectedColor: Category.content.color.withAlpha(40),
                  onSelected: (_) => setState(() => _status = s),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
