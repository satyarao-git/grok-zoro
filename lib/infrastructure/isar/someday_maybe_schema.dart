import 'package:isar/isar.dart';

part 'someday_maybe_schema.g.dart';

@collection
class SomedayMaybeSchema {
  Id id = Isar.autoIncrement;

  @Index()
  String? uuid;
  late String title;
  late DateTime reconsiderDate;
  String? notes;
  List<String> tags = [];
  late DateTime createdAt;
}
