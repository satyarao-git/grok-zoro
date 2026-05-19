import 'package:isar/isar.dart';

part 'inbox_item_schema.g.dart';

@collection
class InboxItemSchema {
  Id id = Isar.autoIncrement;

  @Index()
  String? uuid;
  late String title;
  String? notes;
  late DateTime capturedAt;
  String source = 'manual';
}
