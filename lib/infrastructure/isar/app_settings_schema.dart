import 'package:isar/isar.dart';

part 'app_settings_schema.g.dart';

@collection
class AppSettingsSchema {
  Id id = 1;

  bool voiceCaptureEnabled = true;
  String defaultContextName = '@Anywhere';
  int weeklyReviewWeekday = DateTime.sunday;
  bool aiEnabled = false;
  String aiBaseUrl = 'https://zoro-windows.web.app';
  String aiModel = 'gpt-5.2';
  String? aiApiKey;
  String? voiceLocaleId;
}
