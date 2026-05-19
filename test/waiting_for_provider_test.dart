import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grok_zoro/core/utils/failure.dart';
import 'package:grok_zoro/domain/entities/waiting_for_item.dart';
import 'package:grok_zoro/domain/repositories/waiting_for_repository.dart';
import 'package:grok_zoro/injection_container.dart';

void main() {
  test('waiting for items can be added and resolved', () async {
    final repository = _FakeWaitingForRepository();
    final container = ProviderContainer(
      overrides: [
        waitingForRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(waitingForProvider.notifier);
    await container.read(waitingForProvider.future);

    expect(
      await notifier.addItem(
        title: ' Send invoice ',
        person: ' Maya ',
        followUpDate: DateTime(2026, 5, 9),
      ),
      isTrue,
    );

    await container.read(waitingForProvider.future);
    final item = container.read(waitingForProvider).valueOrNull!.single;
    expect(item.title, 'Send invoice');
    expect(item.person, 'Maya');

    expect(await notifier.markResolved(item.id), isTrue);
    await container.read(waitingForProvider.future);
    expect(container.read(waitingForProvider).valueOrNull, isEmpty);
  });
}

class _FakeWaitingForRepository implements WaitingForRepository {
  final _items = <WaitingForItem>[];
  int _nextId = 1;

  @override
  Future<Either<Failure, void>> clearAll() async {
    _items.clear();
    return right(null);
  }

  @override
  Future<Either<Failure, WaitingForItem>> addItem(
    WaitingForItem item,
  ) async {
    final saved = WaitingForItem(
      id: (_nextId++).toString(),
      title: item.title,
      person: item.person,
      projectId: item.projectId,
      followUpDate: item.followUpDate,
      createdAt: item.createdAt,
      notes: item.notes,
      tags: item.tags,
      isResolved: item.isResolved,
    );
    _items.add(saved);
    return right(saved);
  }

  @override
  Future<Either<Failure, void>> deleteItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    return right(null);
  }

  @override
  Future<Either<Failure, List<WaitingForItem>>> getOpenItems() async {
    return right(
      _items.where((item) => !item.isResolved).toList(growable: false),
    );
  }

  @override
  Future<Either<Failure, List<WaitingForItem>>> getAllItems() async {
    return right(_items);
  }

  @override
  Future<Either<Failure, void>> markResolved(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) {
      return left(const NotFoundFailure('Waiting For item was not found.'));
    }

    final item = _items[index];
    _items[index] = WaitingForItem(
      id: item.id,
      title: item.title,
      person: item.person,
      projectId: item.projectId,
      followUpDate: item.followUpDate,
      createdAt: item.createdAt,
      notes: item.notes,
      tags: item.tags,
      isResolved: true,
    );
    return right(null);
  }

  @override
  Future<Either<Failure, void>> updateItem(WaitingForItem item) async {
    final index = _items.indexWhere((entry) => entry.id == item.id);
    if (index == -1) {
      return left(const NotFoundFailure('Waiting For item was not found.'));
    }

    _items[index] = item;
    return right(null);
  }
}
