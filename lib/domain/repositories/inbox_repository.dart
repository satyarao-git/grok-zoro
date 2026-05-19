import 'package:fpdart/fpdart.dart';

import '../../core/utils/failure.dart';
import '../entities/inbox_item.dart';

abstract class InboxRepository {
  Future<Either<Failure, InboxItem>> addInboxItem(InboxItem item);
  Future<Either<Failure, List<InboxItem>>> getAllInboxItems();
  Future<Either<Failure, InboxItem>> getInboxItemById(String id);
  Future<Either<Failure, void>> deleteInboxItem(String id);
  Future<Either<Failure, void>> clearAll();
}
