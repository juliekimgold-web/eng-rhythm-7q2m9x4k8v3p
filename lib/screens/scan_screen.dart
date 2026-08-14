import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_theme.dart';
import '../models/rhythm_word.dart';
import '../repositories/word_repository.dart';

enum LensStage { empty, importing, loaded, setup, ready, live }

class ScanScreen extends StatefulWidget {
  const ScanScreen({
    super.key,
    required this.repository,
    this.onImmersiveChanged,
  });

  final WordRepository repository;
  final ValueChanged<bool>? onImmersiveChanged;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;
  LensStage _stage = LensStage.empty;
  String _importSource = '';
  final Set<String> _deliveredWords = <String>{};
  bool _scanComplete = false;
  bool _pausingForRhythm = false;
  String? _pausedWordId;

  List<RhythmWord> get _recognizedWords => [
        widget.repository.findById('everyday'),
        widget.repository.findById('really'),
        widget.repository.findById('together'),
      ].whereType<RhythmWord>().toList(growable: false);

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )
      ..addListener(_handleScanProgress)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _scanComplete = true);
        }
      });
  }

  @override
  void dispose() {
    widget.onImmersiveChanged?.call(false);
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _importContent(String source) async {
    setState(() {
      _importSource = source;
      _stage = LensStage.importing;
    });
    await Future<void>.delayed(const Duration(milliseconds: 720));
    if (!mounted) return;
    setState(() => _stage = LensStage.loaded);
    widget.onImmersiveChanged?.call(true);
  }

  void _showDeviceSetup() => setState(() => _stage = LensStage.setup);

  void _markReady() => setState(() => _stage = LensStage.ready);

  void _startLiveScan() {
    setState(() {
      _stage = LensStage.live;
      _scanComplete = false;
      _pausingForRhythm = false;
      _pausedWordId = null;
      _deliveredWords.clear();
    });
    widget.onImmersiveChanged?.call(true);
    _scanController.forward(from: 0);
  }

  void _exitLiveScan() {
    _scanController.stop();
    setState(() {
      _stage = LensStage.ready;
      _scanComplete = false;
      _pausingForRhythm = false;
      _pausedWordId = null;
    });
  }

  void _reset() {
    _scanController.stop();
    widget.onImmersiveChanged?.call(false);
    setState(() {
      _stage = LensStage.empty;
      _importSource = '';
      _scanComplete = false;
      _pausingForRhythm = false;
      _pausedWordId = null;
      _deliveredWords.clear();
    });
  }

  void _handleBack() {
    if (_stage == LensStage.live) {
      _exitLiveScan();
    } else if (_stage != LensStage.empty) {
      _reset();
    }
  }

  void _handleScanProgress() {
    if (_stage != LensStage.live || _pausingForRhythm) return;
    const thresholds = <String, double>{
      'everyday': 0.28,
      'really': 0.49,
      'together': 0.70,
    };
    for (final word in _recognizedWords) {
      final threshold = thresholds[word.id];
      if (threshold == null || _scanController.value < threshold) continue;
      if (_deliveredWords.add(word.id)) {
        unawaited(_pauseAndDeliverRhythm(word));
        break;
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _pauseAndDeliverRhythm(RhythmWord word) async {
    if (_pausingForRhythm || _stage != LensStage.live) return;
    _scanController.stop(canceled: false);
    setState(() {
      _pausingForRhythm = true;
      _pausedWordId = word.id;
    });

    await Future<void>.delayed(const Duration(milliseconds: 120));
    await _deliverRhythm(word);
    await Future<void>.delayed(const Duration(milliseconds: 320));

    if (!mounted || _stage != LensStage.live) {
      _pausingForRhythm = false;
      _pausedWordId = null;
      return;
    }
    setState(() {
      _pausingForRhythm = false;
      _pausedWordId = null;
    });
    _scanController.forward();
  }

  Future<void> _deliverRhythm(RhythmWord word) async {
    for (var index = 0; index < word.syllables.length; index++) {
      if (_stage != LensStage.live) return;
      if (index == word.stressIndex) {
        await HapticFeedback.mediumImpact();
      } else {
        await HapticFeedback.lightImpact();
      }
      final duration = word.syllableDurations[index];
      await Future<void>.delayed(
        Duration(milliseconds: (duration * 180).round().clamp(90, 280)),
      );
    }
  }

  String? get _activeWordId {
    if (_stage != LensStage.live || _scanComplete) return null;
    if (_pausedWordId != null) return _pausedWordId;
    final progress = _scanController.value;
    const positions = <String, double>{
      'everyday': 0.28,
      'really': 0.49,
      'together': 0.70,
    };
    String? nearest;
    var distance = 1.0;
    for (final entry in positions.entries) {
      final current = (progress - entry.value).abs();
      if (current < distance) {
        distance = current;
        nearest = entry.key;
      }
    }
    return distance <= 0.075 ? nearest : null;
  }

  @override
  Widget build(BuildContext context) {
    final focused = _stage != LensStage.empty && _stage != LensStage.importing;
    return PopScope(
      canPop: !focused,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && focused) _handleBack();
      },
      child: SafeArea(
        bottom: !focused,
        child: ColoredBox(
          color: focused ? Colors.white : AppColors.surface,
          child: Column(
            children: [
              _LensHeader(
                stage: _stage,
                onBack: _handleBack,
                onReset: _stage == LensStage.empty ? null : _reset,
              ),
              Expanded(child: _buildStage()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStage() {
    return switch (_stage) {
      LensStage.empty => _EmptyLensState(onImport: _importContent),
      LensStage.importing => _ImportingState(source: _importSource),
      LensStage.loaded => _DocumentStage(
          key: const ValueKey('lens-content-loaded'),
          stage: _stage,
          recognizedWords: _recognizedWords,
          progress: 0,
          activeWordId: null,
          onPrimary: _showDeviceSetup,
        ),
      LensStage.setup => Stack(
          children: [
            _DocumentStage(
              stage: LensStage.loaded,
              recognizedWords: _recognizedWords,
              progress: 0,
              activeWordId: null,
              onPrimary: _showDeviceSetup,
            ),
            Positioned.fill(child: _DeviceSetupOverlay(onReady: _markReady)),
          ],
        ),
      LensStage.ready => _DocumentStage(
          key: const ValueKey('lens-scan-ready'),
          stage: _stage,
          recognizedWords: _recognizedWords,
          progress: 0,
          activeWordId: null,
          onPrimary: _startLiveScan,
        ),
      LensStage.live => _DocumentStage(
          key: const ValueKey('lens-live-scan'),
          stage: _stage,
          recognizedWords: _recognizedWords,
          progress: _scanController.value,
          activeWordId: _activeWordId,
          scanComplete: _scanComplete,
          onPrimary: _startLiveScan,
        ),
    };
  }
}

class _LensHeader extends StatelessWidget {
  const _LensHeader({
    required this.stage,
    required this.onBack,
    required this.onReset,
  });

  final LensStage stage;
  final VoidCallback onBack;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final live = stage == LensStage.live;
    return SizedBox(
      height: 68,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            IconButton(
              key: const ValueKey('lens-back'),
              onPressed: onBack,
              tooltip: live ? '스캔 종료' : '처음으로',
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                '텍스트 스캔',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (onReset != null && !live)
              IconButton(
                onPressed: onReset,
                tooltip: '새 콘텐츠',
                icon: const Icon(Icons.refresh_rounded),
              )
            else
              const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}

class _EmptyLensState extends StatelessWidget {
  const _EmptyLensState({required this.onImport});

  final ValueChanged<String> onImport;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            key: const ValueKey('lens-empty-workspace'),
            height: 520,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: AppColors.line),
            ),
            child: Stack(
              children: [
                const Align(
                  alignment: Alignment(0, -0.28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.center_focus_strong_rounded,
                        size: 31,
                        color: AppColors.orangeDark,
                      ),
                      SizedBox(height: 20),
                      Text(
                        '텍스트나 이미지를 불러와\n스캔을 시작하세요',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 16,
                          height: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '텍스트를 불러온 뒤 디바이스를 움직이며\n위에서 아래로 스캔해 주세요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.inkSoft,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 18,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _ImportAction(
                          key: const ValueKey('lens-import-camera'),
                          icon: Icons.photo_camera_outlined,
                          label: '카메라로 촬영',
                          accentColor: AppColors.orangeDark,
                          onTap: () => onImport('카메라'),
                        ),
                      ),
                      Expanded(
                        child: _ImportAction(
                          key: const ValueKey('lens-import-photo'),
                          icon: Icons.image_outlined,
                          label: '사진 불러오기',
                          accentColor: AppColors.ink,
                          onTap: () => onImport('사진'),
                        ),
                      ),
                      Expanded(
                        child: _ImportAction(
                          key: const ValueKey('lens-import-file'),
                          icon: Icons.description_outlined,
                          label: '파일 불러오기',
                          accentColor: AppColors.ink,
                          onTap: () => onImport('파일'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadii.control),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.pan_tool_alt_rounded,
                  size: 21,
                  color: AppColors.ink,
                ),
                SizedBox(width: 11),
                Expanded(
                  child: Text(
                    '디바이스를 손으로 잡고 돋보기처럼 화면 위에 올린 뒤 텍스트를 따라 이동해 주세요.\n스캔 중 발견한 단어의 리듬을 진동으로 전달합니다.',
                    style: TextStyle(
                      color: AppColors.inkSoft,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportAction extends StatelessWidget {
  const _ImportAction({
    super.key,
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.control),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
          child: Column(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: Icon(icon, size: 25, color: accentColor),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImportingState extends StatelessWidget {
  const _ImportingState({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('lens-importing'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppColors.orange,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '$source 콘텐츠를 읽고 있어요',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 7),
          const Text(
            '텍스트와 수집 단어를 비교하고 있습니다.',
            style: TextStyle(color: AppColors.inkSoft, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _DocumentStage extends StatelessWidget {
  const _DocumentStage({
    super.key,
    required this.stage,
    required this.recognizedWords,
    required this.progress,
    required this.activeWordId,
    required this.onPrimary,
    this.scanComplete = false,
  });

  final LensStage stage;
  final List<RhythmWord> recognizedWords;
  final double progress;
  final String? activeWordId;
  final VoidCallback onPrimary;
  final bool scanComplete;

  bool get _live => stage == LensStage.live;

  @override
  Widget build(BuildContext context) {
    final status = switch (stage) {
      LensStage.ready => ('스캔 준비됨', const Color(0xFF26945D)),
      LensStage.live when scanComplete => ('스캔 완료', const Color(0xFF26945D)),
      LensStage.live => ('스캔 중', AppColors.orangeDark),
      _ => ('인식된 단어 ${recognizedWords.length}', AppColors.inkSoft),
    };

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Align(
            alignment: Alignment.center,
            child: _StatusLabel(text: status.$1, color: status.$2),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 8, 16, _live ? 84 : 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReadableDocument(
                      stage: stage,
                      progress: progress,
                      recognizedWords: recognizedWords,
                    ),
                    if (!_live) ...[
                      const SizedBox(height: 22),
                      Text(
                        '발견한 단어',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: recognizedWords
                            .map((word) => _WordKeyword(word: word))
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        key: ValueKey(
                          stage == LensStage.ready
                              ? 'lens-start-live'
                              : 'lens-open-setup',
                        ),
                        onPressed: onPrimary,
                        child: Text(
                          stage == LensStage.ready ? '라이브 스캔 시작' : '스캔 준비',
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
              if (_live)
                Positioned(
                  key: const ValueKey('lens-scan-line'),
                  left: 20,
                  right: 20,
                  top: 8 + (progress * 560),
                  child: _ScanPositionLine(
                    activeWord: activeWordId,
                    complete: scanComplete,
                  ),
                ),
              if (_live)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 16,
                  child: _LiveFeedback(
                    activeWord: activeWordId,
                    complete: scanComplete,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReadableDocument extends StatelessWidget {
  const _ReadableDocument({
    required this.stage,
    required this.progress,
    required this.recognizedWords,
  });

  final LensStage stage;
  final double progress;
  final List<RhythmWord> recognizedWords;

  Color _wordColor(String id) =>
      recognizedWords.firstWhere((word) => word.id == id).color;

  double _highlightAlpha(String id, double position) {
    if (stage != LensStage.live) return 0.32;
    final delta = progress - position;
    if (delta.abs() <= 0.075) return 0.70;
    if (delta.abs() <= 0.16) return 0.42;
    if (delta > 0.16) return 0.16;
    return 0.25;
  }

  InlineSpan _hit(String text, String id, double position) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: AnimatedContainer(
        key: ValueKey('lens-highlight-$id'),
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: _wordColor(id).withValues(
            alpha: _highlightAlpha(id, position),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 18,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      color: AppColors.ink,
      fontSize: 18,
      height: 1.74,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.15,
    );
    return Container(
      key: const ValueKey('lens-document'),
      constraints: const BoxConstraints(minHeight: 560),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Finding your own rhythm',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 24,
                    letterSpacing: -0.6,
                  ),
            ),
            const SizedBox(height: 22),
            RichText(
              text: TextSpan(
                style: textStyle,
                children: [
                  const TextSpan(text: 'We speak '),
                  _hit('everyday', 'everyday', 0.28),
                  const TextSpan(
                    text:
                        ', but we do not always listen to the patterns around us. A familiar sound can ',
                  ),
                  _hit('really', 'really', 0.49),
                  const TextSpan(
                    text:
                        ' change how a word feels. When sound and movement work ',
                  ),
                  _hit('together', 'together', 0.70),
                  const TextSpan(
                    text: ', a new rhythm becomes easier to remember.\n\n',
                  ),
                  const TextSpan(
                    text:
                        'A small sound, a tiny movement, and a slight change in rhythm can open a new way to speak.\n\nListen to the world. Feel the rhythm. Speak with your own voice.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordKeyword extends StatelessWidget {
  const _WordKeyword({required this.word});

  final RhythmWord word;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: word.color.withValues(alpha: 0.23),
        borderRadius: BorderRadius.circular(AppRadii.small),
      ),
      child: Text(
        word.word.toLowerCase(),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceSetupOverlay extends StatelessWidget {
  const _DeviceSetupOverlay({required this.onReady});

  final VoidCallback onReady;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.ink.withValues(alpha: 0.5),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 343),
            child: Container(
              key: const ValueKey('lens-device-setup'),
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadii.control),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
                    child: Text(
                      '텍스트 스캔',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: double.infinity,
                    height: 190,
                    child: CustomPaint(
                      painter: _DeviceAttachPainter(),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 13, 24, 0),
                    child: Text(
                      '디바이스를 손으로 잡고 화면 위에 밀착한 뒤\n페이지 상단부터 아래로 천천히 이동해 주세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 12,
                        height: 1.75,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 26, 32, 34),
                    child: FilledButton(
                      key: const ValueKey('lens-ready-button'),
                      onPressed: onReady,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('확인했습니다'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeviceAttachPainter extends CustomPainter {
  const _DeviceAttachPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 310, size.height / 185);

    final line = Paint()
      ..color = const Color(0xFF74716E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final pale = Paint()
      ..color = const Color(0xFFFBFAF8)
      ..style = PaintingStyle.fill;

    canvas.drawLine(const Offset(0, 45), const Offset(310, 45), line);

    final phone = Path()
      ..moveTo(55, 86)
      ..quadraticBezierTo(52, 80, 59, 76)
      ..lineTo(139, 37)
      ..lineTo(287, 95)
      ..quadraticBezierTo(296, 99, 290, 108)
      ..lineTo(207, 164)
      ..quadraticBezierTo(201, 169, 192, 166)
      ..lineTo(64, 111)
      ..quadraticBezierTo(56, 107, 55, 99)
      ..close();
    canvas.drawPath(phone, pale);
    canvas.drawPath(phone, line);

    final screen = Path()
      ..moveTo(66, 85)
      ..lineTo(140, 48)
      ..lineTo(276, 99)
      ..lineTo(199, 153)
      ..lineTo(67, 102)
      ..close();
    canvas.drawPath(screen, line);

    canvas.drawLine(const Offset(55, 99), const Offset(55, 109), line);
    canvas.drawLine(const Offset(64, 111), const Offset(192, 169), line);
    canvas.drawLine(const Offset(192, 169), const Offset(207, 164), line);
    canvas.drawLine(const Offset(207, 164), const Offset(290, 108), line);
    canvas.drawLine(const Offset(290, 108), const Offset(290, 116), line);
    canvas.drawLine(const Offset(290, 116), const Offset(207, 174), line);
    canvas.drawLine(const Offset(207, 174), const Offset(192, 177), line);
    canvas.drawLine(const Offset(192, 177), const Offset(64, 119), line);
    canvas.drawLine(const Offset(64, 119), const Offset(55, 109), line);

    canvas.drawLine(const Offset(74, 105), const Offset(78, 112), line);
    canvas.drawLine(const Offset(82, 109), const Offset(86, 116), line);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(273, 113, 8, 3),
        const Radius.circular(1),
      ),
      line,
    );
    canvas.drawLine(const Offset(137, 156), const Offset(159, 166), line);

    final deviceFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final deviceBody = Path()
      ..moveTo(111, 36)
      ..lineTo(111, 89)
      ..cubicTo(114, 104, 214, 108, 220, 91)
      ..lineTo(220, 36)
      ..close();
    canvas.drawPath(deviceBody, deviceFill);
    canvas.drawPath(deviceBody, line);

    canvas.drawOval(const Rect.fromLTWH(111, 15, 109, 42), deviceFill);
    canvas.drawOval(const Rect.fromLTWH(111, 15, 109, 42), line);
    canvas.drawOval(const Rect.fromLTWH(126, 22, 79, 28), line);
    canvas.drawOval(const Rect.fromLTWH(134, 26, 63, 19), line);
    canvas.drawArc(
      const Rect.fromLTWH(111, 76, 109, 31),
      0,
      3.14159,
      false,
      line,
    );
    canvas.drawLine(const Offset(120, 49), const Offset(120, 92), line);
    canvas.drawLine(const Offset(211, 49), const Offset(211, 92), line);
    canvas.drawLine(const Offset(126, 80), const Offset(126, 93), line);
    canvas.drawLine(const Offset(132, 82), const Offset(132, 95), line);
    canvas.drawLine(const Offset(138, 84), const Offset(138, 97), line);
    canvas.drawLine(const Offset(144, 86), const Offset(144, 98), line);

    final arrowSoft = Paint()
      ..color = AppColors.orange.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;
    final arrowStrong = Paint()
      ..color = AppColors.orange.withValues(alpha: 0.68)
      ..style = PaintingStyle.fill;
    final upperArrow = Path()
      ..moveTo(221, 85)
      ..lineTo(240, 100)
      ..lineTo(247, 91)
      ..lineTo(246, 116)
      ..lineTo(226, 104)
      ..lineTo(235, 102)
      ..close();
    final lowerArrow = Path()
      ..moveTo(230, 104)
      ..lineTo(250, 119)
      ..lineTo(257, 110)
      ..lineTo(256, 136)
      ..lineTo(235, 123)
      ..lineTo(245, 121)
      ..close();
    canvas.drawPath(upperArrow, arrowSoft);
    canvas.drawPath(lowerArrow, arrowStrong);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DeviceAttachPainter oldDelegate) => false;
}

class _ScanPositionLine extends StatelessWidget {
  const _ScanPositionLine({required this.activeWord, required this.complete});

  final String? activeWord;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: complete ? const Color(0xFF26945D) : AppColors.orange,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              height: 1.5,
              color: complete ? const Color(0xFF26945D) : AppColors.orange,
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: complete ? const Color(0xFF26945D) : AppColors.orange,
                width: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveFeedback extends StatelessWidget {
  const _LiveFeedback({required this.activeWord, required this.complete});

  final String? activeWord;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final word = activeWord;
    final title = complete ? '문서 스캔을 완료했어요' : word ?? '아래로 천천히 이동해 주세요';
    final subtitle = complete
        ? '3개의 리듬을 다시 만났습니다.'
        : word == null
            ? '현재 위치의 단어를 찾고 있어요.'
            : '리듬을 전달하고 있어요.';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadii.small),
      ),
      child: Row(
        children: [
          Icon(
            complete ? Icons.check_rounded : Icons.vibration_rounded,
            size: 19,
            color: complete ? const Color(0xFF26945D) : AppColors.orangeDark,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
