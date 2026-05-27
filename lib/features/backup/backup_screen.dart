import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/color_utils.dart';
import '../../util/string_constant.dart';
import '../dsa_tracker/providers/dsa_provider.dart';
import '../history/providers/history_provider.dart';
import '../project/providers/project_provider.dart';
import '../stats/providers/stats_provider.dart';
import '../today/providers/today_provider.dart';
import 'providers/backup_provider.dart';
import 'widgets/backup_passphrase_dialog.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AnimationController _syncIconController;
  bool _passphrasePromptInFlight = false;

  @override
  void initState() {
    super.initState();
    _syncIconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    ref.listenManual(
      backupControllerProvider.select(
        (s) => (
          s.pendingPassphraseSetup,
          s.pendingPassphraseForRestore,
          s.isBusy,
          s.account != null,
        ),
      ),
      (previous, next) {
        final (pending, forRestore, busy, signedIn) = next;
        if (!pending || busy || !signedIn || _passphrasePromptInFlight) return;
        final wasPending = previous?.$1 ?? false;
        if (wasPending && pending) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          unawaited(_handlePendingPassphrasePrompt(forRestore: forRestore));
        });
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _syncIconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(backupControllerProvider);
    final theme = Theme.of(context);

    if (state.isBusy) {
      _syncIconController.repeat();
    } else {
      _syncIconController.stop();
      _syncIconController.reset();
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.backupScreenTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // --- Status / Error banners ---
          if (state.statusMessage != null) ...[
            _StatusBanner(
              icon: Icons.check_circle_rounded,
              color: ThemePalette.success,
              message: state.statusMessage!,
            ),
            const SizedBox(height: 10),
          ],
          if (state.errorMessage != null) ...[
            _StatusBanner(
              icon: Icons.error_rounded,
              color: theme.colorScheme.error,
              message: state.errorMessage!,
            ),
            const SizedBox(height: 10),
          ],

          // --- Main content ---
          if (!state.firebaseAvailable)
            _FirebaseUnavailableCard(error: state.firebaseError)
          else if (state.account == null)
            _AuthCard(
              emailController: _emailController,
              passwordController: _passwordController,
              isBusy: state.isBusy,
              onSignIn: _signIn,
              onCreateAccount: _createAccount,
              onResetPassword: _sendPasswordReset,
            )
          else ...[
            // --- Hero sync status ---
            _SyncHeroCard(
              isBusy: state.isBusy,
              backupEnabled: state.backupEnabled,
              lastBackupAt: state.remoteMetadata.lastBackupAt,
              syncIconController: _syncIconController,
            ),
            const SizedBox(height: 14),

            // --- Account row ---
            _AccountTile(email: state.account!.email ?? state.account!.uid),
            const SizedBox(height: 14),

            // --- Restore choice ---
            if (state.hasPendingRestoreChoice) ...[
              _RestoreChoiceCard(
                isBusy: state.isBusy,
                onRestoreCloud: () => _restoreCloudBackup(context),
                onKeepDevice: () => _keepDeviceData(context),
              ),
              const SizedBox(height: 14),
            ],

            // --- Backup toggle ---
            _BackupToggleCard(
              enabled: state.backupEnabled,
              isBusy: state.isBusy,
              onChanged: (value) => ref
                  .read(backupControllerProvider.notifier)
                  .setBackupEnabled(value),
            ),
            const SizedBox(height: 14),

            _SavedPassphraseCard(
              isBusy: state.isBusy,
              refreshKey: state.statusMessage,
              onView: () => _viewSavedPassphrase(context),
            ),
            const SizedBox(height: 14),

            // --- Data summary (device vs cloud side by side) ---
            Row(
              children: [
                Expanded(
                  child: _DataSummaryCard(
                    label: 'Device',
                    icon: Icons.phone_android_rounded,
                    accentColor: ThemePalette.secondary,
                    logCount: state.localSummary?.logCount ?? 0,
                    projectCount: state.localSummary?.projectCount ?? 0,
                    date: state.localSummary?.latestActivityAt,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DataSummaryCard(
                    label: 'Cloud',
                    icon: Icons.cloud_rounded,
                    accentColor: ThemePalette.primary,
                    logCount: state.remoteMetadata.logCount,
                    projectCount: state.remoteMetadata.projectCount,
                    date: state.remoteMetadata.lastBackupAt,
                    emptyText: state.remoteMetadata.exists
                        ? null
                        : 'No backup yet',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // --- Quick actions row ---
            _QuickActionsRow(
              isBusy: state.isBusy,
              backupEnabled: state.backupEnabled,
              hasCloudBackup: state.remoteMetadata.exists,
              onBackupNow: () => _backupNow(context),
              onRestore: () => _restoreCloudBackup(context),
              onRefresh: () =>
                  ref.read(backupControllerProvider.notifier).refresh(),
            ),
            const SizedBox(height: 24),

            // --- Sign out ---
            Center(
              child: TextButton.icon(
                onPressed: state.isBusy
                    ? null
                    : () =>
                          ref.read(backupControllerProvider.notifier).signOut(),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(AppStrings.backupSignOut),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error.withValues(
                    alpha: 0.8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  // --- Callbacks (unchanged logic) ---

  Future<void> _signIn() async {
    if (!_validateAuthFields()) return;
    await ref
        .read(backupControllerProvider.notifier)
        .signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  Future<void> _createAccount() async {
    if (!_validateAuthFields(requireStrongPassword: true)) return;
    await ref
        .read(backupControllerProvider.notifier)
        .createAccount(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showLocalError('Enter your email first.');
      return;
    }
    await ref.read(backupControllerProvider.notifier).sendPasswordReset(email);
  }

  bool _validateAuthFields({bool requireStrongPassword = false}) {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || !email.contains('@')) {
      _showLocalError('Enter a valid email address.');
      return false;
    }
    if (password.isEmpty) {
      _showLocalError('Enter your password.');
      return false;
    }
    if (requireStrongPassword && password.length < 6) {
      _showLocalError('Use at least 6 characters for the password.');
      return false;
    }
    return true;
  }

  Future<void> _backupNow(BuildContext context) async {
    final passphrase = await _resolveBackupPassphrase(context, isCreate: true);
    if (passphrase == null || !context.mounted) return;
    await ref
        .read(backupControllerProvider.notifier)
        .backupNow(passphrase: passphrase);
  }

  Future<void> _restoreCloudBackup(BuildContext context) async {
    final confirmed = await _confirm(
      context,
      title: AppStrings.backupConfirmRestoreTitle,
      message: AppStrings.backupConfirmRestoreMessage,
      actionLabel: AppStrings.backupRestoreCloud,
    );
    if (!confirmed) return;
    if (!context.mounted) return;

    final state = ref.read(backupControllerProvider);
    String passphrase = '';
    if (state.remoteMetadata.encrypted) {
      final resolved = await _resolveBackupPassphrase(context, isCreate: false);
      if (resolved == null) return;
      passphrase = resolved;
    }
    if (!context.mounted) return;

    await ref
        .read(backupControllerProvider.notifier)
        .restoreFromCloud(passphrase: passphrase);
    _refreshProgressProviders();
  }

  Future<void> _keepDeviceData(BuildContext context) async {
    final confirmed = await _confirm(
      context,
      title: AppStrings.backupConfirmKeepTitle,
      message: AppStrings.backupConfirmKeepMessage,
      actionLabel: AppStrings.backupKeepDevice,
    );
    if (!confirmed) return;
    if (!context.mounted) return;
    final passphrase = await _resolveBackupPassphrase(context, isCreate: true);
    if (passphrase == null) return;
    if (!context.mounted) return;
    await ref
        .read(backupControllerProvider.notifier)
        .keepDeviceData(passphrase: passphrase);
  }

  Future<void> _handlePendingPassphrasePrompt({
    required bool forRestore,
  }) async {
    if (_passphrasePromptInFlight) return;
    _passphrasePromptInFlight = true;
    final notifier = ref.read(backupControllerProvider.notifier);
    try {
      if (!mounted) return;
      final passphrase = await showBackupPassphraseDialog(
        context,
        isCreate: !forRestore,
      );
      if (!mounted) return;
      if (passphrase == null) {
        notifier.dismissPendingPassphraseSetup();
        return;
      }
      notifier.clearPendingPassphraseSetup();
      if (forRestore) {
        await notifier.restoreFromCloud(passphrase: passphrase);
        _refreshProgressProviders();
      } else {
        await notifier.backupNow(passphrase: passphrase);
      }
    } finally {
      _passphrasePromptInFlight = false;
    }
  }

  Future<void> _viewSavedPassphrase(BuildContext context) async {
    if (!context.mounted) return;
    await showSavedBackupPassphraseFlow(
      context,
      readPassphrase: () =>
          ref.read(backupControllerProvider.notifier).readStoredPassphrase(),
    );
  }

  /// Uses the passphrase saved on this device, or prompts the user.
  Future<String?> _resolveBackupPassphrase(
    BuildContext context, {
    required bool isCreate,
  }) async {
    final stored = await ref
        .read(backupControllerProvider.notifier)
        .readStoredPassphrase();
    if (stored != null) return stored;
    if (!context.mounted) return null;
    return showBackupPassphraseDialog(context, isCreate: isCreate);
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String actionLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
    return result == true;
  }

  void _showLocalError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _refreshProgressProviders() {
    ref.invalidate(todayLogsProvider);
    ref.invalidate(dayNumberProvider);
    ref.invalidate(historyProvider);
    ref.invalidate(projectsProvider);
    ref.invalidate(statsProvider);
    ref.invalidate(dsaTrackerProvider);
    ref.invalidate(dsaSolvedCountProvider);
  }
}

// ============================================================
//  WIDGETS
// ============================================================

/// Compact status / error banner with rounded pill shape.
class _StatusBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;

  const _StatusBanner({
    required this.icon,
    required this.color,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hero card showing overall sync status.
class _SyncHeroCard extends StatelessWidget {
  final bool isBusy;
  final bool backupEnabled;
  final DateTime? lastBackupAt;
  final AnimationController syncIconController;

  const _SyncHeroCard({
    required this.isBusy,
    required this.backupEnabled,
    required this.lastBackupAt,
    required this.syncIconController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final IconData statusIcon;
    final Color statusColor;
    final String statusText;

    if (isBusy) {
      statusIcon = Icons.cloud_sync_rounded;
      statusColor = ThemePalette.primary;
      statusText = 'Syncing…';
    } else if (!backupEnabled) {
      statusIcon = Icons.cloud_off_rounded;
      statusColor = ThemePalette.neutral;
      statusText = 'Backup paused';
    } else if (lastBackupAt != null) {
      statusIcon = Icons.cloud_done_rounded;
      statusColor = ThemePalette.success;
      statusText = 'All synced';
    } else {
      statusIcon = Icons.cloud_queue_rounded;
      statusColor = ThemePalette.warning;
      statusText = 'Waiting for first backup';
    }

    final timeText = lastBackupAt != null
        ? 'Last backup ${_timeAgo(lastBackupAt!)}'
        : 'No backups yet';

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            // Animated sync icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: isBusy
                    ? RotationTransition(
                        turns: syncIconController,
                        child: Icon(statusIcon, color: statusColor, size: 28),
                      )
                    : Icon(statusIcon, color: statusColor, size: 28),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(timeText, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            if (isBusy)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat.yMMMd().format(dt.toLocal());
  }
}

/// Small account info row.
class _AccountTile extends StatelessWidget {
  final String email;
  const _AccountTile({required this.email});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: ThemePalette.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(
              Icons.person_rounded,
              size: 18,
              color: ThemePalette.primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            email,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Shows whether a passphrase is saved on this device and lets the user view it.
class _SavedPassphraseCard extends ConsumerStatefulWidget {
  final bool isBusy;
  final String? refreshKey;
  final VoidCallback onView;

  const _SavedPassphraseCard({
    required this.isBusy,
    required this.refreshKey,
    required this.onView,
  });

  @override
  ConsumerState<_SavedPassphraseCard> createState() =>
      _SavedPassphraseCardState();
}

class _SavedPassphraseCardState extends ConsumerState<_SavedPassphraseCard> {
  late Future<bool> _hasPassphrase;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(covariant _SavedPassphraseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) {
      _reload();
    }
  }

  void _reload() {
    _hasPassphrase = ref
        .read(backupControllerProvider.notifier)
        .hasStoredPassphrase();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasPassphrase,
      builder: (context, snapshot) {
        final hasSaved = snapshot.data == true;
        return Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                Icon(
                  hasSaved ? Icons.key_rounded : Icons.key_off_outlined,
                  color: hasSaved
                      ? ThemePalette.primary
                      : Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.backupPassphraseSavedTitle,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasSaved
                            ? AppStrings.backupPassphraseSavedSubtitle
                            : AppStrings.backupPassphraseNotSaved,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (hasSaved)
                  TextButton(
                    onPressed: widget.isBusy ? null : widget.onView,
                    child: const Text(AppStrings.backupPassphraseShow),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Backup enabled toggle.
class _BackupToggleCard extends StatelessWidget {
  final bool enabled;
  final bool isBusy;
  final ValueChanged<bool> onChanged;

  const _BackupToggleCard({
    required this.enabled,
    required this.isBusy,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: const Icon(Icons.cloud_sync_outlined),
        title: const Text(AppStrings.backupEnabled),
        subtitle: const Text(AppStrings.backupEnabledSubtitle),
        value: enabled,
        onChanged: isBusy ? null : onChanged,
      ),
    );
  }
}

/// Side-by-side data summary card (device or cloud).
class _DataSummaryCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final int logCount;
  final int projectCount;
  final DateTime? date;
  final String? emptyText;

  const _DataSummaryCard({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.logCount,
    required this.projectCount,
    required this.date,
    this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = logCount > 0 || projectCount > 0 || emptyText == null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(icon, size: 18, color: accentColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (!hasData && emptyText != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  emptyText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else ...[
              // Counts row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _CountChip(
                    value: logCount,
                    label: 'logs',
                    color: accentColor,
                  ),
                  _CountChip(
                    value: projectCount,
                    label: 'proj',
                    color: accentColor,
                  ),
                ],
              ),
              if (date != null) ...[
                const SizedBox(height: 8),
                Text(
                  DateFormat('MMM d, h:mm a').format(date!.toLocal()),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _CountChip({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal action buttons row.
class _QuickActionsRow extends StatelessWidget {
  final bool isBusy;
  final bool backupEnabled;
  final bool hasCloudBackup;
  final VoidCallback onBackupNow;
  final VoidCallback onRestore;
  final VoidCallback onRefresh;

  const _QuickActionsRow({
    required this.isBusy,
    required this.backupEnabled,
    required this.hasCloudBackup,
    required this.onBackupNow,
    required this.onRestore,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.cloud_upload_rounded,
            label: 'Backup',
            color: ThemePalette.primary,
            enabled: backupEnabled && !isBusy,
            onTap: onBackupNow,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.cloud_download_rounded,
            label: 'Restore',
            color: ThemePalette.secondary,
            enabled: hasCloudBackup && !isBusy,
            onTap: onRestore,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.refresh_rounded,
            label: 'Refresh',
            color: ThemePalette.neutral,
            enabled: !isBusy,
            onTap: onRefresh,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = enabled ? color : color.withValues(alpha: 0.35);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: effectiveColor.withValues(alpha: 0.25)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: effectiveColor, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: effectiveColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Restore choice card (cloud found on sign-in).
class _RestoreChoiceCard extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onRestoreCloud;
  final VoidCallback onKeepDevice;

  const _RestoreChoiceCard({
    required this.isBusy,
    required this.onRestoreCloud,
    required this.onKeepDevice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.backupCloudFound,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.backupCloudFoundMessage,
              style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: isBusy ? null : onRestoreCloud,
                  icon: const Icon(Icons.cloud_download_outlined),
                  label: const Text(AppStrings.backupRestoreCloud),
                ),
                OutlinedButton.icon(
                  onPressed: isBusy ? null : onKeepDevice,
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text(AppStrings.backupKeepDevice),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Firebase not available card.
class _FirebaseUnavailableCard extends StatelessWidget {
  final Object? error;
  const _FirebaseUnavailableCard({required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.cloud_off_outlined, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              AppStrings.backupUnavailableTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text(AppStrings.backupUnavailableMessage),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(
                '$error',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Auth card for sign-in / create account.
class _AuthCard extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isBusy;
  final VoidCallback onSignIn;
  final VoidCallback onCreateAccount;
  final VoidCallback onResetPassword;

  const _AuthCard({
    required this.emailController,
    required this.passwordController,
    required this.isBusy,
    required this.onSignIn,
    required this.onCreateAccount,
    required this.onResetPassword,
  });

  @override
  State<_AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<_AuthCard> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.backupNotSignedIn,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: AppStrings.backupEmail,
                prefixIcon: Icon(Icons.alternate_email),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: widget.passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: AppStrings.backupPassword,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              onSubmitted: (_) {
                if (!widget.isBusy) widget.onSignIn();
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: widget.isBusy ? null : widget.onSignIn,
              icon: const Icon(Icons.login),
              label: const Text(AppStrings.backupSignIn),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: widget.isBusy ? null : widget.onCreateAccount,
              icon: const Icon(Icons.person_add_alt_outlined),
              label: const Text(AppStrings.backupCreateAccount),
            ),
            TextButton(
              onPressed: widget.isBusy ? null : widget.onResetPassword,
              child: const Text(AppStrings.backupForgotPassword),
            ),
          ],
        ),
      ),
    );
  }
}
