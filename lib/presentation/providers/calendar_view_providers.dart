import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/project.dart';
import '../../domain/entities/task.dart';
import '../../domain/services/calendar_occurrence_generator.dart';
import '../../injection_container.dart';

final calendarContextFilterProvider = StateProvider<String?>((ref) => null);

final calendarAgendaEntriesProvider =
    Provider.family<List<CalendarAgendaEntry>, CalendarDateRange>((ref, range) {
  final tasks = ref.watch(allTasksProvider).valueOrNull ?? const <Task>[];
  final projects =
      ref.watch(activeProjectsProvider).valueOrNull ?? const <Project>[];
  final selectedContext = ref.watch(calendarContextFilterProvider);
  final rangeEnd = DateTime(
    range.end.year,
    range.end.month,
    range.end.day,
    23,
    59,
    59,
  );

  final entries = <CalendarAgendaEntry>[
    for (final task in tasks.where((task) => !task.isCompleted)) ...[
      if (task.isCalendarEvent)
        for (final occurrence in calendarOccurrencesForTask(
          task: task,
          rangeStart: range.start,
          rangeEnd: rangeEnd,
        ))
          CalendarAgendaEntry.task(
            id: 'calendar-${occurrence.id}',
            title: task.title,
            date: occurrence.start,
            endDateTime: occurrence.end,
            contextName: task.context.name,
            energyLevel: task.energyLevel,
            route: '/task/${task.id}',
            badge: 'Calendar',
            isRecurring: occurrence.isRecurring,
          ),
      if (task.dueDate != null && range.contains(task.dueDate!))
        CalendarAgendaEntry.task(
          id: 'task-due-${task.id}',
          title: task.title,
          date: task.dueDate!,
          endDateTime: null,
          contextName: task.context.name,
          energyLevel: task.energyLevel,
          route: '/task/${task.id}',
          badge: 'Due',
          isRecurring: false,
        ),
      if (!task.isCalendarEvent &&
          task.targetDate != null &&
          !_sameDay(task.targetDate, task.dueDate) &&
          range.contains(task.targetDate!))
        CalendarAgendaEntry.task(
          id: 'task-target-${task.id}',
          title: task.title,
          date: task.targetDate!,
          endDateTime: task.endDateTime,
          contextName: task.context.name,
          energyLevel: task.energyLevel,
          route: '/task/${task.id}',
          badge: 'Target',
          isRecurring: false,
        ),
    ],
    for (final project in projects.where((project) => !project.isCompleted))
      if (project.targetCompletionDate != null &&
          range.contains(project.targetCompletionDate!))
        CalendarAgendaEntry.project(
          id: 'project-${project.id}',
          title: project.title,
          date: project.targetCompletionDate!,
          route: '/project/${project.id}',
          desiredOutcome: project.desiredOutcome,
        ),
  ];

  return entries
      .where((entry) =>
          selectedContext == null || entry.contextName == selectedContext)
      .toList(growable: false)
    ..sort((left, right) {
      final dateCompare = left.date.compareTo(right.date);
      if (dateCompare != 0) {
        return dateCompare;
      }
      return left.title.compareTo(right.title);
    });
});

final availableCalendarContextsProvider = Provider<List<String>>((ref) {
  final tasks = ref.watch(allTasksProvider).valueOrNull ?? const <Task>[];
  final contexts = tasks
      .where((task) =>
          !task.isCompleted &&
          (task.targetDate != null || task.dueDate != null))
      .map((task) => task.context.name)
      .toSet()
      .toList()
    ..sort();
  return contexts;
});

enum CalendarAgendaEntryType { task, project }

class CalendarAgendaEntry {
  const CalendarAgendaEntry._({
    required this.id,
    required this.title,
    required this.date,
    required this.endDateTime,
    required this.type,
    required this.route,
    required this.contextName,
    required this.energyLevel,
    required this.badge,
    required this.isRecurring,
    this.desiredOutcome,
  });

  factory CalendarAgendaEntry.task({
    required String id,
    required String title,
    required DateTime date,
    required DateTime? endDateTime,
    required String contextName,
    required EnergyLevel energyLevel,
    required String route,
    required String badge,
    required bool isRecurring,
  }) {
    return CalendarAgendaEntry._(
      id: id,
      title: title,
      date: date,
      endDateTime: endDateTime,
      type: CalendarAgendaEntryType.task,
      route: route,
      contextName: contextName,
      energyLevel: energyLevel,
      badge: badge,
      isRecurring: isRecurring,
    );
  }

  factory CalendarAgendaEntry.project({
    required String id,
    required String title,
    required DateTime date,
    required String route,
    required String desiredOutcome,
  }) {
    return CalendarAgendaEntry._(
      id: id,
      title: title,
      date: date,
      endDateTime: null,
      type: CalendarAgendaEntryType.project,
      route: route,
      contextName: 'Project',
      energyLevel: EnergyLevel.medium,
      badge: 'Project',
      isRecurring: false,
      desiredOutcome: desiredOutcome,
    );
  }

  final String id;
  final String title;
  final DateTime date;
  final DateTime? endDateTime;
  final CalendarAgendaEntryType type;
  final String route;
  final String contextName;
  final EnergyLevel energyLevel;
  final String badge;
  final bool isRecurring;
  final String? desiredOutcome;
}

bool _sameDay(DateTime? left, DateTime? right) {
  if (left == null || right == null) {
    return false;
  }
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
