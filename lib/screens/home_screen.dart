import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/rhythm_word.dart';
import '../repositories/word_repository.dart';
import '../widgets/eng_logo.dart';
import '../widgets/section_header.dart';
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
            sliver: SliverList.list(
              children: [
                _HomeHeader(onOpenProfile: onOpenProfile),
                const SizedBox(height: 28),
                _HeroCard(onStartCapture: onStartCapture),
                const SizedBox(height: 18),
                const _WeeklyProgressCard(),
                const SizedBox(height: 30),
                SectionHeader(
                  title: '최근 수집한 리듬',
                  actionLabel: '전체보기',
                  onAction: onOpenLibrary,
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: repository,
                  builder: (context, _) {
                    final recentWords = repository.recentWords.take(4).toList();
                    return SizedBox(
                      height: 178,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: recentWords.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final item = recentWords[index];
                          return _RecentWordCard(
                            word: item,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => WordDetailScreen(
                                  word: item,
                                  repository: repository,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                const SectionHeader(title: '오늘의 리듬 노트'),
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
        const Expanded(child: EngLogo()),
        _HeaderAction(
          icon: Icons.notifications_none_rounded,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('새 알림이 없습니다.')),
            );
          },
        ),
        const SizedBox(width: 8),
        _ProfileButton(onTap: onOpenProfile),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '읽지 않은 알림 2개',
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
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
                Icon(icon, size: 22),
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    width: 14,
                    height: 14,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.coral,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '2',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
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

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '김준희 프로필 열기',
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 7, 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.peach, AppColors.coral],
                    ),
                  ),
                  child: const Text(
                    '준',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '김준희',
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 1),
                    Text(
                      '리듬 탐험가',
                      style: TextStyle(color: AppColors.inkSoft, fontSize: 8),
                    ),
                  ],
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AppColors.inkSoft,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onStartCapture});

  final VoidCallback onStartCapture;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                _StatusMark(),
                Spacer(),
                Icon(Icons.sensors_rounded, color: AppColors.orange, size: 20),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '일상의 소리를\n영어 리듬으로 바꿔보세요',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              '반복되는 소리를 감지하면 가장 가까운 영어 리듬을 찾아드려요.',
              style: TextStyle(color: AppColors.inkSoft, height: 1.5),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.small),
              ),
              child: const SoundLengthPattern(
                lengths: [0.48, 1.0, 0.42, 0.9, 0.48],
                height: 10,
                gap: 6,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onStartCapture,
              icon: const Icon(Icons.graphic_eq_rounded, size: 19),
              label: const Text('새 리듬 수집하기'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusMark extends StatelessWidget {
  const _StatusMark();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 7,
          height: 7,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFF62B86B),
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(width: 8),
        Text(
          'ENG 디바이스 연결됨',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
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
    const values = [3, 5, 2, 7, 4, 0, 0];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('이번 주 리듬',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    const Text(
                      '5일 연속 수집 중',
                      style: TextStyle(color: AppColors.inkSoft, fontSize: 13),
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  '21',
                  style: TextStyle(
                    color: AppColors.orangeDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('개', style: TextStyle(color: AppColors.inkSoft)),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(days.length, (index) {
                final active = index < 5;
                final today = index == 4;
                return SizedBox(
                  width: 32,
                  child: Column(
                    children: [
                      Text(
                        values[index] == 0 ? '–' : '${values[index]}',
                        style: TextStyle(
                          color:
                              active ? AppColors.ink : const Color(0xFFA9A5A1),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: today ? 22 : 12,
                        height: 3,
                        color: today
                            ? AppColors.orange
                            : active
                                ? const Color(0xFFC9C4BF)
                                : AppColors.line,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        days[index],
                        style: TextStyle(
                          color:
                              today ? AppColors.orangeDark : AppColors.inkSoft,
                          fontSize: 12,
                          fontWeight: today ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
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
      width: 162,
      child: Material(
        color: Color.alphaBlend(
          word.color.withValues(alpha: 0.1),
          Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 28, height: 3, color: word.color),
                const SizedBox(height: 18),
                Text(word.word, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  word.meaning,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(color: AppColors.inkSoft, fontSize: 12),
                ),
                const Spacer(),
                SoundLengthPattern(
                  lengths: word.syllableDurations,
                  color: word.color,
                  height: 7,
                  gap: 4,
                ),
                const SizedBox(height: 9),
                Text(
                  word.phonetic,
                  style:
                      const TextStyle(color: AppColors.inkSoft, fontSize: 11),
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
        color: const Color(0xFFFFF8F1),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.notes_rounded, color: AppColors.orange, size: 21),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '강세는 크게보다 길고 선명하게',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                SizedBox(height: 6),
                Text(
                  '모음을 조금 더 길게 유지하면 영어 리듬이 훨씬 자연스러워집니다.',
                  style: TextStyle(color: AppColors.inkSoft, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
