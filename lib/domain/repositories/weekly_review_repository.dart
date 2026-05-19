import 'package:fpdart/fpdart.dart';

import '../../core/utils/failure.dart';
import '../entities/weekly_review_progress.dart';

abstract class WeeklyReviewRepository {
  Future<Either<Failure, WeeklyReviewProgress>> getProgress();
  Future<Either<Failure, void>> saveProgress(WeeklyReviewProgress progress);
}
