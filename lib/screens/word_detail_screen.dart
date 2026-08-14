import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../core/theme/app_theme.dart';
import '../models/rhythm_word.dart';
import '../widgets/icon_tile.dart';
import '../widgets/sound_length_pattern.dart';

class WordDetailScreen extends StatefulWidget {
  const WordDetailScreen({super.key, required this.word});

  final RhythmWord word;

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  final _tts = FlutterTts();
  var _playing = false;
  var _ttsInitialized = false;
  var _activeSyllable = -1;
  var _flipped = false;
  var _playbackSpeed = 1.0;
  var _intensity = 0.72;

  Future<void> _playRhythm() async {
    if (_playing) return;
    setState(() {
      _playing = true;
      _activeSyllable = 0;
    });

    try {
      _ttsInitialized = true;
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _tts.setSpeechRate((0.42 * _playbackSpeed).clamp(0.28, 0.62));
      await _tts.awaitSpeakCompletion(true);

      final speech = _tts.speak(widget.word.word);
      await _runSyllableHighlights();
      await speech;
    } catch (_) {
      if (mounted && _activeSyllable == 0) {
        await _runSyllableHighlights();
      }
    } finally {
      if (mounted) {
        setState(() {
          _playing = false;
          _activeSyllable = -1;
        });
      }
    }
  }

  Future<void> _runSyllableHighlights() async {
    final durations = widget.word.syllableDurations;
    for (var index = 0; index < durations.length; index++) {
      if (!mounted || !_playing) return;
      setState(() => _activeSyllable = index);
      final milliseconds = (durations[index] * 600 / _playbackSpeed).round();
      await Future<void>.delayed(Duration(milliseconds: milliseconds));
    }
  }

  @override
  void dispose() {
    if (_ttsInitialized) _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
    final expandedCardExtent = math.max(
      560.0,
      MediaQuery.sizeOf(context).height - 100,
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('리듬 상세'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(word.isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              delegate: _WordCardHeaderDelegate(
                word: word,
                expandedExtent: expandedCardExtent,
                playing: _playing,
                activeSyllable: _activeSyllable,
                flipped: _flipped,
                onFlip: () => setState(() => _flipped = !_flipped),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              sliver: SliverList.list(
                children: [
                  _RhythmControlsCard(
                    playing: _playing,
                    playbackSpeed: _playbackSpeed,
                    intensity: _intensity,
                    onSpeedChanged: (speed) =>
                        setState(() => _playbackSpeed = speed),
                    onIntensityChanged: (value) =>
                        setState(() => _intensity = value),
                    onPlay: _playRhythm,
                  ),
                  const SizedBox(height: 20),
                  _PracticeCard(word: word),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordCardHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _WordCardHeaderDelegate({
    required this.word,
    required this.expandedExtent,
    required this.playing,
    required this.activeSyllable,
    required this.flipped,
    required this.onFlip,
  });

  final RhythmWord word;
  final double expandedExtent;
  final bool playing;
  final int activeSyllable;
  final bool flipped;
  final VoidCallback onFlip;

  @override
  double get maxExtent => expandedExtent;

  @override
  double get minExtent => 292;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final sideMargin = 20 + 42 * progress;
    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          sideMargin,
          8 + 4 * progress,
          sideMargin,
          12,
        ),
        child: _FlippableWordCard(
          word: word,
          progress: progress,
          playing: playing,
          activeSyllable: activeSyllable,
          flipped: flipped,
          onFlip: onFlip,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _WordCardHeaderDelegate oldDelegate) {
    return oldDelegate.playing != playing ||
        oldDelegate.activeSyllable != activeSyllable ||
        oldDelegate.flipped != flipped ||
        oldDelegate.expandedExtent != expandedExtent ||
        oldDelegate.word != word;
  }
}

class _FlippableWordCard extends StatelessWidget {
  const _FlippableWordCard({
    required this.word,
    required this.progress,
    required this.playing,
    required this.activeSyllable,
    required this.flipped,
    required this.onFlip,
  });

  final RhythmWord word;
  final double progress;
  final bool playing;
  final int activeSyllable;
  final bool flipped;
  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context) {
    final angle = flipped ? math.pi : 0.0;
    return Semantics(
      button: true,
      label: flipped ? '단어 카드 앞면 보기' : '단어 상세 설명 보기',
      child: GestureDetector(
        key: const ValueKey('word-flip-card'),
        onTap: onFlip,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: angle),
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeInOutCubic,
          builder: (context, value, _) {
            final showBack = value > math.pi / 2;
            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.0014)
              ..rotateY(value);
            return Transform(
              alignment: Alignment.center,
              transform: transform,
              child: Transform(
                alignment: Alignment.center,
                transform: showBack
                    ? (Matrix4.identity()..rotateY(math.pi))
                    : Matrix4.identity(),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(
                      word.color.withValues(alpha: 0.11),
                      Colors.white,
                    ),
                    border:
                        Border.all(color: word.color.withValues(alpha: 0.55)),
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: showBack
                        ? _WordCardBack(
                            key: const ValueKey('word-card-back'),
                            word: word,
                            compact: progress > 0.48,
                          )
                        : _WordCardFront(
                            key: const ValueKey('word-card-front'),
                            word: word,
                            progress: progress,
                            playing: playing,
                            activeSyllable: activeSyllable,
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WordCardFront extends StatelessWidget {
  const _WordCardFront({
    super.key,
    required this.word,
    required this.progress,
    required this.playing,
    required this.activeSyllable,
  });

  final RhythmWord word;
  final double progress;
  final bool playing;
  final int activeSyllable;

  @override
  Widget build(BuildContext context) {
    final compact = progress > 0.58;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        22 - 6 * progress,
        22 - 8 * progress,
        22 - 6 * progress,
        18 - 4 * progress,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${word.rhythmBeats} SYLLABLES',
                style: const TextStyle(
                  color: AppColors.inkSoft,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              const Icon(Icons.flip_rounded,
                  size: 17, color: AppColors.inkSoft),
            ],
          ),
          SizedBox(height: compact ? 10 : 24),
          SoundLengthPattern(
            lengths: word.syllableDurations,
            color: word.color,
            activeIndex: playing ? activeSyllable : -1,
            emphasisIndex: word.stressIndex,
            height: compact ? 8 : 12,
            gap: 7,
          ),
          const Spacer(),
          Text(
            word.word,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: compact ? 24 : 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
            ),
          ),
          SizedBox(height: compact ? 3 : 8),
          Text(
            '${word.phonetic}  ·  ${word.meaning}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.inkSoft,
              fontSize: compact ? 10 : 13,
            ),
          ),
          const Spacer(),
          _SyllableBlocks(
            word: word,
            activeSyllable: activeSyllable,
            compact: compact,
          ),
          if (!compact) ...[
            const SizedBox(height: 14),
            Text(
              activeSyllable < 0
                  ? '카드를 눌러 상세 설명 보기'
                  : '지금 재생: ${word.syllables[activeSyllable]}',
              style: TextStyle(
                color: activeSyllable < 0
                    ? AppColors.inkSoft
                    : AppColors.orangeDark,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SyllableBlocks extends StatelessWidget {
  const _SyllableBlocks({
    required this.word,
    required this.activeSyllable,
    required this.compact,
  });

  final RhythmWord word;
  final int activeSyllable;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(word.syllables.length, (index) {
        final stressed = index == word.stressIndex;
        final active = index == activeSyllable;
        return Expanded(
          flex: (word.syllableDurations[index] * 100).round(),
          child: Padding(
            padding: EdgeInsets.only(
              right: index == word.syllables.length - 1 ? 0 : 8,
            ),
            child: AnimatedContainer(
              key: ValueKey('syllable-${word.syllables[index]}'),
              duration: const Duration(milliseconds: 160),
              height: compact ? 38 : 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active
                    ? word.color
                    : stressed
                        ? word.color.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.76),
                borderRadius: BorderRadius.circular(AppRadii.small),
                border: Border.all(
                  color: active || stressed ? word.color : AppColors.line,
                  width: active ? 2 : 1,
                ),
              ),
              child: Text(
                word.syllables[index],
                style: TextStyle(
                  color: active || stressed ? AppColors.ink : AppColors.inkSoft,
                  fontSize: compact ? 13 : 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _WordCardBack extends StatelessWidget {
  const _WordCardBack({super.key, required this.word, required this.compact});

  final RhythmWord word;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, compact ? 16 : 26, 24, 22),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'RHYTHM NOTE',
                style: TextStyle(
                  color: AppColors.inkSoft,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                ),
              ),
              const Spacer(),
              const Icon(Icons.flip_rounded,
                  size: 17, color: AppColors.inkSoft),
            ],
          ),
          if (!compact) const Spacer(),
          Text(
            word.syllables.join(' · '),
            style: TextStyle(
              color: AppColors.orangeDark,
              fontSize: compact ? 18 : 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: compact ? 8 : 14),
          Text(
            word.rhythmDescription,
            textAlign: TextAlign.center,
            maxLines: compact ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: compact ? 11 : 13,
              height: 1.55,
            ),
          ),
          if (!compact) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(AppRadii.small),
              ),
              child: Column(
                children: [
                  const Text(
                    'EXAMPLE',
                    style: TextStyle(
                      color: AppColors.inkSoft,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    word.exampleSentence,
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
            const SizedBox(height: 14),
            const Text(
              '카드를 눌러 앞면 보기',
              style: TextStyle(color: AppColors.inkSoft, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}

class _RhythmControlsCard extends StatelessWidget {
  const _RhythmControlsCard({
    required this.playing,
    required this.playbackSpeed,
    required this.intensity,
    required this.onSpeedChanged,
    required this.onIntensityChanged,
    required this.onPlay,
  });

  final bool playing;
  final double playbackSpeed;
  final double intensity;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<double> onIntensityChanged;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('리듬을 느껴보세요', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 7),
            const Text(
              '강세가 있는 음절에서 더 길고 강한 진동이 전달됩니다.',
              style: TextStyle(color: AppColors.inkSoft),
            ),
            const SizedBox(height: 22),
            const Text('재생 속도',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.inkSoft,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 9),
            Row(
              children: [
                for (final speed in [0.75, 1.0, 1.2])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: ChoiceChip(
                        label: Text('${speed}x'),
                        selected: playbackSpeed == speed,
                        onSelected:
                            playing ? null : (_) => onSpeedChanged(speed),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.small),
                        ),
                        showCheckmark: false,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.vibration_rounded, color: AppColors.orange),
                Expanded(
                  child: Slider(
                    value: intensity,
                    onChanged: onIntensityChanged,
                  ),
                ),
                Text('${(intensity * 100).round()}%'),
              ],
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: playing ? null : onPlay,
              icon: Icon(playing
                  ? Icons.graphic_eq_rounded
                  : Icons.play_arrow_rounded),
              label: Text(playing ? '재생 중...' : '발음과 진동 재생'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({required this.word});

  final RhythmWord word;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        children: [
          const IconTile(
            icon: Icons.mic_rounded,
            backgroundColor: AppColors.orange,
            iconColor: Colors.white,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '이제 직접 말해볼까요?',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(
                  word.syllables.join(' · '),
                  style: const TextStyle(color: Color(0xFFCFC8C2)),
                ),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('발음 녹음을 시작합니다.')),
              );
            },
            style: IconButton.styleFrom(backgroundColor: Colors.white),
            icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}
