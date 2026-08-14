import 'package:flutter_tts/flutter_tts.dart';

abstract interface class SpeechService {
  Future<void> prepare({required double speed});
  Future<void> speak(String text);
  Future<void> stop();
}

class FlutterTtsSpeechService implements SpeechService {
  FlutterTtsSpeechService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;

  @override
  Future<void> prepare({required double speed}) async {
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate((0.42 * speed).clamp(0.28, 0.62));
    await _tts.awaitSpeakCompletion(true);
  }

  @override
  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }
}
