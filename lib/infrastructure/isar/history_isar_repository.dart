import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';

import '../../core/utils/failure.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/repositories/history_repository.dart';
import 'history_schema.dart';

class HistoryIsarRepository implements HistoryRepository {
  const HistoryIsarRepository(this._isar);

  final Future<Isar> _isar;

  @override
  Future<Either<Failure, void>> clearAll() async {
    try {
      final isar = await _isar;
      await isar.writeTxn(() => isar.historySchemas.clear());
      return right(null);
    } catch (error) {
      return left(DatabaseFailure('Could not clear history: $error'));
    }
  }

  @override
  Future<Either<Failure, List<HistoryEntry>>> getRecent({
    required DateTime since,
  }) async {
    try {
      final isar = await _isar;
      final rows = await isar.historySchemas.where().findAll();
      final entries = rows
          .where((row) => !row.timestamp.isBefore(since))
          .map(_toEntity)
          .toList()
        ..sort((left, right) => right.timestamp.compareTo(left.timestamp));
      return right(entries);
    } catch (error) {
      return left(DatabaseFailure('Could not read history: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> log(HistoryEntry entry) async {
    try {
      final isar = await _isar;
      final row = HistorySchema()
        ..timestamp = entry.timestamp
        ..action = entry.action.name
        ..entityType = entry.entityType
        ..entityId = entry.entityId
        ..description = entry.description
        ..details = entry.details;
      await isar.writeTxn(() => isar.historySchemas.put(row));
      return right(null);
    } catch (error) {
      return left(DatabaseFailure('Could not write history: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> pruneBefore(DateTime cutoff) async {
    try {
      final isar = await _isar;
      final rows = await isar.historySchemas.where().findAll();
      final ids = rows
          .where((row) => row.timestamp.isBefore(cutoff))
          .map((row) => row.id)
          .toList();
      await isar.writeTxn(() => isar.historySchemas.deleteAll(ids));
      return right(null);
    } catch (error) {
      return left(DatabaseFailure('Could not prune history: $error'));
    }
  }

  HistoryEntry _toEntity(HistorySchema row) {
    return HistoryEntry(
      id: row.id.toString(),
      timestamp: row.timestamp,
      action: HistoryAction.values.firstWhere(
        (action) => action.name == row.action,
        orElse: () => HistoryAction.inboxProcessed,
      ),
      entityType: row.entityType,
      entityId: row.entityId,
      description: row.description,
      details: row.details,
    );
  }
}
