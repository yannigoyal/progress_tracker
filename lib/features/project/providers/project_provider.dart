import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/project.dart';
import '../../../core/providers/isar_provider.dart';
import '../data/project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return ProjectRepository(isar);
});

final projectsProvider = FutureProvider<List<Project>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.fetchProjects();
});

final projectProvider = FutureProvider.family<Project?, int>((ref, id) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.fetchProject(id);
});

class ProjectNotifier extends AutoDisposeNotifier<AsyncValue<List<Project>>> {
  @override
  AsyncValue<List<Project>> build() {
    return const AsyncValue.loading();
  }

  Future<void> addProject(String name, String description) async {
    state = const AsyncValue.loading();
    final repository = ref.read(projectRepositoryProvider);
    await repository.addProject(name, description);
    ref.invalidate(projectsProvider);
    state = AsyncValue.data(await ref.read(projectsProvider.future));
  }

  Future<void> updateStatus(int id, ProjectStatus status) async {
    final repository = ref.read(projectRepositoryProvider);
    await repository.updateStatus(id, status);
    ref.invalidate(projectsProvider);
    ref.invalidate(projectProvider(id));
    state = AsyncValue.data(await ref.read(projectsProvider.future));
  }

  Future<void> deleteProject(int id) async {
    final repository = ref.read(projectRepositoryProvider);
    await repository.deleteProject(id);
    ref.invalidate(projectsProvider);
    ref.invalidate(projectProvider(id));
    state = AsyncValue.data(await ref.read(projectsProvider.future));
  }

  Future<void> addSession(
    Project project,
    String whatDone,
    String whatLearnt,
  ) async {
    final repository = ref.read(projectRepositoryProvider);
    await repository.addSessionLog(
      project: project,
      whatDone: whatDone,
      whatLearnt: whatLearnt,
    );
  }
}

final projectNotifierProvider =
    NotifierProvider.autoDispose<ProjectNotifier, AsyncValue<List<Project>>>(
      () => ProjectNotifier(),
    );
