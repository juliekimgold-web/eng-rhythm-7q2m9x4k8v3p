import 'package:flutter/material.dart';

class RhythmWord {
  RhythmWord({
    required this.id,
    required this.cardNumber,
    required this.word,
    required this.phonetic,
    required this.meaning,
    required List<String> syllables,
    required this.stressIndex,
    required this.color,
    required this.source,
    required this.collectedAt,
    required List<double> soundPattern,
    required List<double> syllableDurations,
    required this.rhythmDescription,
    required this.exampleSentence,
    this.isFavorite = false,
  })  : syllables = List.unmodifiable(syllables),
        soundPattern = List.unmodifiable(soundPattern),
        syllableDurations = List.unmodifiable(syllableDurations);

  final String id;
  final int cardNumber;
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

  RhythmWord copyWith({
    String? id,
    int? cardNumber,
    String? word,
    String? phonetic,
    String? meaning,
    List<String>? syllables,
    int? stressIndex,
    Color? color,
    String? source,
    DateTime? collectedAt,
    List<double>? soundPattern,
    List<double>? syllableDurations,
    String? rhythmDescription,
    String? exampleSentence,
    bool? isFavorite,
  }) {
    return RhythmWord(
      id: id ?? this.id,
      cardNumber: cardNumber ?? this.cardNumber,
      word: word ?? this.word,
      phonetic: phonetic ?? this.phonetic,
      meaning: meaning ?? this.meaning,
      syllables: syllables ?? this.syllables,
      stressIndex: stressIndex ?? this.stressIndex,
      color: color ?? this.color,
      source: source ?? this.source,
      collectedAt: collectedAt ?? this.collectedAt,
      soundPattern: soundPattern ?? this.soundPattern,
      syllableDurations: syllableDurations ?? this.syllableDurations,
      rhythmDescription: rhythmDescription ?? this.rhythmDescription,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
