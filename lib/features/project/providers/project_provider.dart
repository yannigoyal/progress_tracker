import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/models/project.dart';
import '../../../core/providers/isar_provider.dart';

final projectsProvider = FutureProvider<List<Project>>((ref) async {
  final isar = ref.watch(isarProvider);
  return isar.projects.where().sortByCreatedAtDesc().findAll();
});

final projectProvider = FutureProvider.family<Project?, int>((ref, id) async {
  final isar = ref.watch(isarProvider);
  return isar.projects.get(id);
});

class ProjectNotifier extends AutoDisposeNotifier<AsyncValue<List<Project>>> {
  @override
  AsyncValue<List<Project>> build() {
    return const AsyncValue.loading();
  }

  Future<void> addProject(String name, String description) async {
    state = const AsyncValue.loading();
    final isar = ref.read(isarProvider);
    final project = Project()
      ..name = name
      ..description = description
      ..status = ProjectStatus.active
      ..createdAt = DateTime.now();
    await isar.writeTxn(() => isar.projects.put(project));
    ref.invalidate(projectsProvider);
    state = AsyncValue.data(await ref.read(projectsProvider.future));
  }

  Future<void> updateStatus(int id, ProjectStatus status) async {
    final isar = ref.read(isarProvider);
    final project = await isar.projects.get(id);
    if (project != null) {
      project.status = status;
      await isar.writeTxn(() => isar.projects.put(project));
      ref.invalidate(projectsProvider);
      ref.invalidate(projectProvider(id));
      state = AsyncValue.data(await ref.read(projectsProvider.future));
    }
  }

  Future<void> deleteProject(int id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.projects.delete(id));
    ref.invalidate(projectsProvider);
    ref.invalidate(projectProvider(id));
    state = AsyncValue.data(await ref.read(projectsProvider.future));
  }
}

final projectNotifierProvider =
    NotifierProvider.autoDispose<ProjectNotifier, AsyncValue<List<Project>>>(
      () => ProjectNotifier(),
    );
