import 'package:isar/isar.dart';

part 'project.g.dart';

enum ProjectStatus { active, paused, completed }

@collection
class Project {
  Id id = Isar.autoIncrement;

  @Index()
  late String name;

  late String description;

  @Index()
  late int statusIndex;

  late DateTime createdAt;

  @ignore
  ProjectStatus get status => ProjectStatus.values[statusIndex];

  set status(ProjectStatus s) => statusIndex = s.index;
}
