import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/custom_activity.dart';
import '../../../core/providers/isar_provider.dart';
import '../data/custom_activity_icon_storage.dart';
import '../data/custom_activity_repository.dart';

final customActivityIconStorageProvider = Provider(
  (ref) => CustomActivityIconStorage(),
);

final customActivityRepositoryProvider = Provider<CustomActivityRepository>((
  ref,
) {
  return CustomActivityRepository(
    ref.watch(isarProvider),
    iconStorage: ref.watch(customActivityIconStorageProvider),
  );
});

final customActivitiesProvider = StreamProvider<List<CustomActivity>>((ref) {
  return ref.watch(customActivityRepositoryProvider).watchOrdered();
});

final customActivityByIdProvider = FutureProvider.family<CustomActivity?, int>((
  ref,
  id,
) {
  return ref.watch(customActivityRepositoryProvider).getById(id);
});
