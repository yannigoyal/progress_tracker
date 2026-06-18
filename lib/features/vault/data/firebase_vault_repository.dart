import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../backup/data/backup_crypto.dart';
import 'vault_models.dart';

class FirebaseVaultRepository {
  static const String _rootCollection = 'userVaults';
  static const String _encryptedDocId = 'payload';

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final BackupCrypto _crypto;

  FirebaseVaultRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    BackupCrypto? crypto,
  }) : _auth = auth,
       _firestore = firestore,
       _crypto = crypto ?? BackupCrypto();

  String? get currentUid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> _vaultDoc(String uid) {
    return _firestore.collection(_rootCollection).doc(uid);
  }

  DocumentReference<Map<String, dynamic>> _payloadRef(String uid) {
    return _vaultDoc(uid).collection('encrypted').doc(_encryptedDocId);
  }

  Future<VaultCloudMetadata> fetchMetadata() async {
    final uid = currentUid;
    if (uid == null) return const VaultCloudMetadata.empty();

    final doc = await _vaultDoc(uid).get();
    if (!doc.exists) return const VaultCloudMetadata.empty();

    final data = doc.data() ?? {};
    return VaultCloudMetadata(
      exists: true,
      lastSyncedAt: (data['lastSyncedAt'] as Timestamp?)?.toDate(),
      entryCount: (data['entryCount'] as int?) ?? 0,
    );
  }

  Future<VaultSnapshot?> download({required String pin}) async {
    final uid = currentUid;
    if (uid == null) return null;

    final root = await _vaultDoc(uid).get();
    if (!root.exists) return null;

    final payload = await _payloadRef(uid).get();
    final payloadData = payload.data();
    if (payloadData == null) return null;

    final salt = root.data()?['encryptionSalt'] as String?;
    final ciphertext = payloadData['ciphertext'] as String?;
    if (salt == null || ciphertext == null) return null;

    final json = await _crypto.decrypt(
      ciphertextBase64: ciphertext,
      passphrase: pin,
      saltBase64: salt,
    );
    return VaultSnapshot.fromJsonString(json);
  }

  Future<void> upload({
    required String pin,
    required VaultSnapshot snapshot,
    String? encryptionSalt,
  }) async {
    final uid = currentUid;
    if (uid == null) {
      throw StateError('Sign in to backup account to sync the vault.');
    }

    final salt = encryptionSalt ?? _crypto.generateSaltBase64();
    final encrypted = await _crypto.encrypt(
      plaintext: snapshot.toJsonString(),
      passphrase: pin,
      saltBase64: salt,
    );

    final now = FieldValue.serverTimestamp();
    final vaultDoc = _vaultDoc(uid);

    await vaultDoc.set({
      'schemaVersion': VaultSnapshot.schemaVersion,
      'encrypted': true,
      'encryptionSalt': salt,
      'entryCount': snapshot.entries.length,
      'lastSyncedAt': now,
    }, SetOptions(merge: true));

    await _payloadRef(uid).set({
      'ciphertext': encrypted.ciphertextBase64,
      'nonceLength': encrypted.nonceLength,
      'macLength': encrypted.macLength,
    });
  }
}
