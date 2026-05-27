import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../../../core/models/category.dart';
import '../../../../core/models/log_entry.dart';
import '../../../../shared/widgets/formatted_note_field.dart';
import '../../../../util/string_constant.dart';
import '../../../project/providers/project_provider.dart';
import 'form_shell.dart';

class ProjectForm extends ConsumerStatefulWidget {
  final void Function(LogEntry) onSave;
  final LogEntry? existingLog;

  const ProjectForm({super.key, required this.onSave, this.existingLog});

  @override
  ConsumerState<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends ConsumerState<ProjectForm> {
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
    final projectSuggestions =
        ref
            .watch(projectsProvider)
            .valueOrNull
            ?.map((project) => project.name)
            .toList() ??
        const <String>[];

    return FormShell(
      title: AppStrings.projectFormTitle,
      category: Category.project,
      onSave: _submit,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TypeAheadField<String>(
              controller: _projectCtrl,
              direction: VerticalDirection.down,
              debounceDuration: Duration.zero,
              hideOnEmpty: true,
              constraints: const BoxConstraints(maxHeight: 220),
              suggestionsCallback: (pattern) {
                return _filterSuggestions(projectSuggestions, pattern);
              },
              builder: (context, controller, focusNode) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: AppStrings.projectName,
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? AppStrings.requiredField
                      : null,
                );
              },
              itemBuilder: (context, projectName) {
                return ListTile(
                  dense: true,
                  title: Text(
                    projectName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
              onSelected: _selectProject,
              decorationBuilder: _buildSuggestionsDecoration,
            ),
            const SizedBox(height: 12),
            FormattedNoteField(
              controller: _whatDoneCtrl,
              decoration: const InputDecoration(
                labelText: AppStrings.whatDidYouDo,
                hintText: AppStrings.describeYourProgress,
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (v) => v == null || v.trim().isEmpty
                  ? AppStrings.requiredField
                  : null,
            ),
            const SizedBox(height: 12),
            FormattedNoteField(
              controller: _whatLearntCtrl,
              decoration: const InputDecoration(
                labelText: AppStrings.whatDidYouLearn,
                hintText: AppStrings.keyTakeaways,
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  List<String> _filterSuggestions(List<String> suggestions, String pattern) {
    final query = pattern.trim().toLowerCase();
    if (query.isEmpty) return const <String>[];

    return suggestions
        .where((suggestion) => suggestion.toLowerCase().contains(query))
        .take(8)
        .toList(growable: false);
  }

  void _selectProject(String projectName) {
    _projectCtrl.text = projectName;
    _projectCtrl.selection = TextSelection.collapsed(
      offset: projectName.length,
    );
  }

  Widget _buildSuggestionsDecoration(BuildContext context, Widget child) {
    return Material(
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
