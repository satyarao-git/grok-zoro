import 'package:fpdart/fpdart.dart';

import '../../core/utils/failure.dart';
import '../entities/someday_maybe_item.dart';

abstract class SomedayMaybeRepository {
  Future<Either<Failure, SomedayMaybeItem>> addItem(SomedayMaybeItem item);
  Future<Either<Failure, List<SomedayMaybeItem>>> getAllItems();
  Future<Either<Failure, void>> snoozeItem(String id, DateTime reconsiderDate);
  Future<Either<Failure, void>> deleteItem(String id);
  Future<Either<Failure, void>> clearAll();
}
