import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/pronunciation_controller.dart';
import '../core/theme/app_theme.dart';
import '../models/rhythm_word.dart';
import '../repositories/word_repository.dart';
import '../services/speech_service.dart';
import '../widgets/word_rhythm_card.dart';

class WordDetailScreen extends StatefulWidget {
  const WordDetailScreen({
    super.key,
    required this.word,
    required this.repository,
    this.speechService,
    this.openPracticeOnLaunch = false,
  });

  final RhythmWord word;
  final WordRepository repository;
  final SpeechService? speechService;
  final bool openPracticeOnLaunch;

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  late final PronunciationController _pronunciation;
  late final PageController _pageController;
  late int _currentIndex;
  var _lastPage = 0.0;
  var _pageDirection = 1;
  var _verticalDragDistance = 0.0;
  var _controlsOpen = false;
  var _flipped = false;
  var _rhythmRevealed = false;
  var _intensity = 0.72;

  @override
  void initState() {
    super.initState();
    final words = widget.repository.words;
    final initialIndex = words.indexWhere((item) => item.id == widget.word.id);
    _currentIndex = initialIndex < 0 ? 0 : initialIndex;
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 0.88,
    );
    _lastPage = _currentIndex.toDouble();
    _pageController.addListener(_trackPageDirection);
    _pronunciation = PronunciationController(
      speechService: widget.speechService ?? FlutterTtsSpeechService(),
    );
    if (widget.openPracticeOnLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openSpeakPractice();
      });
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_trackPageDirection);
    _pageController.dispose();
    _pronunciation.dispose();
    super.dispose();
  }

  RhythmWord _currentWord() {
    final words = widget.repository.words;
    if (words.isEmpty) return widget.word;
    final safeIndex = _currentIndex.clamp(0, words.length - 1);
    return words[safeIndex];
  }

  void _onPageChanged(int index) {
    unawaited(_pronunciation.stop());
    setState(() {
      _currentIndex = index;
      _flipped = false;
      _rhythmRevealed = false;
    });
  }

  void _trackPageDirection() {
    if (!_pageController.hasClients ||
        !_pageController.position.haveDimensions) {
      return;
    }
    final page = _pageController.page ?? _lastPage;
    if ((page - _lastPage).abs() > 0.0001) {
      _pageDirection = page > _lastPage ? 1 : -1;
      _lastPage = page;
    }
  }

  void _onCardHorizontalDragUpdate(DragUpdateDetails details) {
    if (_controlsOpen || !_pageController.hasClients) return;
    final position = _pageController.position;
    final nextOffset = (_pageController.offset - details.delta.dx).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    _pageController.jumpTo(nextOffset);
  }

  void _onCardHorizontalDragEnd(DragEndDetails details) {
    if (_controlsOpen || !_pageController.hasClients) return;
    final page = _pageController.page ?? _currentIndex.toDouble();
    final velocity = details.primaryVelocity ?? 0;
    final int targetPage;
    if (velocity < -250) {
      targetPage = page.floor() + 1;
    } else if (velocity > 250) {
      targetPage = page.ceil() - 1;
    } else {
      targetPage = page.round();
    }
    unawaited(
      _pageController.animateToPage(
        targetPage.clamp(0, widget.repository.words.length - 1),
        duration: AppMotion.base,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _onCardVerticalDragStart(DragStartDetails details) {
    if (_controlsOpen) return;
    setState(() => _verticalDragDistance = 0);
  }

  void _onCardVerticalDragUpdate(DragUpdateDetails details) {
    if (_controlsOpen) return;
    setState(() {
      _verticalDragDistance =
          (_verticalDragDistance - details.delta.dy).clamp(0, 72);
    });
  }

  void _onCardVerticalDragEnd(DragEndDetails details) {
    final shouldOpen =
        (details.primaryVelocity ?? 0) < -250 || _verticalDragDistance >= 28;
    if (shouldOpen) {
      unawaited(_openRhythmControls());
    } else {
      setState(() => _verticalDragDistance = 0);
    }
  }

  Future<void> _openRhythmControls() async {
    if (_controlsOpen) return;
    setState(() {
      _controlsOpen = true;
      _verticalDragDistance = 72;
    });
    final screenWidth = MediaQuery.sizeOf(context).width;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x10000000),
      constraints: BoxConstraints.tightFor(width: screenWidth),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => AnimatedBuilder(
          animation: _pronunciation,
          builder: (context, _) => _RhythmControlSheet(
            playing: _pronunciation.playing,
            speed: _pronunciation.speed,
            intensity: _intensity,
            onSpeedChanged: _pronunciation.setSpeed,
            onIntensityChanged: (value) {
              setState(() => _intensity = value);
              setSheetState(() {});
            },
            onPractice: _openSpeakPractice,
            onPlay: _playCurrent,
          ),
        ),
      ),
    );
    if (!mounted) return;
    setState(() {
      _controlsOpen = false;
      _verticalDragDistance = 0;
    });
  }

  Future<void> _playCurrent() async {
    final word = _currentWord();
    setState(() {
      _flipped = false;
      _rhythmRevealed = true;
    });
    await _pronunciation.play(word, intensity: _intensity);
  }

  void _openSpeakPractice() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints.tightFor(width: screenWidth),
      builder: (_) => _SpeakPracticeSheet(word: _currentWord()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.repository, _pronunciation]),
      builder: (context, _) {
        final words = widget.repository.words;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            scrolledUnderElevation: 0,
            title: const Text('리듬 상세'),
            centerTitle: true,
          ),
          body: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardHeight =
                    (constraints.maxHeight * 0.63).clamp(470.0, 520.0);
                final sheetProgress =
                    (_verticalDragDistance / 72).clamp(0.0, 1.0);
                return CustomScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _PinnedWordCardDelegate(
                        expandedHeight: constraints.maxHeight,
                        collapsedHeight: (constraints.maxHeight * 0.54).clamp(
                          430.0,
                          480.0,
                        ),
                        cardHeight: cardHeight,
                        indicator: GestureDetector(
                          key: const ValueKey('rhythm-sheet-handle'),
                          behavior: HitTestBehavior.opaque,
                          onTap: () => unawaited(_openRhythmControls()),
                          onVerticalDragStart: _onCardVerticalDragStart,
                          onVerticalDragUpdate: _onCardVerticalDragUpdate,
                          onVerticalDragEnd: _onCardVerticalDragEnd,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${_currentIndex + 1} / ${words.length}  ·  좌우로 넘겨 다음 단어 보기',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.inkSoft,
                                    fontSize: AppTypeScale.caption,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '위로 밀어 리듬 조정',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.ink,
                                    fontSize: AppTypeScale.caption,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        card: Transform.translate(
                          offset: Offset(0, -12 * sheetProgress),
                          child: AnimatedScale(
                            key: const ValueKey('detail-card-sheet-scale'),
                            scale: 1 - 0.12 * sheetProgress,
                            duration: AppMotion.fast,
                            curve: Curves.easeOutCubic,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onHorizontalDragUpdate:
                                  _onCardHorizontalDragUpdate,
                              onHorizontalDragEnd: _onCardHorizontalDragEnd,
                              child: PageView.builder(
                                key: const ValueKey(
                                  'word-card-page-view',
                                ),
                                controller: _pageController,
                                clipBehavior: Clip.none,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: words.length,
                                onPageChanged: _onPageChanged,
                                itemBuilder: (context, index) {
                                  final word = words[index];
                                  final current = index == _currentIndex;
                                  return AnimatedBuilder(
                                    animation: _pageController,
                                    builder: (context, child) {
                                      final page = _pageController.hasClients &&
                                              _pageController
                                                  .position.haveDimensions
                                          ? _pageController.page ??
                                              _currentIndex.toDouble()
                                          : _currentIndex.toDouble();
                                      final delta = index - page;
                                      final distance =
                                          delta.abs().clamp(0.0, 1.0);
                                      final outgoing = _pageDirection > 0
                                          ? delta < 0
                                          : delta > 0;
                                      final verticalOffset =
                                          outgoing ? -24 * distance : 0.0;
                                      final rotation = outgoing
                                          ? (_pageDirection > 0
                                                  ? -0.011
                                                  : 0.011) *
                                              distance
                                          : 0.0;
                                      final scale = outgoing
                                          ? 1 - 0.006 * distance
                                          : 1 - 0.01 * distance;
                                      final opacity =
                                          outgoing ? 1.0 : 1 - 0.035 * distance;
                                      return Transform.translate(
                                        key: ValueKey(
                                          'swipe-transform-${word.id}',
                                        ),
                                        offset: Offset(0, verticalOffset),
                                        child: Transform.rotate(
                                          key: ValueKey(
                                            'swipe-rotation-${word.id}',
                                          ),
                                          angle: rotation,
                                          alignment: Alignment.bottomCenter,
                                          child: Transform.scale(
                                            scale: scale,
                                            child: Opacity(
                                              opacity: opacity,
                                              child: child,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: GestureDetector(
                                      key: current
                                          ? const ValueKey(
                                              'word-card-vertical-gesture',
                                            )
                                          : null,
                                      behavior: HitTestBehavior.translucent,
                                      onVerticalDragStart: current
                                          ? _onCardVerticalDragStart
                                          : null,
                                      onVerticalDragUpdate: current
                                          ? _onCardVerticalDragUpdate
                                          : null,
                                      onVerticalDragEnd: current
                                          ? _onCardVerticalDragEnd
                                          : null,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 8,
                                        ),
                                        child: WordRhythmCard(
                                          word: word,
                                          isCurrent: current,
                                          playing:
                                              current && _pronunciation.playing,
                                          activeSyllable: current
                                              ? _pronunciation.activeSyllable
                                              : -1,
                                          playbackProgress: current
                                              ? _pronunciation.progress
                                              : 0,
                                          rhythmRevealed:
                                              current && _rhythmRevealed,
                                          flipped: current && _flipped,
                                          onFlip: current
                                              ? () => setState(
                                                    () => _flipped = !_flipped,
                                                  )
                                              : () {},
                                          onPlay:
                                              current ? _playCurrent : () {},
                                          onFavorite: () => widget.repository
                                              .toggleFavorite(word.id),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _PinnedWordCardDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedWordCardDelegate({
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.cardHeight,
    required this.card,
    required this.indicator,
  });

  final double expandedHeight;
  final double collapsedHeight;
  final double cardHeight;
  final Widget card;
  final Widget indicator;

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = maxExtent - minExtent;
    final progress = range <= 0 ? 1.0 : (shrinkOffset / range).clamp(0.0, 1.0);
    final motion = Curves.easeOutCubic.transform(progress);
    final collapsedScale = ((collapsedHeight - 8) / cardHeight).clamp(
      0.86,
      0.91,
    );
    final scale = 1 - (1 - collapsedScale) * motion;
    final indicatorOpacity = (1 - progress * 1.8).clamp(0.0, 1.0);

    return ColoredBox(
      key: const ValueKey('pinned-word-card-header'),
      color: AppColors.surface,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Center(
            child: Transform.translate(
              offset: Offset(0, -48 * (1 - motion)),
              child: Transform.scale(
                key: const ValueKey('pinned-card-scale'),
                scale: scale,
                child: SizedBox(height: cardHeight, child: card),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 22,
            child: IgnorePointer(
              ignoring: indicatorOpacity < 0.5,
              child: Opacity(opacity: indicatorOpacity, child: indicator),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedWordCardDelegate oldDelegate) {
    return oldDelegate.expandedHeight != expandedHeight ||
        oldDelegate.collapsedHeight != collapsedHeight ||
        oldDelegate.cardHeight != cardHeight ||
        oldDelegate.card != card ||
        oldDelegate.indicator != indicator;
  }
}

class _RhythmControlSheet extends StatelessWidget {
  const _RhythmControlSheet({
    required this.playing,
    required this.speed,
    required this.intensity,
    required this.onSpeedChanged,
    required this.onIntensityChanged,
    required this.onPractice,
    required this.onPlay,
  });

  final bool playing;
  final double speed;
  final double intensity;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<double> onIntensityChanged;
  final VoidCallback onPractice;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('rhythm-control-sheet'),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.large),
        ),
        boxShadow: AppShadows.bottomSheet,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '리듬 조정',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                '발음, 음절 강조와 진동이 같은 타이밍으로 재생됩니다.',
                style: TextStyle(
                  color: AppColors.inkSoft,
                  fontSize: AppTypeScale.compactLabel,
                ),
              ),
              const SizedBox(height: 22),
              _PlaybackControls(
                playing: playing,
                speed: speed,
                intensity: intensity,
                onSpeedChanged: onSpeedChanged,
                onIntensityChanged: onIntensityChanged,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: OutlinedButton.icon(
                      onPressed: onPractice,
                      icon: const Icon(Icons.mic_none_rounded),
                      label: const Text('말해보기'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 6,
                    child: FilledButton.icon(
                      onPressed: playing ? null : onPlay,
                      icon: Icon(
                        playing
                            ? Icons.volume_up_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      label: Text(
                        playing ? '리듬 재생 중' : '발음과 진동 재생',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls({
    required this.playing,
    required this.speed,
    required this.intensity,
    required this.onSpeedChanged,
    required this.onIntensityChanged,
  });

  final bool playing;
  final double speed;
  final double intensity;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<double> onIntensityChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '재생 속도',
          style: TextStyle(
            color: AppColors.inkSoft,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final option in [0.75, 1.0, 1.25]) ...[
              Expanded(
                child: _SpeedOption(
                  value: option,
                  selected: speed == option,
                  enabled: !playing,
                  onTap: () => onSpeedChanged(option),
                ),
              ),
              if (option != 1.25) const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(
              child: Text(
                '진동 강도',
                style: TextStyle(
                  color: AppColors.inkSoft,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${(intensity * 100).round()}%',
              style: const TextStyle(
                color: AppColors.inkSoft,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Slider(
          value: intensity,
          onChanged: onIntensityChanged,
        ),
      ],
    );
  }
}

class _SpeedOption extends StatelessWidget {
  const _SpeedOption({
    required this.value,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final double value;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.cream : Colors.white,
      borderRadius: BorderRadius.circular(AppRadii.small),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadii.small),
        child: SizedBox(
          height: 42,
          child: Center(
            child: Text(
              '$value×',
              style: TextStyle(
                color: selected ? AppColors.orangeDark : AppColors.inkSoft,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeakPracticeSheet extends StatefulWidget {
  const _SpeakPracticeSheet({required this.word});

  final RhythmWord word;

  @override
  State<_SpeakPracticeSheet> createState() => _SpeakPracticeSheetState();
}

class _SpeakPracticeSheetState extends State<_SpeakPracticeSheet> {
  Timer? _timer;
  var _seconds = 0;
  var _recording = false;
  var _finished = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleRecording() {
    if (_recording) {
      _finishRecording();
      return;
    }
    setState(() {
      _seconds = 0;
      _recording = true;
      _finished = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_seconds >= 9) {
        _finishRecording();
      } else {
        setState(() => _seconds++);
      }
    });
  }

  void _finishRecording() {
    _timer?.cancel();
    setState(() {
      _recording = false;
      _finished = true;
    });
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    final sheetHeight =
        (MediaQuery.sizeOf(context).height * 0.55).clamp(420.0, 500.0);
    return Material(
      key: const ValueKey('speak-practice-sheet'),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadii.large),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: sheetHeight,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              22,
              12,
              22,
              18 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.word.word,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.word.phonetic,
                  style: const TextStyle(color: AppColors.inkSoft),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.word.syllables.join(' · '),
                  style: const TextStyle(
                    color: AppColors.orange,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 28),
                Semantics(
                  button: true,
                  label: _recording ? '녹음 종료' : '말하기 시작',
                  child: InkWell(
                    onTap: _toggleRecording,
                    customBorder: const CircleBorder(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: _recording ? AppColors.orange : AppColors.cream,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _recording ? Icons.stop_rounded : Icons.mic_rounded,
                        color:
                            _recording ? AppColors.ink : AppColors.orangeDark,
                        size: 34,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _recording
                      ? '녹음 중  $minutes:$seconds'
                      : _finished
                          ? '말하기가 끝났어요'
                          : '버튼을 누르고 편하게 말해보세요',
                  style:
                      const TextStyle(color: AppColors.inkSoft, fontSize: 12),
                ),
                if (_finished) ...[
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showFeedback('내 발음을 재생합니다.'),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('내 발음 듣기'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showFeedback('원어민 발음을 재생합니다.'),
                          icon: const Icon(Icons.volume_up_outlined),
                          label: const Text('원어민 발음'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _toggleRecording,
                      icon: const Icon(Icons.mic_none_rounded),
                      label: const Text('다시 말해보기'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
