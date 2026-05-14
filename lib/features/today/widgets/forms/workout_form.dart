import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/models/category.dart';
import '../../../../core/models/log_entry.dart';
import '../../../../util/string_constant.dart';
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
  int _durationSeconds = 30;
  String? _exercise;
  bool _useCustom = false;
  bool? _wentToGym;

  static const _exercises = [...AppStrings.workoutExercises];

  bool get _isTimeBased =>
      _exercise == AppStrings.workoutPlank ||
      _exercise == AppStrings.workoutWallSit;

  @override
  void initState() {
    super.initState();
    final p = widget.existingLog?.payload ?? {};
    final ex = p['exercise'] as String?;
    if (ex == null) {
      _exercise = null;
      _customExerciseCtrl = TextEditingController(text: '');
      _useCustom = false;
    } else if (_exercises.contains(ex)) {
      _exercise = ex;
      _customExerciseCtrl = TextEditingController(text: '');
      _useCustom = ex == AppStrings.otherEllipsis;
    } else {
      _exercise = null;
      _customExerciseCtrl = TextEditingController(text: ex);
      _useCustom = true;
    }
    // initialize count/duration
    final countOrDuration = p['count'] ?? p['duration'];
    if (_isTimeBased) {
      _durationSeconds = (p['duration'] is int)
          ? (p['duration'] as int)
          : (int.tryParse(countOrDuration?.toString() ?? '') ?? 30);
    }
    _countCtrl = TextEditingController(
      text: !_isTimeBased ? (countOrDuration?.toString() ?? '') : '',
    );
    _setsCtrl = TextEditingController(text: p['sets']?.toString() ?? '0');
    _wentToGym = p['wentToGym'] as bool?;
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

    final went = _wentToGym ?? false;
    final exerciseName = _useCustom
        ? _customExerciseCtrl.text.trim()
        : (_exercise ?? '');

    if (_isTimeBased && _durationSeconds <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set a duration greater than 0')),
      );
      return;
    }

    final int? val = !_isTimeBased
        ? (int.tryParse(_countCtrl.text.trim()) ?? null)
        : _durationSeconds;
    final sets = int.tryParse(_setsCtrl.text.trim()) ?? 0;

    final entry = (widget.existingLog ?? LogEntry())
      ..category = Category.workout
      ..createdAt = widget.existingLog?.createdAt ?? DateTime.now().toUtc();

    final payload = <String, dynamic>{'wentToGym': went, 'sets': sets};
    if (went && exerciseName.isNotEmpty) {
      payload['exercise'] = exerciseName;
      if (_isTimeBased) payload['duration'] = val;
      if (!_isTimeBased && val != null) payload['count'] = val;
    }

    entry.payload = payload;
    widget.onSave(entry);

    final summary = <String>[];
    if (payload['exercise'] != null) summary.add('${payload['exercise']}');
    summary.add('sets: ${payload['sets'] ?? 0}');
    if (payload['count'] != null) summary.add('count: ${payload['count']}');
    if (payload['duration'] != null)
      summary.add('duration: ${payload['duration']}s');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Workout saved: ${summary.join(' • ')}'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            final hasDetails =
                payload['exercise'] != null ||
                payload['count'] != null ||
                payload['duration'] != null ||
                ((payload['sets'] is int) && payload['sets'] > 0);
            final subtitle = hasDetails
                ? summary.join(' • ')
                : (payload['wentToGym'] == true ? 'No exercise logged' : '');

            showModalBottomSheet(
              context: context,
              builder: (_) => Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Category.workout.color(context),
                    child: Icon(
                      Category.workout.icon,
                      color: Category.workout.surfaceColor(context),
                    ),
                  ),
                  title: Text(
                    payload['exercise'] ?? AppStrings.workoutFormTitle,
                  ),
                  subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormShell(
      title: AppStrings.workoutFormTitle,
      category: Category.workout,
      onSave: _submit,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormField<bool>(
              initialValue: _wentToGym,
              validator: (v) => v == null ? AppStrings.requiredField : null,
              builder: (field) {
                final theme = Theme.of(context);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      'Did you go to the gym today?',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            value: true,
                            groupValue: field.value,
                            title: const Text('Yes'),
                            contentPadding: EdgeInsets.zero,
                            onChanged: (v) => setState(() {
                              _wentToGym = v;
                              field.didChange(v);
                            }),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            value: false,
                            groupValue: field.value,
                            title: const Text('No'),
                            contentPadding: EdgeInsets.zero,
                            onChanged: (v) => setState(() {
                              _wentToGym = v;
                              field.didChange(v);
                            }),
                          ),
                        ),
                      ],
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 4),
                        child: Text(
                          field.errorText!,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            if (_wentToGym == true) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _exercise,
                hint: const Text('Select exercise'),
                decoration: const InputDecoration(
                  labelText: AppStrings.exercise,
                ),
                isExpanded: true,
                items: _exercises
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() {
                  _exercise = v;
                  _useCustom = v == AppStrings.otherEllipsis;
                }),
              ),
              if (_useCustom) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customExerciseCtrl,
                  decoration: const InputDecoration(
                    labelText: AppStrings.exerciseNameRequired,
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _isTimeBased
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(AppStrings.durationSecondsRequired),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () => setState(() {
                                    _durationSeconds = _durationSeconds > 5
                                        ? _durationSeconds - 5
                                        : 1;
                                  }),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      '$_durationSeconds s',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => setState(() {
                                    _durationSeconds += 5;
                                  }),
                                ),
                              ],
                            ),
                          ],
                        )
                      : TextFormField(
                          controller: _countCtrl,
                          decoration: InputDecoration(
                            labelText: AppStrings.countOrRepsRequired,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _setsCtrl,
                    decoration: const InputDecoration(
                      labelText: AppStrings.sets,
                    ),
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
