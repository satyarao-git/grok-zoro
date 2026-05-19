enum HistoryAction {
  inboxProcessed,
  taskCreated,
  taskCompleted,
  calendarEventCreated,
  projectCreated,
  somedayCreated,
  referenceCreated,
  waitingForCreated,
  waitingForResolved,
  somedayActivated,
  inboxTrashed,
  dataCleared,
}

extension HistoryActionLabel on HistoryAction {
  String get label {
    return switch (this) {
      HistoryAction.inboxProcessed => 'Inbox processed',
      HistoryAction.taskCreated => 'Task created',
      HistoryAction.taskCompleted => 'Task completed',
      HistoryAction.calendarEventCreated => 'Calendar event created',
      HistoryAction.projectCreated => 'Project created',
      HistoryAction.somedayCreated => 'Someday/Maybe created',
      HistoryAction.referenceCreated => 'Reference created',
      HistoryAction.waitingForCreated => 'Waiting For created',
      HistoryAction.waitingForResolved => 'Waiting For resolved',
      HistoryAction.somedayActivated => 'Someday activated',
      HistoryAction.inboxTrashed => 'Inbox trashed',
      HistoryAction.dataCleared => 'Data cleared',
    };
  }
}

class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.entityType,
    required this.description,
    this.entityId,
    this.details,
  });

  final String id;
  final DateTime timestamp;
  final HistoryAction action;
  final String entityType;
  final String? entityId;
  final String description;
  final String? details;
}
