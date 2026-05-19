import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';

import '../../core/utils/failure.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../isar/app_settings_schema.dart';

class SettingsIsarRepository implements SettingsRepository {
  const SettingsIsarRepository(this._isar);

  static const _singletonId = 1;

  final Future<Isar> _isar;

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      final isar = await _isar;
      final row = await isar.appSettingsSchemas.get(_singletonId);
      if (row == null) {
        return right(const AppSettings());
      }
      return right(_toEntity(row));
    } catch (error) {
      return left(DatabaseFailure('Could not load settings: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(AppSettings settings) async {
    try {
      final isar = await _isar;
      final row = AppSettingsSchema()
        ..id = _singletonId
        ..voiceCaptureEnabled = settings.voiceCaptureEnabled
        ..defaultContextName = settings.defaultContextName
        ..weeklyReviewWeekday = settings.weeklyReviewWeekday
        ..aiEnabled = settings.aiEnabled
        ..aiBaseUrl = settings.aiBaseUrl
        ..aiModel = settings.aiModel
        ..aiApiKey = settings.aiApiKey
        ..voiceLocaleId = settings.voiceLocaleId;

      await isar.writeTxn(() => isar.appSettingsSchemas.put(row));
      return right(null);
    } catch (error) {
      return left(DatabaseFailure('Could not save settings: $error'));
    }
  }

  AppSettings _toEntity(AppSettingsSchema row) {
    return AppSettings(
      voiceCaptureEnabled: row.voiceCaptureEnabled,
      defaultContextName: row.defaultContextName,
      weeklyReviewWeekday: row.weeklyReviewWeekday,
      aiEnabled: row.aiEnabled,
      aiBaseUrl: row.aiBaseUrl,
      aiModel: row.aiModel,
      aiApiKey: row.aiApiKey,
      voiceLocaleId: row.voiceLocaleId,
    );
  }
}
