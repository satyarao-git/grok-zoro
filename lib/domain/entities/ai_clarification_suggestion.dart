import 'processing_choice.dart';

class AiClarificationSuggestion {
  const AiClarificationSuggestion({
    required this.choice,
    required this.title,
    this.desiredOutcome,
    this.nextActionTitle,
    this.contextName,
    this.targetDate,
    this.reconsiderDate,
    this.notes,
    this.tags = const [],
    this.stepTitles = const [],
  });

  final ProcessingChoice choice;
  final String title;
  final String? desiredOutcome;
  final String? nextActionTitle;
  final String? contextName;
  final DateTime? targetDate;
  final DateTime? reconsiderDate;
  final String? notes;
  final List<String> tags;
  final List<String> stepTitles;
}
