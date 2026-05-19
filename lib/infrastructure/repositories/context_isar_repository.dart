import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';

import '../../core/utils/failure.dart';
import '../../domain/entities/context.dart';
import '../../domain/repositories/context_repository.dart';
import '../isar/context_schema.dart';

class ContextIsarRepository implements ContextRepository {
  const ContextIsarRepository(this._isar);

  final Future<Isar> _isar;

  @override
  Future<Either<Failure, void>> deleteContext(String id) async {
    final isar = await _isar;
    final numericId = int.tryParse(id);
    if (numericId == null) {
      return right(null);
    }

    await isar.writeTxn(() => isar.contextSchemas.delete(numericId));
    return right(null);
  }

  @override
  Future<Either<Failure, List<ZoroContext>>> getAllContexts() async {
    final isar = await _isar;
    final schemas = await isar.contextSchemas.where().findAll();
    final contexts = schemas.map(_fromSchema).toList()
      ..sort((a, b) {
        if (a.isDefault != b.isDefault) {
          return a.isDefault ? -1 : 1;
        }
        return a.name.compareTo(b.name);
      });
    return right(contexts);
  }

  @override
  Future<Either<Failure, ZoroContext>> saveContext(ZoroContext context) async {
    final isar = await _isar;
    final schema = ContextSchema()
      ..name = context.name
      ..description = context.description
      ..isDefault = context.isDefault;

    final numericId = int.tryParse(context.id);
    if (numericId != null) {
      schema.id = numericId;
    }

    final id = await isar.writeTxn(() => isar.contextSchemas.put(schema));
    return right(
      ZoroContext(
        id: id.toString(),
        name: schema.name,
        description: schema.description,
        isDefault: schema.isDefault,
      ),
    );
  }

  ZoroContext _fromSchema(ContextSchema schema) {
    return ZoroContext(
      id: schema.id.toString(),
      name: schema.name,
      description: schema.description,
      isDefault: schema.isDefault,
    );
  }
}
