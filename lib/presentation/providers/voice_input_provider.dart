import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../domain/entities/inbox_item.dart';
import '../../infrastructure/services/speech_to_text_service.dart';
import '../../injection_container.dart';

final speechToTextProvider = Provider<SpeechToText>((ref) {
  return zoroSpeechToText;
});

final speechCaptureSupportedProvider = Provider<bool>((ref) {
  if (kIsWeb) {
    return true;
  }
  return switch (defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.macOS =>
      true,
    _ => false,
  };
});

final voiceLocalesProvider = FutureProvider<List<LocaleName>>((ref) async {
  if (!ref.watch(speechCaptureSupportedProvider)) {
    return const [];
  }
  final speech = ref.watch(speechToTextProvider);
  if (!speech.isAvailable) {
    await speech.initialize();
  }
  final locales = await speech.locales();
  locales.sort((left, right) => left.name.compareTo(right.name));
  return locales;
});

final voiceInputProvider =
    StateNotifierProvider<VoiceInputNotifier, VoiceInputState>((ref) {
  return VoiceInputNotifier(ref);
});

class VoiceInputState {
  const VoiceInputState({
    this.isInitializing = false,
    this.isListening = false,
    this.transcript = '',
    this.confidence = 0,
    this.soundLevel = 0,
    this.status = 'Ready',
    this.error,
  });

  final bool isInitializing;
  final bool isListening;
  final String transcript;
  final double confidence;
  final double soundLevel;
  final String status;
  final String? error;

  bool get hasTranscript => transcript.trim().isNotEmpty;

  VoiceInputState copyWith({
    bool? isInitializing,
    bool? isListening,
    String? transcript,
    double? confidence,
    double? soundLevel,
    String? status,
    Object? error = _unchangedError,
  }) {
    return VoiceInputState(
      isInitializing: isInitializing ?? this.isInitializing,
      isListening: isListening ?? this.isListening,
      transcript: transcript ?? this.transcript,
      confidence: confidence ?? this.confidence,
      soundLevel: soundLevel ?? this.soundLevel,
      status: status ?? this.status,
      error: identical(error, _unchangedError) ? this.error : error as String?,
    );
  }
}

const _unchangedError = Object();

class VoiceInputNotifier extends StateNotifier<VoiceInputState> {
  VoiceInputNotifier(this._ref) : super(const VoiceInputState());

  final Ref _ref;
  String _dictationPrefix = '';

  SpeechToText get _speech => _ref.read(speechToTextProvider);

  Future<void> startListening({
    String? localeId,
    String initialText = '',
  }) async {
    if (!_ref.read(speechCaptureSupportedProvider)) {
      state = VoiceInputState(
        transcript: initialText,
        status: 'Voice dictation unavailable',
        error:
            'Built-in microphone capture is not available in the Windows tester build. Type into the box, or use Windows dictation with Win+H.',
      );
      return;
    }

    _dictationPrefix = initialText.trim();
    state = VoiceInputState(
      isInitializing: true,
      transcript: initialText,
      confidence: state.confidence,
      status: 'Preparing microphone...',
    );

    final available = await _speech.initialize(
      onStatus: _handleStatus,
      onError: _handleError,
    );
    final hasPermission = await _speech.hasPermission;
    if (!available || !hasPermission) {
      state = state.copyWith(
        isInitializing: false,
        isListening: false,
        status: 'Microphone unavailable',
        error:
            'Microphone permission is required. Check browser or device settings and try again.',
      );
      return;
    }

    final settings = _ref.read(appSettingsProvider);
    final resolvedLocaleId = localeId ?? settings.voiceLocaleId;
    await _speech.listen(
      localeId: resolvedLocaleId,
      listenFor: const Duration(minutes: 3),
      pauseFor: const Duration(seconds: 8),
      // ignore: deprecated_member_use
      listenMode: ListenMode.dictation,
      // speech_to_text 6.6.0 exposes these directly; newer releases move them
      // into SpeechListenOptions, so keep this isolated for easy upgrading.
      // ignore: deprecated_member_use
      partialResults: true,
      // ignore: deprecated_member_use
      cancelOnError: false,
      onResult: _handleResult,
      onSoundLevelChange: _handleSoundLevel,
    );

    state = state.copyWith(
      isInitializing: false,
      isListening: true,
      status: 'Listening...',
      error: null,
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    state = state.copyWith(isListening: false, status: 'Stopped');
  }

  Future<void> pauseListening() async {
    await _speech.stop();
    state = state.copyWith(isListening: false, status: 'Muted');
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
    _dictationPrefix = '';
    state = const VoiceInputState(status: 'Cancelled');
  }

  Future<void> reset() async {
    await _speech.cancel();
    _dictationPrefix = '';
    state = const VoiceInputState(status: 'Tap microphone to speak');
  }

  Future<void> restartListening(
      {String? localeId, String initialText = ''}) async {
    await _speech.cancel();
    await startListening(localeId: localeId, initialText: initialText);
  }

  void updateTranscript(String value) {
    state = state.copyWith(transcript: value);
  }

  Future<InboxItem?> saveTranscript(String value) async {
    final text = value.trim();
    if (text.isEmpty) {
      state = state.copyWith(
        error: 'No speech was captured.',
        status: 'Nothing to save',
      );
      return null;
    }

    await stopListening();
    final result = await _ref.read(createInboxItemUseCaseProvider)(
      title: text,
      source: CaptureSource.voice,
    );

    return result.match(
      (failure) {
        state = state.copyWith(error: failure.message);
        return null;
      },
      (item) {
        _ref.invalidate(inboxItemsProvider);
        return item;
      },
    );
  }

  void _handleResult(SpeechRecognitionResult result) {
    final recognized = result.recognizedWords.trim();
    final transcript = [
      if (_dictationPrefix.isNotEmpty) _dictationPrefix,
      if (recognized.isNotEmpty) recognized,
    ].join(_dictationPrefix.isEmpty || recognized.isEmpty ? '' : ' ');
    state = state.copyWith(
      transcript: transcript,
      confidence: result.confidence < 0 ? state.confidence : result.confidence,
      status: result.finalResult ? 'Speech captured' : 'Listening...',
      error: null,
    );
  }

  void _handleSoundLevel(double level) {
    state = state.copyWith(soundLevel: level);
  }

  void _handleStatus(String status) {
    state = state.copyWith(
      isListening: status == 'listening',
      status: _labelForStatus(status),
    );
  }

  void _handleError(SpeechRecognitionError error) {
    state = state.copyWith(
      isInitializing: false,
      isListening: false,
      status: 'Voice input paused',
      error: error.errorMsg,
    );
  }

  String _labelForStatus(String status) {
    return switch (status) {
      'listening' => 'Listening...',
      'notListening' => 'Paused',
      'done' => 'Speech captured',
      _ => status,
    };
  }
}
