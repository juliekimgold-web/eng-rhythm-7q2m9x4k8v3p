import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/rhythm_word.dart';

class WordRepository extends ChangeNotifier {
  WordRepository(Iterable<RhythmWord> initialWords)
      : _words = List.of(initialWords);

  final List<RhythmWord> _words;

  UnmodifiableListView<RhythmWord> get words => UnmodifiableListView(_words);

  List<RhythmWord> get recentWords {
    final result = List<RhythmWord>.of(_words)
      ..sort((a, b) => b.collectedAt.compareTo(a.collectedAt));
    return List.unmodifiable(result);
  }

  RhythmWord? findById(String id) {
    for (final word in _words) {
      if (word.id == id) return word;
    }
    return null;
  }

  List<RhythmWord> wordsForDay(DateTime day) => List.unmodifiable(
        _words.where((word) =>
            word.collectedAt.year == day.year &&
            word.collectedAt.month == day.month &&
            word.collectedAt.day == day.day),
      );

  List<RhythmWord> search({String query = '', String filter = '전체'}) {
    final normalizedQuery = query.trim().toLowerCase();
    return List.unmodifiable(_words.where((word) {
      final matchesQuery = normalizedQuery.isEmpty ||
          word.word.toLowerCase().contains(normalizedQuery) ||
          word.meaning.toLowerCase().contains(normalizedQuery);
      final matchesFilter = switch (filter) {
        '즐겨찾기' => word.isFavorite,
        '2박자' => word.rhythmBeats == 2,
        '3박자' => word.rhythmBeats == 3,
        _ => true,
      };
      return matchesQuery && matchesFilter;
    }));
  }

  void toggleFavorite(String id) {
    final index = _words.indexWhere((word) => word.id == id);
    if (index < 0) return;
    _words[index] = _words[index].copyWith(
      isFavorite: !_words[index].isFavorite,
    );
    notifyListeners();
  }
}
