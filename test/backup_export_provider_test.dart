import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grok_zoro/domain/entities/app_settings.dart';
import 'package:grok_zoro/domain/entities/context.dart';
import 'package:grok_zoro/domain/entities/inbox_item.dart';
import 'package:grok_zoro/domain/entities/project.dart';
import 'package:grok_zoro/domain/entities/project_step.dart';
import 'package:grok_zoro/domain/entities/reference_item.dart';
import 'package:grok_zoro/domain/entities/someday_maybe_item.dart';
import 'package:grok_zoro/domain/entities/task.dart';
import 'package:grok_zoro/domain/entities/waiting_for_item.dart';
import 'package:grok_zoro/domain/entities/weekly_review_progress.dart';
import 'package:grok_zoro/injection_container.dart';

void main() {
  test('backup export includes trusted system buckets', () async {
    final container = ProviderContainer(
      overrides: [
        appSettingsControllerProvider.overrideWith(() => _SettingsStub()),
        contextsStateProvider.overrideWith(() => _ContextsStub()),
        inboxItemsProvider.overrideWith(() => _InboxStub()),
        allTasksProvider.overrideWith(() => _TasksStub()),
        allProjectsProvider.overrideWith(() => _ProjectsStub()),
        referenceProvider.overrideWith(() => _ReferenceStub()),
        somedayMaybeProvider.overrideWith(() => _SomedayStub()),
        waitingForProvider.overrideWith(() => _WaitingForStub()),
        allWaitingForProvider.overrideWith((ref) async => [
              WaitingForItem(
                id: 'waiting-resolved',
                title: 'Resolved handoff',
                person: 'Maya',
                createdAt: DateTime(2026, 5, 6),
                isResolved: true,
              ),
            ]),
        weeklyReviewProgressProvider.overrideWith(() => _WeeklyReviewStub()),
      ],
    );
    addTearDown(container.dispose);

    await Future.wait([
      container.read(backupExportProvider.future),
    ]);

    final json = jsonDecode(await container.read(backupExportProvider.future))
        as Map<String, Object?>;

    expect(json['schemaVersion'], 1);
    expect(json.keys, containsAll(['settings', 'contexts', 'inbox', 'tasks']));
    expect(json['inbox'], isA<List>());
    expect(json['tasks'], isA<List>());
    final projects = json['projects'] as List;
    final project = projects.single as Map<String, Object?>;
    expect(project['projectSteps'], isA<List>());
    expect(project['projectSteps'] as List, hasLength(1));
    final waitingFor = json['waitingFor'] as List;
    expect(
      waitingFor.single as Map<String, Object?>,
      containsPair('isResolved', true),
    );
  });
}

class _SettingsStub extends AppSettingsNotifier {
  @override
  Future<AppSettings> build() async {
    return const AppSettings();
  }
}

class _ContextsStub extends ContextsNotifier {
  @override
  Future<List<ZoroContext>> build() async {
    return ContextsNotifier.defaultContexts;
  }
}

class _InboxStub extends InboxItemsNotifier {
  @override
  Future<List<InboxItem>> build() async {
    return [
      InboxItem(
        id: 'inbox-1',
        title: 'Export me',
        capturedAt: DateTime(2026, 5, 8),
      ),
    ];
  }
}

class _TasksStub extends AllTasksNotifier {
  @override
  Future<List<Task>> build() async {
    return [
      Task(
        id: 'task-1',
        title: 'Back up task',
        context: const ZoroContext(id: 'computer', name: '@Computer'),
        createdAt: DateTime(2026, 5, 8),
      ),
    ];
  }
}

class _ProjectsStub extends AllProjectsNotifier {
  @override
  Future<List<Project>> build() async {
    return [
      Project(
        id: 'project-1',
        title: 'Back up project',
        desiredOutcome: 'Project is preserved.',
        createdAt: DateTime(2026, 5, 8),
        stepIds: const ['task-1'],
        projectSteps: const [
          NextActionProjectStep(
            id: 'step-1',
            title: 'Back up task',
            context: ZoroContext(id: 'computer', name: '@Computer'),
            createdEntityId: 'task-1',
          ),
        ],
        currentNextActionId: 'task-1',
      ),
    ];
  }
}

class _SomedayStub extends SomedayMaybeNotifier {
  @override
  Future<List<SomedayMaybeItem>> build() async {
    return const [];
  }
}

class _ReferenceStub extends ReferenceNotifier {
  @override
  Future<List<ReferenceItem>> build() async {
    return const [];
  }
}

class _WaitingForStub extends WaitingForNotifier {
  @override
  Future<List<WaitingForItem>> build() async {
    return const [];
  }
}

class _WeeklyReviewStub extends WeeklyReviewProgressNotifier {
  @override
  Future<WeeklyReviewProgress> build() async {
    return const WeeklyReviewProgress();
  }
}
