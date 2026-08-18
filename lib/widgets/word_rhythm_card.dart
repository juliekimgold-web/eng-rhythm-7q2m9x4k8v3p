import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/rhythm_word.dart';
import 'sound_length_pattern.dart';

class WordRhythmCard extends StatelessWidget {
  const WordRhythmCard({
    super.key,
    required this.word,
    required this.isCurrent,
    required this.playing,
    required this.activeSyllable,
    required this.playbackProgress,
    required this.rhythmRevealed,
    required this.flipped,
    required this.onFlip,
    required this.onPlay,
    required this.onFavorite,
  });

  final RhythmWord word;
  final bool isCurrent;
  final bool playing;
  final int activeSyllable;
  final double playbackProgress;
  final bool rhythmRevealed;
  final bool flipped;
  final VoidCallback onFlip;
  final VoidCallback onPlay;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final angle = flipped ? math.pi : 0.0;
    return Semantics(
      button: true,
      label: flipped ? '단어 카드 앞면 보기' : '단어 상세 설명 보기',
      child: GestureDetector(
        key: isCurrent
            ? const ValueKey('word-flip-card')
            : ValueKey('word-flip-card-${word.id}'),
        onTap: onFlip,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: angle),
          duration: AppMotion.slow,
          curve: Curves.easeInOutCubic,
          builder: (context, value, _) {
            final showBack = value > math.pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY(value),
              child: Transform(
                alignment: Alignment.center,
                transform: showBack
                    ? (Matrix4.identity()..rotateY(math.pi))
                    : Matrix4.identity(),
                child: DecoratedBox(
                  key: ValueKey('word-card-${word.id}'),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.line),
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 140),
                          child: showBack
                              ? _CardBack(
                                  key: isCurrent
                                      ? const ValueKey('word-card-back')
                                      : ValueKey('word-card-back-${word.id}'),
                                  word: word,
                                )
                              : _CardFront(
                                  key: isCurrent
                                      ? const ValueKey('word-card-front')
                                      : ValueKey('word-card-front-${word.id}'),
                                  word: word,
                                  playing: playing,
                                  activeSyllable: activeSyllable,
                                  playbackProgress: playbackProgress,
                                  rhythmRevealed: rhythmRevealed,
                                ),
                        ),
                      ),
                      if (!showBack)
                        Positioned(
                          top: 10,
                          right: 58,
                          child: Material(
                            color: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadii.control,
                              ),
                              side: const BorderSide(color: AppColors.line),
                            ),
                            child: IconButton(
                              key: ValueKey('card-play-${word.id}'),
                              onPressed: playing ? null : onPlay,
                              visualDensity: VisualDensity.compact,
                              tooltip: '발음 재생',
                              icon: Icon(
                                playing
                                    ? Icons.graphic_eq_rounded
                                    : Icons.volume_up_rounded,
                                size: 19,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Material(
                          color: Colors.transparent,
                          child: IconButton(
                            key: ValueKey('favorite-${word.id}'),
                            onPressed: onFavorite,
                            visualDensity: VisualDensity.compact,
                            tooltip: word.isFavorite ? '찜 해제' : '찜하기',
                            icon: Icon(
                              word.isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 19,
                              color: word.isFavorite
                                  ? AppColors.orange
                                  : AppColors.inkSoft,
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _CardFront extends StatelessWidget {
  const _CardFront({
    super.key,
    required this.word,
    required this.playing,
    required this.activeSyllable,
    required this.playbackProgress,
    required this.rhythmRevealed,
  });

  final RhythmWord word;
  final bool playing;
  final int activeSyllable;
  final double playbackProgress;
  final bool rhythmRevealed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 22, 26, 22),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'No.${word.cardNumber.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: AppColors.inkSoft,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${word.rhythmBeats} SYLLABLES',
                style: const TextStyle(
                  color: AppColors.inkSoft,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(width: 92),
            ],
          ),
          const SizedBox(height: 24),
          FractionallySizedBox(
            widthFactor: 0.76,
            child: SoundLengthPattern(
              lengths: word.syllableDurations,
              color: AppColors.orange,
              activeIndex: playing ? activeSyllable : -1,
              emphasisIndex: word.stressIndex,
              progress: playing ? playbackProgress : null,
              height: 9,
              gap: 9,
            ),
          ),
          const Spacer(flex: 2),
          Text(
            word.word,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            word.phonetic,
            style: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
          ),
          const SizedBox(height: 7),
          Text(
            word.meaning,
            style: const TextStyle(
              color: AppColors.inkSoft,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(flex: 2),
          _PronunciationRhythm(
            word: word,
            revealed: rhythmRevealed,
            activeSyllable: activeSyllable,
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.swipe_rounded, size: 15, color: AppColors.inkSoft),
              SizedBox(width: 6),
              Text(
                '좌우로 넘기기  ·  탭하여 상세 보기',
                style: TextStyle(color: AppColors.inkSoft, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PronunciationRhythm extends StatelessWidget {
  const _PronunciationRhythm({
    required this.word,
    required this.revealed,
    required this.activeSyllable,
  });

  final RhythmWord word;
  final bool revealed;
  final int activeSyllable;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.slow,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: revealed
          ? Row(
              key: const ValueKey('syllable-rhythm'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(word.syllables.length, (index) {
                final active = index == activeSyllable;
                final stressed = index == word.stressIndex;
                final mutedByPlayback = activeSyllable >= 0 && !active;
                final opacity = active
                    ? 1.0
                    : mutedByPlayback
                        ? 0.24
                        : stressed
                            ? 1.0
                            : 0.48;
                return Expanded(
                  flex: (word.syllableDurations[index] * 100).round(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            AnimatedDefaultTextStyle(
                              key: ValueKey(
                                'syllable-${word.syllables[index]}',
                              ),
                              duration: AppMotion.fast,
                              style: TextStyle(
                                color: AppColors.orange.withValues(
                                  alpha: opacity,
                                ),
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                              child: Text(word.syllables[index]),
                            ),
                            const SizedBox(height: 10),
                            AnimatedContainer(
                              duration: AppMotion.fast,
                              height: 2,
                              margin: EdgeInsets.symmetric(
                                horizontal: stressed ? 2 : 12,
                              ),
                              color: AppColors.orange.withValues(
                                alpha: opacity,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              stressed ? '강세 · 길게' : '약하게 · 짧게',
                              maxLines: 1,
                              style: const TextStyle(
                                color: AppColors.inkSoft,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (index < word.syllables.length - 1)
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            '·',
                            style: TextStyle(
                              color: AppColors.inkSoft,
                              fontSize: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            )
          : Text(
              word.word,
              key: const ValueKey('unseparated-word-rhythm'),
              style: TextStyle(
                color: AppColors.orange.withValues(alpha: 0.86),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({super.key, required this.word});

  final RhythmWord word;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'RHYTHM NOTE',
                style: TextStyle(
                  color: AppColors.inkSoft,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.flip_rounded,
                size: 18,
                color: AppColors.inkSoft,
              ),
              const SizedBox(width: 42),
            ],
          ),
          const Spacer(),
          Text(
            word.syllables.join(' · '),
            style: const TextStyle(
              color: AppColors.orange,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            word.rhythmDescription,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 14,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 26),
          const Divider(color: AppColors.line),
          const SizedBox(height: 22),
          const Text(
            'EXAMPLE',
            style: TextStyle(
              color: AppColors.inkSoft,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            word.exampleSentence,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
          const Spacer(),
          const Align(
            alignment: Alignment.center,
            child: Text(
              '카드를 눌러 앞면 보기',
              style: TextStyle(color: AppColors.inkSoft, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
