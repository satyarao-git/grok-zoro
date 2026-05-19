import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/failure.dart';
import '../../domain/entities/inbox_item.dart';
import '../../domain/repositories/inbox_repository.dart';
import '../isar/inbox_item_schema.dart';

class InboxIsarRepository implements InboxRepository {
  const InboxIsarRepository(this._isar);

  final Future<Isar> _isar;
  static const _uuid = Uuid();

  @override
  Future<Either<Failure, void>> clearAll() async {
    try {
      final isar = await _isar;
      await isar.writeTxn(() => isar.inboxItemSchemas.clear());
      return right(null);
    } catch (error) {
      return left(DatabaseFailure('Could not clear inbox: $error'));
    }
  }

  @override
  Future<Either<Failure, InboxItem>> addInboxItem(InboxItem item) async {
    try {
      final isar = await _isar;
      final row = InboxItemSchema()
        ..uuid = item.id.isEmpty ? _uuid.v4() : item.id
        ..title = item.title
        ..notes = item.notes
        ..capturedAt = item.capturedAt
        ..source = item.source.name;

      final id = await isar.writeTxn(() => isar.inboxItemSchemas.put(row));
      row.id = id;
      return right(_toEntity(row));
    } catch (error) {
      return left(DatabaseFailure('Could not add inbox item: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteInboxItem(String id) async {
    try {
      final isar = await _isar;
      final row = await _findByDomainId(isar, id);
      if (row == null) {
        return left(const NotFoundFailure('Inbox item was not found.'));
      }

      await isar.writeTxn(() => isar.inboxItemSchemas.delete(row.id));
      return right(null);
    } catch (error) {
      return left(DatabaseFailure('Could not delete inbox item: $error'));
    }
  }

  @override
  Future<Either<Failure, List<InboxItem>>> getAllInboxItems() async {
    try {
      final isar = await _isar;
      final rows = await isar.inboxItemSchemas.where().findAll();
      rows.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
      return right(rows.map(_toEntity).toList(growable: false));
    } catch (error) {
      return left(DatabaseFailure('Could not load inbox: $error'));
    }
  }

  @override
  Future<Either<Failure, InboxItem>> getInboxItemById(String id) async {
    try {
      final isar = await _isar;
      final row = await _findByDomainId(isar, id);
      if (row == null) {
        return left(const NotFoundFailure('Inbox item was not found.'));
      }

      return right(_toEntity(row));
    } catch (error) {
      return left(DatabaseFailure('Could not load inbox item: $error'));
    }
  }

  InboxItem _toEntity(InboxItemSchema row) {
    return InboxItem(
      id: row.uuid ?? row.id.toString(),
      title: row.title,
      notes: row.notes,
      capturedAt: row.capturedAt,
      source: CaptureSource.values.firstWhere(
        (source) => source.name == row.source,
        orElse: () => CaptureSource.manual,
      ),
    );
  }

  Future<InboxItemSchema?> _findByDomainId(Isar isar, String id) async {
    final rows = await isar.inboxItemSchemas.where().findAll();
    return rows
        .where((row) => (row.uuid ?? row.id.toString()) == id)
        .firstOrNull;
  }
}
