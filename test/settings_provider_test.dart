import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grok_zoro/core/utils/failure.dart';
import 'package:grok_zoro/domain/entities/app_settings.dart';
import 'package:grok_zoro/domain/repositories/settings_repository.dart';
import 'package:grok_zoro/injection_container.dart';

void main() {
  test('settings update voice capture, default context, review day, and AI',
      () async {
    final repository = _FakeSettingsRepository();
    final container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appSettingsControllerProvider.future);
    final notifier = container.read(appSettingsControllerProvider.notifier);

    expect(await notifier.setVoiceCaptureEnabled(enabled: false), isTrue);
    expect(await notifier.setDefaultContextName('@Computer'), isTrue);
    expect(await notifier.setWeeklyReviewDay(DateTime.friday), isTrue);
    expect(await notifier.setAiEnabled(enabled: true), isTrue);
    expect(await notifier.setAiBaseUrl('http://127.0.0.1:8788'), isTrue);
    expect(await notifier.setAiModel('gpt-5.2-mini'), isTrue);

    final settings = container.read(appSettingsProvider);
    expect(settings.voiceCaptureEnabled, isFalse);
    expect(settings.defaultContextName, '@Computer');
    expect(settings.weeklyReviewWeekday, DateTime.friday);
    expect(settings.aiEnabled, isTrue);
    expect(settings.aiBaseUrl, 'http://127.0.0.1:8788');
    expect(settings.aiModel, 'gpt-5.2-mini');
    expect(repository.savedSettings.weeklyReviewWeekday, DateTime.friday);
    expect(repository.savedSettings.aiEnabled, isTrue);
    expect(container.read(selectedContextProvider), '@Computer');
  });
}

class _FakeSettingsRepository implements SettingsRepository {
  AppSettings savedSettings = const AppSettings();

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    return right(savedSettings);
  }

  @override
  Future<Either<Failure, void>> saveSettings(AppSettings settings) async {
    savedSettings = settings;
    return right(null);
  }
}
