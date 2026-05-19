import 'package:isar/isar.dart';

part 'context_schema.g.dart';

@collection
class ContextSchema {
  Id id = Isar.autoIncrement;

  late String name;
  String? description;
  bool isDefault = false;
}
