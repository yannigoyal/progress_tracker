import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/category.dart';
import '../../util/string_constant.dart';
import 'providers/category_order_provider.dart';

class CategoryOrderScreen extends ConsumerStatefulWidget {
  const CategoryOrderScreen({super.key});

  @override
  ConsumerState<CategoryOrderScreen> createState() =>
      _CategoryOrderScreenState();
}

class _CategoryOrderScreenState extends ConsumerState<CategoryOrderScreen> {
  List<Category>? _order;

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(categoryOrderProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.categoryOrderTitle)),
      body: orderAsync.when(
        data: (order) {
          final list = _order ??= List<Category>.from(order);
          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: list.length,
            onReorder: (oldIndex, newIndex) async {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = list.removeAt(oldIndex);
                list.insert(newIndex, item);
              });
              await ref.read(categoryOrderStoreProvider).saveOrder(list);
              ref.invalidate(categoryOrderProvider);
            },
            itemBuilder: (context, index) {
              final cat = list[index];
              return ListTile(
                key: ValueKey(cat.index),
                leading: Text(cat.emoji, style: const TextStyle(fontSize: 24)),
                title: Text(cat.label),
                trailing: const Icon(Icons.drag_handle),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(AppStrings.genericScreenError(e))),
      ),
    );
  }
}
