import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/models/category.dart';
import '../../../../core/models/log_entry.dart';
import 'form_shell.dart';

class ReadingForm extends StatefulWidget {
  final void Function(LogEntry) onSave;
  final LogEntry? existingLog;

  const ReadingForm({super.key, required this.onSave, this.existingLog});

  @override
  State<ReadingForm> createState() => _ReadingFormState();
}

class _ReadingFormState extends State<ReadingForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bookCtrl;
  late final TextEditingController _pagesCtrl;
  late final TextEditingController _quoteCtrl;

  @override
  void initState() {
    super.initState();
    final p = widget.existingLog?.payload ?? {};
    _bookCtrl = TextEditingController(text: p['bookName'] as String? ?? '');
    _pagesCtrl = TextEditingController(
        text: p['pagesRead']?.toString() ?? '');
    _quoteCtrl = TextEditingController(text: p['quote'] as String? ?? '');
  }

  @override
  void dispose() {
    _bookCtrl.dispose();
    _pagesCtrl.dispose();
    _quoteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final entry = (widget.existingLog ?? LogEntry())
      ..category = Category.reading
      ..createdAt = widget.existingLog?.createdAt ?? DateTime.now().toUtc()
      ..payload = {
        'bookName': _bookCtrl.text.trim(),
        'pagesRead': int.tryParse(_pagesCtrl.text.trim()) ?? 0,
        if (_quoteCtrl.text.trim().isNotEmpty) 'quote': _quoteCtrl.text.trim(),
      };
    widget.onSave(entry);
  }

  @override
  Widget build(BuildContext context) {
    return FormShell(
      title: 'Reading',
      category: Category.reading,
      onSave: _submit,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _bookCtrl,
              decoration: const InputDecoration(labelText: 'Book Name *'),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pagesCtrl,
              decoration: const InputDecoration(labelText: 'Pages Read *'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _quoteCtrl,
              decoration: const InputDecoration(
                labelText: 'Key takeaway or quote (optional)',
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
    );
  }
}
