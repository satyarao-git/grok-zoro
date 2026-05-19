import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';

import '../../core/utils/failure.dart';
import '../../domain/entities/weekly_review_progress.dart';
import '../../domain/repositories/weekly_review_repository.dart';
import '../isar/weekly_review_schema.dart';

class WeeklyReviewIsarRepository implements WeeklyReviewRepository {
  const WeeklyReviewIsarRepository(this._isar);

  static const _singletonId = 1;

  final Future<Isar> _isar;

  @override
  Future<Either<Failure, WeeklyReviewProgress>> getProgress() async {
    try {
      final isar = await _isar;
      final row = await isar.weeklyReviewSchemas.get(_singletonId);
      if (row == null) {
        return right(const WeeklyReviewProgress());
      }

      return right(
        WeeklyReviewProgress(
          reviewedStepIds: row.reviewedStepIds.toSet(),
          completedAt: row.completedAt,
        ),
      );
    } catch (error) {
      return left(DatabaseFailure('Could not load weekly review: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> saveProgress(
    WeeklyReviewProgress progress,
  ) async {
    try {
      final isar = await _isar;
      final row = WeeklyReviewSchema()
        ..id = _singletonId
        ..reviewedStepIds = progress.reviewedStepIds.toList(growable: false)
        ..completedAt = progress.completedAt;
      await isar.writeTxn(() => isar.weeklyReviewSchemas.put(row));
      return right(null);
    } catch (error) {
      return left(DatabaseFailure('Could not save weekly review: $error'));
    }
  }
}
