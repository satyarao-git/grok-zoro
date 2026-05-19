import 'context.dart';
import 'recurrence.dart';

enum EnergyLevel { low, medium, high }

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.context,
    required this.createdAt,
    this.description,
    this.dueDate,
    this.targetDate,
    this.endDateTime,
    this.isNextAction = true,
    this.isCompleted = false,
    this.completedAt,
    this.projectId,
    this.tags = const [],
    this.energyLevel = EnergyLevel.medium,
    this.estimatedMinutes,
    this.isCalendarEvent = false,
    this.recurrence,
  });

  final String id;
  final String title;
  final String? description;
  final ZoroContext context;
  final DateTime? dueDate;
  final DateTime? targetDate;
  final DateTime? endDateTime;
  final bool isNextAction;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? projectId;
  final List<String> tags;
  final EnergyLevel energyLevel;
  final int? estimatedMinutes;
  final bool isCalendarEvent;
  final Recurrence? recurrence;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    ZoroContext? context,
    DateTime? dueDate,
    DateTime? targetDate,
    DateTime? endDateTime,
    bool? isNextAction,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    String? projectId,
    List<String>? tags,
    EnergyLevel? energyLevel,
    int? estimatedMinutes,
    bool? isCalendarEvent,
    Recurrence? recurrence,
    bool clearDescription = false,
    bool clearDueDate = false,
    bool clearTargetDate = false,
    bool clearEndDateTime = false,
    bool clearCompletedAt = false,
    bool clearProjectId = false,
    bool clearEstimatedMinutes = false,
    bool clearRecurrence = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : description ?? this.description,
      context: context ?? this.context,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
      targetDate: clearTargetDate ? null : targetDate ?? this.targetDate,
      endDateTime: clearEndDateTime ? null : endDateTime ?? this.endDateTime,
      isNextAction: isNextAction ?? this.isNextAction,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      projectId: clearProjectId ? null : projectId ?? this.projectId,
      tags: tags ?? this.tags,
      energyLevel: energyLevel ?? this.energyLevel,
      estimatedMinutes: clearEstimatedMinutes
          ? null
          : estimatedMinutes ?? this.estimatedMinutes,
      isCalendarEvent: isCalendarEvent ?? this.isCalendarEvent,
      recurrence: clearRecurrence ? null : recurrence ?? this.recurrence,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.context == context &&
        other.dueDate == dueDate &&
        other.targetDate == targetDate &&
        other.endDateTime == endDateTime &&
        other.isNextAction == isNextAction &&
        other.isCompleted == isCompleted &&
        other.createdAt == createdAt &&
        other.completedAt == completedAt &&
        other.projectId == projectId &&
        _listEquals(other.tags, tags) &&
        other.energyLevel == energyLevel &&
        other.estimatedMinutes == estimatedMinutes &&
        other.isCalendarEvent == isCalendarEvent &&
        other.recurrence == recurrence;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        description,
        context,
        dueDate,
        targetDate,
        endDateTime,
        isNextAction,
        isCompleted,
        createdAt,
        completedAt,
        projectId,
        Object.hashAll(tags),
        energyLevel,
        estimatedMinutes,
        isCalendarEvent,
        recurrence,
      );
}

bool _listEquals<T>(List<T> left, List<T> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}
