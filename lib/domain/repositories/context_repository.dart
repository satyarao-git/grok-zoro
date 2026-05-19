import 'package:fpdart/fpdart.dart';

import '../../core/utils/failure.dart';
import '../entities/context.dart';

abstract class ContextRepository {
  Future<Either<Failure, List<ZoroContext>>> getAllContexts();
  Future<Either<Failure, ZoroContext>> saveContext(ZoroContext context);
  Future<Either<Failure, void>> deleteContext(String id);
}
