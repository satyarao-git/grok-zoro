import 'package:fpdart/fpdart.dart';

import '../../core/utils/failure.dart';
import '../entities/inbox_item.dart';
import '../repositories/inbox_repository.dart';

class CreateInboxItemUseCase {
  const CreateInboxItemUseCase(this._repository);

  final InboxRepository _repository;

  Future<Either<Failure, InboxItem>> call({
    required String title,
    String? notes,
    CaptureSource source = CaptureSource.manual,
  }) {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return Future.value(
        left(const ValidationFailure('Capture text is required.')),
      );
    }

    return _repository.addInboxItem(
      InboxItem(
        id: '',
        title: trimmedTitle,
        notes: _clean(notes),
        capturedAt: DateTime.now(),
        source: source,
      ),
    );
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
