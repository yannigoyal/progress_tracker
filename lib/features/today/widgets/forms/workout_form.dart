import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/models/category.dart';
import '../../../../core/models/log_entry.dart';
import 'form_shell.dart';

class WorkoutForm extends StatefulWidget {
  final void Function(LogEntry) onSave;
  final LogEntry? existingLog;

  const WorkoutForm({super.key, required this.onSave, this.existingLog});

  @override
  State<WorkoutForm> createState() => _WorkoutFormState();
}

class _WorkoutFormState extends State<WorkoutForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _countCtrl;
  late final TextEditingController _setsCtrl;
  late final TextEditingController _customExerciseCtrl;
  String _exercise = 'Pushups';
  bool _useCustom = false;

  static const _exercises = [
    'Pushups', 'Plank', 'Squats', 'Pull-ups', 'Dips',
    'Lunges', 'Burpees', 'Sit-ups', 'Mountain Climbers', 'Other…',
  ];

  bool get _isTimeBased => _exercise == 'Plank' || _exercise == 'Wall Sit';

  @override
  void initState() {
    super.initState();
    final p = widget.existingLog?.payload ?? {};
    final ex = p['exercise'] as String? ?? 'Pushups';
    _exercise = _exercises.contains(ex) ? ex : 'Other…';
    _customExerciseCtrl = TextEditingController(
        text: _exercises.contains(ex) ? '' : ex);
    _useCustom = !_exercises.contains(ex);
    _countCtrl = TextEditingController(
        text: (p['count'] ?? p['duration'])?.toString() ?? '');
    _setsCtrl = TextEditingController(text: p['sets']?.toString() ?? '3');
  }

  @override
  void dispose() {
    _countCtrl.dispose();
    _setsCtrl.dispose();
    _customExerciseCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final exerciseName =
        _useCustom ? _customExerciseCtrl.text.trim() : _exercise;
    final val = int.tryParse(_countCtrl.text.trim()) ?? 0;
    final sets = int.tryParse(_setsCtrl.text.trim()) ?? 1;
    final entry = (widget.existingLog ?? LogEntry())
      ..category = Category.workout
      ..createdAt = widget.existingLog?.createdAt ?? DateTime.now().toUtc()
      ..payload = {
        'exercise': exerciseName,
        if (_isTimeBased) 'duration': val else 'count': val,
        'sets': sets,
      };
    widget.onSave(entry);
  }

  @override
  Widget build(BuildContext context) {
    return FormShell(
      title: 'Workout',
      category: Category.workout,
      onSave: _submit,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _exercise,
              decoration: const InputDecoration(labelText: 'Exercise'),
              isExpanded: true,
              items: _exercises
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() {
                _exercise = v!;
                _useCustom = v == 'Other…';
              }),
            ),
            if (_useCustom) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _customExerciseCtrl,
                decoration:
                    const InputDecoration(labelText: 'Exercise name *'),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _countCtrl,
                    decoration: InputDecoration(
                      labelText: _isTimeBased
                          ? 'Duration (seconds) *'
                          : 'Count / Reps *',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _setsCtrl,
                    decoration: const InputDecoration(labelText: 'Sets'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
