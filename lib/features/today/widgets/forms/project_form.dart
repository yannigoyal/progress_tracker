import 'package:flutter/material.dart';

import '../../../../core/models/category.dart';
import '../../../../core/models/log_entry.dart';
import '../../../../util/string_constant.dart';
import 'form_shell.dart';

class ProjectForm extends StatefulWidget {
  final void Function(LogEntry) onSave;
  final LogEntry? existingLog;

  const ProjectForm({super.key, required this.onSave, this.existingLog});

  @override
  State<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<ProjectForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _projectCtrl;
  late final TextEditingController _whatDoneCtrl;
  late final TextEditingController _whatLearntCtrl;

  @override
  void initState() {
    super.initState();
    final p = widget.existingLog?.payload ?? {};
    _projectCtrl = TextEditingController(
      text: p['projectName'] as String? ?? '',
    );
    _whatDoneCtrl = TextEditingController(text: p['whatDone'] as String? ?? '');
    _whatLearntCtrl = TextEditingController(
      text: p['whatLearnt'] as String? ?? '',
    );
  }

  @override
  void dispose() {
    _projectCtrl.dispose();
    _whatDoneCtrl.dispose();
    _whatLearntCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final entry = (widget.existingLog ?? LogEntry())
      ..category = Category.project
      ..createdAt = widget.existingLog?.createdAt ?? DateTime.now().toUtc()
      ..payload = {
        'projectName': _projectCtrl.text.trim(),
        'whatDone': _whatDoneCtrl.text.trim(),
        'whatLearnt': _whatLearntCtrl.text.trim(),
      };
    widget.onSave(entry);
  }

  @override
  Widget build(BuildContext context) {
    return FormShell(
      title: AppStrings.projectFormTitle,
      category: Category.project,
      onSave: _submit,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _projectCtrl,
              decoration: const InputDecoration(
                labelText: AppStrings.projectName,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty
                  ? AppStrings.requiredField
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _whatDoneCtrl,
              decoration: const InputDecoration(
                labelText: AppStrings.whatDidYouDo,
                hintText: AppStrings.describeYourProgress,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => v == null || v.trim().isEmpty
                  ? AppStrings.requiredField
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _whatLearntCtrl,
              decoration: const InputDecoration(
                labelText: AppStrings.whatDidYouLearn,
                hintText: AppStrings.keyTakeaways,
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
