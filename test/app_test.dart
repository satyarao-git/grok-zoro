import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:grok_zoro/app.dart';
import 'package:grok_zoro/core/routes/app_router.dart';
import 'package:grok_zoro/domain/entities/context.dart';
import 'package:grok_zoro/domain/entities/project.dart';
import 'package:grok_zoro/domain/entities/task.dart';
import 'package:grok_zoro/injection_container.dart';
import 'package:grok_zoro/presentation/screens/calendar/calendar_screen.dart';
import 'package:grok_zoro/presentation/screens/project/project_detail_screen.dart';
import 'package:grok_zoro/presentation/screens/task/task_detail_screen.dart';
import 'package:grok_zoro/presentation/screens/weekly_review/weekly_review_screen.dart';
import 'package:grok_zoro/presentation/widgets/zoro_app_scaffold.dart';

void main() {
  testWidgets('Zoro app starts on the dashboard', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ZoroApp()));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('A Trusted System'), findsOneWidget);
  });

  testWidgets('desktop navigation exposes every primary GTD area',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: ZoroApp()));
    await tester.pumpAndSettle();

    const labels = [
      'Dashboard',
      'Inbox',
      'Next Actions',
      'Someday/Maybe',
      'Projects',
      'Calendar',
      'Weekly Review',
      'Waiting for',
      'Reference',
      'Contexts',
      'Horizons',
      'Search',
      'Archive',
      'Settings',
    ];

    for (final label in labels) {
      expect(find.text(label), findsAtLeastNWidgets(1), reason: label);
    }

    expect(find.text('All next actions'), findsNothing);
    expect(find.text('History'), findsNothing);
  });

  testWidgets('calendar week view renders scheduled entries', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final today = DateTime.now();
    final scheduledDate = DateTime(today.year, today.month, today.day, 10);
    final router = GoRouter(
      initialLocation: '/calendar',
      routes: [
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/task/:taskId',
          builder: (context, state) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/project/:projectId',
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRouterProvider.overrideWithValue(router),
          allTasksProvider.overrideWith(
            () => _CalendarTaskStub(scheduledDate),
          ),
          activeProjectsProvider.overrideWith(() => _CalendarProjectStub()),
        ],
        child: const ZoroApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Calendar smoke test'), findsOneWidget);
  });

  testWidgets('weekly review calendar add opens the direct creation form',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/weekly-review',
      routes: [
        GoRoute(
          path: '/weekly-review',
          builder: (context, state) => const WeeklyReviewScreen(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRouterProvider.overrideWithValue(router),
        ],
        child: const ZoroApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Review Calendar').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add new Calendar Event'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Add Calendar Event'), findsOneWidget);
    expect(find.text('Calendar Event Title'), findsOneWidget);
    expect(find.text('Recurrence'), findsOneWidget);
  });

  testWidgets('weekly review next action add opens the direct creation form',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/weekly-review',
      routes: [
        GoRoute(
          path: '/weekly-review',
          builder: (context, state) => const WeeklyReviewScreen(),
        ),
        GoRoute(
          path: '/next-actions',
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRouterProvider.overrideWithValue(router),
        ],
        child: const ZoroApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Review Next Actions').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add new Next Action'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Add Next Action'), findsOneWidget);
    expect(find.text('Next Action Title'), findsOneWidget);
    expect(find.text('Target date - optional'), findsOneWidget);
  });

  testWidgets('weekly review open calendar can navigate back', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/weekly-review',
      routes: [
        GoRoute(
          path: '/weekly-review',
          builder: (context, state) => const WeeklyReviewScreen(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const ZoroAppScaffold(
            title: 'Calendar',
            child: Text('Calendar target'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRouterProvider.overrideWithValue(router),
        ],
        child: const ZoroApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Review Calendar').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Calendar'));
    await tester.pumpAndSettle();

    expect(find.text('Calendar target'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Weekly Review'), findsAtLeastNWidgets(1));
    expect(find.text('Review Calendar'), findsWidgets);
  });

  testWidgets('project detail shows step statuses and opens details',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final tasks = [
      _projectTask('task-active-1', 'Call vendor', isNextAction: true),
      _projectTask('task-active-2', 'Draft outline', isNextAction: true),
      _projectTask('task-future', 'Review launch checklist'),
    ];
    final router = GoRouter(
      initialLocation: '/project/project-1',
      routes: [
        GoRoute(
          path: '/project/:projectId',
          builder: (context, state) {
            return ProjectDetailScreen(
              projectId: state.pathParameters['projectId']!,
            );
          },
        ),
        GoRoute(
          path: '/task/:taskId',
          builder: (context, state) {
            return ZoroAppScaffold(
              title: 'Task',
              child: Text('Task ${state.pathParameters['taskId']}'),
            );
          },
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRouterProvider.overrideWithValue(router),
          allProjectsProvider.overrideWith(() => _AllProjectsStub()),
          allNextActionsProvider
              .overrideWith(() => _AllNextActionsMutableStub(tasks)),
          projectTasksProvider('project-1').overrideWith((ref) async => tasks),
        ],
        child: const ZoroApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Current Next Actions'), findsNothing);
    expect(find.text('Steps'), findsOneWidget);
    expect(find.text('Not active'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Review launch checklist'),
      320,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Not active'));
    await tester.pumpAndSettle();
    expect(
      tasks.singleWhere((task) => task.id == 'task-future').isNextAction,
      isTrue,
    );

    final futureStepTile = find.ancestor(
      of: find.text('Review launch checklist'),
      matching: find.byType(ListTile),
    );
    await tester.tap(find.descendant(
      of: futureStepTile,
      matching: find.byType(Checkbox),
    ));
    await tester.pumpAndSettle();
    expect(tasks.singleWhere((task) => task.id == 'task-future').isCompleted,
        isTrue);

    await tester.tap(find.descendant(
      of: futureStepTile,
      matching: find.byType(Checkbox),
    ));
    await tester.pumpAndSettle();
    expect(tasks.singleWhere((task) => task.id == 'task-future').isCompleted,
        isFalse);

    await tester.tap(find.byTooltip('View details').last);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Task task-future'), findsOneWidget);
  });

  testWidgets('task detail can mark a completed task not complete',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var task = Task(
      id: 'task-1',
      title: 'Undo accidental completion',
      context: const ZoroContext(id: 'computer', name: '@Computer'),
      createdAt: DateTime(2026),
      completedAt: DateTime(2026, 5, 15),
      isCompleted: true,
    );
    final router = GoRouter(
      initialLocation: '/task/task-1',
      routes: [
        GoRoute(
          path: '/task/:taskId',
          builder: (context, state) {
            return TaskDetailScreen(taskId: state.pathParameters['taskId']!);
          },
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRouterProvider.overrideWithValue(router),
          activeProjectsProvider.overrideWith(() => _CalendarProjectStub()),
          allNextActionsProvider.overrideWith(
            () => _MutableTaskActionsStub(
              getTask: () => task,
              setTask: (updated) => task = updated,
            ),
          ),
          taskDetailProvider('task-1').overrideWith((ref) async => task),
        ],
        child: const ZoroApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mark Not Complete'), findsOneWidget);
    await tester.tap(find.text('Mark Not Complete'));
    await tester.pumpAndSettle();

    expect(task.isCompleted, isFalse);
    expect(task.completedAt, isNull);
    expect(find.text('Mark Complete'), findsOneWidget);
  });
}

class _CalendarTaskStub extends AllTasksNotifier {
  _CalendarTaskStub(this.scheduledDate);

  final DateTime scheduledDate;

  @override
  Future<List<Task>> build() async {
    return [
      Task(
        id: 'calendar-smoke-test',
        title: 'Calendar smoke test',
        context: const ZoroContext(id: 'computer', name: '@Computer'),
        targetDate: scheduledDate,
        endDateTime: scheduledDate.add(const Duration(hours: 1)),
        createdAt: DateTime(2026),
      ),
    ];
  }
}

class _CalendarProjectStub extends ActiveProjectsNotifier {
  @override
  Future<List<Project>> build() async {
    return const [];
  }
}

class _AllProjectsStub extends AllProjectsNotifier {
  @override
  Future<List<Project>> build() async {
    return [
      Project(
        id: 'project-1',
        title: 'Launch Project',
        desiredOutcome: 'Launch is complete.',
        createdAt: DateTime(2026),
        currentNextActionId: 'task-active-1',
        stepIds: const ['task-active-1', 'task-active-2', 'task-future'],
      ),
    ];
  }
}

class _AllNextActionsMutableStub extends AllNextActionsNotifier {
  _AllNextActionsMutableStub(this.tasks);

  final List<Task> tasks;

  @override
  Future<List<Task>> build() async {
    return tasks
        .where((task) =>
            task.isNextAction && !task.isCompleted && !task.isCalendarEvent)
        .toList(growable: false);
  }

  @override
  Future<bool> updateTask(Task task) async {
    final index = tasks.indexWhere((entry) => entry.id == task.id);
    if (index == -1) {
      return false;
    }

    tasks[index] = task;
    ref.invalidate(projectTasksProvider('project-1'));
    return true;
  }
}

class _MutableTaskActionsStub extends AllNextActionsNotifier {
  _MutableTaskActionsStub({
    required this.getTask,
    required this.setTask,
  });

  final Task Function() getTask;
  final void Function(Task task) setTask;

  @override
  Future<List<Task>> build() async {
    final task = getTask();
    return task.isNextAction && !task.isCompleted && !task.isCalendarEvent
        ? [task]
        : [];
  }

  @override
  Future<bool> updateTask(Task task) async {
    setTask(task);
    ref
      ..invalidate(taskDetailProvider(task.id))
      ..invalidateSelf();
    return true;
  }
}

Task _projectTask(
  String id,
  String title, {
  bool isNextAction = false,
}) {
  return Task(
    id: id,
    title: title,
    context: const ZoroContext(id: 'computer', name: '@Computer'),
    createdAt: DateTime(2026),
    projectId: 'project-1',
    isNextAction: isNextAction,
  );
}
