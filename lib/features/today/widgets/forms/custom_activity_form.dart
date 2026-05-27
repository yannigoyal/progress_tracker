import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/category.dart';
import '../../../../core/models/custom_activity.dart';
import '../../../../core/models/log_entry.dart';
import '../../../../core/models/log_field_kind.dart';
import '../../../../shared/widgets/formatted_note_field.dart';
import '../../../../util/string_constant.dart';
import '../../data/learning_tags_store.dart';
import '../activity_icon.dart';
import '../tags_input_field.dart';
import 'form_shell.dart';

final _tagsStoreProvider = Provider((ref) => LearningTagsStore());

class CustomActivityForm extends ConsumerStatefulWidget {
  final CustomActivity activity;
  final void Function(LogEntry) onSave;
  final LogEntry? existingLog;

  const CustomActivityForm({
    super.key,
    required this.activity,
    required this.onSave,
    this.existingLog,
  });

  @override
  ConsumerState<CustomActivityForm> createState() => _CustomActivityFormState();
}

class _CustomActivityFormState extends ConsumerState<CustomActivityForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _noteCtrl;
  late final TextEditingController _numberCtrl;
  late final TextEditingController _durationCtrl;
  late Set<String> _selectedTags;
  List<String> _userTags = [];

  Set<String> get _fields => widget.activity.enabledFields.toSet();

  @override
  void initState() {
    super.initState();
    final p = widget.existingLog?.payload ?? {};
    _titleCtrl = TextEditingController(text: p['title'] as String? ?? '');
    _noteCtrl = TextEditingController(text: p['note'] as String? ?? '');
    _numberCtrl = TextEditingController(
      text: p['number']?.toString() ?? '',
    );
    _durationCtrl = TextEditingController(
      text: p['durationMinutes']?.toString() ?? '',
    );
    _selectedTags = Set<String>.from(
      (p['tags'] as List?)?.cast<String>() ?? [],
    );
    if (_fields.contains(LogFieldKind.tags)) _loadUserTags();
  }

  Future<void> _loadUserTags() async {
    final tags = await ref.read(_tagsStoreProvider).loadUserTags();
    if (mounted) setState(() => _userTags = tags);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    _numberCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  bool _validateEnabledFields() {
    if (_fields.contains(LogFieldKind.note) &&
        !_fields.contains(LogFieldKind.title) &&
        !_fields.contains(LogFieldKind.number) &&
        !_fields.contains(LogFieldKind.duration) &&
        !_fields.contains(LogFieldKind.tags)) {
      if (_noteCtrl.text.trim().isEmpty) return false;
    }
    return true;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateEnabledFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.requiredField)),
      );
      return;
    }

    final payload = <String, dynamic>{
      'customActivityId': widget.activity.id,
      'customActivityName': widget.activity.name,
    };

    if (_fields.contains(LogFieldKind.title)) {
      payload['title'] = _titleCtrl.text.trim();
    }
    if (_fields.contains(LogFieldKind.note)) {
      final note = _noteCtrl.text.trim();
      if (note.isNotEmpty) payload['note'] = note;
    }
    if (_fields.contains(LogFieldKind.number)) {
      final n = int.tryParse(_numberCtrl.text.trim());
      if (n != null) payload['number'] = n;
    }
    if (_fields.contains(LogFieldKind.duration)) {
      final d = int.tryParse(_durationCtrl.text.trim());
      if (d != null) payload['durationMinutes'] = d;
    }
    if (_fields.contains(LogFieldKind.tags)) {
      payload['tags'] = _selectedTags.toList();
    }

    final entry = (widget.existingLog ?? LogEntry())
      ..category = Category.custom
      ..createdAt = widget.existingLog?.createdAt ?? DateTime.now().toUtc()
      ..payload = payload;
    widget.onSave(entry);
  }

  String _label(String kind) => widget.activity.fieldLabels.labelFor(kind);

  @override
  Widget build(BuildContext context) {
    final onlyNote = _fields.length == 1 && _fields.contains(LogFieldKind.note);

    return FormShell(
      title: widget.activity.name,
      category: Category.custom,
      leading: ActivityIcon(activity: widget.activity, size: 20),
      onSave: _submit,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_fields.contains(LogFieldKind.title))
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(labelText: _label(LogFieldKind.title)),
                textCapitalization: TextCapitalization.words,
              ),
            if (_fields.contains(LogFieldKind.title) &&
                _fields.contains(LogFieldKind.note))
              const SizedBox(height: 12),
            if (_fields.contains(LogFieldKind.note))
              FormattedNoteField(
                controller: _noteCtrl,
                decoration: InputDecoration(
                  labelText: _label(LogFieldKind.note),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: onlyNote
                    ? (v) => v == null || v.trim().isEmpty
                        ? AppStrings.requiredField
                        : null
                    : null,
              ),
            if (_fields.contains(LogFieldKind.number)) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _numberCtrl,
                decoration: InputDecoration(
                  labelText: _label(LogFieldKind.number),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
            if (_fields.contains(LogFieldKind.duration)) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _durationCtrl,
                decoration: InputDecoration(
                  labelText: _label(LogFieldKind.duration),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
            if (_fields.contains(LogFieldKind.tags)) ...[
              const SizedBox(height: 16),
              TagsInputField(
                presetTags: AppStrings.learningTags,
                userTags: _userTags,
                selectedTags: _selectedTags,
                chipColor: widget.activity.color,
                onSelectedChanged: (tags) => setState(() {
                  _selectedTags
                    ..clear()
                    ..addAll(tags);
                }),
                onAddUserTag: (tag) async {
                  await ref.read(_tagsStoreProvider).addTag(tag);
                  await _loadUserTags();
                },
                onRemoveUserTag: (tag) async {
                  await ref.read(_tagsStoreProvider).removeTag(tag);
                  await _loadUserTags();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
