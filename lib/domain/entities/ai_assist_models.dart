import 'processing_choice.dart';

enum AiAssistContext {
  inboxProcessing('inbox_processing'),
  weeklyReview('weekly_review');

  const AiAssistContext(this.wireName);

  final String wireName;
}

class InboxProcessingAiSuggestion {
  const InboxProcessingAiSuggestion({
    required this.recommendedChoice,
    required this.title,
    this.desiredOutcome,
    this.nextActionTitle,
    this.contextName,
    this.targetDate,
    this.reconsiderDate,
    this.notes,
    this.tags = const [],
    this.steps = const [],
  });

  final ProcessingChoice recommendedChoice;
  final String title;
  final String? desiredOutcome;
  final String? nextActionTitle;
  final String? contextName;
  final DateTime? targetDate;
  final DateTime? reconsiderDate;
  final String? notes;
  final List<String> tags;
  final List<String> steps;
}

class AiWeeklyReviewSummary {
  const AiWeeklyReviewSummary({
    required this.inboxCount,
    required this.activeProjects,
    required this.nextActions,
    required this.somedayItems,
    required this.readyToActivateCount,
    required this.waitingForItems,
    required this.waitingForDueCount,
    required this.calendarEntryCount,
    required this.horizonsAlignedCount,
    required this.horizonsTotalCount,
  });

  final int inboxCount;
  final List<String> activeProjects;
  final List<String> nextActions;
  final List<String> somedayItems;
  final int readyToActivateCount;
  final List<String> waitingForItems;
  final int waitingForDueCount;
  final int calendarEntryCount;
  final int horizonsAlignedCount;
  final int horizonsTotalCount;

  Map<String, Object?> toJson() {
    return {
      'inboxCount': inboxCount,
      'activeProjects': activeProjects,
      'nextActions': nextActions,
      'somedayItems': somedayItems,
      'readyToActivateCount': readyToActivateCount,
      'waitingForItems': waitingForItems,
      'waitingForDueCount': waitingForDueCount,
      'calendarEntryCount': calendarEntryCount,
      'horizonsAlignedCount': horizonsAlignedCount,
      'horizonsTotalCount': horizonsTotalCount,
    };
  }
}

class WeeklyReviewAiInsights {
  const WeeklyReviewAiInsights({
    this.priorityActions = const [],
    this.stalledProjects = const [],
    this.readyToActivateCount = 0,
    this.horizonsAlignmentTips = const [],
    this.suggestedFocusAreas = const [],
  });

  final List<String> priorityActions;
  final List<String> stalledProjects;
  final int readyToActivateCount;
  final List<String> horizonsAlignmentTips;
  final List<String> suggestedFocusAreas;
}
