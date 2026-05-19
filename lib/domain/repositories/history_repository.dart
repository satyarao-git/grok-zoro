import 'package:fpdart/fpdart.dart';

import '../../core/utils/failure.dart';
import '../entities/history_entry.dart';

abstract class HistoryRepository {
  Future<Either<Failure, List<HistoryEntry>>> getRecent({
    required DateTime since,
  });

  Future<Either<Failure, void>> log(HistoryEntry entry);
  Future<Either<Failure, void>> pruneBefore(DateTime cutoff);
  Future<Either<Failure, void>> clearAll();
}
