import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../util/string_constant.dart';
import '../dsa_tracker/providers/dsa_provider.dart';
import '../history/providers/history_provider.dart';
import '../project/providers/project_provider.dart';
import '../stats/providers/stats_provider.dart';
import '../today/providers/today_provider.dart';
import 'providers/backup_provider.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(backupControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.backupScreenTitle)),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          if (state.isBusy) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
          ],
          if (state.statusMessage != null)
            _MessageCard(
              icon: Icons.check_circle_outline,
              color: theme.colorScheme.primary,
              message: state.statusMessage!,
            ),
          if (state.errorMessage != null)
            _MessageCard(
              icon: Icons.error_outline,
              color: theme.colorScheme.error,
              message: state.errorMessage!,
            ),
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
            _AccountCard(email: state.account!.email ?? state.account!.uid),
            if (state.hasPendingRestoreChoice)
              _RestoreChoiceCard(
                isBusy: state.isBusy,
                onRestoreCloud: () => _restoreCloudBackup(context),
                onKeepDevice: () => _keepDeviceData(context),
              ),
            _BackupSwitchCard(
              enabled: state.backupEnabled,
              isBusy: state.isBusy,
              onChanged: (value) => ref
                  .read(backupControllerProvider.notifier)
                  .setBackupEnabled(value),
            ),
            _SummaryCard(
              title: AppStrings.backupLocalData,
              icon: Icons.phone_android_outlined,
              logCount: state.localSummary?.logCount ?? 0,
              projectCount: state.localSummary?.projectCount ?? 0,
              date: state.localSummary?.latestActivityAt,
            ),
            _SummaryCard(
              title: AppStrings.backupCloudData,
              icon: Icons.cloud_outlined,
              logCount: state.remoteMetadata.logCount,
              projectCount: state.remoteMetadata.projectCount,
              date: state.remoteMetadata.lastBackupAt,
              emptyText: state.remoteMetadata.exists
                  ? null
                  : AppStrings.backupNoCloudData,
            ),
            _BackupActionsCard(
              isBusy: state.isBusy,
              backupEnabled: state.backupEnabled,
              hasCloudBackup: state.remoteMetadata.exists,
              onBackupNow: () =>
                  ref.read(backupControllerProvider.notifier).backupNow(),
              onRestore: () => _restoreCloudBackup(context),
              onRefresh: () =>
                  ref.read(backupControllerProvider.notifier).refresh(),
              onSignOut: () =>
                  ref.read(backupControllerProvider.notifier).signOut(),
            ),
          ],
        ],
      ),
    );
  }

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

  Future<void> _restoreCloudBackup(BuildContext context) async {
    final confirmed = await _confirm(
      context,
      title: AppStrings.backupConfirmRestoreTitle,
      message: AppStrings.backupConfirmRestoreMessage,
      actionLabel: AppStrings.backupRestoreCloud,
    );
    if (!confirmed) return;

    await ref.read(backupControllerProvider.notifier).restoreFromCloud();
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

    await ref.read(backupControllerProvider.notifier).keepDeviceData();
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

class _AccountCard extends StatelessWidget {
  final String email;

  const _AccountCard({required this.email});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.verified_user_outlined),
        title: const Text(AppStrings.backupAccount),
        subtitle: Text(email),
      ),
    );
  }
}

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

class _BackupSwitchCard extends StatelessWidget {
  final bool enabled;
  final bool isBusy;
  final ValueChanged<bool> onChanged;

  const _BackupSwitchCard({
    required this.enabled,
    required this.isBusy,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        secondary: const Icon(Icons.cloud_sync_outlined),
        title: const Text(AppStrings.backupEnabled),
        subtitle: const Text(AppStrings.backupEnabledSubtitle),
        value: enabled,
        onChanged: isBusy ? null : onChanged,
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int logCount;
  final int projectCount;
  final DateTime? date;
  final String? emptyText;

  const _SummaryCard({
    required this.title,
    required this.icon,
    required this.logCount,
    required this.projectCount,
    required this.date,
    this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = emptyText ?? _summaryText(context);

    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text('$logCount', style: theme.textTheme.titleLarge),
      ),
    );
  }

  String _summaryText(BuildContext context) {
    final counts = '$logCount logs, $projectCount projects';
    if (date == null) return counts;
    final formattedDate = DateFormat.yMMMd().add_jm().format(date!.toLocal());
    return '$counts\nLast activity: $formattedDate';
  }
}

class _BackupActionsCard extends StatelessWidget {
  final bool isBusy;
  final bool backupEnabled;
  final bool hasCloudBackup;
  final VoidCallback onBackupNow;
  final VoidCallback onRestore;
  final VoidCallback onRefresh;
  final VoidCallback onSignOut;

  const _BackupActionsCard({
    required this.isBusy,
    required this.backupEnabled,
    required this.hasCloudBackup,
    required this.onBackupNow,
    required this.onRestore,
    required this.onRefresh,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.cloud_upload_outlined),
            title: const Text(AppStrings.backupNow),
            enabled: backupEnabled && !isBusy,
            onTap: backupEnabled && !isBusy ? onBackupNow : null,
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: const Icon(Icons.cloud_download_outlined),
            title: const Text(AppStrings.backupRestore),
            enabled: hasCloudBackup && !isBusy,
            onTap: hasCloudBackup && !isBusy ? onRestore : null,
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text(AppStrings.backupRefresh),
            enabled: !isBusy,
            onTap: isBusy ? null : onRefresh,
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(AppStrings.backupSignOut),
            enabled: !isBusy,
            onTap: isBusy ? null : onSignOut,
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;

  const _MessageCard({
    required this.icon,
    required this.color,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(message),
      ),
    );
  }
}
