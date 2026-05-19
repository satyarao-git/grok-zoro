import 'package:fpdart/fpdart.dart' hide Task;

import '../../core/utils/failure.dart';
import '../entities/task.dart';

abstract class TaskRepository {
  Future<Either<Failure, Task>> createTask(Task task);
  Future<Either<Failure, Task>> getTaskById(String id);
  Future<Either<Failure, List<Task>>> getTasksForProject(String projectId);
  Future<Either<Failure, List<Task>>> getNextActionsByContext(
    String contextName,
  );
  Future<Either<Failure, List<Task>>> getAllNextActions();
  Future<Either<Failure, List<Task>>> getAllTasks();
  Future<Either<Failure, void>> completeTask(String taskId);
  Future<Either<Failure, void>> updateTask(Task task);
  Future<Either<Failure, void>> clearAll();
}
