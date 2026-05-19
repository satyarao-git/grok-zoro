import 'context.dart';
import 'recurrence.dart';

enum ProjectStepKind { nextAction, calendarEvent, waitingFor }

sealed class ProjectStep {
  const ProjectStep({
    required this.id,
    required this.title,
    this.createdEntityId,
    this.notes,
  });

  final String id;
  final String title;
  final String? createdEntityId;
  final String? notes;

  ProjectStepKind get kind;

  ProjectStep withCreatedEntityId(String entityId);

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'kind': kind.name,
      'title': title,
      'createdEntityId': createdEntityId,
      'notes': notes,
    };
  }

  static ProjectStep fromJson(Map<String, Object?> json) {
    final kind = ProjectStepKind.values.firstWhere(
      (entry) => entry.name == json['kind'],
      orElse: () => ProjectStepKind.nextAction,
    );

    return switch (kind) {
      ProjectStepKind.nextAction => NextActionProjectStep.fromJson(json),
      ProjectStepKind.calendarEvent => CalendarEventProjectStep.fromJson(json),
      ProjectStepKind.waitingFor => WaitingForProjectStep.fromJson(json),
    };
  }
}

class NextActionProjectStep extends ProjectStep {
  const NextActionProjectStep({
    required super.id,
    required super.title,
    required this.context,
    super.createdEntityId,
    super.notes,
    this.targetDate,
    this.allDay = false,
    this.tags = const [],
  });

  final ZoroContext context;
  final DateTime? targetDate;
  final bool allDay;
  final List<String> tags;

  @override
  ProjectStepKind get kind => ProjectStepKind.nextAction;

  @override
  NextActionProjectStep withCreatedEntityId(String entityId) {
    return NextActionProjectStep(
      id: id,
      title: title,
      context: context,
      createdEntityId: entityId,
      notes: notes,
      targetDate: targetDate,
      allDay: allDay,
      tags: tags,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      ...super.toJson(),
      'contextName': context.name,
      'targetDate': targetDate?.toIso8601String(),
      'allDay': allDay,
      'tags': tags,
    };
  }

  static NextActionProjectStep fromJson(Map<String, Object?> json) {
    final contextName = json['contextName'] as String? ?? '@Anywhere';
    return NextActionProjectStep(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      context: ZoroContext(
        id: contextName.replaceAll('@', '').toLowerCase(),
        name: contextName,
      ),
      createdEntityId: json['createdEntityId'] as String?,
      notes: json['notes'] as String?,
      targetDate: _dateOrNull(json['targetDate']),
      allDay: json['allDay'] as bool? ?? false,
      tags: _strings(json['tags']),
    );
  }
}

class CalendarEventProjectStep extends ProjectStep {
  const CalendarEventProjectStep({
    required super.id,
    required super.title,
    required this.context,
    required this.targetDate,
    super.createdEntityId,
    super.notes,
    this.endDateTime,
    this.allDay = false,
    this.recurrence,
    this.tags = const [],
  });

  final ZoroContext context;
  final DateTime targetDate;
  final DateTime? endDateTime;
  final bool allDay;
  final Recurrence? recurrence;
  final List<String> tags;

  @override
  ProjectStepKind get kind => ProjectStepKind.calendarEvent;

  @override
  CalendarEventProjectStep withCreatedEntityId(String entityId) {
    return CalendarEventProjectStep(
      id: id,
      title: title,
      context: context,
      targetDate: targetDate,
      createdEntityId: entityId,
      notes: notes,
      endDateTime: endDateTime,
      allDay: allDay,
      recurrence: recurrence,
      tags: tags,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      ...super.toJson(),
      'contextName': context.name,
      'targetDate': targetDate.toIso8601String(),
      'endDateTime': endDateTime?.toIso8601String(),
      'allDay': allDay,
      'recurrenceRule': recurrence?.toRRule(),
      'tags': tags,
    };
  }

  static CalendarEventProjectStep fromJson(Map<String, Object?> json) {
    final contextName = json['contextName'] as String? ?? '@Anywhere';
    return CalendarEventProjectStep(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      context: ZoroContext(
        id: contextName.replaceAll('@', '').toLowerCase(),
        name: contextName,
      ),
      targetDate: _dateOrNull(json['targetDate']) ?? DateTime.now(),
      createdEntityId: json['createdEntityId'] as String?,
      notes: json['notes'] as String?,
      endDateTime: _dateOrNull(json['endDateTime']),
      allDay: json['allDay'] as bool? ?? false,
      recurrence: Recurrence.fromRRule(json['recurrenceRule'] as String?),
      tags: _strings(json['tags']),
    );
  }
}

class WaitingForProjectStep extends ProjectStep {
  const WaitingForProjectStep({
    required super.id,
    required super.title,
    required this.person,
    super.createdEntityId,
    super.notes,
    this.followUpDate,
    this.tags = const [],
  });

  final String person;
  final DateTime? followUpDate;
  final List<String> tags;

  @override
  ProjectStepKind get kind => ProjectStepKind.waitingFor;

  @override
  WaitingForProjectStep withCreatedEntityId(String entityId) {
    return WaitingForProjectStep(
      id: id,
      title: title,
      person: person,
      createdEntityId: entityId,
      notes: notes,
      followUpDate: followUpDate,
      tags: tags,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      ...super.toJson(),
      'person': person,
      'followUpDate': followUpDate?.toIso8601String(),
      'tags': tags,
    };
  }

  static WaitingForProjectStep fromJson(Map<String, Object?> json) {
    return WaitingForProjectStep(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      person: json['person'] as String? ?? '',
      createdEntityId: json['createdEntityId'] as String?,
      notes: json['notes'] as String?,
      followUpDate: _dateOrNull(json['followUpDate']),
      tags: _strings(json['tags']),
    );
  }
}

DateTime? _dateOrNull(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

List<String> _strings(Object? value) {
  if (value is List) {
    return value.whereType<String>().toList(growable: false);
  }
  return const [];
}
