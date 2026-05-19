import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/failure.dart';
import '../../domain/entities/reference_item.dart';
import '../../domain/repositories/reference_repository.dart';
import '../isar/reference_schema.dart';

class ReferenceIsarRepository implements ReferenceRepository {
  const ReferenceIsarRepository(this._isar);

  final Future<Isar> _isar;
  static const _uuid = Uuid();

  @override
  Future<Either<Failure, ReferenceItem>> addItem(ReferenceItem item) async {
    try {
      final isar = await _isar;
      final row = ReferenceSchema()
        ..uuid = item.id.isEmpty ? _uuid.v4() : item.id
        ..title = item.title
        ..notes = item.notes
        ..tags = item.tags
        ..folder = item.folder
        ..createdAt = item.createdAt;

      final id = await isar.writeTxn(() => isar.referenceSchemas.put(row));
      row.id = id;
      return right(_toEntity(row));
    } catch (error) {
      return left(DatabaseFailure('Could not add Reference item: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAll() async {
    try {
      final isar = await _isar;
      await isar.writeTxn(() => isar.referenceSchemas.clear());
      return right(null);
    } catch (error) {
      return left(DatabaseFailure('Could not clear Reference: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem(String id) async {
    try {
      final isar = await _isar;
      final row = await _findByDomainId(isar, id);
      if (row == null) {
        return left(const NotFoundFailure('Reference item was not found.'));
      }

      await isar.writeTxn(() => isar.referenceSchemas.delete(row.id));
      return right(null);
    } catch (error) {
      return left(DatabaseFailure('Could not delete Reference item: $error'));
    }
  }

  @override
  Future<Either<Failure, List<ReferenceItem>>> getAllItems() async {
    try {
      final isar = await _isar;
      final rows = await isar.referenceSchemas.where().findAll();
      rows.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return right(rows.map(_toEntity).toList(growable: false));
    } catch (error) {
      return left(DatabaseFailure('Could not load Reference: $error'));
    }
  }

  ReferenceItem _toEntity(ReferenceSchema row) {
    return ReferenceItem(
      id: row.uuid ?? row.id.toString(),
      title: row.title,
      notes: row.notes,
      tags: row.tags,
      folder: row.folder,
      createdAt: row.createdAt,
    );
  }

  Future<ReferenceSchema?> _findByDomainId(Isar isar, String id) async {
    final rows = await isar.referenceSchemas.where().findAll();
    return rows
        .where((row) => (row.uuid ?? row.id.toString()) == id)
        .firstOrNull;
  }
}
