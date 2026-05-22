import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CustomActivityIconStorage {
  static const int iconSize = 64;
  static const String folderName = 'custom_icons';

  final ImagePicker _picker = ImagePicker();

  Future<Directory> _iconsDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/$folderName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Relative path for Isar, e.g. `custom_icons/3.png`.
  String relativePathForId(int activityId) => '$folderName/$activityId.png';

  Future<File?> resolveFile(String? relativePath) async {
    if (relativePath == null || relativePath.trim().isEmpty) return null;
    final docs = await getApplicationDocumentsDirectory();
    final file = File('${docs.path}/$relativePath');
    return file.existsSync() ? file : null;
  }

  Future<Uint8List?> pickPngBytes() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (picked == null) return null;

    final name = picked.name.toLowerCase();
    if (!name.endsWith('.png')) {
      throw CustomActivityIconException(
        'Only PNG images are supported. Choose a .png file.',
      );
    }

    final bytes = await picked.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw CustomActivityIconException('Could not read PNG image.');
    }

    final resized = img.copyResizeCropSquare(decoded, size: iconSize);
    return Uint8List.fromList(img.encodePng(resized));
  }

  Future<String?> pickAndSavePng(int activityId) async {
    final pngBytes = await pickPngBytes();
    if (pngBytes == null) return null;
    return savePngBytes(activityId, pngBytes);
  }

  Future<String?> savePngBytes(int activityId, Uint8List pngBytes) async {
    final dir = await _iconsDir();
    final file = File('${dir.path}/$activityId.png');
    await file.writeAsBytes(pngBytes, flush: true);
    return relativePathForId(activityId);
  }

  Future<void> deleteIconFile(String? relativePath) async {
    final file = await resolveFile(relativePath);
    if (file != null && await file.exists()) {
      await file.delete();
    }
  }

  Future<String?> readBase64(String? relativePath) async {
    final file = await resolveFile(relativePath);
    if (file == null) return null;
    return base64Encode(await file.readAsBytes());
  }

  Future<void> restoreFromBase64(int activityId, String base64) async {
    try {
      await savePngBytes(activityId, base64Decode(base64));
    } catch (_) {
      // Ignore corrupt backup icon data.
    }
  }
}

class CustomActivityIconException implements Exception {
  final String message;
  const CustomActivityIconException(this.message);

  @override
  String toString() => message;
}
