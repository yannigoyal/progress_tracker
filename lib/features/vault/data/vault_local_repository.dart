import 'package:isar/isar.dart';

import '../../../core/models/vault_blob.dart';
import '../../backup/data/backup_crypto.dart';
import 'vault_models.dart';

class VaultLocalRepository {
  static const int _singletonId = 1;

  final Isar _isar;
  final BackupCrypto _crypto;

  VaultLocalRepository({
    required Isar isar,
    BackupCrypto? crypto,
  }) : _isar = isar,
       _crypto = crypto ?? BackupCrypto();

  Future<bool> hasLocalVault() async {
    final blob = await _isar.vaultBlobs.get(_singletonId);
    return blob != null;
  }

  Future<DateTime?> localUpdatedAt() async {
    final blob = await _isar.vaultBlobs.get(_singletonId);
    return blob?.updatedAt;
  }

  Future<VaultSnapshot> load({required String pin}) async {
    final blob = await _isar.vaultBlobs.get(_singletonId);
    if (blob == null) return const VaultSnapshot(entries: []);

    final json = await _crypto.decrypt(
      ciphertextBase64: blob.ciphertextBase64,
      passphrase: pin,
      saltBase64: blob.encryptionSalt,
    );
    return VaultSnapshot.fromJsonString(json);
  }

  Future<void> save({
    required String pin,
    required VaultSnapshot snapshot,
    String? encryptionSalt,
  }) async {
    final salt = encryptionSalt ?? _crypto.generateSaltBase64();
    final encrypted = await _crypto.encrypt(
      plaintext: snapshot.toJsonString(),
      passphrase: pin,
      saltBase64: salt,
    );

    final blob = VaultBlob()
      ..id = _singletonId
      ..ciphertextBase64 = encrypted.ciphertextBase64
      ..encryptionSalt = salt
      ..schemaVersion = VaultSnapshot.schemaVersion
      ..updatedAt = DateTime.now().toUtc();

    await _isar.writeTxn(() => _isar.vaultBlobs.put(blob));
  }

  Future<String?> encryptionSalt() async {
    final blob = await _isar.vaultBlobs.get(_singletonId);
    return blob?.encryptionSalt;
  }

  Future<void> deleteLocal() async {
    await _isar.writeTxn(() => _isar.vaultBlobs.delete(_singletonId));
  }
}
