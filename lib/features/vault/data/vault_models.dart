import 'dart:convert';

import 'package:uuid/uuid.dart';

class VaultEntry {
  static const int maxPasswordHistory = 3;
  static const _uuid = Uuid();

  final String id;
  final String appName;
  final String username;
  final String password;
  final List<String> passwordHistory;
  final String? url;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VaultEntry({
    required this.id,
    required this.appName,
    required this.username,
    required this.password,
    this.passwordHistory = const [],
    this.url,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VaultEntry.create({
    required String appName,
    required String username,
    required String password,
    String? url,
    String? notes,
  }) {
    final now = DateTime.now().toUtc();
    return VaultEntry(
      id: _uuid.v4(),
      appName: appName.trim(),
      username: username.trim(),
      password: password,
      url: url?.trim().isEmpty == true ? null : url?.trim(),
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      createdAt: now,
      updatedAt: now,
    );
  }

  VaultEntry copyWith({
    String? appName,
    String? username,
    String? password,
    List<String>? passwordHistory,
    String? url,
    String? notes,
    bool clearUrl = false,
    bool clearNotes = false,
  }) {
    return VaultEntry(
      id: id,
      appName: appName ?? this.appName,
      username: username ?? this.username,
      password: password ?? this.password,
      passwordHistory: passwordHistory ?? this.passwordHistory,
      url: clearUrl ? null : (url ?? this.url),
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  VaultEntry withPasswordUpdate(String newPassword) {
    if (newPassword == password) return this;
    final history = [password, ...passwordHistory]
        .take(maxPasswordHistory)
        .toList();
    return copyWith(password: newPassword, passwordHistory: history);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'appName': appName,
    'username': username,
    'password': password,
    'passwordHistory': passwordHistory,
    'url': url,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory VaultEntry.fromJson(Map<String, dynamic> json) {
    return VaultEntry(
      id: json['id'] as String,
      appName: json['appName'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      passwordHistory: (json['passwordHistory'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      url: json['url'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class VaultSnapshot {
  static const int schemaVersion = 1;

  final List<VaultEntry> entries;

  const VaultSnapshot({required this.entries});

  String toJsonString() => jsonEncode({
    'schemaVersion': schemaVersion,
    'entries': entries.map((e) => e.toJson()).toList(),
  });

  factory VaultSnapshot.fromJsonString(String jsonString) {
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    final raw = map['entries'] as List<dynamic>? ?? [];
    return VaultSnapshot(
      entries: raw
          .map((e) => VaultEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class VaultCloudMetadata {
  final bool exists;
  final DateTime? lastSyncedAt;
  final int entryCount;

  const VaultCloudMetadata({
    required this.exists,
    this.lastSyncedAt,
    this.entryCount = 0,
  });

  const VaultCloudMetadata.empty() : exists = false, lastSyncedAt = null, entryCount = 0;
}
