import 'package:isar/isar.dart';

import '../../../core/models/category.dart';
import '../../../core/models/log_entry.dart';
import '../../../core/models/project.dart';

class ProjectRepository {
  final Isar _isar;

  const ProjectRepository(this._isar);

  Future<List<Project>> fetchProjects() {
    return _isar.projects.where().sortByCreatedAtDesc().findAll();
  }

  Future<Project?> fetchProject(int id) {
    return _isar.projects.get(id);
  }

  Future<void> addProject(String name, String description) async {
    final project = Project()
      ..name = name
      ..description = description
      ..status = ProjectStatus.active
      ..createdAt = DateTime.now();

    await _isar.writeTxn(() => _isar.projects.put(project));
  }

  Future<void> updateStatus(int id, ProjectStatus status) async {
    final project = await _isar.projects.get(id);
    if (project == null) return;

    project.status = status;
    await _isar.writeTxn(() => _isar.projects.put(project));
  }

  Future<void> deleteProject(int id) async {
    await _isar.writeTxn(() => _isar.projects.delete(id));
  }

  Future<void> addSessionLog({
    required Project project,
    required String whatDone,
    required String whatLearnt,
  }) async {
    final entry = LogEntry()
      ..category = Category.project
      ..createdAt = DateTime.now().toUtc()
      ..payload = {
        'projectId': project.id,
        'projectName': project.name,
        'whatDone': whatDone,
        'whatLearnt': whatLearnt,
      };

    await _isar.writeTxn(() => _isar.logEntrys.put(entry));
  }
}
