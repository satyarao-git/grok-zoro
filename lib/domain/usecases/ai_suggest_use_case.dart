import '../entities/ai_assist_models.dart';
import '../entities/app_settings.dart';
import '../entities/context.dart';
import '../entities/inbox_item.dart';
import '../entities/processing_choice.dart';
import '../../infrastructure/ai/ai_service.dart';

class AiSuggestUseCase {
  const AiSuggestUseCase(this._service);

  final AiAssistService _service;

  Future<InboxProcessingAiSuggestion> suggestInboxProcessing({
    required InboxItem item,
    required ProcessingChoice currentChoice,
    required List<ZoroContext> contexts,
    required AppSettings settings,
  }) async {
    final json = await _service.suggest(
      context: AiAssistContext.inboxProcessing.wireName,
      settings: settings,
      payload: {
        'rawText': item.title,
        'notes': item.notes,
        'currentChoice': _choiceToJson(currentChoice),
        'availableContexts': contexts.map((context) => context.name).toList(),
      },
    );
    return _inboxSuggestionFromJson(json);
  }

  Future<WeeklyReviewAiInsights> suggestWeeklyReview({
    required AiWeeklyReviewSummary summary,
    required AppSettings settings,
  }) async {
    final json = await _service.suggest(
      context: AiAssistContext.weeklyReview.wireName,
      settings: settings,
      payload: summary.toJson(),
    );
    return _weeklyReviewInsightsFromJson(json);
  }

  InboxProcessingAiSuggestion _inboxSuggestionFromJson(
    Map<String, dynamic> json,
  ) {
    final title = _readString(json['title']);
    final steps = _readStringList(json['steps'] ?? json['stepTitles']);
    return InboxProcessingAiSuggestion(
      recommendedChoice: _choiceFromJson(
        json['recommendedChoice'] ?? json['choice'],
      ),
      title: title.isEmpty ? 'Clarified item' : title,
      desiredOutcome: _readNullableString(json['desiredOutcome']),
      nextActionTitle: _readNullableString(json['nextActionTitle']) ??
          (steps.isEmpty ? null : steps.first),
      contextName: _readNullableString(json['context'] ?? json['contextName']),
      targetDate: _readDate(json['targetDate']),
      reconsiderDate: _readDate(json['reconsiderDate']),
      notes: _readNullableString(json['notes']),
      tags: _readStringList(json['tags']),
      steps: steps,
    );
  }

  WeeklyReviewAiInsights _weeklyReviewInsightsFromJson(
    Map<String, dynamic> json,
  ) {
    return WeeklyReviewAiInsights(
      priorityActions: _readStringList(json['priorityActions']),
      stalledProjects: _readStringList(json['stalledProjects']),
      readyToActivateCount: _readInt(json['readyToActivateCount']),
      horizonsAlignmentTips: _readStringList(json['horizonsAlignmentTips']),
      suggestedFocusAreas: _readStringList(json['suggestedFocusAreas']),
    );
  }

  ProcessingChoice _choiceFromJson(Object? value) {
    final normalized = _readString(value)
        .replaceAll('-', '')
        .replaceAll('_', '')
        .replaceAll(' ', '')
        .toLowerCase();
    return switch (normalized) {
      'project' => ProcessingChoice.project,
      'calendarevent' ||
      'calendar' ||
      'event' =>
        ProcessingChoice.calendarEvent,
      'someday' || 'somedaymaybe' || 'maybe' => ProcessingChoice.someday,
      'reference' => ProcessingChoice.reference,
      'waitingfor' || 'waiting' || 'delegated' => ProcessingChoice.waitingFor,
      'trash' || 'delete' => ProcessingChoice.trash,
      _ => ProcessingChoice.nextAction,
    };
  }

  String _choiceToJson(ProcessingChoice choice) {
    return switch (choice) {
      ProcessingChoice.nextAction => 'nextAction',
      ProcessingChoice.project => 'project',
      ProcessingChoice.calendarEvent => 'calendarEvent',
      ProcessingChoice.someday => 'someday',
      ProcessingChoice.reference => 'reference',
      ProcessingChoice.waitingFor => 'waitingFor',
      ProcessingChoice.trash => 'trash',
    };
  }

  String _readString(Object? value) => value?.toString().trim() ?? '';

  String? _readNullableString(Object? value) {
    final text = _readString(value);
    return text.isEmpty ? null : text;
  }

  DateTime? _readDate(Object? value) {
    final text = _readNullableString(value);
    return text == null ? null : DateTime.tryParse(text);
  }

  int _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(_readString(value)) ?? 0;
  }

  List<String> _readStringList(Object? value) {
    if (value is! List) {
      return const [];
    }
    return value
        .map(_readString)
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
  }
}
