import 'package:isar/isar.dart';

part 'vault_blob.g.dart';

/// Singleton encrypted vault payload stored locally.
@collection
class VaultBlob {
  Id id = 1;

  late String ciphertextBase64;
  late String encryptionSalt;
  late int schemaVersion;
  late DateTime updatedAt;
}
