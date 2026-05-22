import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';

/// Client-side encryption for cloud backups. Firestore only stores ciphertext;
/// the user passphrase never leaves the device (except in secure local storage
/// for convenience on repeat backups).
class BackupCrypto {
  static const int schemaVersion = 2;
  static const int pbkdf2Iterations = 120000;
  static const int _saltLength = 16;
  static const int _nonceLength = 12;
  static const int _macLength = 16;

  final AesGcm _algorithm = AesGcm.with256bits();
  final Pbkdf2 _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: pbkdf2Iterations,
    bits: 256,
  );

  String generateSaltBase64() {
    return base64Encode(_randomBytes(_saltLength));
  }

  Future<EncryptedBackupBlob> encrypt({
    required String plaintext,
    required String passphrase,
    required String saltBase64,
  }) async {
    final salt = base64Decode(saltBase64);
    final secretKey = await _deriveKey(passphrase, salt);
    final nonce = _randomBytes(_nonceLength);
    final secretBox = await _algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
      nonce: nonce,
    );

    return EncryptedBackupBlob(
      ciphertextBase64: base64Encode(secretBox.concatenation()),
      nonceLength: _nonceLength,
      macLength: _macLength,
    );
  }

  Future<String> decrypt({
    required String ciphertextBase64,
    required String passphrase,
    required String saltBase64,
  }) async {
    final salt = base64Decode(saltBase64);
    final secretKey = await _deriveKey(passphrase, salt);
    final concatenation = base64Decode(ciphertextBase64);
    final secretBox = SecretBox.fromConcatenation(
      concatenation,
      nonceLength: _nonceLength,
      macLength: _macLength,
    );
    final clearBytes = await _algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );
    return utf8.decode(clearBytes);
  }

  Future<SecretKey> _deriveKey(String passphrase, List<int> salt) {
    return _pbkdf2.deriveKeyFromPassword(
      password: passphrase,
      nonce: salt,
    );
  }

  List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
}

class EncryptedBackupBlob {
  final String ciphertextBase64;
  final int nonceLength;
  final int macLength;

  const EncryptedBackupBlob({
    required this.ciphertextBase64,
    required this.nonceLength,
    required this.macLength,
  });
}
