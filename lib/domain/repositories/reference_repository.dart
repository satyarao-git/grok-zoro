import 'package:fpdart/fpdart.dart';

import '../../core/utils/failure.dart';
import '../entities/reference_item.dart';

abstract class ReferenceRepository {
  Future<Either<Failure, ReferenceItem>> addItem(ReferenceItem item);
  Future<Either<Failure, List<ReferenceItem>>> getAllItems();
  Future<Either<Failure, void>> deleteItem(String id);
  Future<Either<Failure, void>> clearAll();
}
