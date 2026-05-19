import 'package:flutter_test/flutter_test.dart';
import 'package:grok_zoro/domain/entities/context.dart';
import 'package:grok_zoro/domain/entities/recurrence.dart';
import 'package:grok_zoro/domain/entities/task.dart';
import 'package:grok_zoro/domain/services/calendar_occurrence_generator.dart';

void main() {
  test('weekly recurrence expands matching weekdays inside range', () {
    final task = Task(
      id: 'calendar-1',
      title: 'Garden planning',
      context: const ZoroContext(id: 'home', name: '@Home'),
      createdAt: DateTime(2026, 5, 13),
      targetDate: DateTime(2026, 5, 19, 8),
      endDateTime: DateTime(2026, 5, 19, 8, 30),
      isNextAction: false,
      isCalendarEvent: true,
      recurrence: const Recurrence(
        frequency: RecurrenceFrequency.weekly,
        weekdays: [DateTime.tuesday],
      ),
    );

    final occurrences = calendarOccurrencesForTask(
      task: task,
      rangeStart: DateTime(2026, 5, 18),
      rangeEnd: DateTime(2026, 6, 1, 23, 59),
    );

    expect(
      occurrences.map((entry) => entry.start),
      [DateTime(2026, 5, 19, 8), DateTime(2026, 5, 26, 8)],
    );
    expect(occurrences.every((entry) => entry.isRecurring), isTrue);
  });
}
