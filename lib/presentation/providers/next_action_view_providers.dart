import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/project.dart';
import '../../domain/entities/task.dart';
import '../../injection_container.dart';

enum Next7DaysFilter { nextActions, projects, all }

enum AllNextActionsView { all, today, next7Days, byContext, byProject }

final next7DaysFilterProvider =
    StateProvider<Next7DaysFilter>((ref) => Next7DaysFilter.all);

final allNextActionsViewProvider =
    StateProvider<AllNextActionsView>((ref) => AllNextActionsView.all);

final allNextActionsSearchProvider = StateProvider<String>((ref) => '');

final selectedAllNextActionsContextProvider =
    StateProvider<String>((ref) => '@Anywhere');

final nextActionsByContextProvider = Provider.family<List<Task>, String>(
  (ref, contextName) {
    final tasks = ref.watch(allNextActionsProvider).valueOrNull ?? const [];
    return tasks
        .where((task) => !task.isCompleted && task.context.name == contextName)
        .toList(growable: false);
  },
);

final tasksByDateRangeProvider =
    Provider.family<List<Task>, NextActionDateRange>((ref, range) {
  final tasks = ref.watch(allNextActionsProvider).valueOrNull ?? const [];
  return tasks
      .where((task) => !task.isCompleted && range.matchesTask(task))
      .toList(growable: false)
    ..sort(_compareTasksByDate);
});

final projectsByDateRangeProvider =
    Provider.family<List<Project>, NextActionDateRange>((ref, range) {
  final projects = ref.watch(activeProjectsProvider).valueOrNull ?? const [];
  return projects
      .where((project) =>
          !project.isCompleted &&
          project.targetCompletionDate != null &&
          range.contains(project.targetCompletionDate!))
      .toList(growable: false)
    ..sort((left, right) => left.targetCompletionDate!.compareTo(
          right.targetCompletionDate!,
        ));
});

final todayActionSummaryProvider = Provider<TodayActionSummary>((ref) {
  final today = DateTime.now();
  final tasks = ref.watch(allNextActionsProvider).valueOrNull ?? const [];
  final dueToday = tasks
      .where((task) =>
          !task.isCompleted &&
          [_dateOnly(task.targetDate), _dateOnly(task.dueDate)].contains(
            _dateOnly(today),
          ))
      .length;
  final overdue = tasks.where((task) {
    if (task.isCompleted) {
      return false;
    }
    final dates = [task.targetDate, task.dueDate].whereType<DateTime>();
    return dates.any((date) => _dateOnly(date).isBefore(_dateOnly(today)));
  }).length;
  return TodayActionSummary(dueToday: dueToday, overdue: overdue);
});

class NextActionDateRange {
  const NextActionDateRange({
    required this.start,
    required this.end,
    this.includeOverdue = false,
  });

  final DateTime start;
  final DateTime end;
  final bool includeOverdue;

  bool contains(DateTime date) {
    final normalized = _dateOnly(date);
    final normalizedStart = _dateOnly(start);
    final normalizedEnd = _dateOnly(end);
    return !normalized.isBefore(normalizedStart) &&
        !normalized.isAfter(normalizedEnd);
  }

  bool matchesTask(Task task) {
    final dates = [task.targetDate, task.dueDate].whereType<DateTime>();
    return dates.any((date) {
      final normalized = _dateOnly(date);
      return contains(normalized) ||
          (includeOverdue && normalized.isBefore(_dateOnly(start)));
    });
  }
}

class TodayActionSummary {
  const TodayActionSummary({
    required this.dueToday,
    required this.overdue,
  });

  final int dueToday;
  final int overdue;
}

DateTime effectiveTaskDate(Task task) {
  final targetDate = task.targetDate;
  final dueDate = task.dueDate;
  if (targetDate == null) {
    return dueDate ?? task.createdAt;
  }
  if (dueDate == null) {
    return targetDate;
  }
  return targetDate.isBefore(dueDate) ? targetDate : dueDate;
}

String projectNameForTask(Task task, List<Project> projects) {
  final projectId = task.projectId;
  if (projectId == null) {
    return '';
  }
  return projects
          .where((project) => project.id == projectId)
          .firstOrNull
          ?.title ??
      '';
}

int _compareTasksByDate(Task left, Task right) {
  final dateCompare =
      effectiveTaskDate(left).compareTo(effectiveTaskDate(right));
  if (dateCompare != 0) {
    return dateCompare;
  }
  return left.title.compareTo(right.title);
}

DateTime _dateOnly(DateTime? date) {
  final value = date ?? DateTime.now();
  return DateTime(value.year, value.month, value.day);
}
