import 'package:isar/isar.dart';

part 'waiting_for_schema.g.dart';

@collection
class WaitingForSchema {
  Id id = Isar.autoIncrement;

  @Index()
  String? uuid;
  late String title;
  late String person;
  String? projectId;
  DateTime? followUpDate;
  late DateTime createdAt;
  String? notes;
  List<String> tags = [];
  bool isResolved = false;
}
