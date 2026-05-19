import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/failure.dart';
import '../../domain/entities/someday_maybe_item.dart';
import '../../domain/repositories/someday_maybe_repository.dart';
import '../isar/someday_maybe_schema.dart';

class SomedayMaybeIsarRepository implements SomedayMaybeRepository {
  const SomedayMaybeIsarRepository(this._isar);

  final Future<Isar> _isar;
  static const _uuid = Uuid();

  @override
  Future<Either<Failure, void>> clearAll() async {
    try {
      final isar = await _isar;
      await isar.writeTxn(() => isar.somedayMaybeSchemas.clear());
      return right(null);
    } catch (error) {
      return left(DatabaseFailure('Could not clear Someday/Maybe: $error'));
    }
  }

  @override
  Future<Either<Failure, SomedayMaybeItem>> addItem(
    SomedayMaybeItem item,
  ) async {
    try {
      final isar = await _isar;
      final row = SomedayMaybeSchema()
        ..uuid = item.id.isEmpty ? _uuid.v4() : item.id
        ..title = item.title
        ..reconsiderDate = item.reconsiderDate
        ..createdAt = item.createdAt
        ..notes = item.notes
        ..tags = item.tags;

      final id = await isar.writeTxn(() => isar.somedayMaybeSchemas.put(row));
      row.id = id;
      return right(_toEntity(row));
    } catch (error) {
      return left(DatabaseFailure('Could not add Someday/Maybe item: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem(String id) async {
    try {
      final isar = await _isar;
      final row = await _findByDomainId(isar, id);
      if (row == null) {
        return left(const NotFoundFailure('Someday/Maybe item was not found.'));
      }

      await isar.writeTxn(() => isar.somedayMaybeSchemas.delete(row.id));
      return right(null);
    } catch (error) {
      return left(
          DatabaseFailure('Could not delete Someday/Maybe item: $error'));
    }
  }

  @override
  Future<Either<Failure, List<SomedayMaybeItem>>> getAllItems() async {
    try {
      final isar = await _isar;
      final rows = await isar.somedayMaybeSchemas.where().findAll();
      rows.sort((a, b) => a.reconsiderDate.compareTo(b.reconsiderDate));
      return right(rows.map(_toEntity).toList(growable: false));
    } catch (error) {
      return left(DatabaseFailure('Could not load Someday/Maybe: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> snoozeItem(
    String id,
    DateTime reconsiderDate,
  ) async {
    try {
      final isar = await _isar;
      final row = await _findByDomainId(isar, id);
      if (row == null) {
        return left(const NotFoundFailure('Someday/Maybe item was not found.'));
      }

      row.reconsiderDate = reconsiderDate;
      await isar.writeTxn(() => isar.somedayMaybeSchemas.put(row));
      return right(null);
    } catch (error) {
      return left(
          DatabaseFailure('Could not snooze Someday/Maybe item: $error'));
    }
  }

  SomedayMaybeItem _toEntity(SomedayMaybeSchema row) {
    return SomedayMaybeItem(
      id: row.uuid ?? row.id.toString(),
      title: row.title,
      reconsiderDate: row.reconsiderDate,
      createdAt: row.createdAt,
      notes: row.notes,
      tags: row.tags,
    );
  }

  Future<SomedayMaybeSchema?> _findByDomainId(Isar isar, String id) async {
    final rows = await isar.somedayMaybeSchemas.where().findAll();
    return rows
        .where((row) => (row.uuid ?? row.id.toString()) == id)
        .firstOrNull;
  }
}
