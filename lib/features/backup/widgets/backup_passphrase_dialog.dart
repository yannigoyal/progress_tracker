import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../util/string_constant.dart';

/// Confirms, then shows the passphrase saved on this device (with copy).
Future<void> showSavedBackupPassphraseFlow(
  BuildContext context, {
  required Future<String?> Function() readPassphrase,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text(AppStrings.backupPassphraseRevealConfirmTitle),
      content: const Text(AppStrings.backupPassphraseRevealConfirmMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text(AppStrings.backupPassphraseShow),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final passphrase = await readPassphrase();
  if (!context.mounted) return;
  if (passphrase == null || passphrase.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.backupPassphraseNotSaved),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (ctx) => _ViewPassphraseDialog(passphrase: passphrase),
  );
}

class _ViewPassphraseDialog extends StatelessWidget {
  final String passphrase;

  const _ViewPassphraseDialog({required this.passphrase});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.backupPassphraseRevealTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(AppStrings.backupPassphraseRevealHint),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                passphrase,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: passphrase));
            if (!context.mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.backupPassphraseCopied),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.copy_rounded, size: 18),
          label: const Text(AppStrings.backupPassphraseCopy),
        ),
      ],
    );
  }
}

/// Prompts for the backup encryption passphrase (separate from Firebase login).
Future<String?> showBackupPassphraseDialog(
  BuildContext context, {
  required bool isCreate,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _BackupPassphraseDialog(isCreate: isCreate),
  );
}

class _BackupPassphraseDialog extends StatefulWidget {
  final bool isCreate;

  const _BackupPassphraseDialog({required this.isCreate});

  @override
  State<_BackupPassphraseDialog> createState() => _BackupPassphraseDialogState();
}

class _BackupPassphraseDialogState extends State<_BackupPassphraseDialog> {
  final _passphraseController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _passphraseController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final passphrase = _passphraseController.text;
    if (passphrase.length < 8) {
      setState(() => _error = AppStrings.backupPassphraseTooShort);
      return;
    }
    if (widget.isCreate) {
      if (passphrase != _confirmController.text) {
        setState(() => _error = AppStrings.backupPassphraseMismatch);
        return;
      }
    }
    Navigator.pop(context, passphrase);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isCreate
            ? AppStrings.backupPassphraseCreateTitle
            : AppStrings.backupPassphraseEnterTitle,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.isCreate
                  ? AppStrings.backupPassphraseCreateMessage
                  : AppStrings.backupPassphraseEnterMessage,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passphraseController,
              obscureText: _obscure,
              autofocus: true,
              decoration: InputDecoration(
                labelText: AppStrings.backupPassphraseLabel,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            if (widget.isCreate) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _confirmController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: AppStrings.backupPassphraseConfirmLabel,
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                onSubmitted: (_) => _submit(),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(
            widget.isCreate
                ? AppStrings.backupPassphraseSave
                : AppStrings.backupPassphraseContinue,
          ),
        ),
      ],
    );
  }
}
