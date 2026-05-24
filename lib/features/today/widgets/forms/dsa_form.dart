import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

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
  late final TextEditingController _titleCtrl;
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
    _titleCtrl = TextEditingController(
      text: _selectedProblem?.name ?? (p['problemName'] as String? ?? ''),
    );
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

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final name = _titleCtrl.text.trim();
    final payload = <String, dynamic>{
      'problemName': name,
      'topic': _topic,
      'approach': _approach,
      'status': _isSolved ? AppStrings.solved : AppStrings.revised,
    };
    if (_selectedProblem != null) {
      payload['problemNumber'] = _selectedProblem!.id;
      payload['problemName'] = _selectedProblem!.name;
    }
    final entry = (widget.existingLog ?? LogEntry())
      ..category = Category.dsa
      ..createdAt = widget.existingLog?.createdAt ?? DateTime.now().toUtc()
      ..payload = payload;
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
            TypeAheadField<DsaProblem>(
              controller: _titleCtrl,
              direction: VerticalDirection.down,
              debounceDuration: Duration.zero,
              hideOnEmpty: true,
              constraints: const BoxConstraints(maxHeight: 220),
              suggestionsCallback: (pattern) {
                final q = pattern.trim().toLowerCase();
                if (q.isEmpty) return const <DsaProblem>[];
                return blind75Problems
                    .where(
                      (p) =>
                          p.name.toLowerCase().contains(q) ||
                          p.id.toString().contains(q),
                    )
                    .take(8)
                    .toList(growable: false);
              },
              builder: (context, controller, focusNode) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: AppStrings.problemNameRequired,
                    hintText: AppStrings.dsaProblemNameHint,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? AppStrings.requiredField : null,
                  onChanged: (v) => setState(() {
                    DsaProblem? match;
                    final q = v.trim().toLowerCase();
                    if (q.isNotEmpty) {
                      for (final p in blind75Problems) {
                        if (p.name.toLowerCase() == q ||
                            p.id.toString() == q.replaceAll('#', '')) {
                          match = p;
                          break;
                        }
                      }
                    }
                    _selectedProblem = match;
                  }),
                );
              },
              itemBuilder: (context, problem) {
                return ListTile(
                  dense: true,
                  title: Text('#${problem.id} · ${problem.name}'),
                );
              },
              onSelected: (problem) => setState(() {
                _selectedProblem = problem;
                _titleCtrl.text = problem.name;
                _topic = problem.topic;
              }),
              decorationBuilder: _buildSuggestionsDecoration,
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
