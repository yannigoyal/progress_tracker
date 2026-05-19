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

  const BackupMetadata({
    required this.exists,
    this.lastBackupAt,
    this.logCount = 0,
    this.projectCount = 0,
  });

  const BackupMetadata.empty()
    : exists = false,
      lastBackupAt = null,
      logCount = 0,
      projectCount = 0;
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
