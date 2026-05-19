import 'package:isar/isar.dart';

part 'horizon_schema.g.dart';

@collection
class HorizonSchema {
  Id id = Isar.autoIncrement;

  late String levelName;
  late String title;
  late String description;
  double? alignmentScore;
}
