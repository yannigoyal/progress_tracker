import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isar/isar.dart';

import '../../../core/models/custom_activity.dart';
import '../../../core/models/log_entry.dart';
import '../../../core/models/project.dart';
import '../../settings/data/custom_activity_icon_storage.dart';
import 'backup_crypto.dart';
import 'backup_models.dart';
import 'backup_serializer.dart';

class FirebaseBackupRepository {
  static const int legacySchemaVersion = 1;
  static const String _rootCollection = 'userBackups';
  static const String _encryptedDocId = 'payload';

  final Isar _isar;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final BackupCrypto _crypto;

  FirebaseBackupRepository({
    required Isar isar,
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    BackupCrypto? crypto,
  }) : _isar = isar,
       _auth = auth,
       _firestore = firestore,
       _crypto = crypto ?? BackupCrypto();

  BackupAccount? get currentAccount {
    final user = _auth.currentUser;
    if (user == null) return null;
    return BackupAccount(uid: user.uid, email: user.email);
  }

  Stream<BackupAccount?> authStateChanges() {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return BackupAccount(uid: user.uid, email: user.email);
    });
  }

  Stream<void> watchLocalLogs() {
    return _isar.logEntrys.watchLazy(fireImmediately: false);
  }

  Stream<void> watchLocalProjects() {
    return _isar.projects.watchLazy(fireImmediately: false);
  }

  Future<void> createAccount({
    required String email,
    required String password,
  }) async {
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  Future<LocalBackupSummary> fetchLocalSummary() async {
    final logs = await _isar.logEntrys.count();
    final projects = await _isar.projects.count();
    final latestLog = await _isar.logEntrys
        .where()
        .sortByCreatedAtDesc()
        .findFirst();
    final latestProject = await _isar.projects
        .where()
        .sortByCreatedAtDesc()
        .findFirst();

    final latestLogDate = latestLog?.createdAt;
    final latestProjectDate = latestProject?.createdAt;
    DateTime? latestActivityAt;
    if (latestLogDate != null && latestProjectDate != null) {
      latestActivityAt = latestLogDate.isAfter(latestProjectDate)
          ? latestLogDate
          : latestProjectDate;
    } else {
      latestActivityAt = latestLogDate ?? latestProjectDate;
    }

    return LocalBackupSummary(
      logCount: logs,
      projectCount: projects,
      latestActivityAt: latestActivityAt,
    );
  }

  Future<BackupMetadata> fetchRemoteMetadata(String uid) async {
    final doc = await _backupDoc(uid).get();
    if (!doc.exists) return const BackupMetadata.empty();

    final data = doc.data();
    if (data == null || data['status'] != 'complete') {
      return const BackupMetadata.empty();
    }

    return BackupMetadata(
      exists: true,
      lastBackupAt: _readDate(data['lastBackupAt']),
      logCount: _readInt(data['logCount']) ?? 0,
      projectCount: _readInt(data['projectCount']) ?? 0,
      encrypted: data['encrypted'] == true,
    );
  }

  Future<BackupMetadata> saveFullBackup({
    required String uid,
    required String passphrase,
  }) async {
    final logs = await _isar.logEntrys.where().sortByCreatedAt().findAll();
    final projects = await _isar.projects.where().sortByCreatedAt().findAll();
    final customActivities =
        await _isar.customActivitys.where().sortBySortOrder().findAll();

    final backupDoc = _backupDoc(uid);
    final writer = _FirestoreBatchWriter(_firestore);

    final existing = await backupDoc.get();
    final existingData = existing.data();
    final saltBase64 = existingData?['encryptionSalt'] as String? ??
        _crypto.generateSaltBase64();

    final iconStorage = CustomActivityIconStorage();
    final snapshot = BackupSnapshot(
      logs: logs,
      projects: projects,
      customActivities: customActivities,
    );
    final encrypted = await _crypto.encrypt(
      plaintext: await snapshot.toJsonString(iconStorage: iconStorage),
      passphrase: passphrase,
      saltBase64: saltBase64,
    );

    writer.set(backupDoc, {
      'schemaVersion': BackupCrypto.schemaVersion,
      'status': 'writing',
      'encrypted': true,
      'encryptionSalt': saltBase64,
      'startedAt': FieldValue.serverTimestamp(),
    }, merge: true);

    await _deleteCollection(backupDoc.collection('logs'), writer);
    await _deleteCollection(backupDoc.collection('projects'), writer);

    writer.set(_encryptedPayloadRef(uid), {
      'ciphertext': encrypted.ciphertextBase64,
      'nonceLength': encrypted.nonceLength,
      'macLength': encrypted.macLength,
    });

    final clientBackupAt = DateTime.now().toUtc();
    writer.set(backupDoc, {
      'schemaVersion': BackupCrypto.schemaVersion,
      'status': 'complete',
      'encrypted': true,
      'encryptionSalt': saltBase64,
      'lastBackupAt': FieldValue.serverTimestamp(),
      'clientBackupAt': Timestamp.fromDate(clientBackupAt),
      'logCount': logs.length,
      'projectCount': projects.length,
    }, merge: true);

    await writer.commit();

    return BackupMetadata(
      exists: true,
      lastBackupAt: clientBackupAt,
      logCount: logs.length,
      projectCount: projects.length,
      encrypted: true,
    );
  }

  Future<BackupMetadata> restoreFullBackup({
    required String uid,
    required String passphrase,
  }) async {
    final metadata = await fetchRemoteMetadata(uid);
    if (!metadata.exists) return metadata;

    final backupDoc = _backupDoc(uid);
    final root = await backupDoc.get();
    final rootData = root.data();
    if (rootData == null) return const BackupMetadata.empty();

    final BackupSnapshot snapshot;
    if (rootData['encrypted'] == true) {
      snapshot = await _restoreEncrypted(uid, passphrase, rootData);
    } else {
      snapshot = await _restoreLegacyPlaintext(backupDoc);
    }

    final iconStorage = CustomActivityIconStorage();
    await snapshot.restoreCustomIcons(iconStorage);

    await _isar.writeTxn(() async {
      await _isar.logEntrys.clear();
      await _isar.projects.clear();
      await _isar.customActivitys.clear();
      await _isar.customActivitys.putAll(snapshot.customActivities);
      await _isar.projects.putAll(snapshot.projects);
      await _isar.logEntrys.putAll(snapshot.logs);
    });

    return BackupMetadata(
      exists: true,
      lastBackupAt: metadata.lastBackupAt,
      logCount: snapshot.logs.length,
      projectCount: snapshot.projects.length,
      encrypted: metadata.encrypted,
    );
  }

  Future<BackupSnapshot> _restoreEncrypted(
    String uid,
    String passphrase,
    Map<String, dynamic> rootData,
  ) async {
    final saltBase64 = rootData['encryptionSalt'] as String?;
    if (saltBase64 == null) {
      throw const BackupDecryptException('Backup is missing encryption salt.');
    }

    final payloadDoc = await _encryptedPayloadRef(uid).get();
    final payloadData = payloadDoc.data();
    final ciphertext = payloadData?['ciphertext'] as String?;
    if (ciphertext == null) {
      throw const BackupDecryptException('Encrypted backup payload not found.');
    }

    try {
      final jsonString = await _crypto.decrypt(
        ciphertextBase64: ciphertext,
        passphrase: passphrase,
        saltBase64: saltBase64,
      );
      return BackupSnapshot.fromJsonString(jsonString);
    } on SecretBoxAuthenticationError {
      throw const BackupDecryptException(
        'Wrong backup passphrase. Check the phrase you used when backing up.',
      );
    } catch (_) {
      throw const BackupDecryptException(
        'Could not decrypt backup. The passphrase may be wrong or the file is corrupt.',
      );
    }
  }

  Future<BackupSnapshot> _restoreLegacyPlaintext(
    DocumentReference<Map<String, dynamic>> backupDoc,
  ) async {
    final logDocs = await backupDoc
        .collection('logs')
        .orderBy('createdAt')
        .get();
    final projectDocs = await backupDoc
        .collection('projects')
        .orderBy('createdAt')
        .get();

    final logs = logDocs.docs
        .map((doc) => _logFromFirestore(doc.data()))
        .whereType<LogEntry>()
        .toList();
    final projects = projectDocs.docs
        .map((doc) => _projectFromFirestore(doc.data()))
        .whereType<Project>()
        .toList();

    return BackupSnapshot(logs: logs, projects: projects);
  }

  DocumentReference<Map<String, dynamic>> _backupDoc(String uid) {
    return _firestore.collection(_rootCollection).doc(uid);
  }

  DocumentReference<Map<String, dynamic>> _encryptedPayloadRef(String uid) {
    return _backupDoc(uid).collection('encrypted').doc(_encryptedDocId);
  }

  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collection,
    _FirestoreBatchWriter writer,
  ) async {
    final snapshot = await collection.get();
    for (final doc in snapshot.docs) {
      writer.delete(doc.reference);
    }
  }

  LogEntry? _logFromFirestore(Map<String, dynamic> data) {
    final id = _readInt(data['isarId']);
    final createdAt = _readDate(data['createdAt']);
    final categoryIndex = _readInt(data['categoryIndex']);
    final payloadJson = data['payloadJson'] as String?;

    if (id == null ||
        createdAt == null ||
        categoryIndex == null ||
        payloadJson == null) {
      return null;
    }

    return LogEntry()
      ..id = id
      ..createdAt = createdAt.toUtc()
      ..categoryIndex = categoryIndex
      ..payloadJson = payloadJson;
  }

  Project? _projectFromFirestore(Map<String, dynamic> data) {
    final id = _readInt(data['isarId']);
    final statusIndex = _readInt(data['statusIndex']);
    final createdAt = _readDate(data['createdAt']);
    final name = data['name'] as String?;
    final description = data['description'] as String?;

    if (id == null ||
        statusIndex == null ||
        createdAt == null ||
        name == null ||
        description == null) {
      return null;
    }

    return Project()
      ..id = id
      ..name = name
      ..description = description
      ..statusIndex = statusIndex
      ..createdAt = createdAt.toUtc();
  }

  static int? _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  static DateTime? _readDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

class _FirestoreBatchWriter {
  static const int _maxOpsPerBatch = 450;

  final FirebaseFirestore _firestore;
  late WriteBatch _batch;
  int _ops = 0;
  Future<void> _pendingCommit = Future.value();

  _FirestoreBatchWriter(this._firestore) {
    _batch = _firestore.batch();
  }

  void set(
    DocumentReference<Map<String, dynamic>> reference,
    Map<String, dynamic> data, {
    bool merge = false,
  }) {
    _rotateIfFull();
    _batch.set(reference, data, merge ? SetOptions(merge: true) : null);
    _ops++;
  }

  void delete(DocumentReference<Map<String, dynamic>> reference) {
    _rotateIfFull();
    _batch.delete(reference);
    _ops++;
  }

  Future<void> commit() async {
    await _pendingCommit;
    if (_ops == 0) return;
    final batch = _batch;
    _batch = _firestore.batch();
    _ops = 0;
    await batch.commit();
  }

  void _rotateIfFull() {
    if (_ops < _maxOpsPerBatch) return;
    final batch = _batch;
    _pendingCommit = _pendingCommit.then((_) => batch.commit());
    _batch = _firestore.batch();
    _ops = 0;
  }
}
