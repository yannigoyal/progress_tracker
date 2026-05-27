import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../../../core/models/category.dart';
import '../../../../core/models/log_entry.dart';
import '../../../../shared/widgets/formatted_note_field.dart';
import '../../../../util/string_constant.dart';
import '../../providers/today_provider.dart';
import 'form_shell.dart';

class ReadingForm extends ConsumerStatefulWidget {
  final void Function(LogEntry) onSave;
  final LogEntry? existingLog;

  const ReadingForm({super.key, required this.onSave, this.existingLog});

  @override
  ConsumerState<ReadingForm> createState() => _ReadingFormState();
}

class _ReadingFormState extends ConsumerState<ReadingForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bookCtrl;
  late final TextEditingController _pagesCtrl;
  late final TextEditingController _quoteCtrl;

  @override
  void initState() {
    super.initState();
    final p = widget.existingLog?.payload ?? {};
    _bookCtrl = TextEditingController(text: p['bookName'] as String? ?? '');
    _pagesCtrl = TextEditingController(text: p['pagesRead']?.toString() ?? '');
    _quoteCtrl = TextEditingController(text: p['quote'] as String? ?? '');
  }

  @override
  void dispose() {
    _bookCtrl.dispose();
    _pagesCtrl.dispose();
    _quoteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final entry = (widget.existingLog ?? LogEntry())
      ..category = Category.reading
      ..createdAt = widget.existingLog?.createdAt ?? DateTime.now().toUtc()
      ..payload = {
        'bookName': _bookCtrl.text.trim(),
        'pagesRead': int.tryParse(_pagesCtrl.text.trim()) ?? 0,
        if (_quoteCtrl.text.trim().isNotEmpty) 'quote': _quoteCtrl.text.trim(),
      };
    widget.onSave(entry);
  }

  @override
  Widget build(BuildContext context) {
    final bookSuggestions =
        ref.watch(readingBookNameSuggestionsProvider).valueOrNull ??
        const <String>[];

    return FormShell(
      title: AppStrings.readingFormTitle,
      category: Category.reading,
      onSave: _submit,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TypeAheadField<String>(
              controller: _bookCtrl,
              direction: VerticalDirection.down,
              debounceDuration: Duration.zero,
              hideOnEmpty: true,
              constraints: const BoxConstraints(maxHeight: 220),
              suggestionsCallback: (pattern) {
                return _filterSuggestions(bookSuggestions, pattern);
              },
              builder: (context, controller, focusNode) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: AppStrings.bookNameRequired,
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? AppStrings.requiredField
                      : null,
                );
              },
              itemBuilder: (context, bookName) {
                return ListTile(
                  dense: true,
                  title: Text(
                    bookName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
              onSelected: _selectBook,
              decorationBuilder: _buildSuggestionsDecoration,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pagesCtrl,
              decoration: const InputDecoration(
                labelText: AppStrings.pagesReadRequired,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => v == null || v.trim().isEmpty
                  ? AppStrings.requiredField
                  : null,
            ),
            const SizedBox(height: 12),
            FormattedNoteField(
              controller: _quoteCtrl,
              decoration: const InputDecoration(
                labelText: AppStrings.keyTakeawayOrQuoteOptional,
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

  void _selectBook(String bookName) {
    _bookCtrl.text = bookName;
    _bookCtrl.selection = TextSelection.collapsed(offset: bookName.length);
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
