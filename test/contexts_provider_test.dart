import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grok_zoro/core/utils/failure.dart';
import 'package:grok_zoro/domain/entities/context.dart';
import 'package:grok_zoro/domain/repositories/context_repository.dart';
import 'package:grok_zoro/injection_container.dart';

void main() {
  test('contexts can be added, updated, and deleted', () async {
    final repository = _FakeContextRepository();
    final container = ProviderContainer(
      overrides: [
        contextRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(contextsStateProvider.notifier);
    await container.read(contextsStateProvider.future);

    expect(await notifier.addContext(name: 'Office'), isTrue);
    expect(
      container.read(contextsProvider).map((context) => context.name),
      contains('@Office'),
    );

    expect(await notifier.addContext(name: '@Office'), isFalse);

    final office = container
        .read(contextsProvider)
        .firstWhere((context) => context.name == '@Office');
    expect(
      await notifier.updateContext(
        ZoroContext(
          id: office.id,
          name: 'Deep Work',
          description: 'Focus-only actions',
        ),
      ),
      isTrue,
    );
    expect(
      container.read(contextsProvider).map((context) => context.name),
      contains('@Deep Work'),
    );

    final updated = container
        .read(contextsProvider)
        .firstWhere((context) => context.name == '@Deep Work');
    expect(await notifier.deleteContext(updated.id), isTrue);
    expect(
      container.read(contextsProvider).map((context) => context.name),
      isNot(contains('@Deep Work')),
    );
  });

  test('default contexts cannot be deleted or renamed', () async {
    final container = ProviderContainer(
      overrides: [
        contextRepositoryProvider.overrideWithValue(_FakeContextRepository()),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(contextsStateProvider.notifier);
    await container.read(contextsStateProvider.future);
    final anywhere = container.read(contextsProvider).first;

    expect(await notifier.deleteContext(anywhere.id), isFalse);
    expect(
      await notifier.updateContext(
        ZoroContext(id: anywhere.id, name: 'Anywhere Else'),
      ),
      isFalse,
    );
    expect(container.read(contextsProvider).first.name, '@Anywhere');
  });
}

class _FakeContextRepository implements ContextRepository {
  _FakeContextRepository()
      : _contexts = [...ContextsNotifier.defaultContexts],
        _nextId = 100;

  final List<ZoroContext> _contexts;
  int _nextId;

  @override
  Future<Either<Failure, void>> deleteContext(String id) async {
    _contexts.removeWhere((context) => context.id == id);
    return right(null);
  }

  @override
  Future<Either<Failure, List<ZoroContext>>> getAllContexts() async {
    return right([..._contexts]);
  }

  @override
  Future<Either<Failure, ZoroContext>> saveContext(ZoroContext context) async {
    final saved = ZoroContext(
      id: context.id.isEmpty ? (_nextId++).toString() : context.id,
      name: context.name,
      description: context.description,
      isDefault: context.isDefault,
    );
    final index = _contexts.indexWhere((entry) => entry.id == saved.id);
    if (index == -1) {
      _contexts.add(saved);
    } else {
      _contexts[index] = saved;
    }
    return right(saved);
  }
}
