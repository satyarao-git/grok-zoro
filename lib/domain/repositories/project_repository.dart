import 'package:fpdart/fpdart.dart';

import '../../core/utils/failure.dart';
import '../entities/project.dart';

abstract class ProjectRepository {
  Future<Either<Failure, Project>> createProject(Project project);
  Future<Either<Failure, Project>> getProjectById(String id);
  Future<Either<Failure, List<Project>>> getActiveProjects();
  Future<Either<Failure, List<Project>>> getAllProjects();
  Future<Either<Failure, void>> updateProject(Project project);
  Future<Either<Failure, void>> completeProject(String projectId);
  Future<Either<Failure, void>> moveProjectToSomeday(String projectId);
  Future<Either<Failure, void>> clearAll();
}
