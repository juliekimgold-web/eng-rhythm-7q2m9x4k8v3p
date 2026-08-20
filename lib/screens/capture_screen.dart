import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/capture_controller.dart';
import '../core/theme/app_theme.dart';
import '../repositories/word_repository.dart';
import '../widgets/icon_tile.dart';
import '../widgets/sound_length_pattern.dart';
import 'word_detail_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key, required this.repository});

  final WordRepository repository;

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  late final CaptureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CaptureController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: '뒤로가기',
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const Spacer(),
                  const _DevicePill(),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 420),
                    child: switch (_controller.stage) {
                      CaptureStage.ready => _ReadyState(
                          key: const ValueKey('ready'),
                          onStart: _controller.start,
                        ),
                      CaptureStage.listening => _ListeningState(
                          key: const ValueKey('listening'),
                          onStop: _controller.stop,
                        ),
                      CaptureStage.pattern =>
                        const _PatternState(key: ValueKey('pattern')),
                      CaptureStage.matching =>
                        const _MatchingState(key: ValueKey('matching')),
                      CaptureStage.result => _ResultState(
                          key: const ValueKey('result'),
                          onReset: _controller.reset,
                          repository: widget.repository,
                        ),
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DevicePill extends StatelessWidget {
  const _DevicePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.small),
      ),
      child: const Row(
        children: [
          Icon(Icons.circle, color: Color(0xFF5BCB63), size: 8),
          SizedBox(width: 6),
          Text('디바이스 연결됨',
              style: TextStyle(
                fontSize: AppTypeScale.caption,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}

class _ReadyState extends StatelessWidget {
  const _ReadyState({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 236,
                  height: 188,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                  child: Center(
                    child: Container(
                      width: 148,
                      height: 92,
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(46),
                        border: Border.all(color: AppColors.peach, width: 2),
                      ),
                      child: const Icon(
                        Icons.graphic_eq_rounded,
                        color: AppColors.orange,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  '어떤 리듬을 발견할까요?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                const Text(
                  '주변의 반복되는 소리 가까이에\n디바이스를 놓아주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.inkSoft, height: 1.5),
                ),
                const Spacer(),
                FilledButton.icon(
                  key: const ValueKey('capture-start-button'),
                  onPressed: onStart,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: AppColors.ink,
                  ),
                  icon: const Icon(Icons.graphic_eq_rounded),
                  label: const Text('소리 감지 시작'),
                ),
                const SizedBox(height: 13),
                const Text(
                  '최대 10초 동안 소리를 분석해요',
                  style: TextStyle(color: AppColors.inkSoft, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ListeningState extends StatelessWidget {
  const _ListeningState({super.key, required this.onStop});

  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Container(
          width: 270,
          height: 188,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.orange),
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: const Center(
            child: _RecordingPattern(),
          ),
        ),
        const SizedBox(height: 36),
        Text('소리의 길이를 기록하고 있어요',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 14),
        const Text('짧은 소리와 긴 소리의 반복을 찾는 중...',
            style: TextStyle(color: AppColors.inkSoft)),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: onStop,
          icon: const Icon(Icons.stop_rounded),
          label: const Text('여기까지 분석하기'),
        ),
      ],
    );
  }
}

class _RecordingPattern extends StatefulWidget {
  const _RecordingPattern();

  @override
  State<_RecordingPattern> createState() => _RecordingPatternState();
}

class _RecordingPatternState extends State<_RecordingPattern> {
  static const _lengths = [0.55, 1.15, 0.48, 1.08, 0.52];
  Timer? _timer;
  var _active = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 260), (_) {
      if (mounted) {
        setState(() => _active = (_active + 1) % _lengths.length);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SoundLengthPattern(
      lengths: _lengths,
      activeIndex: _active,
      color: AppColors.orange,
      height: 15,
      gap: 7,
    );
  }
}

class _PatternState extends StatelessWidget {
  const _PatternState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 286,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: const Column(
            children: [
              Text('수집된 소리 길이',
                  style: TextStyle(
                      color: AppColors.inkSoft,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
              SizedBox(height: 20),
              SoundLengthPattern(
                lengths: [0.55, 1.15, 0.48, 1.08, 0.52],
                height: 15,
                gap: 7,
              ),
              SizedBox(height: 17),
              Text('짧게  ·  길게  ·  짧게  ·  길게  ·  짧게',
                  style: TextStyle(
                    color: AppColors.inkSoft,
                    fontSize: AppTypeScale.caption,
                  )),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('반복되는 길이 패턴을 찾았어요',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        const Text(
          '파형의 모양이 아니라\n소리가 이어지는 시간을 기준으로 분석해요.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.inkSoft, height: 1.55),
        ),
      ],
    );
  }
}

class _MatchingState extends StatelessWidget {
  const _MatchingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('가까운 영어 음절을 찾는 중',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        const Text(
          '수집한 길이와 영어 발화의 음절 길이를 비교해요.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.inkSoft),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: const Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 68,
                    child: Text('소리 패턴',
                        style: TextStyle(
                          color: AppColors.inkSoft,
                          fontSize: AppTypeScale.caption,
                        )),
                  ),
                  Expanded(
                    child: SoundLengthPattern(
                      lengths: [1.15, 0.55],
                      height: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 22),
              Icon(Icons.arrow_downward_rounded,
                  color: AppColors.orange, size: 22),
              SizedBox(height: 22),
              Row(
                children: [
                  SizedBox(
                    width: 68,
                    child: Text('영어 음절',
                        style: TextStyle(
                          color: AppColors.inkSoft,
                          fontSize: AppTypeScale.caption,
                        )),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 145,
                          child: _MatchedSyllable(label: 'LAUN', active: true),
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          flex: 72,
                          child: _MatchedSyllable(label: 'dry'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text('LAUNDRY와 92% 가까워요',
            style: TextStyle(
                color: AppColors.orangeDark, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _MatchedSyllable extends StatelessWidget {
  const _MatchedSyllable({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? AppColors.orange : AppColors.cream,
        borderRadius: BorderRadius.circular(AppRadii.small),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : AppColors.orangeDark,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ResultState extends StatelessWidget {
  const _ResultState({
    super.key,
    required this.onReset,
    required this.repository,
  });

  final VoidCallback onReset;
  final WordRepository repository;

  @override
  Widget build(BuildContext context) {
    final result = repository.recentWords.first;
    return ListView(
      padding: const EdgeInsets.only(top: 10),
      children: [
        const Text(
          'NEW RHYTHM FOUND',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.orangeDark,
            fontSize: AppTypeScale.caption,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Text('새 리듬을 찾았어요!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 26),
        Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: Column(
            children: [
              const Text('세탁기 회전음에서 발견한 길이 패턴'),
              const SizedBox(height: 24),
              SoundLengthPattern(
                key: const ValueKey('capture-result-sound-pattern'),
                lengths: result.soundPattern,
                color: result.color,
                height: 14,
                gap: 7,
              ),
              const SizedBox(height: 18),
              const Icon(Icons.keyboard_double_arrow_down_rounded,
                  color: AppColors.orange),
              const SizedBox(height: 18),
              Text(result.word,
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 6),
              Text('${result.phonetic}  ·  ${result.meaning}'),
              const SizedBox(height: 22),
              SoundLengthPattern(
                key: const ValueKey('capture-result-syllable-pattern'),
                lengths: result.syllableDurations,
                color: result.color,
                height: 10,
                gap: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(19),
            child: Row(
              children: [
                const IconTile(icon: Icons.vibration_rounded),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('디바이스로 리듬 느끼기',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      SizedBox(height: 4),
                      Text('강세와 길이가 진동으로 재생돼요',
                          style: TextStyle(
                              color: AppColors.inkSoft, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton.filled(
                  key: const ValueKey('capture-device-rhythm'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const _RhythmAttachmentGuideScreen(),
                    ),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: result.color.withValues(alpha: 0.42),
                    foregroundColor: AppColors.ink,
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton(
          key: const ValueKey('capture-save-button'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => WordDetailScreen(
                word: result,
                repository: repository,
              ),
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.orange,
            foregroundColor: AppColors.ink,
          ),
          child: const Text('라이브러리에 저장하고 자세히 보기'),
        ),
        const SizedBox(height: 10),
        TextButton(onPressed: onReset, child: const Text('다른 소리 수집하기')),
      ],
    );
  }
}

class _RhythmAttachmentGuideScreen extends StatelessWidget {
  const _RhythmAttachmentGuideScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('rhythm-attachment-guide'),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 64,
              child: Row(
                children: [
                  IconButton(
                    key: const ValueKey('rhythm-guide-back'),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: '뒤로가기',
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Text(
                      '리듬 변환',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    tooltip: '알림',
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                  IconButton(
                    onPressed: () {},
                    tooltip: '설정',
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Image.asset(
                      'assets/images/rhythm_attach_guide.png',
                      key: const ValueKey('rhythm-attachment-image'),
                      width: double.infinity,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      semanticLabel: '핸드폰 뒷면에 ENG 디바이스를 부착하는 방법',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '핸드폰 뒷면에 디바이스를 부착해주세요',
                    key: ValueKey('rhythm-attachment-instruction'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: AppTypeScale.caption,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
