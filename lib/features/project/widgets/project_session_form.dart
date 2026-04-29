import 'package:flutter/material.dart';

import '../../../core/models/project.dart';
import '../../../util/string_constant.dart';

class ProjectSessionForm extends StatefulWidget {
  final Project project;
  final Future<void> Function(String whatDone, String whatLearnt) onSave;

  const ProjectSessionForm({
    super.key,
    required this.project,
    required this.onSave,
  });

  @override
  State<ProjectSessionForm> createState() => _ProjectSessionFormState();
}

class _ProjectSessionFormState extends State<ProjectSessionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _whatDoneCtrl;
  late final TextEditingController _whatLearntCtrl;

  @override
  void initState() {
    super.initState();
    _whatDoneCtrl = TextEditingController();
    _whatLearntCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _whatDoneCtrl.dispose();
    _whatLearntCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await widget.onSave(_whatDoneCtrl.text.trim(), _whatLearntCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.logSessionTitle(widget.project.name),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _whatLearntCtrl,
                  decoration: const InputDecoration(
                    labelText: AppStrings.whatDidYouLearn,
                    hintText: AppStrings.keyTakeaways,
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.save),
                    label: const Text(AppStrings.saveSession),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
