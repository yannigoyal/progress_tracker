import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/custom_activity.dart';
import '../../core/models/custom_activity_field_labels.dart';
import '../../core/models/log_field_kind.dart';
import '../../util/string_constant.dart';
import 'data/custom_activity_icon_storage.dart';
import 'data/custom_activity_icons.dart';
import 'providers/custom_activity_provider.dart';

class CustomActivityEditorScreen extends ConsumerStatefulWidget {
  final CustomActivity? existing;

  const CustomActivityEditorScreen({super.key, this.existing});

  @override
  ConsumerState<CustomActivityEditorScreen> createState() =>
      _CustomActivityEditorScreenState();
}

class _CustomActivityEditorScreenState
    extends ConsumerState<CustomActivityEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late int _iconCodePoint;
  late int _colorValue;
  late Set<String> _enabledFields;
  String? _customIconPath;
  Uint8List? _pendingPngBytes;
  final Map<String, TextEditingController> _labelControllers = {};

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _iconCodePoint =
        e?.iconCodePoint ?? CustomActivityIcons.presets.first.codePoint;
    _colorValue = e?.colorValue ?? CustomActivityIcons.colorPresets.first;
    _enabledFields = Set<String>.from(
      e?.enabledFields ?? [LogFieldKind.title, LogFieldKind.note],
    );
    _customIconPath = e?.customIconPath;
    final labels =
        e?.fieldLabels.withDefaultsFor(_enabledFields) ??
        CustomActivityFieldLabels.empty.withDefaultsFor(_enabledFields);
    for (final kind in LogFieldKind.all) {
      _labelControllers[kind] = TextEditingController(
        text: labels.labelFor(kind),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    for (final c in _labelControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _useCustomImage =>
      _customIconPath != null || _pendingPngBytes != null;

  Future<void> _pickPng() async {
    final storage = ref.read(customActivityIconStorageProvider);
    try {
      if (widget.existing != null) {
        final path = await storage.pickAndSavePng(widget.existing!.id);
        if (path != null) {
          setState(() {
            _customIconPath = path;
            _pendingPngBytes = null;
          });
        }
        return;
      }
      final bytes = await storage.pickPngBytes();
      if (bytes != null) {
        setState(() {
          _pendingPngBytes = bytes;
          _customIconPath = null;
        });
      }
    } on CustomActivityIconException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  void _clearCustomIcon() {
    setState(() {
      _customIconPath = null;
      _pendingPngBytes = null;
    });
  }

  Map<String, String> _collectFieldLabels() {
    return {
      for (final kind in _enabledFields)
        kind: _labelControllers[kind]!.text.trim(),
    };
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_enabledFields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.atLeastOneField)),
      );
      return;
    }

    final storage = ref.read(customActivityIconStorageProvider);
    final repo = ref.read(customActivityRepositoryProvider);

    final activity = widget.existing ?? CustomActivity();
    activity
      ..name = _nameCtrl.text.trim()
      ..iconCodePoint = _iconCodePoint
      ..colorValue = _colorValue
      ..enabledFields = _enabledFields.toList()
      ..fieldLabelsJson =
          CustomActivityFieldLabels(_collectFieldLabels()).toJsonString();

    if (!_useCustomImage) {
      activity.customIconPath = null;
      if (widget.existing?.hasCustomIcon == true) {
        await storage.deleteIconFile(widget.existing!.customIconPath);
      }
    }

    await repo.save(activity);

    if (_pendingPngBytes != null) {
      activity.customIconPath =
          await storage.savePngBytes(activity.id, _pendingPngBytes!);
      await repo.save(activity);
    } else if (_customIconPath != null) {
      activity.customIconPath = _customIconPath;
      await repo.save(activity);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? AppStrings.editCustomActivity : AppStrings.addCustomActivity,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: AppStrings.customActivityNameRequired,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? AppStrings.requiredField : null,
            ),
            const SizedBox(height: 20),
            Text(AppStrings.customImageSection, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(AppStrings.pngOnlyHint, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickPng,
                    icon: const Icon(Icons.image_outlined),
                    label: const Text(AppStrings.importPngIcon),
                  ),
                ),
                if (_useCustomImage) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _clearCustomIcon,
                    child: const Text(AppStrings.clearCustomIcon),
                  ),
                ],
              ],
            ),
            if (_pendingPngBytes != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    _pendingPngBytes!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else if (_customIconPath != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: FutureBuilder(
                  future: ref
                      .read(customActivityIconStorageProvider)
                      .resolveFile(_customIconPath),
                  builder: (context, snapshot) {
                    final file = snapshot.data;
                    if (file == null) return const SizedBox.shrink();
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        file,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            Text(AppStrings.materialIconsSection, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: CustomActivityIcons.presets.length,
              itemBuilder: (context, i) {
                final icon = CustomActivityIcons.presets[i];
                final selected =
                    !_useCustomImage && icon.codePoint == _iconCodePoint;
                return InkWell(
                  onTap: () => setState(() {
                    _iconCodePoint = icon.codePoint;
                    _clearCustomIcon();
                  }),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected
                          ? Color(_colorValue).withAlpha(40)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? Color(_colorValue)
                            : theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: selected
                          ? Color(_colorValue)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(AppStrings.pickColor, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: CustomActivityIcons.colorPresets.map((argb) {
                final selected = argb == _colorValue;
                return GestureDetector(
                  onTap: () => setState(() => _colorValue = argb),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(argb),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? theme.colorScheme.onSurface
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(AppStrings.enabledFields, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            ...LogFieldKind.all.map((kind) {
              return Column(
                children: [
                  CheckboxListTile(
                    value: _enabledFields.contains(kind),
                    title: Text(LogFieldKind.label(kind)),
                    onChanged: (v) => setState(() {
                      if (v == true) {
                        _enabledFields.add(kind);
                      } else {
                        _enabledFields.remove(kind);
                      }
                    }),
                  ),
                  if (_enabledFields.contains(kind))
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 8,
                        bottom: 8,
                      ),
                      child: TextFormField(
                        controller: _labelControllers[kind],
                        decoration: InputDecoration(
                          labelText: AppStrings.fieldDisplayLabel,
                          hintText: LogFieldKind.label(kind),
                          isDense: true,
                        ),
                        validator: (v) =>
                            _enabledFields.contains(kind) &&
                                (v == null || v.trim().isEmpty)
                            ? AppStrings.requiredField
                            : null,
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _save,
            child: Text(isEdit ? AppStrings.saveLog : AppStrings.addCustomActivity),
          ),
        ),
      ),
    );
  }
}
