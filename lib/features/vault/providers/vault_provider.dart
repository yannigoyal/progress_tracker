import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/firebase_provider.dart';
import '../../../core/providers/isar_provider.dart';
import '../data/firebase_vault_repository.dart';
import '../data/vault_local_repository.dart';
import '../data/vault_models.dart';
import '../data/vault_pin_store.dart';
import '../../backup/providers/backup_provider.dart';

final vaultPinStoreProvider = Provider<VaultPinStore>((ref) => VaultPinStore());

final vaultLocalRepositoryProvider = Provider<VaultLocalRepository>((ref) {
  return VaultLocalRepository(isar: ref.watch(isarProvider));
});

final firebaseVaultRepositoryProvider = Provider<FirebaseVaultRepository?>((ref) {
  final firebaseStatus = ref.watch(firebaseInitStatusProvider);
  if (!firebaseStatus.isAvailable) return null;
  return FirebaseVaultRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'default',
    ),
  );
});

enum VaultPhase { loading, setup, locked, unlocked }

class VaultState {
  final VaultPhase phase;
  final List<VaultEntry> entries;
  final bool isBusy;
  final String? statusMessage;
  final String? errorMessage;
  final bool cloudSyncAvailable;
  final DateTime? lockoutUntil;
  final int failedAttempts;

  const VaultState({
    required this.phase,
    required this.entries,
    required this.isBusy,
    this.statusMessage,
    this.errorMessage,
    required this.cloudSyncAvailable,
    this.lockoutUntil,
    this.failedAttempts = 0,
  });

  factory VaultState.initial({required bool cloudSyncAvailable}) {
    return VaultState(
      phase: VaultPhase.loading,
      entries: const [],
      isBusy: false,
      cloudSyncAvailable: cloudSyncAvailable,
    );
  }

  VaultState copyWith({
    VaultPhase? phase,
    List<VaultEntry>? entries,
    bool? isBusy,
    String? statusMessage,
    String? errorMessage,
    bool clearStatus = false,
    bool clearError = false,
    bool? cloudSyncAvailable,
    DateTime? lockoutUntil,
    bool clearLockout = false,
    int? failedAttempts,
  }) {
    return VaultState(
      phase: phase ?? this.phase,
      entries: entries ?? this.entries,
      isBusy: isBusy ?? this.isBusy,
      statusMessage: clearStatus ? null : (statusMessage ?? this.statusMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      cloudSyncAvailable: cloudSyncAvailable ?? this.cloudSyncAvailable,
      lockoutUntil: clearLockout ? null : (lockoutUntil ?? this.lockoutUntil),
      failedAttempts: failedAttempts ?? this.failedAttempts,
    );
  }
}

class VaultController extends Notifier<VaultState> {
  String? _sessionPin;
  bool _bootstrapped = false;

  VaultPinStore get _pinStore => ref.read(vaultPinStoreProvider);
  VaultLocalRepository get _local => ref.read(vaultLocalRepositoryProvider);
  FirebaseVaultRepository? get _cloud => ref.read(firebaseVaultRepositoryProvider);

  @override
  VaultState build() {
    final backupAccount = ref.watch(
      backupControllerProvider.select((s) => s.account),
    );
    final cloudAvailable =
        ref.watch(firebaseInitStatusProvider).isAvailable &&
        backupAccount != null;

    if (!_bootstrapped) {
      _bootstrapped = true;
      Future.microtask(_bootstrap);
    }

    return VaultState.initial(cloudSyncAvailable: cloudAvailable);
  }

  Future<void> _bootstrap() async {
    final configured = await _pinStore.isConfigured();
    if (!configured) {
      state = state.copyWith(phase: VaultPhase.setup, clearError: true);
      return;
    }
    state = state.copyWith(
      phase: VaultPhase.locked,
      cloudSyncAvailable: _isCloudReady(),
      clearError: true,
    );
    await _refreshLockoutInfo();
  }

  bool _isCloudReady() {
    final firebase = ref.read(firebaseInitStatusProvider).isAvailable;
    final account = ref.read(backupControllerProvider).account;
    return firebase && account != null;
  }

  Future<void> _refreshLockoutInfo() async {
    state = state.copyWith(
      lockoutUntil: await _pinStore.lockoutUntil(),
      failedAttempts: await _pinStore.failedAttempts(),
    );
  }

  Future<void> setupPin(String pin, String confirmPin) async {
    if (!_isValidPin(pin)) {
      state = state.copyWith(
        errorMessage: 'PIN must be exactly 6 digits.',
        clearStatus: true,
      );
      return;
    }
    if (pin != confirmPin) {
      state = state.copyWith(
        errorMessage: 'PINs do not match.',
        clearStatus: true,
      );
      return;
    }

    state = state.copyWith(isBusy: true, clearError: true, clearStatus: true);
    try {
      await _pinStore.savePin(pin);
      await _local.save(
        pin: pin,
        snapshot: const VaultSnapshot(entries: []),
      );
      _sessionPin = pin;
      if (_isCloudReady()) {
        await _cloud?.upload(pin: pin, snapshot: const VaultSnapshot(entries: []));
      }
      state = state.copyWith(
        phase: VaultPhase.unlocked,
        entries: const [],
        isBusy: false,
        statusMessage: 'Vault created. Add your first password.',
        cloudSyncAvailable: _isCloudReady(),
      );
    } catch (error) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: '$error',
      );
    }
  }

  Future<void> unlock(String pin) async {
    if (!_isValidPin(pin)) {
      state = state.copyWith(
        errorMessage: 'PIN must be exactly 6 digits.',
        clearStatus: true,
      );
      return;
    }

    final lockout = await _pinStore.lockoutUntil();
    if (lockout != null && DateTime.now().isBefore(lockout)) {
      await _refreshLockoutInfo();
      state = state.copyWith(
        errorMessage: 'Too many attempts. Try again later.',
        clearStatus: true,
      );
      return;
    }

    state = state.copyWith(isBusy: true, clearError: true, clearStatus: true);
    try {
      final valid = await _pinStore.verifyPin(pin);
      if (!valid) {
        await _refreshLockoutInfo();
        state = state.copyWith(
          isBusy: false,
          errorMessage: 'Incorrect PIN.',
        );
        return;
      }

      var snapshot = await _local.load(pin: pin);
      if (_isCloudReady()) {
        snapshot = await _mergeWithCloud(pin: pin, local: snapshot) ?? snapshot;
      }

      _sessionPin = pin;
      state = state.copyWith(
        phase: VaultPhase.unlocked,
        entries: _sorted(snapshot.entries),
        isBusy: false,
        cloudSyncAvailable: _isCloudReady(),
        clearLockout: true,
        failedAttempts: 0,
      );
    } catch (error) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: 'Could not unlock vault. Check your PIN.',
      );
    }
  }

  Future<VaultSnapshot?> _mergeWithCloud({
    required String pin,
    required VaultSnapshot local,
  }) async {
    final cloudRepo = _cloud;
    if (cloudRepo == null) return null;

    final metadata = await cloudRepo.fetchMetadata();
    if (!metadata.exists) {
      final salt = await _local.encryptionSalt();
      await cloudRepo.upload(pin: pin, snapshot: local, encryptionSalt: salt);
      return local;
    }

    final cloudSnapshot = await cloudRepo.download(pin: pin);
    if (cloudSnapshot == null) return local;

    final localUpdated = await _local.localUpdatedAt();
    final cloudUpdated = metadata.lastSyncedAt;
    final useCloud = cloudUpdated != null &&
        (localUpdated == null || cloudUpdated.isAfter(localUpdated));

    final chosen = useCloud ? cloudSnapshot : local;
    final salt = await _local.encryptionSalt();
    await _local.save(pin: pin, snapshot: chosen, encryptionSalt: salt);
    if (!useCloud) {
      await cloudRepo.upload(pin: pin, snapshot: chosen, encryptionSalt: salt);
    }
    return chosen;
  }

  void lock() {
    _sessionPin = null;
    state = state.copyWith(
      phase: VaultPhase.locked,
      entries: const [],
      clearStatus: true,
      clearError: true,
    );
  }

  Future<void> addEntry(VaultEntry entry) async {
    await _persist(entries: [...state.entries, entry]);
  }

  Future<void> updateEntry(VaultEntry entry) async {
    final updated = state.entries
        .map((e) => e.id == entry.id ? entry : e)
        .toList();
    await _persist(entries: updated);
  }

  Future<void> deleteEntry(String id) async {
    final updated = state.entries.where((e) => e.id != id).toList();
    await _persist(entries: updated);
  }

  Future<void> _persist({required List<VaultEntry> entries}) async {
    final pin = _sessionPin;
    if (pin == null) {
      state = state.copyWith(errorMessage: 'Vault is locked.');
      return;
    }

    state = state.copyWith(isBusy: true, clearError: true);
    try {
      final snapshot = VaultSnapshot(entries: entries);
      final salt = await _local.encryptionSalt();
      await _local.save(pin: pin, snapshot: snapshot, encryptionSalt: salt);
      if (_isCloudReady()) {
        await _cloud?.upload(
          pin: pin,
          snapshot: snapshot,
          encryptionSalt: salt,
        );
      }
      state = state.copyWith(
        entries: _sorted(entries),
        isBusy: false,
        statusMessage: 'Saved.',
      );
    } catch (error) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: '$error',
      );
    }
  }

  VaultEntry? entryById(String id) {
    for (final entry in state.entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  List<VaultEntry> _sorted(List<VaultEntry> entries) {
    final copy = [...entries];
    copy.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    return copy;
  }

  bool _isValidPin(String pin) =>
      pin.length == 6 && RegExp(r'^\d{6}$').hasMatch(pin);
}

final vaultControllerProvider =
    NotifierProvider<VaultController, VaultState>(VaultController.new);
