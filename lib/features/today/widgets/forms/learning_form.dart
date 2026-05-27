import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/category.dart';
import '../../../../core/models/log_entry.dart';
import '../../../../util/string_constant.dart';
import '../../../../shared/widgets/formatted_note_field.dart';
import '../../data/learning_tags_store.dart';
import '../tags_input_field.dart';
import 'form_shell.dart';

final _learningTagsStoreProvider = Provider((ref) => LearningTagsStore());

class LearningForm extends ConsumerStatefulWidget {
  final void Function(LogEntry) onSave;
  final LogEntry? existingLog;

  const LearningForm({super.key, required this.onSave, this.existingLog});

  @override
  ConsumerState<LearningForm> createState() => _LearningFormState();
}

class _LearningFormState extends ConsumerState<LearningForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _noteCtrl;
  late final Set<String> _selectedTags;
  List<String> _userTags = [];

  @override
  void initState() {
    super.initState();
    final p = widget.existingLog?.payload ?? {};
    _noteCtrl = TextEditingController(text: p['note'] as String? ?? '');
    _selectedTags = Set<String>.from(
      (p['tags'] as List?)?.cast<String>() ?? [],
    );
    _loadUserTags();
  }

  Future<void> _loadUserTags() async {
    final tags = await ref.read(_learningTagsStoreProvider).loadUserTags();
    if (mounted) setState(() => _userTags = tags);
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
      title: AppStrings.learningFormTitle,
      category: Category.learning,
      onSave: _submit,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormattedNoteField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: AppStrings.whatDidYouLearnRequired,
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (v) => v == null || v.trim().isEmpty
                  ? AppStrings.requiredField
                  : null,
            ),
            const SizedBox(height: 16),
            TagsInputField(
              presetTags: AppStrings.learningTags,
              userTags: _userTags,
              selectedTags: _selectedTags,
              chipColor: Category.learning.color(context),
              onSelectedChanged: (tags) => setState(() {
                _selectedTags
                  ..clear()
                  ..addAll(tags);
              }),
              onAddUserTag: (tag) async {
                await ref.read(_learningTagsStoreProvider).addTag(tag);
                await _loadUserTags();
              },
              onRemoveUserTag: (tag) async {
                await ref.read(_learningTagsStoreProvider).removeTag(tag);
                await _loadUserTags();
              },
            ),
          ],
        ),
      ),
    );
  }
}
