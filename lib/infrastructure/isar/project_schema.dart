import 'package:isar/isar.dart';

part 'project_schema.g.dart';

@collection
class ProjectSchema {
  Id id = Isar.autoIncrement;

  @Index()
  String? uuid;
  late String title;
  late String desiredOutcome;
  List<String> stepIds = [];
  List<String> projectStepsJson = [];
  String? currentNextActionId;
  DateTime? targetCompletionDate;
  bool isCompleted = false;
  late DateTime createdAt;
  List<String> tags = [];
  String? areaOfFocus;
  int completedStepCount = 0;
}
