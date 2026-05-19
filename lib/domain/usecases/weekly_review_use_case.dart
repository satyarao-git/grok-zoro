import 'package:fpdart/fpdart.dart';

import '../../core/utils/failure.dart';

class WeeklyReviewSummary {
  const WeeklyReviewSummary({
    required this.inboxCount,
    required this.activeProjectCount,
    required this.nextActionCount,
    required this.readyToActivateCount,
  });

  final int inboxCount;
  final int activeProjectCount;
  final int nextActionCount;
  final int readyToActivateCount;
}

class WeeklyReviewUseCase {
  const WeeklyReviewUseCase();

  Future<Either<Failure, WeeklyReviewSummary>> call() async {
    return right(
      const WeeklyReviewSummary(
        inboxCount: 0,
        activeProjectCount: 0,
        nextActionCount: 0,
        readyToActivateCount: 0,
      ),
    );
  }
}
