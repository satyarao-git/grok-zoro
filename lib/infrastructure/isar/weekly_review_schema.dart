import 'package:isar/isar.dart';

part 'weekly_review_schema.g.dart';

@collection
class WeeklyReviewSchema {
  Id id = 1;

  List<String> reviewedStepIds = [];
  DateTime? completedAt;
}
