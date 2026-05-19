import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/failure.dart';
import '../../domain/entities/waiting_for_item.dart';
import '../../domain/repositories/waiting_for_repository.dart';
import '../isar/waiting_for_schema.dart';

class WaitingForIsarRepository implements WaitingForRepository {
  const WaitingForIsarRepository(this._isar);

  final Future<Isar> _isar;
  static const _uuid = Uuid();

  @override
  Future<Either<Failure, void>> clearAll() async {
    try {
      final isar = await _isar;
      await isar.writeTxn(() => isar.waitingForSchemas.clear());
      return right(null);
    } catch (error) {
      return left(DatabaseFailure('Could not clear Waiting For: $error'));
    }
  }

  @override
  Future<Either<Failure, WaitingForItem>> addItem(
    WaitingForItem item,
  ) async {
    try {
      final isar = await _isar;
      final row = WaitingForSchema()
        ..uuid = item.id.isEmpty ? _uuid.v4() : item.id
        ..title = item.title
        ..person = item.person
        ..projectId = item.projectId
        ..followUpDate = item.followUpDate
        ..createdAt = item.createdAt
        ..notes = item.notes
        ..tags = item.tags
        ..isResolved = item.isResolved;

      final id = await isar.writeTxn(() => isar.waitingForSchemas.put(row));
      row.id = id;
      return right(_toEntity(row));
    } catch (error) {
      return left(DatabaseFailure('Could not add Waiting For item: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem(String id) async {
    try {
      final isar = await _isar;
      final row = await _findByDomainId(isar, id);
      if (row == null) {
        return left(const NotFoundFailure('Waiting For item was not found.'));
      }

      await isar.writeTxn(() => isar.waitingForSchemas.delete(row.id));
      return right(null);
    } catch (error) {
      return left(DatabaseFailure('Could not delete Waiting For item: $error'));
    }
  }

  @override
  Future<Either<Failure, List<WaitingForItem>>> getOpenItems() async {
    try {
      final isar = await _isar;
      final rows = await isar.waitingForSchemas.where().findAll();
      final items = rows
          .where((row) => !row.isResolved)
          .map(_toEntity)
          .toList(growable: false)
        ..sort(_compareItems);
      return right(items);
    } catch (error) {
      return left(DatabaseFailure('Could not load Waiting For items: $error'));
    }
  }

  @override
  Future<Either<Failure, List<WaitingForItem>>> getAllItems() async {
    try {
      final isar = await _isar;
      final rows = await isar.waitingForSchemas.where().findAll();
      final items = rows.map(_toEntity).toList(growable: false)
        ..sort(_compareItems);
      return right(items);
    } catch (error) {
      return left(DatabaseFailure('Could not load Waiting For items: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> markResolved(String id) async {
    try {
      final isar = await _isar;
      final row = await _findByDomainId(isar, id);
      if (row == null) {
        return left(const NotFoundFailure('Waiting For item was not found.'));
      }

      row.isResolved = true;
      await isar.writeTxn(() => isar.waitingForSchemas.put(row));
      return right(null);
    } catch (error) {
      return left(
          DatabaseFailure('Could not resolve Waiting For item: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> updateItem(WaitingForItem item) async {
    try {
      final isar = await _isar;
      final row = await _findByDomainId(isar, item.id);
      if (row == null) {
        return left(const NotFoundFailure('Waiting For item was not found.'));
      }

      row
        ..title = item.title
        ..person = item.person
        ..projectId = item.projectId
        ..followUpDate = item.followUpDate
        ..notes = item.notes
        ..tags = item.tags
        ..isResolved = item.isResolved;
      await isar.writeTxn(() => isar.waitingForSchemas.put(row));
      return right(null);
    } catch (error) {
      return left(DatabaseFailure('Could not update Waiting For item: $error'));
    }
  }

  WaitingForItem _toEntity(WaitingForSchema row) {
    return WaitingForItem(
      id: row.uuid ?? row.id.toString(),
      title: row.title,
      person: row.person,
      projectId: row.projectId,
      followUpDate: row.followUpDate,
      createdAt: row.createdAt,
      notes: row.notes,
      tags: row.tags,
      isResolved: row.isResolved,
    );
  }

  Future<WaitingForSchema?> _findByDomainId(Isar isar, String id) async {
    final rows = await isar.waitingForSchemas.where().findAll();
    return rows
        .where((row) => (row.uuid ?? row.id.toString()) == id)
        .firstOrNull;
  }

  int _compareItems(WaitingForItem a, WaitingForItem b) {
    final aDate = a.followUpDate;
    final bDate = b.followUpDate;
    if (aDate != null && bDate != null) {
      return aDate.compareTo(bDate);
    }
    if (aDate != null) {
      return -1;
    }
    if (bDate != null) {
      return 1;
    }
    return b.createdAt.compareTo(a.createdAt);
  }
}
