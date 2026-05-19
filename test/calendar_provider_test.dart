import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grok_zoro/domain/entities/context.dart';
import 'package:grok_zoro/domain/entities/project.dart';
import 'package:grok_zoro/domain/entities/task.dart';
import 'package:grok_zoro/domain/entities/waiting_for_item.dart';
import 'package:grok_zoro/injection_container.dart';

void main() {
  test('calendar entries derive from tasks, projects, and waiting for',
      () async {
    final container = ProviderContainer(
      overrides: [
        allTasksProvider.overrideWith(() => _TaskStub()),
        activeProjectsProvider.overrideWith(() => _ProjectStub()),
        waitingForProvider.overrideWith(() => _WaitingForStub()),
      ],
    );
    addTearDown(container.dispose);

    await Future.wait([
      container.read(allTasksProvider.future),
      container.read(activeProjectsProvider.future),
      container.read(waitingForProvider.future),
    ]);

    final entries = container.read(calendarEntriesProvider);

    expect(entries.map((entry) => entry.type), [
      CalendarEntryType.taskTarget,
      CalendarEntryType.projectTarget,
      CalendarEntryType.waitingFor,
      CalendarEntryType.taskDue,
    ]);
    expect(entries.map((entry) => entry.route), [
      '/task/task-1',
      '/project/project-1',
      '/waiting-for',
      '/task/task-2',
    ]);
  });

  test('visible calendar entries respect selected week', () async {
    final container = ProviderContainer(
      overrides: [
        allTasksProvider.overrideWith(() => _TaskStub()),
        activeProjectsProvider.overrideWith(() => _ProjectStub()),
        waitingForProvider.overrideWith(() => _WaitingForStub()),
      ],
    );
    addTearDown(container.dispose);

    await Future.wait([
      container.read(allTasksProvider.future),
      container.read(activeProjectsProvider.future),
      container.read(waitingForProvider.future),
    ]);
    container.read(selectedCalendarModeProvider.notifier).state =
        CalendarViewMode.week;
    container.read(selectedCalendarDateProvider.notifier).state =
        DateTime(2026, 5, 13);

    final entries = container.read(visibleCalendarEntriesProvider);

    expect(entries.map((entry) => entry.title), [
      'Review staging copy',
      'Launch Website',
      'Vendor quote',
    ]);
  });

  test('calendar entries omit completed dated tasks', () async {
    final container = ProviderContainer(
      overrides: [
        allTasksProvider.overrideWith(() => _CompletedTaskStub()),
        activeProjectsProvider.overrideWith(() => _EmptyProjectStub()),
        waitingForProvider.overrideWith(() => _EmptyWaitingForStub()),
      ],
    );
    addTearDown(container.dispose);

    await Future.wait([
      container.read(allTasksProvider.future),
      container.read(activeProjectsProvider.future),
      container.read(waitingForProvider.future),
    ]);

    final entries = container.read(calendarEntriesProvider);

    expect(entries, isEmpty);
  });
}

class _TaskStub extends AllTasksNotifier {
  @override
  Future<List<Task>> build() async {
    return [
      Task(
        id: 'task-1',
        title: 'Review staging copy',
        context: const ZoroContext(id: 'computer', name: '@Computer'),
        targetDate: DateTime(2026, 5, 11),
        createdAt: DateTime(2026, 5, 8),
      ),
      Task(
        id: 'task-2',
        title: 'File signed contract',
        context: const ZoroContext(id: 'computer', name: '@Computer'),
        dueDate: DateTime(2026, 5, 25),
        createdAt: DateTime(2026, 5, 8),
      ),
    ];
  }
}

class _ProjectStub extends ActiveProjectsNotifier {
  @override
  Future<List<Project>> build() async {
    return [
      Project(
        id: 'project-1',
        title: 'Launch Website',
        desiredOutcome: 'Website is live.',
        targetCompletionDate: DateTime(2026, 5, 12),
        createdAt: DateTime(2026, 5, 1),
      ),
    ];
  }
}

class _WaitingForStub extends WaitingForNotifier {
  @override
  Future<List<WaitingForItem>> build() async {
    return [
      WaitingForItem(
        id: 'waiting-1',
        title: 'Vendor quote',
        person: 'Maya',
        followUpDate: DateTime(2026, 5, 13),
        createdAt: DateTime(2026, 5, 8),
      ),
    ];
  }
}

class _CompletedTaskStub extends AllTasksNotifier {
  @override
  Future<List<Task>> build() async {
    return [
      Task(
        id: 'task-complete',
        title: 'Completed dated task',
        context: const ZoroContext(id: 'computer', name: '@Computer'),
        dueDate: DateTime(2026, 5, 11),
        createdAt: DateTime(2026, 5, 8),
        isCompleted: true,
      ),
    ];
  }
}

class _EmptyProjectStub extends ActiveProjectsNotifier {
  @override
  Future<List<Project>> build() async {
    return const [];
  }
}

class _EmptyWaitingForStub extends WaitingForNotifier {
  @override
  Future<List<WaitingForItem>> build() async {
    return const [];
  }
}
