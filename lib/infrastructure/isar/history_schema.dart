import 'package:isar/isar.dart';

part 'history_schema.g.dart';

@collection
class HistorySchema {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime timestamp;
  late String action;
  late String entityType;
  String? entityId;
  late String description;
  String? details;
}
