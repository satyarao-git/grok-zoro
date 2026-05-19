import 'package:fpdart/fpdart.dart' hide Task;
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/failure.dart';
import '../../domain/entities/context.dart';
import '../../domain/entities/recurrence.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../isar/task_schema.dart';

class TaskIsarRepository implements TaskRepository {
  const TaskIsarRepository(this._isar);

  final Future<Isar> _isar;
  static const _uuid = Uuid();

  @override
  Future<Either<Failure, void>> clearAll() async {
    try {
      final isar = await _isar;
      await isar.writeTxn(() => isar.taskSchemas.clear());
      return right(null);
    } catch (error) {
      return left(DatabaseFailure('Could not clear tasks: $error'));
    }
  }

  @override
  Future<Either<Failure, Task>> createTask(Task task) async {
    try {
      final isar = await _isar;
      final row = _toSchema(task);
      final id = await isar.writeTxn(() => isar.taskSchemas.put(row));
      row.id = id;
      return right(_toEntity(row));
    } catch (error) {
      return left(DatabaseFailure('Could not create task: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> completeTask(String taskId) async {
    try {
      final isar = await _isar;
      final row = await _findByDomainId(isar, taskId);
      if (row == null) {
        return left(const NotFoundFailure('Task was not found.'));
      }

      row
        ..isCompleted = true
        ..completedAt = DateTime.now();
      await isar.writeTxn(() => isar.taskSchemas.put(row));
      return right(null);
    } catch (error) {
      return left(DatabaseFailure('Could not complete task: $error'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getAllNextActions() async {
    try {
      final isar = await _isar;
      final rows = await isar.taskSchemas.where().findAll();
      rows
        ..removeWhere((row) =>
            row.isCompleted || !row.isNextAction || row.isCalendarEvent)
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return right(rows.map(_toEntity).toList(growable: false));
    } catch (error) {
      return left(DatabaseFailure('Could not load next actions: $error'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getAllTasks() async {
    try {
      final isar = await _isar;
      final rows = await isar.taskSchemas.where().findAll();
      rows.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return right(rows.map(_toEntity).toList(growable: false));
    } catch (error) {
      return left(DatabaseFailure('Could not load tasks: $error'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getNextActionsByContext(
    String contextName,
  ) async {
    final result = await getAllNextActions();
    return result.map(
      (tasks) => tasks
          .where((task) => task.context.name == contextName)
          .toList(growable: false),
    );
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksForProject(
    String projectId,
  ) async {
    try {
      final isar = await _isar;
      final rows = await isar.taskSchemas.where().findAll();
      return right(
        rows
            .where((row) => row.projectId == projectId)
            .map(_toEntity)
            .toList(growable: false),
      );
    } catch (error) {
      return left(DatabaseFailure('Could not load project tasks: $error'));
    }
  }

  @override
  Future<Either<Failure, Task>> getTaskById(String id) async {
    try {
      final isar = await _isar;
      final row = await _findByDomainId(isar, id);
      if (row == null) {
        return left(const NotFoundFailure('Task was not found.'));
      }

      return right(_toEntity(row));
    } catch (error) {
      return left(DatabaseFailure('Could not load task: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTask(Task task) async {
    try {
      final isar = await _isar;
      final row = _toSchema(task);
      final existing = await _findByDomainId(isar, task.id);
      if (existing == null) {
        return left(const NotFoundFailure('Task was not found.'));
      }

      row.id = existing.id;
      await isar.writeTxn(() => isar.taskSchemas.put(row));
      return right(null);
    } catch (error) {
      return left(DatabaseFailure('Could not update task: $error'));
    }
  }

  TaskSchema _toSchema(Task task) {
    return TaskSchema()
      ..uuid = task.id.isEmpty ? _uuid.v4() : task.id
      ..title = task.title
      ..description = task.description
      ..contextName = task.context.name
      ..dueDate = task.dueDate
      ..targetDate = task.targetDate
      ..endDateTime = task.endDateTime
      ..isNextAction = task.isNextAction
      ..isCalendarEvent = task.isCalendarEvent
      ..isCompleted = task.isCompleted
      ..createdAt = task.createdAt
      ..completedAt = task.completedAt
      ..projectId = task.projectId
      ..tags = task.tags
      ..energyLevel = task.energyLevel.name
      ..estimatedMinutes = task.estimatedMinutes
      ..recurrenceRule = task.recurrence?.toRRule();
  }

  Task _toEntity(TaskSchema row) {
    return Task(
      id: row.uuid ?? row.id.toString(),
      title: row.title,
      description: row.description,
      context: ZoroContext(
        id: row.contextName.replaceAll('@', '').toLowerCase(),
        name: row.contextName,
      ),
      dueDate: row.dueDate,
      targetDate: row.targetDate,
      endDateTime: row.endDateTime,
      isNextAction: row.isNextAction,
      isCalendarEvent: row.isCalendarEvent,
      isCompleted: row.isCompleted,
      createdAt: row.createdAt,
      completedAt: row.completedAt,
      projectId: row.projectId,
      tags: row.tags,
      energyLevel: EnergyLevel.values.firstWhere(
        (level) => level.name == row.energyLevel,
        orElse: () => EnergyLevel.medium,
      ),
      estimatedMinutes: row.estimatedMinutes,
      recurrence: Recurrence.fromRRule(row.recurrenceRule),
    );
  }

  Future<TaskSchema?> _findByDomainId(Isar isar, String id) async {
    final rows = await isar.taskSchemas.where().findAll();
    return rows
        .where((row) => (row.uuid ?? row.id.toString()) == id)
        .firstOrNull;
  }
}
