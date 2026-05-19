import 'package:fpdart/fpdart.dart';

import '../../core/utils/failure.dart';
import '../entities/history_entry.dart';
import '../repositories/history_repository.dart';
import '../repositories/inbox_repository.dart';
import '../repositories/project_repository.dart';
import '../repositories/reference_repository.dart';
import '../repositories/someday_maybe_repository.dart';
import '../repositories/task_repository.dart';
import '../repositories/waiting_for_repository.dart';
import 'log_history_entry_use_case.dart';

class ClearAllDataUseCase {
  const ClearAllDataUseCase({
    required this.inboxRepository,
    required this.taskRepository,
    required this.projectRepository,
    required this.somedayMaybeRepository,
    required this.referenceRepository,
    required this.waitingForRepository,
    required this.historyRepository,
    required this.logHistoryEntryUseCase,
  });

  final InboxRepository inboxRepository;
  final TaskRepository taskRepository;
  final ProjectRepository projectRepository;
  final SomedayMaybeRepository somedayMaybeRepository;
  final ReferenceRepository referenceRepository;
  final WaitingForRepository waitingForRepository;
  final HistoryRepository historyRepository;
  final LogHistoryEntryUseCase logHistoryEntryUseCase;

  Future<Either<Failure, void>> call() async {
    for (final action in [
      inboxRepository.clearAll,
      taskRepository.clearAll,
      projectRepository.clearAll,
      somedayMaybeRepository.clearAll,
      referenceRepository.clearAll,
      waitingForRepository.clearAll,
      historyRepository.clearAll,
    ]) {
      final result = await action();
      final failure = result.match((failure) => failure, (_) => null);
      if (failure != null) {
        return left(failure);
      }
    }

    return logHistoryEntryUseCase(
      action: HistoryAction.dataCleared,
      entityType: 'System',
      description: 'Cleared all operational GTD data.',
      details:
          'Inbox, Next Actions, Projects, Someday/Maybe, Reference, and Waiting For were cleared from Settings.',
    );
  }
}
