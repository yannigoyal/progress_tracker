class BackupAccount {
  final String uid;
  final String? email;

  const BackupAccount({required this.uid, required this.email});
}

class BackupMetadata {
  final bool exists;
  final DateTime? lastBackupAt;
  final int logCount;
  final int projectCount;
  final bool encrypted;

  const BackupMetadata({
    required this.exists,
    this.lastBackupAt,
    this.logCount = 0,
    this.projectCount = 0,
    this.encrypted = false,
  });

  const BackupMetadata.empty()
    : exists = false,
      lastBackupAt = null,
      logCount = 0,
      projectCount = 0,
      encrypted = false;
}

/// Thrown when decrypting a cloud backup fails (wrong passphrase or corrupt data).
class BackupDecryptException implements Exception {
  final String message;

  const BackupDecryptException(this.message);

  @override
  String toString() => message;
}

class LocalBackupSummary {
  final int logCount;
  final int projectCount;
  final DateTime? latestActivityAt;

  const LocalBackupSummary({
    required this.logCount,
    required this.projectCount,
    required this.latestActivityAt,
  });

  bool get hasData => logCount > 0 || projectCount > 0;
}
