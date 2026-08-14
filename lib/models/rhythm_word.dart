import 'package:flutter/material.dart';

class RhythmWord {
  const RhythmWord({
    required this.word,
    required this.phonetic,
    required this.meaning,
    required this.syllables,
    required this.stressIndex,
    required this.color,
    required this.source,
    required this.collectedAt,
    required this.soundPattern,
    required this.syllableDurations,
    required this.rhythmDescription,
    required this.exampleSentence,
    this.isFavorite = false,
  });

  final String word;
  final String phonetic;
  final String meaning;
  final List<String> syllables;
  final int stressIndex;
  final Color color;
  final String source;
  final DateTime collectedAt;
  final List<double> soundPattern;
  final List<double> syllableDurations;
  final String rhythmDescription;
  final String exampleSentence;
  final bool isFavorite;

  int get rhythmBeats => syllables.length;

  RhythmWord copyWith({bool? isFavorite}) {
    return RhythmWord(
      word: word,
      phonetic: phonetic,
      meaning: meaning,
      syllables: syllables,
      stressIndex: stressIndex,
      color: color,
      source: source,
      collectedAt: collectedAt,
      soundPattern: soundPattern,
      syllableDurations: syllableDurations,
      rhythmDescription: rhythmDescription,
      exampleSentence: exampleSentence,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
