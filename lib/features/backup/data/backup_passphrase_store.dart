import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores the backup encryption passphrase on-device (Keychain / Keystore).
/// Cleared on backup sign-out.
class BackupPassphraseStore {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String _key(String uid) => 'vaultlog_backup_passphrase_$uid';

  Future<String?> read(String uid) => _storage.read(key: _key(uid));

  Future<void> write(String uid, String passphrase) {
    return _storage.write(key: _key(uid), value: passphrase);
  }

  Future<void> delete(String uid) => _storage.delete(key: _key(uid));
}
