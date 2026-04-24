import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../core/models/category.dart';
import '../../core/models/log_entry.dart';
import '../../core/providers/isar_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../util/string_constant.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text(AppStrings.settingsScreenTitle),
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Appearance ─────────────────────────────────────────
                _SectionHeader(title: AppStrings.appearance),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.theme,
                          style: theme.textTheme.labelLarge,
                        ),
                        const SizedBox(height: 12),
                        SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.dark,
                              icon: Icon(Icons.dark_mode_outlined, size: 16),
                              label: Text(AppStrings.dark),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              icon: Icon(Icons.light_mode_outlined, size: 16),
                              label: Text(AppStrings.light),
                            ),
                            ButtonSegment(
                              value: ThemeMode.system,
                              icon: Icon(Icons.contrast_outlined, size: 16),
                              label: Text(AppStrings.system),
                            ),
                          ],
                          selected: {themeMode},
                          onSelectionChanged: (s) =>
                              ref.read(themeModeProvider.notifier).state =
                                  s.first,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Data ───────────────────────────────────────────────
                _SectionHeader(title: AppStrings.data),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.upload_outlined),
                        title: const Text(AppStrings.exportDataAsJson),
                        subtitle: const Text(AppStrings.saveAllLogsToJson),
                        trailing: const Icon(Icons.chevron_right, size: 18),
                        onTap: () => _exportData(context, ref),
                      ),
                      Divider(
                        height: 1,
                        indent: 56,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      ListTile(
                        leading: const Icon(Icons.download_outlined),
                        title: const Text(AppStrings.importDataFromJson),
                        subtitle: const Text(AppStrings.mergeLogsFromJson),
                        trailing: const Icon(Icons.chevron_right, size: 18),
                        onTap: () => _showImportDialog(context, ref),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── About ──────────────────────────────────────────────
                _SectionHeader(title: AppStrings.about),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Text(
                          AppStrings.aboutEmoji,
                          style: TextStyle(fontSize: 20),
                        ),
                        title: const Text(AppStrings.appName),
                        subtitle: const Text(AppStrings.appVersionSubtitle),
                      ),
                      Divider(
                        height: 1,
                        indent: 56,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFF87171),
                        ),
                        title: const Text(
                          AppStrings.clearAllData,
                          style: TextStyle(color: Color(0xFFF87171)),
                        ),
                        onTap: () => _confirmClear(context, ref),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final isar = ref.read(isarProvider);
    final logs = await isar.logEntrys
        .where()
        .createdAtBetween(
          DateTime.fromMillisecondsSinceEpoch(0),
          DateTime(2100),
        )
        .findAll();
    final jsonList = logs
        .map(
          (l) => {
            'id': l.id,
            'createdAt': l.createdAt.toIso8601String(),
            'category': l.category.name,
            'payload': l.payload,
          },
        )
        .toList();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(jsonList);

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.exportDataTitle),
        content: SingleChildScrollView(
          child: SelectableText(
            jsonStr,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  Future<void> _showImportDialog(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.importJsonTitle),
        content: TextField(
          controller: ctrl,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: AppStrings.pasteJsonArrayHere,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.import),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final list = jsonDecode(ctrl.text) as List;
      final isar = ref.read(isarProvider);
      final entries = list.map((e) {
        final map = e as Map<String, dynamic>;
        return LogEntry()
          ..createdAt = DateTime.parse(map['createdAt'] as String)
          ..category = _categoryFromName(map['category'] as String)
          ..payload = map['payload'] as Map<String, dynamic>;
      }).toList();
      await isar.writeTxn(() => isar.logEntrys.putAll(entries));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.importedLogsMessage(entries.length)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.importFailedMessage(e)),
            backgroundColor: const Color(0xFFF87171),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.clearAllDataTitle),
        content: const Text(AppStrings.clearAllDataMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              AppStrings.deleteAll,
              style: TextStyle(color: Color(0xFFF87171)),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.logEntrys.clear());
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.allDataCleared),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Category _categoryFromName(String name) => Category.values.firstWhere(
    (c) => c.name == name,
    orElse: () => Category.misc,
  );
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(letterSpacing: 1.2),
      ),
    );
  }
}
