import 'package:flutter/foundation.dart';

enum CaptureStage { ready, listening, pattern, matching, result }

typedef CaptureDelay = Future<void> Function(Duration duration);

class CaptureController extends ChangeNotifier {
  CaptureController({CaptureDelay? delay})
      : _delay = delay ?? Future<void>.delayed;

  final CaptureDelay _delay;
  CaptureStage _stage = CaptureStage.ready;
  var _operation = 0;

  CaptureStage get stage => _stage;

  Future<void> start() async {
    final operation = ++_operation;
    _setStage(CaptureStage.listening);
    await _delay(const Duration(milliseconds: 1800));
    if (!_isCurrent(operation, CaptureStage.listening)) return;
    await _finish(operation);
  }

  Future<void> stop() async {
    if (_stage != CaptureStage.listening) return;
    final operation = ++_operation;
    await _finish(operation);
  }

  Future<void> _finish(int operation) async {
    _setStage(CaptureStage.pattern);
    await _delay(const Duration(milliseconds: 1500));
    if (!_isCurrent(operation, CaptureStage.pattern)) return;
    _setStage(CaptureStage.matching);
    await _delay(const Duration(milliseconds: 1700));
    if (!_isCurrent(operation, CaptureStage.matching)) return;
    _setStage(CaptureStage.result);
  }

  void reset() {
    _operation++;
    _setStage(CaptureStage.ready);
  }

  bool _isCurrent(int operation, CaptureStage expectedStage) =>
      operation == _operation && _stage == expectedStage;

  void _setStage(CaptureStage value) {
    if (_stage == value) return;
    _stage = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _operation++;
    super.dispose();
  }
}
