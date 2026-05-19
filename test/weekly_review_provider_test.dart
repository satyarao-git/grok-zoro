import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grok_zoro/core/utils/failure.dart';
import 'package:grok_zoro/domain/entities/weekly_review_progress.dart';
import 'package:grok_zoro/domain/repositories/weekly_review_repository.dart';
import 'package:grok_zoro/injection_container.dart';

void main() {
  test('weekly review progress loads and saves checklist changes', () async {
    final repository = _FakeWeeklyReviewRepository(
      const WeeklyReviewProgress(reviewedStepIds: {'inbox'}),
    );
    final container = ProviderContainer(
      overrides: [
        weeklyReviewRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(weeklyReviewProgressProvider.future);
    expect(container.read(weeklyReviewChecklistProvider), {'inbox'});

    final notifier = container.read(weeklyReviewProgressProvider.notifier);
    expect(await notifier.setReviewed('projects', reviewed: true), isTrue);
    expect(await notifier.markComplete(DateTime(2026, 5, 10)), isTrue);

    expect(repository.saved.reviewedStepIds, {'inbox', 'projects'});
    expect(repository.saved.completedAt, DateTime(2026, 5, 10));

    expect(await notifier.reset(), isTrue);
    expect(repository.saved.reviewedStepIds, isEmpty);
    expect(repository.saved.completedAt, isNull);
  });
}

class _FakeWeeklyReviewRepository implements WeeklyReviewRepository {
  _FakeWeeklyReviewRepository(this.saved);

  WeeklyReviewProgress saved;

  @override
  Future<Either<Failure, WeeklyReviewProgress>> getProgress() async {
    return right(saved);
  }

  @override
  Future<Either<Failure, void>> saveProgress(
    WeeklyReviewProgress progress,
  ) async {
    saved = progress;
    return right(null);
  }
}
