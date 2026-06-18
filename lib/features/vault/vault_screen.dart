import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/color_utils.dart';
import '../../../util/string_constant.dart';
import 'data/vault_models.dart';
import 'providers/vault_provider.dart';
import 'widgets/vault_pin_pad.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirmStep = false;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final vault = ref.watch(vaultControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.vaultScreenTitle),
        actions: [
          if (vault.phase == VaultPhase.unlocked)
            IconButton(
              icon: const Icon(Icons.lock_outline),
              tooltip: AppStrings.vaultLock,
              onPressed: () => ref.read(vaultControllerProvider.notifier).lock(),
            ),
        ],
      ),
      body: switch (vault.phase) {
        VaultPhase.loading => const Center(child: CircularProgressIndicator()),
        VaultPhase.setup => _buildSetup(context, vault),
        VaultPhase.locked => _buildLocked(context, vault),
        VaultPhase.unlocked => _buildUnlocked(context, vault),
      },
      floatingActionButton: vault.phase == VaultPhase.unlocked
          ? FloatingActionButton(
              onPressed: vault.isBusy
                  ? null
                  : () => context.push('/more/vault/entry/new'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildSetup(BuildContext context, VaultState vault) {
    final title = _isConfirmStep
        ? AppStrings.vaultConfirmPinTitle
        : AppStrings.vaultCreatePinTitle;
    final subtitle = _isConfirmStep
        ? AppStrings.vaultConfirmPinSubtitle
        : AppStrings.vaultCreatePinSubtitle;

    return VaultPinPad(
      title: title,
      subtitle: subtitle,
      pin: _isConfirmStep ? _confirmPin : _pin,
      isBusy: vault.isBusy,
      errorMessage: vault.errorMessage,
      onPinChanged: (value) => setState(() {
        if (_isConfirmStep) {
          _confirmPin = value;
        } else {
          _pin = value;
        }
      }),
      onBackspace: () {},
      onSubmit: () async {
        if (_isConfirmStep) {
          await ref
              .read(vaultControllerProvider.notifier)
              .setupPin(_pin, _confirmPin);
          if (!mounted) return;
          final next = ref.read(vaultControllerProvider);
          if (next.phase == VaultPhase.unlocked) {
            setState(() {
              _pin = '';
              _confirmPin = '';
              _isConfirmStep = false;
            });
          } else if (next.errorMessage != null) {
            setState(() {
              _pin = '';
              _confirmPin = '';
              _isConfirmStep = false;
            });
          }
        } else {
          setState(() {
            _isConfirmStep = true;
            _confirmPin = '';
          });
        }
      },
    );
  }

  Widget _buildLocked(BuildContext context, VaultState vault) {
    final lockoutMsg = vaultLockoutMessage(vault.lockoutUntil);
    return VaultPinPad(
      title: AppStrings.vaultUnlockTitle,
      subtitle: lockoutMsg ?? AppStrings.vaultUnlockSubtitle,
      pin: _pin,
      isBusy: vault.isBusy,
      errorMessage: vault.errorMessage ?? lockoutMsg,
      onPinChanged: (value) => setState(() => _pin = value),
      onSubmit: () {
        ref.read(vaultControllerProvider.notifier).unlock(_pin).then((_) {
          if (!mounted) return;
          final next = ref.read(vaultControllerProvider);
          if (next.phase == VaultPhase.unlocked) {
            setState(() => _pin = '');
          }
        });
      },
    );
  }

  Widget _buildUnlocked(BuildContext context, VaultState vault) {
    final query = _search.trim().toLowerCase();
    final entries = vault.entries.where((entry) {
      if (query.isEmpty) return true;
      return entry.appName.toLowerCase().contains(query) ||
          entry.username.toLowerCase().contains(query) ||
          (entry.url?.toLowerCase().contains(query) ?? false);
    }).toList();

    return Column(
      children: [
        if (vault.statusMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              vault.statusMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.secondary,
              ),
            ),
          ),
        if (vault.cloudSyncAvailable)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Icon(Icons.cloud_done_outlined, size: 16, color: context.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.vaultCloudSyncEnabled,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: AppStrings.vaultSearchHint,
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _search = value),
          ),
        ),
        Expanded(
          child: entries.isEmpty
              ? _EmptyVault(hasSearch: query.isNotEmpty)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: entries.length,
                  itemBuilder: (_, index) {
                    final entry = entries[index];
                    return _VaultEntryTile(
                      entry: entry,
                      onTap: () => context.push('/more/vault/entry/${entry.id}'),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _EmptyVault extends StatelessWidget {
  final bool hasSearch;

  const _EmptyVault({required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔐', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              hasSearch ? AppStrings.vaultNoSearchResults : AppStrings.vaultEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (!hasSearch) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.vaultEmptySubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VaultEntryTile extends StatelessWidget {
  final VaultEntry entry;
  final VoidCallback onTap;

  const _VaultEntryTile({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: context.primaryLightContainer,
          child: Text(
            entry.appName.isNotEmpty ? entry.appName[0].toUpperCase() : '?',
            style: TextStyle(color: context.primary),
          ),
        ),
        title: Text(entry.appName),
        subtitle: Text(entry.username),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class VaultEntryScreen extends ConsumerStatefulWidget {
  final String? entryId;

  const VaultEntryScreen({super.key, this.entryId});

  @override
  ConsumerState<VaultEntryScreen> createState() => _VaultEntryScreenState();
}

class _VaultEntryScreenState extends ConsumerState<VaultEntryScreen> {
  final _appNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isNew = true;
  VaultEntry? _existing;

  @override
  void initState() {
    super.initState();
    _isNew = widget.entryId == null || widget.entryId == 'new';
    if (!_isNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadEntry());
    }
  }

  void _loadEntry() {
    final entry = ref
        .read(vaultControllerProvider.notifier)
        .entryById(widget.entryId!);
    if (entry == null) {
      if (mounted) Navigator.pop(context);
      return;
    }
    setState(() {
      _existing = entry;
      _appNameCtrl.text = entry.appName;
      _usernameCtrl.text = entry.username;
      _passwordCtrl.text = entry.password;
      _urlCtrl.text = entry.url ?? '';
      _notesCtrl.text = entry.notes ?? '';
    });
  }

  @override
  void dispose() {
    _appNameCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _urlCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vault = ref.watch(vaultControllerProvider);
    final history = _existing?.passwordHistory ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? AppStrings.vaultAddEntry : AppStrings.vaultEditEntry),
        actions: [
          if (!_isNew)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: AppStrings.vaultShare,
              onPressed: _existing == null ? null : () => _shareEntry(_existing!),
            ),
          if (!_isNew)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: AppStrings.delete,
              onPressed: vault.isBusy ? null : _confirmDelete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _appNameCtrl,
            decoration: const InputDecoration(
              labelText: AppStrings.vaultAppName,
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _usernameCtrl,
            decoration: const InputDecoration(
              labelText: AppStrings.vaultUsername,
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordCtrl,
            decoration: InputDecoration(
              labelText: AppStrings.vaultPassword,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            obscureText: _obscurePassword,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _urlCtrl,
            decoration: const InputDecoration(
              labelText: AppStrings.vaultWebsiteOptional,
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            decoration: const InputDecoration(
              labelText: AppStrings.vaultNotesOptional,
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          if (history.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              AppStrings.vaultPasswordHistory,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...history.map(
              (password) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('••••••••'),
                trailing: IconButton(
                  icon: const Icon(Icons.copy_outlined),
                  onPressed: () => _copy(password),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: vault.isBusy ? null : _save,
            child: Text(_isNew ? AppStrings.create : AppStrings.vaultSaveEntry),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final appName = _appNameCtrl.text.trim();
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (appName.isEmpty || username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.requiredField)),
      );
      return;
    }

    final notifier = ref.read(vaultControllerProvider.notifier);
    if (_isNew) {
      await notifier.addEntry(
        VaultEntry.create(
          appName: appName,
          username: username,
          password: password,
          url: _urlCtrl.text,
          notes: _notesCtrl.text,
        ),
      );
    } else if (_existing != null) {
      final updated = _existing!
          .copyWith(
            appName: appName,
            username: username,
            url: _urlCtrl.text,
            notes: _notesCtrl.text,
          )
          .withPasswordUpdate(password);
      await notifier.updateEntry(updated);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.vaultDeleteEntryTitle),
        content: Text(
          AppStrings.vaultDeleteEntryMessage(_existing?.appName ?? ''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.delete, style: TextStyle(color: context.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || _existing == null) return;
    await ref.read(vaultControllerProvider.notifier).deleteEntry(_existing!.id);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _shareEntry(VaultEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.vaultShareTitle),
        content: Text(AppStrings.vaultShareMessage(entry.appName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.vaultShare),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final buffer = StringBuffer()
      ..writeln('${entry.appName} — ${AppStrings.vaultShareFooter}')
      ..writeln()
      ..writeln('${AppStrings.vaultUsername}: ${entry.username}')
      ..writeln('${AppStrings.vaultPassword}: ${entry.password}');
    if (entry.url != null && entry.url!.isNotEmpty) {
      buffer.writeln('${AppStrings.vaultWebsiteOptional}: ${entry.url}');
    }
    buffer
      ..writeln()
      ..writeln(AppStrings.vaultShareWarning);

    await Share.share(
      buffer.toString(),
      subject: '${entry.appName} credentials',
    );
  }

  Future<void> _copy(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.vaultCopied)),
    );
  }
}
