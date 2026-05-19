import 'package:fpdart/fpdart.dart' hide Task;

import '../../core/utils/failure.dart';
import '../entities/context.dart';
import '../entities/history_entry.dart';
import '../entities/project.dart';
import '../entities/project_step.dart';
import '../entities/processing_choice.dart';
import '../entities/recurrence.dart';
import '../entities/reference_item.dart';
import '../entities/someday_maybe_item.dart';
import '../entities/task.dart';
import '../entities/waiting_for_item.dart';
import '../repositories/inbox_repository.dart';
import '../repositories/project_repository.dart';
import '../repositories/reference_repository.dart';
import '../repositories/someday_maybe_repository.dart';
import '../repositories/task_repository.dart';
import '../repositories/waiting_for_repository.dart';
import 'log_history_entry_use_case.dart';

class ProcessInboxItemUseCase {
  const ProcessInboxItemUseCase({
    required this.inboxRepository,
    required this.taskRepository,
    required this.projectRepository,
    required this.somedayMaybeRepository,
    required this.referenceRepository,
    required this.waitingForRepository,
    this.logHistoryEntryUseCase,
  });

  final InboxRepository inboxRepository;
  final TaskRepository taskRepository;
  final ProjectRepository projectRepository;
  final SomedayMaybeRepository somedayMaybeRepository;
  final ReferenceRepository referenceRepository;
  final WaitingForRepository waitingForRepository;
  final LogHistoryEntryUseCase? logHistoryEntryUseCase;

  Future<Either<Failure, void>> call({
    required String inboxItemId,
    required ProcessingChoice choice,
    String? title,
    String? desiredOutcome,
    ZoroContext? context,
    DateTime? targetDate,
    DateTime? endDateTime,
    String? notes,
    String? nextActionTitle,
    DateTime? reconsiderDate,
    String? referenceFolder,
    String? waitingOn,
    String? waitingForProjectId,
    DateTime? followUpDate,
    Recurrence? recurrence,
    List<String> tags = const [],
    List<String> stepTitles = const [],
    List<ProjectStep> projectSteps = const [],
  }) async {
    final inboxResult = await inboxRepository.getInboxItemById(inboxItemId);
    final inboxFailure = _failureOf(inboxResult);
    if (inboxFailure != null) {
      return left(inboxFailure);
    }

    final inboxItem = _valueOf(inboxResult)!;
    final resolvedTitle = _clean(title) ?? inboxItem.title;
    final now = DateTime.now();

    final mutationResult = switch (choice) {
      ProcessingChoice.nextAction => await _saveNextAction(
          title: resolvedTitle,
          context: context,
          targetDate: targetDate,
          endDateTime: endDateTime,
          notes: notes ?? inboxItem.notes,
          createdAt: now,
          tags: tags,
        ),
      ProcessingChoice.project => await _saveProjectWithCurrentAction(
          projectTitle: resolvedTitle,
          desiredOutcome: _clean(desiredOutcome),
          nextActionTitle: _clean(nextActionTitle),
          context: context,
          targetDate: targetDate,
          notes: notes ?? inboxItem.notes,
          createdAt: now,
          tags: tags,
          stepTitles: stepTitles,
          projectSteps: projectSteps,
        ),
      ProcessingChoice.calendarEvent => await _saveCalendarEvent(
          title: resolvedTitle,
          context: context,
          targetDate: targetDate,
          endDateTime: endDateTime,
          notes: notes ?? inboxItem.notes,
          createdAt: now,
          tags: tags,
          recurrence: recurrence,
        ),
      ProcessingChoice.someday => await _saveSomedayMaybe(
          title: resolvedTitle,
          reconsiderDate: reconsiderDate,
          notes: notes ?? inboxItem.notes,
          createdAt: now,
          tags: tags,
        ),
      ProcessingChoice.reference => await _saveReference(
          title: resolvedTitle,
          notes: notes ?? inboxItem.notes,
          createdAt: now,
          tags: tags,
          folder: referenceFolder,
        ),
      ProcessingChoice.waitingFor => await _saveWaitingFor(
          title: resolvedTitle,
          person: _clean(waitingOn),
          projectId: _clean(waitingForProjectId),
          followUpDate: followUpDate,
          notes: notes ?? inboxItem.notes,
          createdAt: now,
          tags: tags,
        ),
      ProcessingChoice.trash => await _archiveTrashedInboxItem(
          title: resolvedTitle,
          notes: notes ?? inboxItem.notes,
          createdAt: now,
          tags: tags,
        ),
    };

    final mutationFailure = _failureOf(mutationResult);
    if (mutationFailure != null) {
      return left(mutationFailure);
    }

    final deleteResult = await inboxRepository.deleteInboxItem(inboxItemId);
    final deleteFailure = _failureOf(deleteResult);
    if (deleteFailure != null) {
      return left(deleteFailure);
    }

    if (choice != ProcessingChoice.trash) {
      await _logInboxProcessed(
        inboxItemId: inboxItemId,
        title: resolvedTitle,
        choice: choice,
      );
    }
    return right(null);
  }

  Future<Either<Failure, void>> _saveNextAction({
    required String title,
    required ZoroContext? context,
    required DateTime? targetDate,
    required DateTime? endDateTime,
    required String? notes,
    required DateTime createdAt,
    required List<String> tags,
  }) async {
    if (title.isEmpty) {
      return left(const ValidationFailure('Next action title is required.'));
    }

    final result = await taskRepository.createTask(
      Task(
        id: '',
        title: title,
        description: _clean(notes),
        context:
            context ?? const ZoroContext(id: 'anywhere', name: '@Anywhere'),
        targetDate: targetDate,
        endDateTime: endDateTime,
        createdAt: createdAt,
        tags: tags,
      ),
    );

    final task = _valueOf(result);
    if (task != null) {
      await logHistoryEntryUseCase?.call(
        action: HistoryAction.taskCreated,
        entityType: 'Task',
        entityId: task.id,
        description: 'Created next action "${task.title}".',
      );
    }

    return result.map((_) {});
  }

  Future<Either<Failure, void>> _saveCalendarEvent({
    required String title,
    required ZoroContext? context,
    required DateTime? targetDate,
    required DateTime? endDateTime,
    required String? notes,
    required DateTime createdAt,
    required List<String> tags,
    required Recurrence? recurrence,
  }) async {
    if (title.isEmpty) {
      return left(const ValidationFailure('Calendar event title is required.'));
    }
    if (targetDate == null) {
      return left(const ValidationFailure('Calendar event start is required.'));
    }

    final result = await taskRepository.createTask(
      Task(
        id: '',
        title: title,
        description: _clean(notes),
        context:
            context ?? const ZoroContext(id: 'anywhere', name: '@Anywhere'),
        targetDate: targetDate,
        endDateTime: endDateTime,
        createdAt: createdAt,
        tags: tags,
        isNextAction: false,
        isCalendarEvent: true,
        recurrence: recurrence,
      ),
    );

    final task = _valueOf(result);
    if (task != null) {
      await logHistoryEntryUseCase?.call(
        action: HistoryAction.calendarEventCreated,
        entityType: 'Task',
        entityId: task.id,
        description: 'Created calendar event "${task.title}".',
        details: task.recurrence?.toRRule().isEmpty == false
            ? 'Recurrence: ${task.recurrence!.toRRule()}.'
            : null,
      );
    }

    return result.map((_) {});
  }

  Future<Either<Failure, void>> _saveProjectWithCurrentAction({
    required String projectTitle,
    required String? desiredOutcome,
    required String? nextActionTitle,
    required ZoroContext? context,
    required DateTime? targetDate,
    required String? notes,
    required DateTime createdAt,
    required List<String> tags,
    required List<String> stepTitles,
    required List<ProjectStep> projectSteps,
  }) async {
    if (projectTitle.isEmpty) {
      return left(const ValidationFailure('Project title is required.'));
    }

    if (desiredOutcome == null) {
      return left(const ValidationFailure('Desired outcome is required.'));
    }

    final futureStepTitles = stepTitles.map(_clean).nonNulls.toList();
    final requestedSteps = [
      ...projectSteps,
      if (projectSteps.isEmpty && nextActionTitle != null)
        NextActionProjectStep(
          id: '',
          title: nextActionTitle,
          context:
              context ?? const ZoroContext(id: 'anywhere', name: '@Anywhere'),
          targetDate: targetDate,
          notes: notes,
          tags: tags,
        ),
    ];

    if (requestedSteps.isEmpty && futureStepTitles.isEmpty) {
      return left(const ValidationFailure('Create at least one action.'));
    }

    final validationFailure = _validateProjectSteps(requestedSteps);
    if (validationFailure != null) {
      return left(validationFailure);
    }

    final projectResult = await projectRepository.createProject(
      Project(
        id: '',
        title: projectTitle,
        desiredOutcome: desiredOutcome,
        createdAt: createdAt,
        targetCompletionDate: targetDate,
        tags: tags,
      ),
    );
    final projectFailure = _failureOf(projectResult);
    if (projectFailure != null) {
      return left(projectFailure);
    }

    final project = _valueOf(projectResult)!;
    final createdSteps = <ProjectStep>[];
    final stepIds = <String>[];
    for (final step in requestedSteps) {
      final shouldBeNextAction = step.kind == ProjectStepKind.nextAction;
      final result = await _createProjectStep(
        step: step,
        projectId: project.id,
        createdAt: createdAt,
        fallbackTags: tags,
        isAvailableNextAction: shouldBeNextAction,
      );
      final failure = _failureOf(result);
      if (failure != null) {
        return left(failure);
      }

      final createdStep = _valueOf(result)!;
      final entityId = createdStep.createdEntityId;
      if (entityId != null) {
        stepIds.add(entityId);
      }
      createdSteps.add(createdStep);
    }

    for (final stepTitle in futureStepTitles) {
      final stepResult = await taskRepository.createTask(
        Task(
          id: '',
          title: stepTitle,
          description: _clean(notes),
          context:
              context ?? const ZoroContext(id: 'anywhere', name: '@Anywhere'),
          targetDate: targetDate,
          createdAt: createdAt,
          projectId: project.id,
          tags: tags,
          isNextAction: false,
        ),
      );
      final stepFailure = _failureOf(stepResult);
      if (stepFailure != null) {
        return left(stepFailure);
      }

      final createdTask = _valueOf(stepResult)!;
      stepIds.add(createdTask.id);
      createdSteps.add(
        NextActionProjectStep(
          id: createdTask.id,
          title: createdTask.title,
          context: createdTask.context,
          createdEntityId: createdTask.id,
          notes: createdTask.description,
          targetDate: createdTask.targetDate,
          tags: createdTask.tags,
        ),
      );
    }

    final updateResult = await projectRepository.updateProject(
      project.copyWith(
        stepIds: stepIds,
        projectSteps: createdSteps,
        clearCurrentNextActionId: true,
      ),
    );
    final updateFailure = _failureOf(updateResult);
    if (updateFailure != null) {
      return left(updateFailure);
    }

    await logHistoryEntryUseCase?.call(
      action: HistoryAction.projectCreated,
      entityType: 'Project',
      entityId: project.id,
      description: 'Created project "${project.title}".',
      details: 'Created ${createdSteps.length} clarified step(s).',
    );

    return right(null);
  }

  Future<Either<Failure, ProjectStep>> _createProjectStep({
    required ProjectStep step,
    required String projectId,
    required DateTime createdAt,
    required List<String> fallbackTags,
    required bool isAvailableNextAction,
  }) async {
    return switch (step) {
      NextActionProjectStep() => await _createProjectNextActionStep(
          step: step,
          projectId: projectId,
          createdAt: createdAt,
          fallbackTags: fallbackTags,
          isAvailableNextAction: isAvailableNextAction,
        ),
      CalendarEventProjectStep() => await _createProjectCalendarStep(
          step: step,
          projectId: projectId,
          createdAt: createdAt,
          fallbackTags: fallbackTags,
        ),
      WaitingForProjectStep() => await _createProjectWaitingForStep(
          step: step,
          projectId: projectId,
          createdAt: createdAt,
          fallbackTags: fallbackTags,
        ),
    };
  }

  Future<Either<Failure, ProjectStep>> _createProjectNextActionStep({
    required NextActionProjectStep step,
    required String projectId,
    required DateTime createdAt,
    required List<String> fallbackTags,
    required bool isAvailableNextAction,
  }) async {
    if (step.title.trim().isEmpty) {
      return left(const ValidationFailure('Next action title is required.'));
    }

    final result = await taskRepository.createTask(
      Task(
        id: '',
        title: step.title.trim(),
        description: _clean(step.notes),
        context: step.context,
        targetDate: step.targetDate,
        createdAt: createdAt,
        projectId: projectId,
        tags: step.tags.isEmpty ? fallbackTags : step.tags,
        isNextAction: isAvailableNextAction,
      ),
    );
    final failure = _failureOf(result);
    if (failure != null) {
      return left(failure);
    }

    final task = _valueOf(result)!;
    await logHistoryEntryUseCase?.call(
      action: HistoryAction.taskCreated,
      entityType: 'Task',
      entityId: task.id,
      description: 'Created next action "${task.title}".',
      details: 'Linked to project.',
    );
    return right(step.withCreatedEntityId(task.id));
  }

  Future<Either<Failure, ProjectStep>> _createProjectCalendarStep({
    required CalendarEventProjectStep step,
    required String projectId,
    required DateTime createdAt,
    required List<String> fallbackTags,
  }) async {
    if (step.title.trim().isEmpty) {
      return left(const ValidationFailure('Calendar event title is required.'));
    }

    final result = await taskRepository.createTask(
      Task(
        id: '',
        title: step.title.trim(),
        description: _clean(step.notes),
        context: step.context,
        targetDate: step.targetDate,
        endDateTime: step.endDateTime,
        createdAt: createdAt,
        projectId: projectId,
        tags: step.tags.isEmpty ? fallbackTags : step.tags,
        isNextAction: false,
        isCalendarEvent: true,
        recurrence: step.recurrence,
      ),
    );
    final failure = _failureOf(result);
    if (failure != null) {
      return left(failure);
    }

    final task = _valueOf(result)!;
    await logHistoryEntryUseCase?.call(
      action: HistoryAction.calendarEventCreated,
      entityType: 'Task',
      entityId: task.id,
      description: 'Created calendar event "${task.title}".',
      details: 'Linked to project.',
    );
    return right(step.withCreatedEntityId(task.id));
  }

  Future<Either<Failure, ProjectStep>> _createProjectWaitingForStep({
    required WaitingForProjectStep step,
    required String projectId,
    required DateTime createdAt,
    required List<String> fallbackTags,
  }) async {
    if (step.title.trim().isEmpty) {
      return left(const ValidationFailure('Waiting For title is required.'));
    }
    if (step.person.trim().isEmpty) {
      return left(const ValidationFailure('Waiting on person is required.'));
    }

    final result = await waitingForRepository.addItem(
      WaitingForItem(
        id: '',
        title: step.title.trim(),
        person: step.person.trim(),
        projectId: projectId,
        followUpDate: step.followUpDate,
        createdAt: createdAt,
        notes: _clean(step.notes),
        tags: step.tags.isEmpty ? fallbackTags : step.tags,
      ),
    );
    final failure = _failureOf(result);
    if (failure != null) {
      return left(failure);
    }

    final item = _valueOf(result)!;
    await logHistoryEntryUseCase?.call(
      action: HistoryAction.waitingForCreated,
      entityType: 'WaitingForItem',
      entityId: item.id,
      description: 'Created Waiting For "${item.title}".',
      details: 'Linked to project. Waiting on ${item.person}.',
    );
    return right(step.withCreatedEntityId(item.id));
  }

  Future<Either<Failure, void>> _saveSomedayMaybe({
    required String title,
    required DateTime? reconsiderDate,
    required String? notes,
    required DateTime createdAt,
    required List<String> tags,
  }) async {
    if (title.isEmpty) {
      return left(const ValidationFailure('Someday/Maybe title is required.'));
    }

    final result = await somedayMaybeRepository.addItem(
      SomedayMaybeItem(
        id: '',
        title: title,
        reconsiderDate: reconsiderDate ?? DateTime(createdAt.year + 1),
        createdAt: createdAt,
        notes: _clean(notes),
        tags: tags,
      ),
    );

    final item = _valueOf(result);
    if (item != null) {
      await logHistoryEntryUseCase?.call(
        action: HistoryAction.somedayCreated,
        entityType: 'SomedayMaybeItem',
        entityId: item.id,
        description: 'Created Someday/Maybe item "${item.title}".',
      );
    }

    return result.map((_) {});
  }

  Future<Either<Failure, void>> _saveReference({
    required String title,
    required String? notes,
    required DateTime createdAt,
    required List<String> tags,
    required String? folder,
  }) async {
    if (title.isEmpty) {
      return left(const ValidationFailure('Reference title is required.'));
    }

    final result = await referenceRepository.addItem(
      ReferenceItem(
        id: '',
        title: title,
        notes: _clean(notes),
        tags: tags,
        folder: _clean(folder),
        createdAt: createdAt,
      ),
    );

    final item = _valueOf(result);
    if (item != null) {
      await logHistoryEntryUseCase?.call(
        action: HistoryAction.referenceCreated,
        entityType: 'ReferenceItem',
        entityId: item.id,
        description: 'Filed reference item "${item.title}".',
        details: item.folder == null ? null : 'Folder: ${item.folder}.',
      );
    }

    return result.map((_) {});
  }

  Future<Either<Failure, void>> _saveWaitingFor({
    required String title,
    required String? person,
    required String? projectId,
    required DateTime? followUpDate,
    required String? notes,
    required DateTime createdAt,
    required List<String> tags,
  }) async {
    if (title.isEmpty) {
      return left(const ValidationFailure('Waiting For title is required.'));
    }

    if (person == null) {
      return left(const ValidationFailure('Waiting on person is required.'));
    }

    final result = await waitingForRepository.addItem(
      WaitingForItem(
        id: '',
        title: title,
        person: person,
        projectId: projectId,
        followUpDate: followUpDate,
        createdAt: createdAt,
        notes: _clean(notes),
        tags: tags,
      ),
    );

    final item = _valueOf(result);
    if (item != null) {
      await logHistoryEntryUseCase?.call(
        action: HistoryAction.waitingForCreated,
        entityType: 'WaitingForItem',
        entityId: item.id,
        description: 'Created Waiting For "${item.title}".',
        details: 'Waiting on ${item.person}.',
      );
    }

    return result.map((_) {});
  }

  Future<Either<Failure, void>> _archiveTrashedInboxItem({
    required String title,
    required String? notes,
    required DateTime createdAt,
    required List<String> tags,
  }) async {
    if (title.isEmpty) {
      return left(const ValidationFailure('Trash title is required.'));
    }

    final result = await taskRepository.createTask(
      Task(
        id: '',
        title: title,
        description: _clean(notes),
        context: const ZoroContext(id: 'archive', name: 'Archive'),
        createdAt: createdAt,
        isNextAction: false,
        isCompleted: true,
        completedAt: createdAt,
        tags: {...tags, 'trash'}.toList(growable: false),
      ),
    );

    final task = _valueOf(result);
    if (task != null) {
      await logHistoryEntryUseCase?.call(
        action: HistoryAction.inboxTrashed,
        entityType: 'Task',
        entityId: task.id,
        description: 'Trashed inbox item "${task.title}".',
        details: 'Archived from Inbox.',
      );
    }

    return result.map((_) {});
  }

  Failure? _failureOf<T>(Either<Failure, T> result) {
    return result.match((failure) => failure, (_) => null);
  }

  T? _valueOf<T>(Either<Failure, T> result) {
    return result.match((_) => null, (value) => value);
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _logInboxProcessed({
    required String inboxItemId,
    required String title,
    required ProcessingChoice choice,
  }) async {
    await logHistoryEntryUseCase?.call(
      action: HistoryAction.inboxProcessed,
      entityType: 'InboxItem',
      entityId: inboxItemId,
      description: 'Processed inbox item "$title".',
      details: 'Clarified as ${choice.label}.',
    );
  }

  Failure? _validateProjectSteps(List<ProjectStep> steps) {
    for (final step in steps) {
      if (step.title.trim().isEmpty) {
        return switch (step.kind) {
          ProjectStepKind.nextAction =>
            const ValidationFailure('Next action title is required.'),
          ProjectStepKind.calendarEvent =>
            const ValidationFailure('Calendar event title is required.'),
          ProjectStepKind.waitingFor =>
            const ValidationFailure('Waiting For title is required.'),
        };
      }

      if (step case WaitingForProjectStep(:final person)
          when person.trim().isEmpty) {
        return const ValidationFailure('Waiting on person is required.');
      }
    }
    return null;
  }
}
