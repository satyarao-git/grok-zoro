const _unsetVoiceLocale = Object();
const _unsetAiApiKey = Object();

class AppSettings {
  const AppSettings({
    this.voiceCaptureEnabled = true,
    this.defaultContextName = '@Anywhere',
    this.weeklyReviewWeekday = DateTime.sunday,
    this.aiEnabled = false,
    this.aiBaseUrl = 'http://127.0.0.1:8787',
    this.aiModel = 'gpt-5.2',
    this.aiApiKey,
    this.voiceLocaleId,
  });

  final bool voiceCaptureEnabled;
  final String defaultContextName;
  final int weeklyReviewWeekday;
  final bool aiEnabled;
  final String aiBaseUrl;
  final String aiModel;
  final String? aiApiKey;
  final String? voiceLocaleId;

  AppSettings copyWith({
    bool? voiceCaptureEnabled,
    String? defaultContextName,
    int? weeklyReviewWeekday,
    bool? aiEnabled,
    String? aiBaseUrl,
    String? aiModel,
    Object? aiApiKey = _unsetAiApiKey,
    Object? voiceLocaleId = _unsetVoiceLocale,
  }) {
    return AppSettings(
      voiceCaptureEnabled: voiceCaptureEnabled ?? this.voiceCaptureEnabled,
      defaultContextName: defaultContextName ?? this.defaultContextName,
      weeklyReviewWeekday: weeklyReviewWeekday ?? this.weeklyReviewWeekday,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      aiBaseUrl: aiBaseUrl ?? this.aiBaseUrl,
      aiModel: aiModel ?? this.aiModel,
      aiApiKey: identical(aiApiKey, _unsetAiApiKey)
          ? this.aiApiKey
          : aiApiKey as String?,
      voiceLocaleId: identical(voiceLocaleId, _unsetVoiceLocale)
          ? this.voiceLocaleId
          : voiceLocaleId as String?,
    );
  }
}
