class WeeklyReviewProgress {
  const WeeklyReviewProgress({
    this.reviewedStepIds = const {},
    this.completedAt,
  });

  final Set<String> reviewedStepIds;
  final DateTime? completedAt;

  WeeklyReviewProgress copyWith({
    Set<String>? reviewedStepIds,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return WeeklyReviewProgress(
      reviewedStepIds: reviewedStepIds ?? this.reviewedStepIds,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
    );
  }
}
