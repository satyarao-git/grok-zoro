import '../entities/recurrence.dart';
import '../entities/task.dart';

class CalendarTaskOccurrence {
  const CalendarTaskOccurrence({
    required this.id,
    required this.task,
    required this.start,
    required this.end,
    required this.isRecurring,
  });

  final String id;
  final Task task;
  final DateTime start;
  final DateTime? end;
  final bool isRecurring;
}

List<CalendarTaskOccurrence> calendarOccurrencesForTask({
  required Task task,
  required DateTime rangeStart,
  required DateTime rangeEnd,
}) {
  final start = task.targetDate ?? task.dueDate;
  if (start == null || task.isCompleted) {
    return const [];
  }

  final recurrence = task.recurrence;
  if (recurrence == null || !recurrence.isRecurring) {
    if (_intersects(start, task.endDateTime, rangeStart, rangeEnd)) {
      return [
        CalendarTaskOccurrence(
          id: '${task.id}-${start.toIso8601String()}',
          task: task,
          start: start,
          end: task.endDateTime,
          isRecurring: false,
        ),
      ];
    }
    return const [];
  }

  return switch (recurrence.frequency) {
    RecurrenceFrequency.none => const [],
    RecurrenceFrequency.daily ||
    RecurrenceFrequency.monthly ||
    RecurrenceFrequency.yearly =>
      _stepOccurrences(task, recurrence, start, rangeStart, rangeEnd),
    RecurrenceFrequency.weekly ||
    RecurrenceFrequency.biweekly =>
      _weeklyOccurrences(task, recurrence, start, rangeStart, rangeEnd),
  };
}

List<CalendarTaskOccurrence> _stepOccurrences(
  Task task,
  Recurrence recurrence,
  DateTime start,
  DateTime rangeStart,
  DateTime rangeEnd,
) {
  final entries = <CalendarTaskOccurrence>[];
  final interval = recurrence.interval < 1 ? 1 : recurrence.interval;
  var current = start;
  var generated = 0;

  while (!current.isAfter(rangeEnd) && generated < 2000) {
    generated++;
    if (_endsBefore(recurrence, current, generated)) {
      break;
    }
    final end = _shiftEnd(task, start, current);
    if (_intersects(current, end, rangeStart, rangeEnd)) {
      entries.add(
        CalendarTaskOccurrence(
          id: '${task.id}-${current.toIso8601String()}',
          task: task,
          start: current,
          end: end,
          isRecurring: true,
        ),
      );
    }
    current = switch (recurrence.frequency) {
      RecurrenceFrequency.daily => current.add(Duration(days: interval)),
      RecurrenceFrequency.monthly => _addMonths(current, interval),
      RecurrenceFrequency.yearly => DateTime(
          current.year + interval,
          current.month,
          current.day,
          current.hour,
          current.minute,
        ),
      _ => current.add(Duration(days: interval)),
    };
  }

  return entries;
}

List<CalendarTaskOccurrence> _weeklyOccurrences(
  Task task,
  Recurrence recurrence,
  DateTime start,
  DateTime rangeStart,
  DateTime rangeEnd,
) {
  final entries = <CalendarTaskOccurrence>[];
  final interval = recurrence.frequency == RecurrenceFrequency.biweekly
      ? 2
      : recurrence.interval < 1
          ? 1
          : recurrence.interval;
  final weekdays = recurrence.weekdays.isEmpty
      ? <int>[start.weekday]
      : recurrence.weekdays.toSet().toList();
  var occurrenceIndex = 0;
  var day = DateTime(start.year, start.month, start.day);
  final last = DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day);

  while (!day.isAfter(last) && occurrenceIndex < 2000) {
    final candidate = DateTime(
      day.year,
      day.month,
      day.day,
      start.hour,
      start.minute,
      start.second,
      start.millisecond,
      start.microsecond,
    );
    if (weekdays.contains(day.weekday) &&
        !candidate.isBefore(start) &&
        _isMatchingWeek(start, candidate, interval)) {
      occurrenceIndex++;
      if (_endsBefore(recurrence, candidate, occurrenceIndex)) {
        break;
      }
      final end = _shiftEnd(task, start, candidate);
      if (_intersects(candidate, end, rangeStart, rangeEnd)) {
        entries.add(
          CalendarTaskOccurrence(
            id: '${task.id}-${candidate.toIso8601String()}',
            task: task,
            start: candidate,
            end: end,
            isRecurring: true,
          ),
        );
      }
    }
    day = day.add(const Duration(days: 1));
  }

  return entries;
}

bool _isMatchingWeek(DateTime start, DateTime candidate, int interval) {
  final startWeek = DateTime(start.year, start.month, start.day)
      .subtract(Duration(days: start.weekday - 1));
  final candidateWeek = DateTime(candidate.year, candidate.month, candidate.day)
      .subtract(Duration(days: candidate.weekday - 1));
  final weeks = candidateWeek.difference(startWeek).inDays ~/ 7;
  return weeks % interval == 0;
}

bool _endsBefore(Recurrence recurrence, DateTime current, int generatedCount) {
  final count = recurrence.count;
  if (count != null && generatedCount > count) {
    return true;
  }
  final until = recurrence.until;
  if (until != null && current.isAfter(until)) {
    return true;
  }
  return false;
}

DateTime? _shiftEnd(Task task, DateTime originalStart, DateTime currentStart) {
  final originalEnd = task.endDateTime;
  if (originalEnd == null) {
    return null;
  }
  return currentStart.add(originalEnd.difference(originalStart));
}

bool _intersects(
  DateTime start,
  DateTime? end,
  DateTime rangeStart,
  DateTime rangeEnd,
) {
  final resolvedEnd = end ?? start;
  return !resolvedEnd.isBefore(rangeStart) && !start.isAfter(rangeEnd);
}

DateTime _addMonths(DateTime value, int months) {
  final desiredMonth = value.month + months;
  final candidate = DateTime(
    value.year,
    desiredMonth,
    1,
    value.hour,
    value.minute,
    value.second,
    value.millisecond,
    value.microsecond,
  );
  final lastDay = DateTime(candidate.year, candidate.month + 1, 0).day;
  return DateTime(
    candidate.year,
    candidate.month,
    value.day > lastDay ? lastDay : value.day,
    value.hour,
    value.minute,
    value.second,
    value.millisecond,
    value.microsecond,
  );
}
