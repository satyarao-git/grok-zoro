import 'package:speech_to_text/speech_to_text.dart';

final zoroSpeechToText = SpeechToText();

Future<void> initializeSpeechToText() async {
  try {
    await zoroSpeechToText.initialize();
  } catch (_) {
    // The voice overlay surfaces permission/device errors when the user taps
    // the microphone. Startup should not block the rest of the GTD system.
  }
}
