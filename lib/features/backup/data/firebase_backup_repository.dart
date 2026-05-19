import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isar/isar.dart';

import '../../../core/models/log_entry.dart';
import '../../../core/models/project.dart';
import 'backup_models.dart';

class FirebaseBackupRepository {
  static const int schemaVersion = 1;
  static const String _rootCollection = 'userBackups';

  final Isar _isar;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  const FirebaseBackupRepository({
    required Isar isar,
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _isar = isar,
       _auth = auth,
       _firestore = firestore;

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
    );
  }

  Future<BackupMetadata> saveFullBackup(String uid) async {
    final logs = await _isar.logEntrys.where().sortByCreatedAt().findAll();
    final projects = await _isar.projects.where().sortByCreatedAt().findAll();

    final backupDoc = _backupDoc(uid);
    final writer = _FirestoreBatchWriter(_firestore);

    writer.set(backupDoc, {
      'schemaVersion': schemaVersion,
      'status': 'writing',
      'startedAt': FieldValue.serverTimestamp(),
    }, merge: true);

    await _deleteCollection(backupDoc.collection('logs'), writer);
    await _deleteCollection(backupDoc.collection('projects'), writer);

    for (final log in logs) {
      writer.set(
        backupDoc.collection('logs').doc(log.id.toString()),
        _logToFirestore(log),
      );
    }

    for (final project in projects) {
      writer.set(
        backupDoc.collection('projects').doc(project.id.toString()),
        _projectToFirestore(project),
      );
    }

    final clientBackupAt = DateTime.now().toUtc();
    writer.set(backupDoc, {
      'schemaVersion': schemaVersion,
      'status': 'complete',
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
    );
  }

  Future<BackupMetadata> restoreFullBackup(String uid) async {
    final metadata = await fetchRemoteMetadata(uid);
    if (!metadata.exists) return metadata;

    final backupDoc = _backupDoc(uid);
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

    await _isar.writeTxn(() async {
      await _isar.logEntrys.clear();
      await _isar.projects.clear();
      await _isar.projects.putAll(projects);
      await _isar.logEntrys.putAll(logs);
    });

    return BackupMetadata(
      exists: true,
      lastBackupAt: metadata.lastBackupAt,
      logCount: logs.length,
      projectCount: projects.length,
    );
  }

  DocumentReference<Map<String, dynamic>> _backupDoc(String uid) {
    return _firestore.collection(_rootCollection).doc(uid);
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

  Map<String, dynamic> _logToFirestore(LogEntry log) {
    return {
      'isarId': log.id,
      'createdAt': Timestamp.fromDate(log.createdAt.toUtc()),
      'categoryIndex': log.categoryIndex,
      'payloadJson': log.payloadJson,
    };
  }

  Map<String, dynamic> _projectToFirestore(Project project) {
    return {
      'isarId': project.id,
      'name': project.name,
      'description': project.description,
      'statusIndex': project.statusIndex,
      'createdAt': Timestamp.fromDate(project.createdAt.toUtc()),
    };
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
