import 'package:isar/isar.dart';

part 'reference_schema.g.dart';

@collection
class ReferenceSchema {
  Id id = Isar.autoIncrement;

  @Index()
  String? uuid;
  late String title;
  String? notes;
  List<String> tags = [];
  String? folder;
  late DateTime createdAt;
}
