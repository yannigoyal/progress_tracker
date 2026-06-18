import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores vault PIN verification hash and setup flag (never the raw PIN).
class VaultPinStore {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _configuredKey = 'vaultlog_vault_pin_configured';
  static const _hashKey = 'vaultlog_vault_pin_hash';
  static const _saltKey = 'vaultlog_vault_pin_salt';
  static const _failedAttemptsKey = 'vaultlog_vault_failed_attempts';
  static const _lockoutUntilKey = 'vaultlog_vault_lockout_until';

  static const int maxFailedAttempts = 5;
  static const Duration lockoutDuration = Duration(seconds: 30);

  final Sha256 _sha256 = Sha256();

  Future<bool> isConfigured() async {
    final value = await _storage.read(key: _configuredKey);
    return value == 'true';
  }

  Future<void> savePin(String pin) async {
    final salt = _randomSalt();
    final hash = await _hashPin(pin, salt);
    await _storage.write(key: _saltKey, value: salt);
    await _storage.write(key: _hashKey, value: hash);
    await _storage.write(key: _configuredKey, value: 'true');
    await _resetFailedAttempts();
  }

  Future<bool> verifyPin(String pin) async {
    final lockoutUntil = await _lockoutUntil();
    if (lockoutUntil != null && DateTime.now().isBefore(lockoutUntil)) {
      return false;
    }

    final salt = await _storage.read(key: _saltKey);
    final storedHash = await _storage.read(key: _hashKey);
    if (salt == null || storedHash == null) return false;

    final hash = await _hashPin(pin, salt);
    final valid = hash == storedHash;
    if (valid) {
      await _resetFailedAttempts();
      return true;
    }

    await _recordFailedAttempt();
    return false;
  }

  Future<DateTime?> lockoutUntil() => _lockoutUntil();

  Future<int> failedAttempts() async {
    final raw = await _storage.read(key: _failedAttemptsKey);
    return int.tryParse(raw ?? '') ?? 0;
  }

  Future<void> clear() async {
    await _storage.delete(key: _configuredKey);
    await _storage.delete(key: _hashKey);
    await _storage.delete(key: _saltKey);
    await _storage.delete(key: _failedAttemptsKey);
    await _storage.delete(key: _lockoutUntilKey);
  }

  Future<DateTime?> _lockoutUntil() async {
    final raw = await _storage.read(key: _lockoutUntilKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> _recordFailedAttempt() async {
    final attempts = await failedAttempts() + 1;
    await _storage.write(key: _failedAttemptsKey, value: '$attempts');
    if (attempts >= maxFailedAttempts) {
      final until = DateTime.now().add(lockoutDuration);
      await _storage.write(
        key: _lockoutUntilKey,
        value: until.toIso8601String(),
      );
    }
  }

  Future<void> _resetFailedAttempts() async {
    await _storage.delete(key: _failedAttemptsKey);
    await _storage.delete(key: _lockoutUntilKey);
  }

  Future<String> _hashPin(String pin, String salt) async {
    final mac = await _sha256.hash(utf8.encode('$salt:$pin'));
    return base64Encode(mac.bytes);
  }

  String _randomSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }
}
