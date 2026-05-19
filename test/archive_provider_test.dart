import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grok_zoro/domain/entities/context.dart';
import 'package:grok_zoro/domain/entities/project.dart';
import 'package:grok_zoro/domain/entities/task.dart';
import 'package:grok_zoro/injection_container.dart';

void main() {
  test('archive contains completed tasks and projects only', () async {
    final container = ProviderContainer(
      overrides: [
        allTasksProvider.overrideWith(() => _AllTasksStub()),
        allProjectsProvider.overrideWith(() => _AllProjectsStub()),
      ],
    );
    addTearDown(container.dispose);

    await Future.wait([
      container.read(allTasksProvider.future),
      container.read(allProjectsProvider.future),
    ]);

    final items = container.read(archiveItemsProvider);

    expect(items.map((item) => item.type), [
      ArchiveItemType.project,
      ArchiveItemType.task,
    ]);
    expect(items.map((item) => item.route), [
      '/project/project-1',
      '/task/task-1',
    ]);
  });
}

class _AllTasksStub extends AllTasksNotifier {
  @override
  Future<List<Task>> build() async {
    return [
      Task(
        id: 'task-1',
        title: 'Send launch update',
        context: const ZoroContext(id: 'computer', name: '@Computer'),
        createdAt: DateTime(2026, 5, 1),
        completedAt: DateTime(2026, 5, 8),
        isCompleted: true,
      ),
      Task(
        id: 'task-2',
        title: 'Open task',
        context: const ZoroContext(id: 'calls', name: '@Calls'),
        createdAt: DateTime(2026, 5, 7),
      ),
    ];
  }
}

class _AllProjectsStub extends AllProjectsNotifier {
  @override
  Future<List<Project>> build() async {
    return [
      Project(
        id: 'project-1',
        title: 'Closed Launch',
        desiredOutcome: 'Launch is complete.',
        createdAt: DateTime(2026, 5, 2),
        targetCompletionDate: DateTime(2026, 5, 9),
        isCompleted: true,
      ),
      Project(
        id: 'project-2',
        title: 'Open Launch',
        desiredOutcome: 'Launch is in progress.',
        createdAt: DateTime(2026, 5, 3),
      ),
    ];
  }
}
