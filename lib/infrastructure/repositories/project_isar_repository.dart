import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/failure.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_step.dart';
import '../../domain/repositories/project_repository.dart';
import '../isar/project_schema.dart';

class ProjectIsarRepository implements ProjectRepository {
  const ProjectIsarRepository(this._isar);

  final Future<Isar> _isar;
  static const _uuid = Uuid();

  @override
  Future<Either<Failure, void>> clearAll() async {
    try {
      final isar = await _isar;
      await isar.writeTxn(() => isar.projectSchemas.clear());
      return right(null);
    } catch (error) {
      return left(DatabaseFailure('Could not clear projects: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> completeProject(String projectId) async {
    try {
      final isar = await _isar;
      final row = await _findByDomainId(isar, projectId);
      if (row == null) {
        return left(const NotFoundFailure('Project was not found.'));
      }

      row.isCompleted = true;
      await isar.writeTxn(() => isar.projectSchemas.put(row));
      return right(null);
    } catch (error) {
      return left(DatabaseFailure('Could not complete project: $error'));
    }
  }

  @override
  Future<Either<Failure, Project>> createProject(Project project) async {
    try {
      final isar = await _isar;
      final row = _toSchema(project);
      final id = await isar.writeTxn(() => isar.projectSchemas.put(row));
      row.id = id;
      return right(_toEntity(row));
    } catch (error) {
      return left(DatabaseFailure('Could not create project: $error'));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getActiveProjects() async {
    final result = await getAllProjects();
    return result.map(
      (projects) => projects
          .where((project) => !project.isCompleted)
          .toList(growable: false),
    );
  }

  @override
  Future<Either<Failure, List<Project>>> getAllProjects() async {
    try {
      final isar = await _isar;
      final rows = await isar.projectSchemas.where().findAll();
      rows.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return right(rows.map(_toEntity).toList(growable: false));
    } catch (error) {
      return left(DatabaseFailure('Could not load projects: $error'));
    }
  }

  @override
  Future<Either<Failure, Project>> getProjectById(String id) async {
    try {
      final isar = await _isar;
      final row = await _findByDomainId(isar, id);
      if (row == null) {
        return left(const NotFoundFailure('Project was not found.'));
      }

      return right(_toEntity(row));
    } catch (error) {
      return left(DatabaseFailure('Could not load project: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> moveProjectToSomeday(String projectId) async {
    return completeProject(projectId);
  }

  @override
  Future<Either<Failure, void>> updateProject(Project project) async {
    try {
      final isar = await _isar;
      final existing = await _findByDomainId(isar, project.id);
      if (existing == null) {
        return left(const NotFoundFailure('Project was not found.'));
      }

      final row = _toSchema(project)..id = existing.id;
      await isar.writeTxn(() => isar.projectSchemas.put(row));
      return right(null);
    } catch (error) {
      return left(DatabaseFailure('Could not update project: $error'));
    }
  }

  ProjectSchema _toSchema(Project project) {
    return ProjectSchema()
      ..uuid = project.id.isEmpty ? _uuid.v4() : project.id
      ..title = project.title
      ..desiredOutcome = project.desiredOutcome
      ..stepIds = project.stepIds
      ..projectStepsJson = project.projectSteps
          .map((step) => jsonEncode(step.toJson()))
          .toList(growable: false)
      ..currentNextActionId = project.currentNextActionId
      ..targetCompletionDate = project.targetCompletionDate
      ..isCompleted = project.isCompleted
      ..createdAt = project.createdAt
      ..tags = project.tags
      ..areaOfFocus = project.areaOfFocus
      ..completedStepCount = project.completedStepCount;
  }

  Project _toEntity(ProjectSchema row) {
    return Project(
      id: row.uuid ?? row.id.toString(),
      title: row.title,
      desiredOutcome: row.desiredOutcome,
      stepIds: row.stepIds,
      projectSteps:
          row.projectStepsJson.map(_projectStepFromJson).nonNulls.toList(
                growable: false,
              ),
      currentNextActionId: row.currentNextActionId,
      targetCompletionDate: row.targetCompletionDate,
      isCompleted: row.isCompleted,
      createdAt: row.createdAt,
      tags: row.tags,
      areaOfFocus: row.areaOfFocus,
      completedStepCount: row.completedStepCount,
    );
  }

  ProjectStep? _projectStepFromJson(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, Object?>) {
        return ProjectStep.fromJson(decoded);
      }
      if (decoded is Map) {
        return ProjectStep.fromJson(Map<String, Object?>.from(decoded));
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<ProjectSchema?> _findByDomainId(Isar isar, String id) async {
    final rows = await isar.projectSchemas.where().findAll();
    return rows
        .where((row) => (row.uuid ?? row.id.toString()) == id)
        .firstOrNull;
  }
}
