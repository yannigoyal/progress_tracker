import 'package:flutter/material.dart';

import '../../../../core/models/category.dart';
import '../../../../core/models/log_entry.dart';
import '../../../../shared/widgets/formatted_note_field.dart';
import '../../../../util/string_constant.dart';
import 'form_shell.dart';

class MiscForm extends StatefulWidget {
  final void Function(LogEntry) onSave;
  final LogEntry? existingLog;

  const MiscForm({super.key, required this.onSave, this.existingLog});

  @override
  State<MiscForm> createState() => _MiscFormState();
}

class _MiscFormState extends State<MiscForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    final p = widget.existingLog?.payload ?? {};
    _titleCtrl = TextEditingController(text: p['title'] as String? ?? '');
    _noteCtrl = TextEditingController(text: p['note'] as String? ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final note = _noteCtrl.text.trim();
    final entry = (widget.existingLog ?? LogEntry())
      ..category = Category.misc
      ..createdAt = widget.existingLog?.createdAt ?? DateTime.now().toUtc()
      ..payload = {
        'title': _titleCtrl.text.trim(),
        if (note.isNotEmpty) 'note': note,
        if (widget.existingLog?.payload['kind'] != null)
          'kind': widget.existingLog!.payload['kind'],
      };
    widget.onSave(entry);
  }

  @override
  Widget build(BuildContext context) {
    return FormShell(
      title: AppStrings.miscFormTitle,
      category: Category.misc,
      onSave: _submit,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: AppStrings.titleRequired,
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofocus: true,
              validator: (v) => v == null || v.trim().isEmpty
                  ? AppStrings.requiredField
                  : null,
            ),
            const SizedBox(height: 12),
            FormattedNoteField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: AppStrings.whatsOnYourMindOptional,
                alignLabelWithHint: true,
              ),
              maxLines: 7,
            ),
          ],
        ),
      ),
    );
  }
}
