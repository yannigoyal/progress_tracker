import 'package:isar/isar.dart';

import '../../../core/models/custom_activity.dart';
import '../../../core/models/log_entry.dart';
import '../../../core/models/category.dart';
import 'custom_activity_icon_storage.dart';

class CustomActivityRepository {
  final Isar _isar;
  final CustomActivityIconStorage _iconStorage;

  CustomActivityRepository(
    this._isar, {
    CustomActivityIconStorage? iconStorage,
  }) : _iconStorage = iconStorage ?? CustomActivityIconStorage();

  Future<List<CustomActivity>> listOrdered() {
    return _isar.customActivitys.where().sortBySortOrder().findAll();
  }

  Stream<List<CustomActivity>> watchOrdered() {
    return _isar.customActivitys
        .where()
        .sortBySortOrder()
        .watch(fireImmediately: true);
  }

  Future<CustomActivity?> getById(int id) {
    return _isar.customActivitys.get(id);
  }

  Future<int> countLogsForActivity(int activityId) {
    return _isar.logEntrys
        .filter()
        .categoryIndexEqualTo(Category.custom.index)
        .findAll()
        .then(
          (logs) => logs
              .where((l) => l.payload['customActivityId'] == activityId)
              .length,
        );
  }

  Future<void> save(CustomActivity activity) async {
    await _isar.writeTxn(() async {
      final isNew = activity.id == Isar.autoIncrement;
      if (isNew) {
        final maxOrder = await _isar.customActivitys
            .where()
            .sortBySortOrderDesc()
            .findFirst();
        activity.sortOrder = (maxOrder?.sortOrder ?? -1) + 1;
      }
      await _isar.customActivitys.put(activity);
    });
  }

  Future<void> delete(int id) async {
    final activity = await getById(id);
    await _iconStorage.deleteIconFile(activity?.customIconPath);
    await _isar.writeTxn(() => _isar.customActivitys.delete(id));
  }

  Future<void> updateSortOrders(List<int> orderedIds) async {
    await _isar.writeTxn(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        final activity = await _isar.customActivitys.get(orderedIds[i]);
        if (activity == null) continue;
        activity.sortOrder = i;
        await _isar.customActivitys.put(activity);
      }
    });
  }
}
