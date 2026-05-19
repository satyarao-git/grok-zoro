enum ProcessingChoice {
  nextAction,
  project,
  calendarEvent,
  someday,
  reference,
  waitingFor,
  trash,
}

extension ProcessingChoiceLabel on ProcessingChoice {
  String get label {
    return switch (this) {
      ProcessingChoice.nextAction => 'Next Action',
      ProcessingChoice.project => 'Project',
      ProcessingChoice.calendarEvent => 'Calendar Event',
      ProcessingChoice.someday => 'Someday/Maybe',
      ProcessingChoice.reference => 'Reference',
      ProcessingChoice.waitingFor => 'Waiting For',
      ProcessingChoice.trash => 'Trash',
    };
  }
}
