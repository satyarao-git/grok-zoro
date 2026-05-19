import 'package:fpdart/fpdart.dart';

import '../../core/utils/failure.dart';
import '../entities/history_entry.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';
import 'log_history_entry_use_case.dart';

class CreateProjectUseCase {
  const CreateProjectUseCase(
    this.repository, {
    this.logHistoryEntryUseCase,
  });

  final ProjectRepository repository;
  final LogHistoryEntryUseCase? logHistoryEntryUseCase;

  Future<Either<Failure, Project>> call(Project project) async {
    final result = await repository.createProject(project);
    final created = result.match((_) => null, (project) => project);
    if (created != null) {
      await logHistoryEntryUseCase?.call(
        action: HistoryAction.projectCreated,
        entityType: 'Project',
        entityId: created.id,
        description: 'Created project "${created.title}".',
      );
    }
    return result;
  }
}
