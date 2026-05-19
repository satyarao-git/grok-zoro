import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Task;
import 'package:grok_zoro/core/utils/failure.dart';
import 'package:grok_zoro/domain/entities/context.dart';
import 'package:grok_zoro/domain/entities/inbox_item.dart';
import 'package:grok_zoro/domain/entities/processing_choice.dart';
import 'package:grok_zoro/domain/entities/project.dart';
import 'package:grok_zoro/domain/entities/project_step.dart';
import 'package:grok_zoro/domain/entities/reference_item.dart';
import 'package:grok_zoro/domain/entities/recurrence.dart';
import 'package:grok_zoro/domain/entities/someday_maybe_item.dart';
import 'package:grok_zoro/domain/entities/task.dart';
import 'package:grok_zoro/domain/entities/waiting_for_item.dart';
import 'package:grok_zoro/domain/repositories/inbox_repository.dart';
import 'package:grok_zoro/domain/repositories/project_repository.dart';
import 'package:grok_zoro/domain/repositories/reference_repository.dart';
import 'package:grok_zoro/domain/repositories/someday_maybe_repository.dart';
import 'package:grok_zoro/domain/repositories/task_repository.dart';
import 'package:grok_zoro/domain/repositories/waiting_for_repository.dart';
import 'package:grok_zoro/domain/usecases/activate_someday_maybe_use_case.dart';
import 'package:grok_zoro/domain/usecases/complete_next_action_use_case.dart';
import 'package:grok_zoro/domain/usecases/process_inbox_item_use_case.dart';

void main() {
  group('InboxRepository capture contract', () {
    test('adds a captured inbox item', () async {
      final inbox = _FakeInboxRepository();

      final result = await inbox.addInboxItem(
        InboxItem(
          id: '',
          title: 'Capture a fresh idea',
          capturedAt: DateTime(2026, 5, 8),
          notes: 'From the global FAB.',
          source: CaptureSource.voice,
        ),
      );

      expect(result.isRight(), isTrue);
      expect(inbox.items, hasLength(2));
      expect(inbox.items.last.id, 'inbox-2');
      expect(inbox.items.last.title, 'Capture a fresh idea');
      expect(inbox.items.last.source, CaptureSource.voice);
    });
  });

  group('ProcessInboxItemUseCase', () {
    test('saves a standalone next action and clears the inbox item', () async {
      final harness = _Harness();

      final result = await harness.processInboxItemUseCase(
        inboxItemId: 'inbox-1',
        choice: ProcessingChoice.nextAction,
        title: 'Email launch notes',
        context: const ZoroContext(id: 'computer', name: '@Computer'),
        notes: 'Send the short version.',
        tags: const ['launch'],
      );

      expect(result.isRight(), isTrue);
      expect(harness.inbox.deletedIds, contains('inbox-1'));
      expect(harness.tasks.tasks, hasLength(1));
      expect(harness.tasks.tasks.single.title, 'Email launch notes');
      expect(harness.tasks.tasks.single.context.name, '@Computer');
      expect(harness.tasks.tasks.single.description, 'Send the short version.');
      expect(harness.tasks.tasks.single.tags, ['launch']);
      expect(harness.tasks.tasks.single.isNextAction, isTrue);
    });

    test('creates a project with starter action and future steps', () async {
      final harness = _Harness();

      final result = await harness.processInboxItemUseCase(
        inboxItemId: 'inbox-1',
        choice: ProcessingChoice.project,
        title: 'Launch website',
        desiredOutcome: 'The website is live and reviewed.',
        nextActionTitle: 'Review staging homepage',
        stepTitles: const [
          'Approve final copy',
          'Publish release notes',
        ],
        context: const ZoroContext(id: 'computer', name: '@Computer'),
        tags: const ['web'],
      );

      expect(result.isRight(), isTrue);
      expect(harness.inbox.deletedIds, contains('inbox-1'));
      expect(harness.projects.projects, hasLength(1));
      expect(harness.tasks.tasks, hasLength(3));

      final project = harness.projects.projects.single;
      final starterAction = harness.tasks.tasks.first;
      final futureSteps = harness.tasks.tasks.skip(1).toList();

      expect(project.title, 'Launch website');
      expect(project.desiredOutcome, 'The website is live and reviewed.');
      expect(project.currentNextActionId, isNull);
      expect(project.stepIds, harness.tasks.tasks.map((task) => task.id));
      expect(starterAction.isNextAction, isTrue);
      expect(futureSteps.map((task) => task.title), [
        'Approve final copy',
        'Publish release notes',
      ]);
      expect(futureSteps.every((task) => !task.isNextAction), isTrue);
    });

    test('keeps all next-action project steps active', () async {
      final harness = _Harness();

      final result = await harness.processInboxItemUseCase(
        inboxItemId: 'inbox-1',
        choice: ProcessingChoice.project,
        title: 'Prepare launch',
        desiredOutcome: 'Launch is ready.',
        projectSteps: const [
          NextActionProjectStep(
            id: 'draft-1',
            title: 'Review launch checklist',
            context: ZoroContext(id: 'computer', name: '@Computer'),
          ),
          NextActionProjectStep(
            id: 'draft-2',
            title: 'Send launch announcement',
            context: ZoroContext(id: 'computer', name: '@Computer'),
          ),
        ],
      );

      expect(result.isRight(), isTrue);
      expect(harness.tasks.tasks, hasLength(2));
      expect(harness.tasks.tasks.every((task) => task.isNextAction), isTrue);
      expect(harness.projects.projects.single.currentNextActionId, isNull);
      expect(harness.projects.projects.single.projectSteps, hasLength(2));
    });

    test('does not set calendar-only project steps as current next action',
        () async {
      final harness = _Harness();
      final start = DateTime(2026, 6, 1, 10);

      final result = await harness.processInboxItemUseCase(
        inboxItemId: 'inbox-1',
        choice: ProcessingChoice.project,
        title: 'Attend trade show',
        desiredOutcome: 'Trade show trip is complete.',
        projectSteps: [
          CalendarEventProjectStep(
            id: 'draft-calendar',
            title: 'Booth setup appointment',
            context: const ZoroContext(id: 'errands', name: '@Errands'),
            targetDate: start,
          ),
        ],
      );

      expect(result.isRight(), isTrue);
      expect(harness.tasks.tasks.single.isCalendarEvent, isTrue);
      expect(harness.tasks.tasks.single.isNextAction, isFalse);
      expect(harness.projects.projects.single.currentNextActionId, isNull);
    });

    test('validates all project steps before creating records', () async {
      final harness = _Harness();

      final result = await harness.processInboxItemUseCase(
        inboxItemId: 'inbox-1',
        choice: ProcessingChoice.project,
        title: 'Get proposal approved',
        desiredOutcome: 'Proposal is approved.',
        projectSteps: const [
          WaitingForProjectStep(
            id: 'draft-waiting',
            title: 'Client returns approval',
            person: '',
          ),
        ],
      );

      expect(result.isLeft(), isTrue);
      expect(harness.inbox.deletedIds, isEmpty);
      expect(harness.projects.projects, isEmpty);
      expect(harness.tasks.tasks, isEmpty);
      expect(harness.waitingFor.items, isEmpty);
    });

    test('moves an item to Someday/Maybe and clears the inbox item', () async {
      final harness = _Harness();
      final reconsiderDate = DateTime(2027, 1, 1);

      final result = await harness.processInboxItemUseCase(
        inboxItemId: 'inbox-1',
        choice: ProcessingChoice.someday,
        title: 'Explore partner event',
        reconsiderDate: reconsiderDate,
        notes: 'Maybe for next year.',
        tags: const ['events'],
      );

      expect(result.isRight(), isTrue);
      expect(harness.inbox.deletedIds, contains('inbox-1'));
      expect(harness.someday.items, hasLength(1));
      expect(harness.someday.items.single.title, 'Explore partner event');
      expect(harness.someday.items.single.reconsiderDate, reconsiderDate);
      expect(harness.someday.items.single.notes, 'Maybe for next year.');
      expect(harness.someday.items.single.tags, ['events']);
    });

    test('files an item as Reference and clears the inbox item', () async {
      final harness = _Harness();

      final result = await harness.processInboxItemUseCase(
        inboxItemId: 'inbox-1',
        choice: ProcessingChoice.reference,
        title: 'Printer invoice PDF',
        notes: 'Keep for event records.',
        referenceFolder: 'Receipts',
        tags: const ['event', 'finance'],
      );

      expect(result.isRight(), isTrue);
      expect(harness.inbox.deletedIds, contains('inbox-1'));
      expect(harness.reference.items, hasLength(1));
      expect(harness.reference.items.single.title, 'Printer invoice PDF');
      expect(harness.reference.items.single.notes, 'Keep for event records.');
      expect(harness.reference.items.single.folder, 'Receipts');
      expect(harness.reference.items.single.tags, ['event', 'finance']);
    });

    test('moves an item to Waiting For and clears the inbox item', () async {
      final harness = _Harness();
      final followUpDate = DateTime(2026, 5, 20);

      final result = await harness.processInboxItemUseCase(
        inboxItemId: 'inbox-1',
        choice: ProcessingChoice.waitingFor,
        title: 'Accountant sends tax packet',
        waitingOn: 'Accountant',
        followUpDate: followUpDate,
        notes: 'Need before filing.',
        tags: const ['tax'],
      );

      expect(result.isRight(), isTrue);
      expect(harness.inbox.deletedIds, contains('inbox-1'));
      expect(harness.waitingFor.items, hasLength(1));
      expect(
          harness.waitingFor.items.single.title, 'Accountant sends tax packet');
      expect(harness.waitingFor.items.single.person, 'Accountant');
      expect(harness.waitingFor.items.single.followUpDate, followUpDate);
      expect(harness.waitingFor.items.single.notes, 'Need before filing.');
      expect(harness.waitingFor.items.single.tags, ['tax']);
    });

    test('saves a recurring calendar event and keeps it out of next actions',
        () async {
      final harness = _Harness();
      final start = DateTime(2026, 5, 19, 8);
      final recurrence = Recurrence(
        frequency: RecurrenceFrequency.weekly,
        weekdays: const [DateTime.tuesday],
      );

      final result = await harness.processInboxItemUseCase(
        inboxItemId: 'inbox-1',
        choice: ProcessingChoice.calendarEvent,
        title: 'Weekly garden planning',
        targetDate: start,
        endDateTime: start.add(const Duration(minutes: 30)),
        recurrence: recurrence,
      );

      expect(result.isRight(), isTrue);
      expect(harness.inbox.deletedIds, contains('inbox-1'));
      expect(harness.tasks.tasks, hasLength(1));
      expect(harness.tasks.tasks.single.isCalendarEvent, isTrue);
      expect(harness.tasks.tasks.single.isNextAction, isFalse);
      expect(harness.tasks.tasks.single.recurrence, recurrence);
      final nextActions = await harness.tasks.getAllNextActions();
      expect(nextActions.getOrElse((_) => []), isEmpty);
    });

    test('trashes an item into archive without creating active records',
        () async {
      final harness = _Harness();

      final result = await harness.processInboxItemUseCase(
        inboxItemId: 'inbox-1',
        choice: ProcessingChoice.trash,
      );

      expect(result.isRight(), isTrue);
      expect(harness.inbox.deletedIds, contains('inbox-1'));
      expect(harness.tasks.tasks, hasLength(1));
      final archivedTask = harness.tasks.tasks.single;
      expect(archivedTask.title, 'Raw capture');
      expect(archivedTask.isCompleted, isTrue);
      expect(archivedTask.isNextAction, isFalse);
      expect(archivedTask.completedAt, isNotNull);
      expect(archivedTask.tags, contains('trash'));
      final nextActions = await harness.tasks.getAllNextActions();
      expect(nextActions.getOrElse((_) => []), isEmpty);
      expect(harness.projects.projects, isEmpty);
      expect(harness.someday.items, isEmpty);
      expect(harness.reference.items, isEmpty);
    });

    test('keeps inbox item when project validation fails', () async {
      final harness = _Harness();

      final result = await harness.processInboxItemUseCase(
        inboxItemId: 'inbox-1',
        choice: ProcessingChoice.project,
        title: 'Launch website',
        nextActionTitle: 'Review staging homepage',
      );

      expect(result.isLeft(), isTrue);
      expect(harness.inbox.deletedIds, isEmpty);
      expect(harness.inbox.items.single.id, 'inbox-1');
      expect(harness.projects.projects, isEmpty);
      expect(harness.tasks.tasks, isEmpty);
    });
  });

  group('CompleteNextActionUseCase', () {
    test('promotes the next incomplete project step', () async {
      final harness = _Harness();
      final project = Project(
        id: 'project-1',
        title: 'Launch website',
        desiredOutcome: 'Live website',
        createdAt: DateTime(2026, 5, 8),
        stepIds: const ['task-1', 'task-2'],
        currentNextActionId: 'task-1',
      );
      final current = Task(
        id: 'task-1',
        title: 'Review staging homepage',
        context: const ZoroContext(id: 'computer', name: '@Computer'),
        createdAt: DateTime(2026, 5, 8),
        projectId: 'project-1',
      );
      final nextStep = Task(
        id: 'task-2',
        title: 'Approve final copy',
        context: const ZoroContext(id: 'computer', name: '@Computer'),
        createdAt: DateTime(2026, 5, 8),
        projectId: 'project-1',
        isNextAction: false,
      );
      harness.projects.projects.add(project);
      harness.tasks.tasks.addAll([current, nextStep]);

      final result = await harness.completeNextActionUseCase('task-1');

      expect(result.isRight(), isTrue);
      expect(harness.tasks.byId('task-1').isCompleted, isTrue);
      expect(harness.tasks.byId('task-2').isNextAction, isTrue);
      expect(harness.projects.byId('project-1').currentNextActionId, 'task-2');
    });

    test('clears current next action when no steps remain', () async {
      final harness = _Harness();
      harness.projects.projects.add(
        Project(
          id: 'project-1',
          title: 'Launch website',
          desiredOutcome: 'Live website',
          createdAt: DateTime(2026, 5, 8),
          stepIds: const ['task-1'],
          currentNextActionId: 'task-1',
        ),
      );
      harness.tasks.tasks.add(
        Task(
          id: 'task-1',
          title: 'Review staging homepage',
          context: const ZoroContext(id: 'computer', name: '@Computer'),
          createdAt: DateTime(2026, 5, 8),
          projectId: 'project-1',
        ),
      );

      final result = await harness.completeNextActionUseCase('task-1');

      expect(result.isRight(), isTrue);
      expect(harness.tasks.byId('task-1').isCompleted, isTrue);
      expect(harness.projects.byId('project-1').currentNextActionId, isNull);
    });

    test('skips calendar events when promoting the next project action',
        () async {
      final harness = _Harness();
      final project = Project(
        id: 'project-1',
        title: 'Launch event',
        desiredOutcome: 'Event launched',
        createdAt: DateTime(2026, 5, 8),
        stepIds: const ['task-1', 'event-1', 'task-2'],
        projectSteps: [
          const NextActionProjectStep(
            id: 'step-1',
            title: 'Book venue',
            context: ZoroContext(id: 'computer', name: '@Computer'),
            createdEntityId: 'task-1',
          ),
          CalendarEventProjectStep(
            id: 'step-2',
            title: 'Venue walkthrough',
            context: ZoroContext(id: 'errands', name: '@Errands'),
            targetDate: DateTime(2026, 5, 20, 13),
            createdEntityId: 'event-1',
          ),
          const NextActionProjectStep(
            id: 'step-3',
            title: 'Send invitations',
            context: ZoroContext(id: 'computer', name: '@Computer'),
            createdEntityId: 'task-2',
          ),
        ],
        currentNextActionId: 'task-1',
      );
      final current = Task(
        id: 'task-1',
        title: 'Book venue',
        context: const ZoroContext(id: 'computer', name: '@Computer'),
        createdAt: DateTime(2026, 5, 8),
        projectId: 'project-1',
      );
      final calendarEvent = Task(
        id: 'event-1',
        title: 'Venue walkthrough',
        context: const ZoroContext(id: 'errands', name: '@Errands'),
        createdAt: DateTime(2026, 5, 8),
        targetDate: DateTime(2026, 5, 20, 13),
        projectId: 'project-1',
        isNextAction: false,
        isCalendarEvent: true,
      );
      final nextStep = Task(
        id: 'task-2',
        title: 'Send invitations',
        context: const ZoroContext(id: 'computer', name: '@Computer'),
        createdAt: DateTime(2026, 5, 8),
        projectId: 'project-1',
        isNextAction: false,
      );
      harness.projects.projects.add(project);
      harness.tasks.tasks.addAll([current, calendarEvent, nextStep]);

      final result = await harness.completeNextActionUseCase('task-1');

      expect(result.isRight(), isTrue);
      expect(harness.tasks.byId('event-1').isCalendarEvent, isTrue);
      expect(harness.tasks.byId('event-1').isNextAction, isFalse);
      expect(harness.tasks.byId('task-2').isNextAction, isTrue);
      expect(harness.projects.byId('project-1').currentNextActionId, 'task-2');
      expect(harness.projects.byId('project-1').projectSteps, hasLength(3));
    });
  });

  group('ActivateSomedayMaybeUseCase', () {
    test('creates an active project and starter next action', () async {
      final harness = _Harness();
      final item = SomedayMaybeItem(
        id: 'someday-1',
        title: 'Plan customer advisory board',
        reconsiderDate: DateTime(2026, 5, 1),
        createdAt: DateTime(2026, 4, 1),
        notes: 'A recurring group gives better roadmap feedback.',
        tags: const ['customers'],
      );
      harness.someday.items.add(item);

      final result = await harness.activateSomedayMaybeUseCase(item);

      expect(result.isRight(), isTrue);
      expect(harness.someday.items, isEmpty);
      expect(harness.projects.projects, hasLength(1));
      expect(harness.tasks.tasks, hasLength(1));

      final project = harness.projects.projects.single;
      final task = harness.tasks.tasks.single;
      expect(project.title, item.title);
      expect(project.desiredOutcome, item.notes);
      expect(project.currentNextActionId, task.id);
      expect(project.stepIds, [task.id]);
      expect(task.title, 'Define next action for ${item.title}');
      expect(task.context.name, '@Anywhere');
      expect(task.projectId, project.id);
      expect(task.tags, ['customers']);
    });
  });
}

class _Harness {
  _Harness()
      : inbox = _FakeInboxRepository(),
        tasks = _FakeTaskRepository(),
        projects = _FakeProjectRepository(),
        someday = _FakeSomedayMaybeRepository(),
        reference = _FakeReferenceRepository(),
        waitingFor = _FakeWaitingForRepository();

  final _FakeInboxRepository inbox;
  final _FakeTaskRepository tasks;
  final _FakeProjectRepository projects;
  final _FakeSomedayMaybeRepository someday;
  final _FakeReferenceRepository reference;
  final _FakeWaitingForRepository waitingFor;

  ProcessInboxItemUseCase get processInboxItemUseCase =>
      ProcessInboxItemUseCase(
        inboxRepository: inbox,
        taskRepository: tasks,
        projectRepository: projects,
        somedayMaybeRepository: someday,
        referenceRepository: reference,
        waitingForRepository: waitingFor,
      );

  CompleteNextActionUseCase get completeNextActionUseCase =>
      CompleteNextActionUseCase(
        taskRepository: tasks,
        projectRepository: projects,
      );

  ActivateSomedayMaybeUseCase get activateSomedayMaybeUseCase =>
      ActivateSomedayMaybeUseCase(
        projectRepository: projects,
        taskRepository: tasks,
        somedayMaybeRepository: someday,
      );
}

class _FakeReferenceRepository implements ReferenceRepository {
  final items = <ReferenceItem>[];
  int _nextId = 1;

  @override
  Future<Either<Failure, ReferenceItem>> addItem(ReferenceItem item) async {
    final saved = ReferenceItem(
      id: 'reference-${_nextId++}',
      title: item.title,
      notes: item.notes,
      tags: item.tags,
      folder: item.folder,
      createdAt: item.createdAt,
    );
    items.add(saved);
    return right(saved);
  }

  @override
  Future<Either<Failure, void>> clearAll() async {
    items.clear();
    return right(null);
  }

  @override
  Future<Either<Failure, void>> deleteItem(String id) async {
    items.removeWhere((item) => item.id == id);
    return right(null);
  }

  @override
  Future<Either<Failure, List<ReferenceItem>>> getAllItems() async {
    return right([...items]);
  }
}

class _FakeWaitingForRepository implements WaitingForRepository {
  final items = <WaitingForItem>[];
  int _nextId = 1;

  @override
  Future<Either<Failure, WaitingForItem>> addItem(
    WaitingForItem item,
  ) async {
    final saved = WaitingForItem(
      id: 'waiting-${_nextId++}',
      title: item.title,
      person: item.person,
      projectId: item.projectId,
      followUpDate: item.followUpDate,
      createdAt: item.createdAt,
      notes: item.notes,
      tags: item.tags,
      isResolved: item.isResolved,
    );
    items.add(saved);
    return right(saved);
  }

  @override
  Future<Either<Failure, void>> clearAll() async {
    items.clear();
    return right(null);
  }

  @override
  Future<Either<Failure, void>> deleteItem(String id) async {
    items.removeWhere((item) => item.id == id);
    return right(null);
  }

  @override
  Future<Either<Failure, List<WaitingForItem>>> getAllItems() async {
    return right(items);
  }

  @override
  Future<Either<Failure, List<WaitingForItem>>> getOpenItems() async {
    return right(
      items.where((item) => !item.isResolved).toList(growable: false),
    );
  }

  @override
  Future<Either<Failure, void>> markResolved(String id) async {
    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) {
      return left(const NotFoundFailure('Waiting For item was not found.'));
    }
    final item = items[index];
    items[index] = WaitingForItem(
      id: item.id,
      title: item.title,
      person: item.person,
      projectId: item.projectId,
      followUpDate: item.followUpDate,
      createdAt: item.createdAt,
      notes: item.notes,
      tags: item.tags,
      isResolved: true,
    );
    return right(null);
  }

  @override
  Future<Either<Failure, void>> updateItem(WaitingForItem item) async {
    final index = items.indexWhere((entry) => entry.id == item.id);
    if (index == -1) {
      return left(const NotFoundFailure('Waiting For item was not found.'));
    }
    items[index] = item;
    return right(null);
  }
}

class _FakeInboxRepository implements InboxRepository {
  final items = <InboxItem>[
    InboxItem(
      id: 'inbox-1',
      title: 'Raw capture',
      capturedAt: DateTime(2026, 5, 8),
      notes: 'Captured notes',
    ),
  ];
  final deletedIds = <String>[];
  int _nextId = 2;

  @override
  Future<Either<Failure, void>> clearAll() async {
    items.clear();
    return right(null);
  }

  @override
  Future<Either<Failure, InboxItem>> addInboxItem(InboxItem item) async {
    final saved = InboxItem(
      id: 'inbox-${_nextId++}',
      title: item.title,
      capturedAt: item.capturedAt,
      notes: item.notes,
      source: item.source,
    );
    items.add(saved);
    return right(saved);
  }

  @override
  Future<Either<Failure, void>> deleteInboxItem(String id) async {
    deletedIds.add(id);
    items.removeWhere((item) => item.id == id);
    return right(null);
  }

  @override
  Future<Either<Failure, List<InboxItem>>> getAllInboxItems() async {
    return right(items);
  }

  @override
  Future<Either<Failure, InboxItem>> getInboxItemById(String id) async {
    final item = items.where((item) => item.id == id).firstOrNull;
    return item == null
        ? left(const NotFoundFailure('Inbox item was not found.'))
        : right(item);
  }
}

class _FakeTaskRepository implements TaskRepository {
  final tasks = <Task>[];
  int _nextId = 1;

  @override
  Future<Either<Failure, void>> clearAll() async {
    tasks.clear();
    return right(null);
  }

  Task byId(String id) => tasks.singleWhere((task) => task.id == id);

  @override
  Future<Either<Failure, Task>> createTask(Task task) async {
    final saved = _copyTask(task, id: 'task-${_nextId++}');
    tasks.add(saved);
    return right(saved);
  }

  @override
  Future<Either<Failure, void>> completeTask(String taskId) async {
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) {
      return left(const NotFoundFailure('Task was not found.'));
    }

    tasks[index] = _copyTask(
      tasks[index],
      isCompleted: true,
      completedAt: DateTime(2026, 5, 8),
    );
    return right(null);
  }

  @override
  Future<Either<Failure, List<Task>>> getAllNextActions() async {
    return right(
      tasks
          .where((task) =>
              task.isNextAction && !task.isCompleted && !task.isCalendarEvent)
          .toList(growable: false),
    );
  }

  @override
  Future<Either<Failure, List<Task>>> getAllTasks() async {
    return right([...tasks]);
  }

  @override
  Future<Either<Failure, List<Task>>> getNextActionsByContext(
    String contextName,
  ) async {
    final all = await getAllNextActions();
    return all.map(
      (tasks) => tasks
          .where((task) => task.context.name == contextName)
          .toList(growable: false),
    );
  }

  @override
  Future<Either<Failure, Task>> getTaskById(String id) async {
    final task = tasks.where((task) => task.id == id).firstOrNull;
    return task == null
        ? left(const NotFoundFailure('Task was not found.'))
        : right(task);
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksForProject(
    String projectId,
  ) async {
    return right(
      tasks
          .where((task) => task.projectId == projectId)
          .toList(growable: false),
    );
  }

  @override
  Future<Either<Failure, void>> updateTask(Task task) async {
    final index = tasks.indexWhere((entry) => entry.id == task.id);
    if (index == -1) {
      return left(const NotFoundFailure('Task was not found.'));
    }

    tasks[index] = task;
    return right(null);
  }
}

class _FakeProjectRepository implements ProjectRepository {
  final projects = <Project>[];
  int _nextId = 1;

  @override
  Future<Either<Failure, void>> clearAll() async {
    projects.clear();
    return right(null);
  }

  Project byId(String id) =>
      projects.singleWhere((project) => project.id == id);

  @override
  Future<Either<Failure, void>> completeProject(String projectId) async {
    final index = projects.indexWhere((project) => project.id == projectId);
    if (index == -1) {
      return left(const NotFoundFailure('Project was not found.'));
    }

    projects[index] = _copyProject(projects[index], isCompleted: true);
    return right(null);
  }

  @override
  Future<Either<Failure, Project>> createProject(Project project) async {
    final saved = _copyProject(project, id: 'project-${_nextId++}');
    projects.add(saved);
    return right(saved);
  }

  @override
  Future<Either<Failure, List<Project>>> getActiveProjects() async {
    return right(
      projects.where((project) => !project.isCompleted).toList(growable: false),
    );
  }

  @override
  Future<Either<Failure, List<Project>>> getAllProjects() async {
    return right(projects);
  }

  @override
  Future<Either<Failure, Project>> getProjectById(String id) async {
    final project = projects.where((project) => project.id == id).firstOrNull;
    return project == null
        ? left(const NotFoundFailure('Project was not found.'))
        : right(project);
  }

  @override
  Future<Either<Failure, void>> moveProjectToSomeday(String projectId) async {
    return completeProject(projectId);
  }

  @override
  Future<Either<Failure, void>> updateProject(Project project) async {
    final index = projects.indexWhere((entry) => entry.id == project.id);
    if (index == -1) {
      return left(const NotFoundFailure('Project was not found.'));
    }

    projects[index] = project;
    return right(null);
  }
}

class _FakeSomedayMaybeRepository implements SomedayMaybeRepository {
  final items = <SomedayMaybeItem>[];
  int _nextId = 1;

  @override
  Future<Either<Failure, void>> clearAll() async {
    items.clear();
    return right(null);
  }

  @override
  Future<Either<Failure, SomedayMaybeItem>> addItem(
    SomedayMaybeItem item,
  ) async {
    final saved = SomedayMaybeItem(
      id: 'someday-${_nextId++}',
      title: item.title,
      reconsiderDate: item.reconsiderDate,
      createdAt: item.createdAt,
      notes: item.notes,
      tags: item.tags,
    );
    items.add(saved);
    return right(saved);
  }

  @override
  Future<Either<Failure, void>> deleteItem(String id) async {
    items.removeWhere((item) => item.id == id);
    return right(null);
  }

  @override
  Future<Either<Failure, List<SomedayMaybeItem>>> getAllItems() async {
    return right(items);
  }

  @override
  Future<Either<Failure, void>> snoozeItem(
    String id,
    DateTime reconsiderDate,
  ) async {
    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) {
      return left(const NotFoundFailure('Someday/Maybe item was not found.'));
    }

    final item = items[index];
    items[index] = SomedayMaybeItem(
      id: item.id,
      title: item.title,
      reconsiderDate: reconsiderDate,
      createdAt: item.createdAt,
      notes: item.notes,
      tags: item.tags,
    );
    return right(null);
  }
}

Task _copyTask(
  Task task, {
  String? id,
  bool? isNextAction,
  bool? isCompleted,
  DateTime? completedAt,
}) {
  return Task(
    id: id ?? task.id,
    title: task.title,
    context: task.context,
    createdAt: task.createdAt,
    description: task.description,
    dueDate: task.dueDate,
    targetDate: task.targetDate,
    endDateTime: task.endDateTime,
    isNextAction: isNextAction ?? task.isNextAction,
    isCompleted: isCompleted ?? task.isCompleted,
    completedAt: completedAt ?? task.completedAt,
    projectId: task.projectId,
    tags: task.tags,
    energyLevel: task.energyLevel,
    estimatedMinutes: task.estimatedMinutes,
    isCalendarEvent: task.isCalendarEvent,
    recurrence: task.recurrence,
  );
}

Project _copyProject(
  Project project, {
  String? id,
  bool? isCompleted,
}) {
  return Project(
    id: id ?? project.id,
    title: project.title,
    desiredOutcome: project.desiredOutcome,
    createdAt: project.createdAt,
    stepIds: project.stepIds,
    currentNextActionId: project.currentNextActionId,
    targetCompletionDate: project.targetCompletionDate,
    isCompleted: isCompleted ?? project.isCompleted,
    tags: project.tags,
    areaOfFocus: project.areaOfFocus,
    completedStepCount: project.completedStepCount,
  );
}
