import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/rhythm_word.dart';
import '../services/speech_service.dart';

typedef PlaybackDelay = Future<void> Function(Duration duration);
typedef RhythmHaptic = Future<void> Function(bool stressed, double intensity);

class PronunciationController extends ChangeNotifier {
  PronunciationController({
    required SpeechService speechService,
    PlaybackDelay? delay,
    RhythmHaptic? haptic,
  })  : _speechService = speechService,
        _delay = delay ?? Future<void>.delayed,
        _haptic = haptic ?? _defaultHaptic;

  final SpeechService _speechService;
  final PlaybackDelay _delay;
  final RhythmHaptic _haptic;
  var _playing = false;
  var _activeSyllable = -1;
  var _progress = 0.0;
  var _speed = 1.0;
  var _operation = 0;

  bool get playing => _playing;
  int get activeSyllable => _activeSyllable;
  double get progress => _progress;
  double get speed => _speed;

  void setSpeed(double value) {
    if (_speed == value || _playing) return;
    _speed = value;
    notifyListeners();
  }

  Future<void> play(RhythmWord word, {double intensity = 1}) async {
    if (_playing) return;
    final operation = ++_operation;
    _playing = true;
    _activeSyllable = 0;
    _progress = 0;
    notifyListeners();

    Future<void>? speech;
    try {
      await _speechService.prepare(speed: _speed);
      speech = _speechService.speak(word.word);
    } catch (_) {
      // Visual rhythm playback remains available when platform TTS is absent.
    }

    try {
      unawaited(_triggerHaptic(word.stressIndex == 0, intensity));
      final totalWeight = word.syllableDurations.fold<double>(
        0,
        (total, duration) => total + duration,
      );
      final totalMilliseconds = (totalWeight * 600 / _speed).round();
      var elapsedMilliseconds = 0;
      var lastSyllable = 0;

      while (elapsedMilliseconds < totalMilliseconds) {
        if (!_isCurrent(operation)) return;
        final frameMilliseconds =
            (totalMilliseconds - elapsedMilliseconds).clamp(1, 16);
        await _delay(Duration(milliseconds: frameMilliseconds));
        elapsedMilliseconds += frameMilliseconds;
        _progress = (elapsedMilliseconds / totalMilliseconds).clamp(0, 1);
        _activeSyllable = _syllableAtProgress(
          word.syllableDurations,
          _progress,
        );
        if (_activeSyllable != lastSyllable) {
          lastSyllable = _activeSyllable;
          unawaited(
            _triggerHaptic(_activeSyllable == word.stressIndex, intensity),
          );
        }
        notifyListeners();
      }
      await speech;
    } catch (_) {
      // A speech engine failure must not interrupt visual playback cleanup.
    } finally {
      if (_isCurrent(operation)) {
        _playing = false;
        _activeSyllable = -1;
        _progress = 0;
        notifyListeners();
      }
    }
  }

  Future<void> stop() async {
    _operation++;
    _playing = false;
    _activeSyllable = -1;
    _progress = 0;
    notifyListeners();
    await _speechService.stop();
  }

  bool _isCurrent(int operation) => operation == _operation;

  int _syllableAtProgress(List<double> durations, double progress) {
    final total = durations.fold<double>(0, (sum, value) => sum + value);
    final position = total * progress;
    var boundary = 0.0;
    for (var index = 0; index < durations.length; index++) {
      boundary += durations[index];
      if (position <= boundary || index == durations.length - 1) return index;
    }
    return durations.length - 1;
  }

  Future<void> _triggerHaptic(bool stressed, double intensity) async {
    try {
      await _haptic(stressed, intensity);
    } catch (_) {
      // Haptics can be unavailable on simulators and unsupported devices.
    }
  }

  static Future<void> _defaultHaptic(bool stressed, double intensity) {
    if (intensity < 0.35) return HapticFeedback.selectionClick();
    if (stressed && intensity >= 0.68) return HapticFeedback.heavyImpact();
    if (stressed) return HapticFeedback.mediumImpact();
    return HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _operation++;
    _speechService.stop();
    super.dispose();
  }
}
