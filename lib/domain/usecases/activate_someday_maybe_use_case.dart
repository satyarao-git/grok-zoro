import 'package:fpdart/fpdart.dart' hide Task;

import '../../core/utils/failure.dart';
import '../entities/context.dart';
import '../entities/history_entry.dart';
import '../entities/project.dart';
import '../entities/someday_maybe_item.dart';
import '../entities/task.dart';
import '../repositories/project_repository.dart';
import '../repositories/someday_maybe_repository.dart';
import '../repositories/task_repository.dart';
import 'log_history_entry_use_case.dart';

class ActivateSomedayMaybeUseCase {
  const ActivateSomedayMaybeUseCase({
    required this.projectRepository,
    required this.taskRepository,
    required this.somedayMaybeRepository,
    this.logHistoryEntryUseCase,
  });

  final ProjectRepository projectRepository;
  final TaskRepository taskRepository;
  final SomedayMaybeRepository somedayMaybeRepository;
  final LogHistoryEntryUseCase? logHistoryEntryUseCase;

  Future<Either<Failure, Project>> call(SomedayMaybeItem item) async {
    final now = DateTime.now();
    final projectResult = await projectRepository.createProject(
      Project(
        id: '',
        title: item.title,
        desiredOutcome: item.notes?.trim().isNotEmpty == true
            ? item.notes!
            : 'This project is active, clarified, and ready to move forward.',
        createdAt: now,
        tags: item.tags,
      ),
    );
    final projectFailure = _failureOf(projectResult);
    if (projectFailure != null) {
      return left(projectFailure);
    }

    final project = _valueOf(projectResult)!;
    final taskResult = await taskRepository.createTask(
      Task(
        id: '',
        title: 'Define next action for ${item.title}',
        context: const ZoroContext(id: 'anywhere', name: '@Anywhere'),
        createdAt: now,
        projectId: project.id,
        tags: item.tags,
      ),
    );
    final taskFailure = _failureOf(taskResult);
    if (taskFailure != null) {
      return left(taskFailure);
    }

    final task = _valueOf(taskResult)!;
    final activatedProject = Project(
      id: project.id,
      title: project.title,
      desiredOutcome: project.desiredOutcome,
      createdAt: project.createdAt,
      stepIds: [task.id],
      currentNextActionId: task.id,
      targetCompletionDate: project.targetCompletionDate,
      isCompleted: project.isCompleted,
      tags: project.tags,
      areaOfFocus: project.areaOfFocus,
    );

    final updateResult =
        await projectRepository.updateProject(activatedProject);
    final updateFailure = _failureOf(updateResult);
    if (updateFailure != null) {
      return left(updateFailure);
    }

    final deleteResult = await somedayMaybeRepository.deleteItem(item.id);
    final deleteFailure = _failureOf(deleteResult);
    if (deleteFailure != null) {
      return left(deleteFailure);
    }

    await logHistoryEntryUseCase?.call(
      action: HistoryAction.somedayActivated,
      entityType: 'SomedayMaybeItem',
      entityId: item.id,
      description: 'Activated Someday/Maybe item "${item.title}".',
      details: 'Created project "${activatedProject.title}".',
    );

    return right(activatedProject);
  }

  Failure? _failureOf<T>(Either<Failure, T> result) {
    return result.match((failure) => failure, (_) => null);
  }

  T? _valueOf<T>(Either<Failure, T> result) {
    return result.match((_) => null, (value) => value);
  }
}
