import 'package:fpdart/fpdart.dart';

import '../../core/utils/failure.dart';
import '../entities/waiting_for_item.dart';

abstract class WaitingForRepository {
  Future<Either<Failure, WaitingForItem>> addItem(WaitingForItem item);
  Future<Either<Failure, List<WaitingForItem>>> getOpenItems();
  Future<Either<Failure, List<WaitingForItem>>> getAllItems();
  Future<Either<Failure, void>> updateItem(WaitingForItem item);
  Future<Either<Failure, void>> markResolved(String id);
  Future<Either<Failure, void>> deleteItem(String id);
  Future<Either<Failure, void>> clearAll();
}
