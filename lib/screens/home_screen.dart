import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/rhythm_word.dart';
import '../repositories/word_repository.dart';
import '../widgets/eng_logo.dart';
import '../widgets/sound_length_pattern.dart';
import 'word_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onStartCapture,
    required this.onOpenLibrary,
    required this.onOpenProfile,
    required this.repository,
  });

  final VoidCallback onStartCapture;
  final VoidCallback onOpenLibrary;
  final VoidCallback onOpenProfile;
  final WordRepository repository;

  void _openWord(BuildContext context, RhythmWord word) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WordDetailScreen(
          word: word,
          repository: repository,
        ),
      ),
    );
  }

  void _openSpeakPractice(BuildContext context) {
    final recentWords = repository.recentWords;
    if (recentWords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 리듬을 하나 수집해 주세요.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WordDetailScreen(
          word: recentWords.first,
          repository: repository,
          openPracticeOnLaunch: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.sm,
              AppSpacing.page,
              104,
            ),
            sliver: SliverList.list(
              children: [
                _HomeHeader(onOpenProfile: onOpenProfile),
                const SizedBox(height: AppSpacing.lg),
                const _Greeting(),
                const SizedBox(height: AppSpacing.md),
                const _DailyTipBanner(),
                const SizedBox(height: AppSpacing.lg),
                _CaptureHero(
                  onStartCapture: onStartCapture,
                  onStartSpeaking: () => _openSpeakPractice(context),
                ),
                const SizedBox(height: AppSpacing.section),
                const _SectionTitle(
                  title: '이번 주 리듬',
                  caption: '짧게, 매일. 감각은 자연스럽게 쌓여요.',
                ),
                const SizedBox(height: 12),
                const _WeeklyProgressCard(),
                const SizedBox(height: AppSpacing.section),
                _SectionTitle(
                  title: '최근 수집한 단어',
                  caption: '가장 최근에 만난 리듬부터 확인해 보세요.',
                  actionLabel: '전체보기',
                  onAction: onOpenLibrary,
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: repository,
                  builder: (context, _) {
                    final recentWords = repository.recentWords;
                    if (recentWords.isEmpty) {
                      return _EmptyRhythmCard(onStartCapture: onStartCapture);
                    }
                    return _TodayRhythmCard(
                      word: recentWords.first,
                      onTap: () => _openWord(context, recentWords.first),
                    );
                  },
                ),
                const SizedBox(height: 16),
                AnimatedBuilder(
                  animation: repository,
                  builder: (context, _) {
                    final recentWords =
                        repository.recentWords.skip(1).take(4).toList();
                    if (recentWords.isEmpty) return const SizedBox.shrink();
                    return SizedBox(
                      height: 148,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: recentWords.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final word = recentWords[index];
                          return _RecentWordCard(
                            word: word,
                            onTap: () => _openWord(context, word),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.section),
                const _SectionTitle(
                  title: '복습이 필요한 단어',
                  caption: '저장한 단어를 짧게 다시 익혀보세요.',
                ),
                const SizedBox(height: AppSpacing.sm),
                AnimatedBuilder(
                  animation: repository,
                  builder: (context, _) => _ReviewWords(
                    words: repository.search(filter: '즐겨찾기').take(3).toList(),
                    onOpenWord: (word) => _openWord(context, word),
                    onOpenLibrary: onOpenLibrary,
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onOpenProfile});

  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: EngLogo(compact: true)),
        _RoundAction(
          semanticLabel: '알림 열기',
          icon: Icons.notifications_none_rounded,
          showBadge: true,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('새 알림이 없습니다.')),
            );
          },
        ),
        const SizedBox(width: 8),
        Semantics(
          button: true,
          label: '김준희 프로필 열기',
          child: Material(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onOpenProfile,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 11, 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.ink,
                      ),
                      child: const Text(
                        '준',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      '김준희',
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
          ),
        ),
      ],
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.semanticLabel,
    required this.icon,
    required this.onTap,
    this.showBadge = false,
  });

  final String semanticLabel;
  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, size: 22, color: AppColors.ink),
                if (showBadge)
                  Positioned(
                    top: 9,
                    right: 9,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.coral,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateLabel =
        '${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TODAY · $dateLabel',
          style: const TextStyle(
            color: AppColors.inkSoft,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          '오늘도 영어 리듬을\n가볍게 깨워볼까요?',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 28,
                height: 1.22,
                letterSpacing: -1,
              ),
        ),
      ],
    );
  }
}

class _DailyTipBanner extends StatelessWidget {
  const _DailyTipBanner();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '오늘의 작은 팁. 강세는 크게보다 길고 선명하게. 모음을 길게 유지하면 리듬이 더 자연스러워져요.',
      child: Container(
        key: const ValueKey('home-daily-tip'),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome_outlined,
                color: AppColors.orangeDark,
                size: 17,
              ),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 작은 팁',
                    style: TextStyle(
                      color: AppColors.orangeDark,
                      fontSize: 11,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    '강세는 크게보다 길고 선명하게',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '모음을 길게 유지하면 리듬이 더 자연스러워져요.',
                    style: TextStyle(
                      color: AppColors.inkSoft,
                      fontSize: 12,
                      height: 1.48,
                      letterSpacing: -0.1,
                    ),
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

class _CaptureHero extends StatelessWidget {
  const _CaptureHero({
    required this.onStartCapture,
    required this.onStartSpeaking,
  });

  final VoidCallback onStartCapture;
  final VoidCallback onStartSpeaking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.page),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _DeviceStatus(),
              Spacer(),
              _CaptureGlyph(),
            ],
          ),
          const SizedBox(height: AppSpacing.page),
          Text(
            '일상의 소리를\n영어 리듬으로 바꿔보세요',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  height: 1.32,
                  letterSpacing: -0.65,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            '주변의 반복되는 소리에서 가장 닮은 영어 리듬을 찾아드려요.',
            style: TextStyle(
              color: AppColors.inkSoft,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.control),
            ),
            child: const SoundLengthPattern(
              lengths: [0.48, 1.0, 0.42, 0.9, 0.48],
              color: AppColors.orange,
              height: 9,
              gap: 6,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onStartCapture,
              icon: const Icon(Icons.graphic_eq_rounded, size: 20),
              label: const Text('새 리듬 수집하기'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const ValueKey('home-speak-practice'),
              onPressed: onStartSpeaking,
              icon: const Icon(Icons.mic_none_rounded, size: 20),
              label: const Text('말하기 · 발음 분석'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptureGlyph extends StatelessWidget {
  const _CaptureGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.control),
      ),
      child: const Icon(
        Icons.multitrack_audio_rounded,
        color: AppColors.orange,
        size: 22,
      ),
    );
  }
}

class _DeviceStatus extends StatelessWidget {
  const _DeviceStatus();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 7,
            height: 7,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 7),
          Text(
            'ENG 디바이스 연결됨',
            style: TextStyle(
              color: AppColors.success,
              fontSize: AppTypeScale.caption,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewWords extends StatelessWidget {
  const _ReviewWords({
    required this.words,
    required this.onOpenWord,
    required this.onOpenLibrary,
  });

  final List<RhythmWord> words;
  final ValueChanged<RhythmWord> onOpenWord;
  final VoidCallback onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: InkWell(
          onTap: onOpenLibrary,
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: const Padding(
            padding: EdgeInsets.all(AppSpacing.page),
            child: Row(
              children: [
                Icon(Icons.bookmark_border_rounded, color: AppColors.inkSoft),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '기억하고 싶은 단어를 저장하면 여기에 모아드려요.',
                    style: TextStyle(color: AppColors.inkSoft),
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.line),
          bottom: BorderSide(color: AppColors.line),
        ),
      ),
      child: Column(
        children: List.generate(words.length, (index) {
          final word = words[index];
          return Column(
            children: [
              _ReviewWordRow(word: word, onTap: () => onOpenWord(word)),
              if (index < words.length - 1)
                const Divider(indent: 48, color: AppColors.line),
            ],
          );
        }),
      ),
    );
  }
}

class _ReviewWordRow extends StatelessWidget {
  const _ReviewWordRow({required this.word, required this.onTap});

  final RhythmWord word;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 68,
        child: Row(
          children: [
            const Icon(Icons.bookmark_rounded, color: AppColors.orange),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.word,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    word.meaning,
                    style: const TextStyle(
                      color: AppColors.inkSoft,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 78,
              child: SoundLengthPattern(
                key: ValueKey('review-rhythm-${word.id}'),
                lengths: word.syllableDurations,
                color: word.color,
                height: 5,
                gap: 4,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.inkSoft,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.caption,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String caption;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                caption,
                style: const TextStyle(
                  color: AppColors.inkSoft,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.inkSoft,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _WeeklyProgressCard extends StatelessWidget {
  const _WeeklyProgressCard();

  @override
  Widget build(BuildContext context) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    const values = [0.42, 0.66, 0.3, 0.94, 0.56, 0.0, 0.0];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 19, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '21개',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '이번 주에 발견한 리듬',
                    style: TextStyle(color: AppColors.inkSoft, fontSize: 12),
                  ),
                ],
              ),
              Spacer(),
              _StreakBadge(),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(days.length, (index) {
              final active = values[index] > 0;
              final today = index == 4;
              return SizedBox(
                width: 28,
                child: Column(
                  children: [
                    Container(
                      width: 7,
                      height: 18 + (42 * values[index]),
                      decoration: BoxDecoration(
                        color: today
                            ? AppColors.orange
                            : active
                                ? const Color(0xFFFFC38F)
                                : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[index],
                      style: TextStyle(
                        color: today ? AppColors.orangeDark : AppColors.inkSoft,
                        fontSize: AppTypeScale.caption,
                        fontWeight: today ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.line),
      ),
      child: const Row(
        children: [
          Icon(Icons.local_fire_department_rounded,
              size: 17, color: AppColors.orange),
          SizedBox(width: 5),
          Text(
            '5일 연속',
            style: TextStyle(
              color: AppColors.orangeDark,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayRhythmCard extends StatelessWidget {
  const _TodayRhythmCard({required this.word, required this.onTap});

  final RhythmWord word;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: ValueKey('recent-feature-card-${word.id}'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.raisedCard,
      ),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(
            color: AppColors.line.withValues(alpha: 0.55),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 19, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'NO.${word.cardNumber.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: AppColors.inkSoft,
                          fontSize: AppTypeScale.caption,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.ink,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Text(
                  word.word,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${word.phonetic}  ·  ${word.meaning}',
                  style: const TextStyle(
                    color: AppColors.inkSoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: SoundLengthPattern(
                        key: ValueKey('recent-rhythm-${word.id}'),
                        lengths: word.syllableDurations,
                        color: word.color,
                        height: 8,
                        gap: 7,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadii.control),
                      ),
                      child: Icon(
                        Icons.volume_up_rounded,
                        color: word.color,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyRhythmCard extends StatelessWidget {
  const _EmptyRhythmCard({required this.onStartCapture});

  final VoidCallback onStartCapture;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: const Color(0x18000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: InkWell(
        onTap: onStartCapture,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: const Padding(
          padding: EdgeInsets.all(22),
          child: Row(
            children: [
              Icon(Icons.add_circle_outline_rounded, color: AppColors.orange),
              SizedBox(width: 12),
              Expanded(child: Text('첫 번째 영어 리듬을 수집해 보세요.')),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentWordCard extends StatelessWidget {
  const _RecentWordCard({required this.word, required this.onTap});

  final RhythmWord word;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      child: DecoratedBox(
        key: ValueKey('recent-mini-card-${word.id}'),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          boxShadow: AppShadows.raisedCard,
        ),
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.card),
            side: BorderSide(
              color: AppColors.line.withValues(alpha: 0.45),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: word.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${word.rhythmBeats} beats',
                        style: const TextStyle(
                          color: AppColors.inkSoft,
                          fontSize: AppTypeScale.caption,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  Text(
                    word.word,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    word.meaning,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.inkSoft,
                      fontSize: AppTypeScale.caption,
                    ),
                  ),
                  const Spacer(),
                  SoundLengthPattern(
                    key: ValueKey('mini-rhythm-${word.id}'),
                    lengths: word.syllableDurations,
                    color: word.color,
                    height: 6,
                    gap: 4,
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
