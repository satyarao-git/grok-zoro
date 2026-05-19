import 'package:flutter_test/flutter_test.dart';
import 'package:grok_zoro/domain/entities/context.dart';
import 'package:grok_zoro/domain/entities/project_step.dart';
import 'package:grok_zoro/domain/entities/recurrence.dart';

void main() {
  test('project steps round-trip through JSON storage shape', () {
    final steps = <ProjectStep>[
      const NextActionProjectStep(
        id: 'step-action',
        title: 'Draft project brief',
        context: ZoroContext(id: 'computer', name: '@Computer'),
        createdEntityId: 'task-1',
        notes: 'Keep it short.',
        tags: ['planning'],
      ),
      CalendarEventProjectStep(
        id: 'step-calendar',
        title: 'Planning review',
        context: const ZoroContext(id: 'computer', name: '@Computer'),
        targetDate: DateTime(2026, 6, 4, 10),
        endDateTime: DateTime(2026, 6, 4, 10, 30),
        createdEntityId: 'task-2',
        recurrence: const Recurrence(
          frequency: RecurrenceFrequency.weekly,
          weekdays: [DateTime.thursday],
          count: 3,
        ),
        tags: const ['planning'],
      ),
      WaitingForProjectStep(
        id: 'step-waiting',
        title: 'Stakeholder approval',
        person: 'Maya',
        followUpDate: DateTime(2026, 6, 8),
        createdEntityId: 'waiting-1',
        tags: const ['approval'],
      ),
    ];

    final restored = steps
        .map((step) => ProjectStep.fromJson(step.toJson()))
        .toList(growable: false);

    expect(restored.map((step) => step.kind), [
      ProjectStepKind.nextAction,
      ProjectStepKind.calendarEvent,
      ProjectStepKind.waitingFor,
    ]);
    expect(restored.map((step) => step.createdEntityId), [
      'task-1',
      'task-2',
      'waiting-1',
    ]);
    expect((restored[1] as CalendarEventProjectStep).recurrence?.toRRule(),
        'FREQ=WEEKLY;INTERVAL=1;BYDAY=TH;COUNT=3');
    expect((restored[2] as WaitingForProjectStep).person, 'Maya');
  });
}
