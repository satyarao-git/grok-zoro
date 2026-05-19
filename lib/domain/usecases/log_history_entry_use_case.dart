import 'package:fpdart/fpdart.dart';

import '../../core/constants/history_constants.dart';
import '../../core/utils/failure.dart';
import '../entities/history_entry.dart';
import '../repositories/history_repository.dart';

class LogHistoryEntryUseCase {
  const LogHistoryEntryUseCase(this.repository);

  final HistoryRepository repository;

  Future<Either<Failure, void>> call({
    required HistoryAction action,
    required String entityType,
    required String description,
    String? entityId,
    String? details,
    DateTime? timestamp,
  }) async {
    final entry = HistoryEntry(
      id: '',
      timestamp: timestamp ?? DateTime.now(),
      action: action,
      entityType: entityType,
      entityId: entityId,
      description: description,
      details: details,
    );
    final result = await repository.log(entry);
    final failure = result.match((failure) => failure, (_) => null);
    if (failure != null) {
      return left(failure);
    }

    return prune();
  }

  Future<Either<Failure, void>> prune() {
    return repository.pruneBefore(
      DateTime.now().subtract(const Duration(days: historyRetentionDays)),
    );
  }
}
