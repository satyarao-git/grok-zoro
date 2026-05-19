import 'package:flutter_test/flutter_test.dart';
import 'package:grok_zoro/domain/entities/processing_choice.dart';
import 'package:grok_zoro/infrastructure/services/ai_clarify_service.dart';

void main() {
  test('parses AI clarification JSON into a suggestion', () {
    final suggestion = aiSuggestionFromJson({
      'choice': 'someday-maybe',
      'title': 'Plan Japan trip',
      'desiredOutcome': null,
      'nextActionTitle': '',
      'contextName': '@Computer',
      'targetDate': '2026-06-01',
      'reconsiderDate': '2026-08-15',
      'notes': 'Wait until budget is clearer.',
      'tags': ['travel', 'budget'],
      'stepTitles': ['Check flight alerts'],
    });

    expect(suggestion.choice, ProcessingChoice.someday);
    expect(suggestion.title, 'Plan Japan trip');
    expect(suggestion.nextActionTitle, isNull);
    expect(suggestion.contextName, '@Computer');
    expect(suggestion.targetDate, DateTime(2026, 6));
    expect(suggestion.reconsiderDate, DateTime(2026, 8, 15));
    expect(suggestion.tags, ['travel', 'budget']);
    expect(suggestion.stepTitles, ['Check flight alerts']);
  });

  test('defaults unknown choices to next action', () {
    final suggestion = aiSuggestionFromJson({
      'choice': 'unclear',
      'title': '',
    });

    expect(suggestion.choice, ProcessingChoice.nextAction);
    expect(suggestion.title, 'Clarified item');
  });
}
