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
  late int _counterValue;
  bool _numberManualEdit = false;

  bool get _useNumberCounter =>
      widget.activity.numberUseCounter &&
      _fields.contains(LogFieldKind.number);

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
    _counterValue = int.tryParse(p['number']?.toString() ?? '') ?? 0;
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
      final n = _useNumberCounter && !_numberManualEdit
          ? _counterValue
          : int.tryParse(_numberCtrl.text.trim());
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
              if (_useNumberCounter && !_numberManualEdit)
                _NumberCounterField(
                  label: _label(LogFieldKind.number),
                  value: _counterValue,
                  onChanged: (v) => setState(() {
                    _counterValue = v;
                    _numberCtrl.text = v.toString();
                  }),
                  onTypeManually: () => setState(() {
                    _numberManualEdit = true;
                    _numberCtrl.text = _counterValue.toString();
                  }),
                )
              else ...[
                TextFormField(
                  controller: _numberCtrl,
                  decoration: InputDecoration(
                    labelText: _label(LogFieldKind.number),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) {
                    _counterValue = int.tryParse(v.trim()) ?? _counterValue;
                  },
                ),
                if (_useNumberCounter)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => setState(() {
                        _numberManualEdit = false;
                        _counterValue =
                            int.tryParse(_numberCtrl.text.trim()) ??
                            _counterValue;
                        _numberCtrl.text = _counterValue.toString();
                      }),
                      child: const Text(AppStrings.useCounter),
                    ),
                  ),
              ],
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

class _NumberCounterField extends StatelessWidget {
  const _NumberCounterField({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.onTypeManually,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final VoidCallback onTypeManually;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove),
            ),
            Expanded(
              child: InkWell(
                onTap: onTypeManually,
                borderRadius: BorderRadius.circular(8),
                child: Center(
                  child: Text(
                    '$value',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
            ),
            IconButton.filledTonal(
              onPressed: () => onChanged(value + 1),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onTypeManually,
            child: const Text(AppStrings.typeManually),
          ),
        ),
      ],
    );
  }
}
