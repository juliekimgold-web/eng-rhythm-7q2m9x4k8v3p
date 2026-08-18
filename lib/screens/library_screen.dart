import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/rhythm_word.dart';
import '../repositories/word_repository.dart';
import '../widgets/sound_length_pattern.dart';
import 'word_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, required this.repository});

  final WordRepository repository;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _searchController = TextEditingController();
  var _filter = '전체';
  var _mode = '갤러리';
  var _visibleMonth = DateTime(2026, 8);
  var _selectedDay = DateTime(2026, 8, 13);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RhythmWord> get _filteredWords {
    final query = _searchController.text.trim().toLowerCase();
    return widget.repository.search(query: query, filter: _filter);
  }

  List<RhythmWord> get _selectedWords =>
      widget.repository.wordsForDay(_selectedDay);

  void _toggleFavorite(RhythmWord item) =>
      widget.repository.toggleFavorite(item.id);

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth =
          DateTime(_visibleMonth.year, _visibleMonth.month + offset);
      _selectedDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: widget.repository,
        builder: (context, _) {
          final showingCalendar = _mode == '수집 기록';
          final visibleWords =
              showingCalendar ? _selectedWords : _filteredWords;
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                sliver: SliverList.list(
                  children: [
                    Text('수집한 단어',
                        style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 7),
                    const Text(
                      '익숙해진 리듬을 날짜와 패턴으로 다시 만나보세요.',
                      style: TextStyle(color: AppColors.inkSoft),
                    ),
                    const SizedBox(height: 20),
                    _LibraryModeSwitch(
                      value: _mode,
                      onChanged: (value) => setState(() => _mode = value),
                    ),
                    const SizedBox(height: 18),
                    if (showingCalendar) ...[
                      _CollectionCalendar(
                        month: _visibleMonth,
                        selectedDay: _selectedDay,
                        words: widget.repository.words,
                        onPreviousMonth: () => _changeMonth(-1),
                        onNextMonth: () => _changeMonth(1),
                        onSelectDay: (day) =>
                            setState(() => _selectedDay = day),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Text(
                            _selectedDateLabel(_selectedDay),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          Text(
                            '${visibleWords.length}개 수집',
                            style: const TextStyle(
                              color: AppColors.orangeDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: '단어 또는 뜻 검색',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 42,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: ['전체', '즐겨찾기', '2박자', '3박자'].map((filter) {
                            final selected = _filter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () => setState(() => _filter = filter),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.small),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        selected ? AppColors.ink : Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.small),
                                    border: Border.all(color: AppColors.line),
                                  ),
                                  child: Text(
                                    filter,
                                    style: TextStyle(
                                      color: selected
                                          ? Colors.white
                                          : AppColors.inkSoft,
                                      fontWeight: FontWeight.w700,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Text(
                            '${visibleWords.length}개의 단어',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          const Icon(Icons.swap_vert_rounded,
                              size: 18, color: AppColors.inkSoft),
                          const SizedBox(width: 4),
                          const Text('최근 수집순',
                              style: TextStyle(
                                  color: AppColors.inkSoft, fontSize: 12)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              if (visibleWords.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.line),
                        borderRadius: BorderRadius.circular(AppRadii.card),
                      ),
                      child: Text(
                        showingCalendar
                            ? '이 날 수집한 단어가 없습니다.'
                            : '조건에 맞는 단어가 없습니다.',
                        style: const TextStyle(color: AppColors.inkSoft),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                  sliver: SliverList.separated(
                    itemCount: visibleWords.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = visibleWords[index];
                      return _LibraryWordCard(
                        word: item,
                        showTime: showingCalendar,
                        onFavorite: () => _toggleFavorite(item),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => WordDetailScreen(
                              word: item,
                              repository: widget.repository,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _LibraryModeSwitch extends StatelessWidget {
  const _LibraryModeSwitch({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadii.control),
      ),
      child: Row(
        children: ['갤러리', '수집 기록'].map((label) {
          final selected = value == label;
          return Expanded(
            child: InkWell(
              key: ValueKey('library-mode-$label'),
              onTap: () => onChanged(label),
              borderRadius: BorderRadius.circular(AppRadii.small),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.small),
                  border: selected
                      ? Border.all(color: AppColors.line)
                      : Border.all(color: Colors.transparent),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      label == '갤러리'
                          ? Icons.grid_view_rounded
                          : Icons.calendar_month_outlined,
                      size: 17,
                      color:
                          selected ? AppColors.orangeDark : AppColors.inkSoft,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      label,
                      style: TextStyle(
                        color: selected ? AppColors.ink : AppColors.inkSoft,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CollectionCalendar extends StatelessWidget {
  const _CollectionCalendar({
    required this.month,
    required this.selectedDay,
    required this.words,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDay,
  });

  final DateTime month;
  final DateTime selectedDay;
  final List<RhythmWord> words;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final first = DateTime(month.year, month.month, 1);
    final leading = first.weekday - 1;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    return Container(
      key: const ValueKey('collection-calendar'),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: Text(
                  '${month.year}년 ${month.month}월',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: weekdays
                .map((day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.inkSoft,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.9,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final dayNumber = index - leading + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }
              final date = DateTime(month.year, month.month, dayNumber);
              final dayWords = words
                  .where((word) => DateUtils.isSameDay(word.collectedAt, date))
                  .toList();
              final selected = DateUtils.isSameDay(date, selectedDay);
              return InkWell(
                key: ValueKey('calendar-day-$dayNumber'),
                onTap: () => onSelectDay(date),
                borderRadius: BorderRadius.circular(AppRadii.small),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.cream : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadii.small),
                    border:
                        selected ? Border.all(color: AppColors.orange) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          color:
                              selected ? AppColors.orangeDark : AppColors.ink,
                          fontSize: 12,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        height: 5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: dayWords.take(3).map((word) {
                            return Container(
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: word.color,
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LibraryWordCard extends StatelessWidget {
  const _LibraryWordCard({
    required this.word,
    required this.showTime,
    required this.onFavorite,
    required this.onTap,
  });

  final RhythmWord word;
  final bool showTime;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = Color.alphaBlend(
      word.color.withValues(alpha: 0.12),
      Colors.white,
    );
    return Material(
      color: tint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: word.color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 15, 8, 15),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 58,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SoundLengthPattern(
                              lengths: word.syllableDurations,
                              color: word.color,
                              emphasisIndex: word.stressIndex,
                              height: 8,
                              gap: 3,
                            ),
                            const SizedBox(height: 9),
                            Text(
                              '${word.rhythmBeats}박자',
                              style: TextStyle(
                                color: _readableColor(word.color),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    word.word,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  word.phonetic,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.inkSoft,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              word.meaning,
                              style: const TextStyle(color: AppColors.inkSoft),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    word.source,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _readableColor(word.color),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (showTime)
                                  Text(
                                    _timeLabel(word.collectedAt),
                                    style: const TextStyle(
                                      color: AppColors.inkSoft,
                                      fontSize: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onFavorite,
                        icon: Icon(
                          word.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: word.isFavorite
                              ? AppColors.coral
                              : AppColors.inkSoft,
                        ),
                      ),
                    ],
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

String _selectedDateLabel(DateTime date) {
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  return '${date.month}월 ${date.day}일 ${weekdays[date.weekday - 1]}요일';
}

String _timeLabel(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

Color _readableColor(Color color) {
  if (color == AppColors.yellow) return const Color(0xFF8A6B00);
  if (color == AppColors.peach) return const Color(0xFFB95600);
  return Color.lerp(color, AppColors.ink, 0.18)!;
}
