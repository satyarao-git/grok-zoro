import 'package:fpdart/fpdart.dart';

import '../../core/utils/failure.dart';
import '../entities/horizon.dart';

abstract class HorizonsRepository {
  Future<Either<Failure, HorizonsOfFocus>> getHorizons();
  Future<Either<Failure, void>> saveHorizons(HorizonsOfFocus horizons);
}
