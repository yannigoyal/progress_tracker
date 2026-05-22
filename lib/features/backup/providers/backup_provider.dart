import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/firebase_provider.dart';
import '../../../core/providers/isar_provider.dart';
import '../../../util/string_constant.dart';
import '../data/backup_models.dart';
import '../data/backup_passphrase_store.dart';
import '../data/firebase_backup_repository.dart';

final backupPassphraseStoreProvider = Provider<BackupPassphraseStore>(
  (ref) => BackupPassphraseStore(),
);

class BackupState {
  final bool firebaseAvailable;
  final Object? firebaseError;
  final BackupAccount? account;
  final bool backupEnabled;
  final bool isBusy;
  final bool hasPendingRestoreChoice;
  final bool pendingPassphraseSetup;
  final bool pendingPassphraseForRestore;
  final BackupMetadata remoteMetadata;
  final LocalBackupSummary? localSummary;
  final String? statusMessage;
  final String? errorMessage;

  const BackupState({
    required this.firebaseAvailable,
    required this.firebaseError,
    required this.account,
    required this.backupEnabled,
    required this.isBusy,
    required this.hasPendingRestoreChoice,
    this.pendingPassphraseSetup = false,
    this.pendingPassphraseForRestore = false,
    required this.remoteMetadata,
    required this.localSummary,
    required this.statusMessage,
    required this.errorMessage,
  });

  factory BackupState.initial({
    required bool firebaseAvailable,
    Object? firebaseError,
  }) {
    return BackupState(
      firebaseAvailable: firebaseAvailable,
      firebaseError: firebaseError,
      account: null,
      backupEnabled: false,
      isBusy: false,
      hasPendingRestoreChoice: false,
      pendingPassphraseSetup: false,
      pendingPassphraseForRestore: false,
      remoteMetadata: const BackupMetadata.empty(),
      localSummary: null,
      statusMessage: null,
      errorMessage: null,
    );
  }

  BackupState copyWith({
    bool? firebaseAvailable,
    Object? firebaseError,
    bool clearFirebaseError = false,
    BackupAccount? account,
    bool clearAccount = false,
    bool? backupEnabled,
    bool? isBusy,
    bool? hasPendingRestoreChoice,
    bool? pendingPassphraseSetup,
    bool clearPendingPassphraseSetup = false,
    bool? pendingPassphraseForRestore,
    BackupMetadata? remoteMetadata,
    LocalBackupSummary? localSummary,
    bool clearLocalSummary = false,
    String? statusMessage,
    bool clearStatusMessage = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return BackupState(
      firebaseAvailable: firebaseAvailable ?? this.firebaseAvailable,
      firebaseError: clearFirebaseError
          ? null
          : (firebaseError ?? this.firebaseError),
      account: clearAccount ? null : (account ?? this.account),
      backupEnabled: backupEnabled ?? this.backupEnabled,
      isBusy: isBusy ?? this.isBusy,
      hasPendingRestoreChoice:
          hasPendingRestoreChoice ?? this.hasPendingRestoreChoice,
      pendingPassphraseSetup: clearPendingPassphraseSetup
          ? false
          : (pendingPassphraseSetup ?? this.pendingPassphraseSetup),
      pendingPassphraseForRestore: clearPendingPassphraseSetup
          ? false
          : (pendingPassphraseForRestore ?? this.pendingPassphraseForRestore),
      remoteMetadata: remoteMetadata ?? this.remoteMetadata,
      localSummary: clearLocalSummary
          ? null
          : (localSummary ?? this.localSummary),
      statusMessage: clearStatusMessage
          ? null
          : (statusMessage ?? this.statusMessage),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

final backupControllerProvider =
    NotifierProvider<BackupController, BackupState>(BackupController.new);

class BackupController extends Notifier<BackupState> {
  static const String _backupEnabledKey = 'backup_enabled';
  static const Duration _autoBackupDelay = Duration(seconds: 8);

  FirebaseBackupRepository? _repository;
  StreamSubscription<BackupAccount?>? _authSub;
  StreamSubscription<void>? _logsSub;
  StreamSubscription<void>? _projectsSub;
  Timer? _autoBackupTimer;
  bool _isRestoring = false;
  bool _bootstrapped = false;

  @override
  BackupState build() {
    final firebaseStatus = ref.watch(firebaseInitStatusProvider);
    final isar = ref.watch(isarProvider);

    ref.onDispose(_dispose);

    if (firebaseStatus.isAvailable) {
      _repository = FirebaseBackupRepository(
        isar: isar,
        auth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instanceFor(
          app: Firebase.app(),
          databaseId: 'default',
        ),
      );
    }

    if (!_bootstrapped) {
      _bootstrapped = true;
      Future.microtask(_bootstrap);
    }

    return BackupState.initial(
      firebaseAvailable: firebaseStatus.isAvailable,
      firebaseError: firebaseStatus.error,
    );
  }

  Future<void> createAccount({
    required String email,
    required String password,
  }) async {
    await _runUserAction(() async {
      final repository = _requireRepository();
      await repository.createAccount(email: email, password: password);
      await _setBackupEnabledPreference(true);
      await _refreshForCurrentAccount(
        statusMessage: 'Backup enabled for this account.',
      );
      await _runPostAuthSync();
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    await _runUserAction(() async {
      final repository = _requireRepository();
      await repository.signIn(email: email, password: password);
      await _setBackupEnabledPreference(true);
      await _refreshForCurrentAccount();
      await _runPostAuthSync();
    });
  }

  Future<void> sendPasswordReset(String email) async {
    await _runUserAction(() async {
      final repository = _requireRepository();
      await repository.sendPasswordReset(email);
      state = state.copyWith(
        statusMessage: 'Password reset email sent.',
        clearErrorMessage: true,
      );
    });
  }

  Future<void> signOut() async {
    await _runUserAction(() async {
      final repository = _requireRepository();
      final uid = state.account?.uid;
      _autoBackupTimer?.cancel();
      await _setBackupEnabledPreference(false);
      if (uid != null) {
        await ref.read(backupPassphraseStoreProvider).delete(uid);
      }
      await repository.signOut();
      state = state.copyWith(
        clearAccount: true,
        backupEnabled: false,
        hasPendingRestoreChoice: false,
        clearPendingPassphraseSetup: true,
        remoteMetadata: const BackupMetadata.empty(),
        clearLocalSummary: true,
        statusMessage: 'Signed out.',
        clearErrorMessage: true,
      );
    });
  }

  Future<void> setBackupEnabled(bool value) async {
    if (state.account == null) {
      state = state.copyWith(
        errorMessage: 'Sign in before enabling backup.',
        clearStatusMessage: true,
      );
      return;
    }

    await _runUserAction(() async {
      await _setBackupEnabledPreference(value);
      state = state.copyWith(
        backupEnabled: value,
        statusMessage: value ? 'Backup enabled.' : 'Backup paused.',
        clearErrorMessage: true,
      );
      if (value) {
        await _runPostAuthSync();
      }
    });
  }

  Future<void> backupNow({
    bool isAutomatic = false,
    required String passphrase,
    bool rememberPassphrase = true,
  }) async {
    if (!state.backupEnabled || state.account == null) return;

    await _runUserAction(
      () => _backupCurrentAccount(
        isAutomatic: isAutomatic,
        passphrase: passphrase,
        rememberPassphrase: rememberPassphrase,
      ),
    );
  }

  Future<void> restoreFromCloud({
    required String passphrase,
    bool rememberPassphrase = true,
  }) async {
    if (state.account == null) return;

    await _runUserAction(() async {
      final repository = _requireRepository();
      final uid = state.account!.uid;
      _isRestoring = true;
      try {
        final metadata = await repository.restoreFullBackup(
          uid: uid,
          passphrase: passphrase,
        );
        if (rememberPassphrase) {
          await ref.read(backupPassphraseStoreProvider).write(uid, passphrase);
        }
        final localSummary = await repository.fetchLocalSummary();
        state = state.copyWith(
          remoteMetadata: metadata,
          localSummary: localSummary,
          hasPendingRestoreChoice: false,
          clearPendingPassphraseSetup: true,
          statusMessage: metadata.exists
              ? 'Cloud backup restored.'
              : 'No cloud backup found.',
          clearErrorMessage: true,
        );
      } finally {
        _isRestoring = false;
      }
    });
  }

  Future<void> keepDeviceData({required String passphrase}) async {
    await backupNow(passphrase: passphrase);
  }

  Future<String?> readStoredPassphrase() async {
    final uid = state.account?.uid;
    if (uid == null) return null;
    return ref.read(backupPassphraseStoreProvider).read(uid);
  }

  Future<bool> hasStoredPassphrase() async {
    final stored = await readStoredPassphrase();
    return stored != null && stored.isNotEmpty;
  }

  Future<void> _backupCurrentAccount({
    required bool isAutomatic,
    required String passphrase,
    bool rememberPassphrase = true,
  }) async {
    if (!state.backupEnabled || state.account == null) return;

    final repository = _requireRepository();
    final uid = state.account!.uid;
    final metadata = await repository.saveFullBackup(
      uid: uid,
      passphrase: passphrase,
    );
    if (rememberPassphrase) {
      await ref.read(backupPassphraseStoreProvider).write(uid, passphrase);
    }
    final localSummary = await repository.fetchLocalSummary();
    state = state.copyWith(
      remoteMetadata: metadata,
      localSummary: localSummary,
      hasPendingRestoreChoice: false,
      clearPendingPassphraseSetup: true,
      statusMessage: isAutomatic ? 'Backup synced.' : 'Backup completed.',
      clearErrorMessage: true,
    );
  }

  void clearPendingPassphraseSetup() {
    state = state.copyWith(clearPendingPassphraseSetup: true);
  }

  void dismissPendingPassphraseSetup({String? statusMessage}) {
    state = state.copyWith(
      clearPendingPassphraseSetup: true,
      statusMessage: statusMessage ?? AppStrings.backupPassphraseDismissed,
      clearErrorMessage: true,
    );
  }

  void clearMessages() {
    state = state.copyWith(clearStatusMessage: true, clearErrorMessage: true);
  }

  Future<void> refresh() async {
    await _runUserAction(() => _refreshForCurrentAccount());
  }

  Future<void> _bootstrap() async {
    final repository = _repository;
    final preferences = await SharedPreferences.getInstance();
    final enabled = preferences.getBool(_backupEnabledKey) ?? false;
    state = state.copyWith(backupEnabled: enabled);

    if (repository == null) return;

    _authSub = repository.authStateChanges().listen((account) {
      unawaited(_handleAuthChange(account));
    });
    _logsSub = repository.watchLocalLogs().listen((_) => _scheduleAutoBackup());
    _projectsSub = repository.watchLocalProjects().listen(
      (_) => _scheduleAutoBackup(),
    );

    final currentAccount = repository.currentAccount;
    if (currentAccount != null) {
      await _handleAuthChange(currentAccount);
    }
  }

  Future<void> _handleAuthChange(BackupAccount? account) async {
    if (account == null) {
      state = state.copyWith(
        clearAccount: true,
        hasPendingRestoreChoice: false,
        clearPendingPassphraseSetup: true,
        remoteMetadata: const BackupMetadata.empty(),
        clearLocalSummary: true,
      );
      return;
    }

    state = state.copyWith(account: account);
    await _refreshForCurrentAccount();
    await _restoreAutomaticallyWhenSafe();
    await _runPostAuthSync();
  }

  Future<void> _refreshForCurrentAccount({String? statusMessage}) async {
    final repository = _repository;
    final account = repository?.currentAccount;
    if (repository == null || account == null) return;

    try {
      final localSummary = await repository.fetchLocalSummary();
      final remoteMetadata = await repository.fetchRemoteMetadata(account.uid);
      state = state.copyWith(
        account: account,
        localSummary: localSummary,
        remoteMetadata: remoteMetadata,
        statusMessage: statusMessage,
        clearErrorMessage: true,
      );
    } on FirebaseException catch (error) {
      state = state.copyWith(
        account: account,
        errorMessage:
            error.message ?? 'Cloud sync unavailable. Try again later.',
      );
    } catch (error) {
      state = state.copyWith(
        account: account,
        errorMessage: 'Could not reach cloud. Try again later.',
      );
    }
  }

  Future<void> _restoreAutomaticallyWhenSafe() async {
    if (!state.backupEnabled ||
        state.account == null ||
        !state.remoteMetadata.exists) {
      return;
    }

    final localSummary = state.localSummary;
    if (localSummary != null && !localSummary.hasData) {
      final passphrase = await readStoredPassphrase();
      if (passphrase != null) {
        await restoreFromCloud(passphrase: passphrase);
      }
      return;
    }

    if (localSummary != null && localSummary.hasData) {
      state = state.copyWith(hasPendingRestoreChoice: true);
    }
  }

  Future<void> _runPostAuthSync() async {
    if (!state.backupEnabled || state.account == null) {
      return;
    }
    if (state.hasPendingRestoreChoice) {
      return;
    }

    final passphrase = await readStoredPassphrase();
    if (passphrase != null) {
      await _backupCurrentAccount(isAutomatic: true, passphrase: passphrase);
      return;
    }

    final localSummary = state.localSummary;
    final remoteMetadata = state.remoteMetadata;

    if (localSummary != null && localSummary.hasData) {
      state = state.copyWith(
        pendingPassphraseSetup: true,
        pendingPassphraseForRestore: false,
        statusMessage: AppStrings.backupSignedInNeedPassphrase,
        clearErrorMessage: true,
      );
      return;
    }

    if (remoteMetadata.exists && remoteMetadata.encrypted) {
      state = state.copyWith(
        pendingPassphraseSetup: true,
        pendingPassphraseForRestore: true,
        statusMessage: AppStrings.backupSignedInNeedPassphraseRestore,
        clearErrorMessage: true,
      );
      return;
    }

    state = state.copyWith(
      clearPendingPassphraseSetup: true,
      statusMessage: AppStrings.backupSignedIn,
      clearErrorMessage: true,
    );
  }

  void _scheduleAutoBackup() {
    if (_isRestoring ||
        !state.backupEnabled ||
        state.account == null ||
        state.isBusy) {
      return;
    }

    _autoBackupTimer?.cancel();
    _autoBackupTimer = Timer(_autoBackupDelay, () async {
      final passphrase = await readStoredPassphrase();
      if (passphrase == null) return;
      await backupNow(isAutomatic: true, passphrase: passphrase);
    });
  }

  Future<void> _setBackupEnabledPreference(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_backupEnabledKey, value);
    state = state.copyWith(backupEnabled: value);
  }

  Future<void> _runUserAction(Future<void> Function() action) async {
    if (state.isBusy) return;

    state = state.copyWith(
      isBusy: true,
      clearStatusMessage: true,
      clearErrorMessage: true,
    );
    try {
      await action();
    } on BackupDecryptException catch (error) {
      state = state.copyWith(errorMessage: error.message);
    } on FirebaseAuthException catch (error) {
      state = state.copyWith(errorMessage: _authErrorMessage(error));
    } on FirebaseException catch (error) {
      state = state.copyWith(errorMessage: error.message ?? error.code);
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    } finally {
      state = state.copyWith(isBusy: false);
    }
  }

  FirebaseBackupRepository _requireRepository() {
    final repository = _repository;
    if (repository == null) {
      throw StateError('Firebase is not configured for this build.');
    }
    return repository;
  }

  String _authErrorMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-email' => 'Enter a valid email address.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'Email or password is incorrect.',
      'email-already-in-use' => 'This email already has an account.',
      'weak-password' => 'Use at least 6 characters for the password.',
      'network-request-failed' => 'Network unavailable. Try again online.',
      _ => error.message ?? error.code,
    };
  }

  void _dispose() {
    _autoBackupTimer?.cancel();
    unawaited(_authSub?.cancel());
    unawaited(_logsSub?.cancel());
    unawaited(_projectsSub?.cancel());
  }
}
