import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/category.dart';
import '../data/category_order_store.dart';

final categoryOrderStoreProvider = Provider((ref) => CategoryOrderStore());

final categoryOrderProvider = FutureProvider<List<Category>>((ref) async {
  return ref.watch(categoryOrderStoreProvider).loadOrder();
});
