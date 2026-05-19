import 'package:isar/isar.dart';

part 'task_schema.g.dart';

@collection
class TaskSchema {
  Id id = Isar.autoIncrement;

  @Index()
  String? uuid;
  late String title;
  String? description;
  late String contextName;
  DateTime? dueDate;
  DateTime? targetDate;
  DateTime? endDateTime;
  bool isNextAction = true;
  @Index()
  bool isCalendarEvent = false;
  bool isCompleted = false;
  late DateTime createdAt;
  DateTime? completedAt;
  String? projectId;
  List<String> tags = [];
  String energyLevel = 'medium';
  int? estimatedMinutes;
  String? recurrenceRule;
}
