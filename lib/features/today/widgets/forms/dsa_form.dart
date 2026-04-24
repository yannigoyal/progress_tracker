import 'package:flutter/material.dart';

import '../../../../core/models/category.dart';
import '../../../../core/models/log_entry.dart';
import '../../../../util/string_constant.dart';
import 'form_shell.dart';

class DsaForm extends StatefulWidget {
  final void Function(LogEntry) onSave;
  final LogEntry? existingLog;

  const DsaForm({super.key, required this.onSave, this.existingLog});

  @override
  State<DsaForm> createState() => _DsaFormState();
}

class _DsaFormState extends State<DsaForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _numCtrl;
  late final TextEditingController _nameCtrl;
  String _topic = AppStrings.dsaTopicDp;
  String _approach = AppStrings.dsaApproachMemoization;
  bool _isSolved = true;

  static const _topics = [...AppStrings.dsaTopics];
  static const _approaches = [...AppStrings.dsaApproaches];

  @override
  void initState() {
    super.initState();
    final p = widget.existingLog?.payload ?? {};
    _numCtrl = TextEditingController(
      text: p['problemNumber']?.toString() ?? '',
    );
    _nameCtrl = TextEditingController(text: p['problemName'] as String? ?? '');
    if (p['topic'] != null && _topics.contains(p['topic'])) {
      _topic = p['topic'] as String;
    }
    if (p['approach'] != null && _approaches.contains(p['approach'])) {
      _approach = p['approach'] as String;
    }
    if (p['status'] != null) {
      _isSolved = p['status'] == AppStrings.solved;
    }
  }

  @override
  void dispose() {
    _numCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final entry = (widget.existingLog ?? LogEntry())
      ..category = Category.dsa
      ..createdAt = widget.existingLog?.createdAt ?? DateTime.now().toUtc()
      ..payload = {
        if (_numCtrl.text.trim().isNotEmpty)
          'problemNumber': int.tryParse(_numCtrl.text.trim()),
        'problemName': _nameCtrl.text.trim(),
        'topic': _topic,
        'approach': _approach,
        'status': _isSolved ? AppStrings.solved : AppStrings.revised,
      };
    widget.onSave(entry);
  }

  @override
  Widget build(BuildContext context) {
    return FormShell(
      title: AppStrings.dsaFormTitle,
      category: Category.dsa,
      onSave: _submit,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _numCtrl,
              decoration: const InputDecoration(
                labelText: AppStrings.leetCodeOptional,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: AppStrings.problemNameRequired,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty
                  ? AppStrings.requiredField
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _topic,
              decoration: const InputDecoration(labelText: AppStrings.topic),
              isExpanded: true,
              items: _topics
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _topic = v!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _approach,
              decoration: const InputDecoration(labelText: AppStrings.approach),
              isExpanded: true,
              items: _approaches
                  .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                  .toList(),
              onChanged: (v) => setState(() => _approach = v!),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.status,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _isSolved
                    ? AppStrings.solvedStatusLabel
                    : AppStrings.revisedStatusLabel,
              ),
              subtitle: Text(
                _isSolved
                    ? AppStrings.trackerSolvedSubtitle
                    : AppStrings.trackerRevisionSubtitle,
              ),
              value: _isSolved,
              onChanged: (value) => setState(() => _isSolved = value),
            ),
          ],
        ),
      ),
    );
  }
}
