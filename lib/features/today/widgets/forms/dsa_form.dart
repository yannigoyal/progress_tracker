import 'package:flutter/material.dart';

import '../../../../core/models/category.dart';
import '../../../../core/models/log_entry.dart';
import '../../../dsa_tracker/data/blind75_problems.dart';
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
  DsaProblem? _selectedProblem;
  String _topic = AppStrings.dsaTopicDp;
  String _approach = AppStrings.dsaApproachMemoization;
  bool _isSolved = true;

  static final _topics = <String>{
    ...AppStrings.dsaTopics,
    ...blind75Problems.map((problem) => problem.topic),
  }.toList();
  static const _approaches = [...AppStrings.dsaApproaches];

  @override
  void initState() {
    super.initState();
    final p = widget.existingLog?.payload ?? {};
    _selectedProblem = _problemFromPayload(p);
    if (p['topic'] != null && _topics.contains(p['topic'])) {
      _topic = p['topic'] as String;
    } else if (_selectedProblem != null) {
      _topic = _selectedProblem!.topic;
    }
    if (p['approach'] != null && _approaches.contains(p['approach'])) {
      _approach = p['approach'] as String;
    }
    if (p['status'] != null) {
      _isSolved = p['status'] == AppStrings.solved;
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final problem = _selectedProblem!;
    final entry = (widget.existingLog ?? LogEntry())
      ..category = Category.dsa
      ..createdAt = widget.existingLog?.createdAt ?? DateTime.now().toUtc()
      ..payload = {
        'problemNumber': problem.id,
        'problemName': problem.name,
        'topic': _topic,
        'approach': _approach,
        'status': _isSolved ? AppStrings.solved : AppStrings.revised,
      };
    widget.onSave(entry);
  }

  DsaProblem? _problemFromPayload(Map<String, dynamic> payload) {
    final problemNumber = payload['problemNumber'];
    final problemName = (payload['problemName'] as String?)?.trim();
    for (final problem in blind75Problems) {
      if (problemNumber == problem.id ||
          problemName?.toLowerCase() == problem.name.toLowerCase()) {
        return problem;
      }
    }
    return null;
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
            DropdownButtonFormField<DsaProblem>(
              initialValue: _selectedProblem,
              decoration: const InputDecoration(
                labelText: AppStrings.problemNameRequired,
              ),
              isExpanded: true,
              items: blind75Problems
                  .map(
                    (problem) => DropdownMenuItem(
                      value: problem,
                      child: Text(
                        '#${problem.id} · ${problem.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (problem) => setState(() {
                _selectedProblem = problem;
                if (problem != null) _topic = problem.topic;
              }),
              validator: (problem) =>
                  problem == null ? AppStrings.requiredField : null,
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
