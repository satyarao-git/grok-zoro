import 'package:fpdart/fpdart.dart' hide Task;

import '../../core/utils/failure.dart';
import '../entities/history_entry.dart';
import '../entities/task.dart';
import '../repositories/project_repository.dart';
import '../repositories/task_repository.dart';
import 'log_history_entry_use_case.dart';

class CompleteNextActionUseCase {
  const CompleteNextActionUseCase({
    required this.taskRepository,
    required this.projectRepository,
    this.logHistoryEntryUseCase,
  });

  final TaskRepository taskRepository;
  final ProjectRepository projectRepository;
  final LogHistoryEntryUseCase? logHistoryEntryUseCase;

  Future<Either<Failure, void>> call(String taskId) async {
    final taskResult = await taskRepository.getTaskById(taskId);
    final taskFailure = _failureOf(taskResult);
    if (taskFailure != null) {
      return left(taskFailure);
    }

    final task = _valueOf(taskResult)!;
    final completeResult = await taskRepository.completeTask(taskId);
    final completeFailure = _failureOf(completeResult);
    if (completeFailure != null) {
      return left(completeFailure);
    }
    await _logTaskCompleted(task);

    final projectId = task.projectId;
    if (projectId == null) {
      return right(null);
    }

    final projectResult = await projectRepository.getProjectById(projectId);
    final projectFailure = _failureOf(projectResult);
    if (projectFailure != null) {
      return left(projectFailure);
    }

    final project = _valueOf(projectResult)!;
    if (project.currentNextActionId != task.id) {
      return right(null);
    }

    final projectTasksResult =
        await taskRepository.getTasksForProject(projectId);
    final projectTasksFailure = _failureOf(projectTasksResult);
    if (projectTasksFailure != null) {
      return left(projectTasksFailure);
    }

    final projectTasks = _valueOf(projectTasksResult)!;
    final nextStep = project.stepIds
        .where((stepId) => stepId != task.id)
        .map((stepId) =>
            projectTasks.where((entry) => entry.id == stepId).firstOrNull)
        .nonNulls
        .where((entry) => !entry.isCompleted && !entry.isCalendarEvent)
        .firstOrNull;

    if (nextStep == null) {
      return projectRepository.updateProject(
        project.copyWith(clearCurrentNextActionId: true),
      );
    }

    final promotedResult = await taskRepository.updateTask(
      nextStep.copyWith(isNextAction: true),
    );
    final promotedFailure = _failureOf(promotedResult);
    if (promotedFailure != null) {
      return left(promotedFailure);
    }

    return projectRepository.updateProject(
      project.copyWith(currentNextActionId: nextStep.id),
    );
  }

  Failure? _failureOf<T>(Either<Failure, T> result) {
    return result.match((failure) => failure, (_) => null);
  }

  T? _valueOf<T>(Either<Failure, T> result) {
    return result.match((_) => null, (value) => value);
  }

  Future<void> _logTaskCompleted(Task task) async {
    await logHistoryEntryUseCase?.call(
      action: HistoryAction.taskCompleted,
      entityType: 'Task',
      entityId: task.id,
      description: 'Completed next action "${task.title}".',
    );
  }
}
