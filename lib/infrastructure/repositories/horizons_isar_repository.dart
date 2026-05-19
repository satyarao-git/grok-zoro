import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';

import '../../core/utils/failure.dart';
import '../../domain/entities/horizon.dart';
import '../../domain/repositories/horizons_repository.dart';
import '../isar/horizon_schema.dart';

class HorizonsIsarRepository implements HorizonsRepository {
  const HorizonsIsarRepository(this._isar);

  final Future<Isar> _isar;

  @override
  Future<Either<Failure, HorizonsOfFocus>> getHorizons() async {
    try {
      final isar = await _isar;
      final rows = await isar.horizonSchemas.where().findAll();
      if (rows.isEmpty) {
        return right(const HorizonsOfFocus(horizons: []));
      }

      final horizons = rows.map(_toEntity).toList()
        ..sort((a, b) => a.level.index.compareTo(b.level.index));
      return right(HorizonsOfFocus(horizons: horizons));
    } catch (error) {
      return left(DatabaseFailure('Could not load horizons: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> saveHorizons(HorizonsOfFocus horizons) async {
    try {
      final isar = await _isar;
      await isar.writeTxn(() async {
        await isar.horizonSchemas.clear();
        await isar.horizonSchemas.putAll(
          horizons.horizons.map(_toSchema).toList(growable: false),
        );
      });
      return right(null);
    } catch (error) {
      return left(DatabaseFailure('Could not save horizons: $error'));
    }
  }

  Horizon _toEntity(HorizonSchema row) {
    final level = HorizonLevel.values.firstWhere(
      (entry) => entry.name == row.levelName,
      orElse: () => HorizonLevel.nextActions,
    );
    return Horizon(
      level: level,
      title: row.title,
      description: row.description,
      alignmentScore: row.alignmentScore,
    );
  }

  HorizonSchema _toSchema(Horizon horizon) {
    return HorizonSchema()
      ..levelName = horizon.level.name
      ..title = horizon.title
      ..description = horizon.description
      ..alignmentScore = horizon.alignmentScore;
  }
}
