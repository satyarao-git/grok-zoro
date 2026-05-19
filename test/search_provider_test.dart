import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grok_zoro/domain/entities/context.dart';
import 'package:grok_zoro/domain/entities/inbox_item.dart';
import 'package:grok_zoro/domain/entities/project.dart';
import 'package:grok_zoro/domain/entities/someday_maybe_item.dart';
import 'package:grok_zoro/domain/entities/task.dart';
import 'package:grok_zoro/domain/entities/waiting_for_item.dart';
import 'package:grok_zoro/injection_container.dart';

void main() {
  test('global search returns categorized matches', () async {
    final container = ProviderContainer(
      overrides: [
        inboxItemsProvider.overrideWith(() => _InboxStub()),
        activeProjectsProvider.overrideWith(() => _ProjectStub()),
        allNextActionsProvider.overrideWith(() => _TaskStub()),
        allTasksProvider.overrideWith(() => _AllTasksStub()),
        allProjectsProvider.overrideWith(() => _AllProjectsStub()),
        somedayMaybeProvider.overrideWith(() => _SomedayStub()),
        waitingForProvider.overrideWith(() => _WaitingForStub()),
      ],
    );
    addTearDown(container.dispose);

    await Future.wait([
      container.read(inboxItemsProvider.future),
      container.read(activeProjectsProvider.future),
      container.read(allNextActionsProvider.future),
      container.read(allTasksProvider.future),
      container.read(allProjectsProvider.future),
      container.read(somedayMaybeProvider.future),
      container.read(waitingForProvider.future),
    ]);
    container.read(searchQueryProvider.notifier).state = 'launch';

    final results = container.read(globalSearchResultsProvider);

    expect(results.map((result) => result.category), [
      'Inbox',
      'Project',
      'Next Action',
      'Someday/Maybe',
      'Waiting For',
    ]);
    expect(results.map((result) => result.route), [
      '/processing/inbox-1',
      '/project/project-1',
      '/task/task-1',
      '/someday',
      '/waiting-for',
    ]);
  });
}

class _AllTasksStub extends AllTasksNotifier {
  @override
  Future<List<Task>> build() async {
    return const [];
  }
}

class _AllProjectsStub extends AllProjectsNotifier {
  @override
  Future<List<Project>> build() async {
    return const [];
  }
}

class _InboxStub extends InboxItemsNotifier {
  @override
  Future<List<InboxItem>> build() async {
    return [
      InboxItem(
        id: 'inbox-1',
        title: 'Launch notes',
        capturedAt: DateTime(2026, 5, 8),
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
        title: 'Launch website',
        desiredOutcome: 'Public launch is ready.',
        createdAt: DateTime(2026, 5, 8),
      ),
    ];
  }
}

class _TaskStub extends AllNextActionsNotifier {
  @override
  Future<List<Task>> build() async {
    return [
      Task(
        id: 'task-1',
        title: 'Review launch checklist',
        context: const ZoroContext(id: 'computer', name: '@Computer'),
        createdAt: DateTime(2026, 5, 8),
      ),
    ];
  }
}

class _SomedayStub extends SomedayMaybeNotifier {
  @override
  Future<List<SomedayMaybeItem>> build() async {
    return [
      SomedayMaybeItem(
        id: 'someday-1',
        title: 'Launch event roadshow',
        reconsiderDate: DateTime(2027, 1, 1),
        createdAt: DateTime(2026, 5, 8),
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
        title: 'Launch contract approval',
        person: 'Maya',
        createdAt: DateTime(2026, 5, 8),
      ),
    ];
  }
}
