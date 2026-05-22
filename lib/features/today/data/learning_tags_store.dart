import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LearningTagsStore {
  static const _key = 'learning_user_tags';

  Future<List<String>> loadUserTags() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded.whereType<String>().map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
  }

  Future<void> addTag(String tag) async {
    final normalized = tag.trim();
    if (normalized.isEmpty) return;
    final existing = await loadUserTags();
    final lower = normalized.toLowerCase();
    if (existing.any((t) => t.toLowerCase() == lower)) return;
    existing.add(normalized);
    await _save(existing);
  }

  Future<void> removeTag(String tag) async {
    final existing = await loadUserTags();
    existing.removeWhere((t) => t.toLowerCase() == tag.toLowerCase());
    await _save(existing);
  }

  Future<void> _save(List<String> tags) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(tags));
  }
}
