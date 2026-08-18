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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 104),
            sliver: SliverList.list(
              children: [
                _HomeHeader(onOpenProfile: onOpenProfile),
                const SizedBox(height: 30),
                const _Greeting(),
                const SizedBox(height: 24),
                _CaptureHero(onStartCapture: onStartCapture),
                const SizedBox(height: 14),
                _QuickActions(
                  onStartCapture: onStartCapture,
                  onOpenLibrary: onOpenLibrary,
                  onOpenProfile: onOpenProfile,
                ),
                const SizedBox(height: 30),
                const _SectionTitle(
                  title: '이번 주 리듬',
                  caption: '짧게, 매일. 감각은 자연스럽게 쌓여요.',
                ),
                const SizedBox(height: 12),
                const _WeeklyProgressCard(),
                const SizedBox(height: 30),
                _SectionTitle(
                  title: '오늘의 리듬',
                  caption: '가장 최근에 만난 소리를 다시 들어보세요.',
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
                const SizedBox(height: 30),
                const _SectionTitle(
                  title: '오늘의 작은 팁',
                  caption: '한 번에 하나만 기억해도 충분해요.',
                ),
                const SizedBox(height: 12),
                const _TipCard(),
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
              side: const BorderSide(color: AppColors.line),
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
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      '김준희',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
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
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.line),
        ),
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
            fontSize: 11,
            fontWeight: FontWeight.w800,
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

class _CaptureHero extends StatelessWidget {
  const _CaptureHero({required this.onStartCapture});

  final VoidCallback onStartCapture;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
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
          const SizedBox(height: 24),
          Text(
            '소리를 켜면\n영어가 들리기 시작해요',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 24,
                  height: 1.25,
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
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const SoundLengthPattern(
              lengths: [0.48, 1.0, 0.42, 0.9, 0.48],
              color: AppColors.orange,
              height: 9,
              gap: 6,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onStartCapture,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ink,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.graphic_eq_rounded, size: 20),
              label: const Text('새 리듬 수집하기'),
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
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cream,
      ),
      child: const Icon(
        Icons.multitrack_audio_rounded,
        color: AppColors.orangeDark,
        size: 23,
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.line),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 7,
            height: 7,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF4CAF66),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 7),
          Text(
            'ENG 디바이스 연결됨',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onStartCapture,
    required this.onOpenLibrary,
    required this.onOpenProfile,
  });

  final VoidCallback onStartCapture;
  final VoidCallback onOpenLibrary;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionItem(
            icon: Icons.hearing_rounded,
            label: '바로 듣기',
            color: AppColors.orange,
            onTap: onStartCapture,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _QuickActionItem(
            icon: Icons.bookmark_outline_rounded,
            label: '단어 모음',
            color: AppColors.blue,
            onTap: onOpenLibrary,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _QuickActionItem(
            icon: Icons.insights_rounded,
            label: '내 학습',
            color: AppColors.coral,
            onTap: onOpenProfile,
          ),
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(height: 9),
              Text(
                label,
                maxLines: 1,
                style: const TextStyle(
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
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
                      fontWeight: FontWeight.w800,
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
                        fontSize: 11,
                        fontWeight: today ? FontWeight.w800 : FontWeight.w500,
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
        color: const Color(0xFFFFF2E5),
        borderRadius: BorderRadius.circular(999),
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
              fontWeight: FontWeight.w800,
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
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.line),
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
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
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
                      lengths: word.syllableDurations,
                      color: AppColors.ink,
                      height: 8,
                      gap: 7,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: word.color,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: Colors.white,
                      size: 20,
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

class _EmptyRhythmCard extends StatelessWidget {
  const _EmptyRhythmCard({required this.onStartCapture});

  final VoidCallback onStartCapture;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        onTap: onStartCapture,
        borderRadius: BorderRadius.circular(18),
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
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.line),
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
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
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
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                SoundLengthPattern(
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
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TipIcon(),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '강세는 크게보다 길고 선명하게',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                SizedBox(height: 6),
                Text(
                  '모음을 조금 더 길게 유지하면 영어 리듬이 훨씬 자연스러워져요.',
                  style: TextStyle(
                    color: AppColors.inkSoft,
                    fontSize: 12,
                    height: 1.55,
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

class _TipIcon extends StatelessWidget {
  const _TipIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.lightbulb_outline_rounded,
        color: AppColors.orangeDark,
        size: 20,
      ),
    );
  }
}
