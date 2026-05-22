import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/category.dart';

class CategoryOrderStore {
  static const _key = 'category_display_order';

  Future<List<Category>> loadOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return List<Category>.from(Category.values);

    try {
      final indices = (jsonDecode(raw) as List).cast<num>().map((n) => n.toInt()).toList();
      final ordered = <Category>[];
      for (final index in indices) {
        if (index >= 0 && index < Category.values.length) {
          final cat = Category.values[index];
          if (!ordered.contains(cat)) ordered.add(cat);
        }
      }
      for (final cat in Category.values) {
        if (!ordered.contains(cat)) ordered.add(cat);
      }
      return ordered;
    } catch (_) {
      return List<Category>.from(Category.values);
    }
  }

  Future<void> saveOrder(List<Category> order) async {
    final prefs = await SharedPreferences.getInstance();
    final indices = order.map((c) => c.index).toList();
    await prefs.setString(_key, jsonEncode(indices));
  }
}
