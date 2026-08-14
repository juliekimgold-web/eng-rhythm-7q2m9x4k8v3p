import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dash_eng/core/theme/app_theme.dart';
import 'package:dash_eng/data/sample_data.dart';
import 'package:dash_eng/main.dart';
import 'package:dash_eng/screens/word_detail_screen.dart';
import 'package:dash_eng/widgets/sound_length_pattern.dart';

void main() {
  testWidgets('renders the primary navigation and opens library',
      (tester) async {
    await tester.pumpWidget(const EngApp());

    expect(find.text('새 리듬 수집하기'), findsOneWidget);
    expect(find.text('라이브러리'), findsOneWidget);

    await tester.tap(find.text('라이브러리'));
    await tester.pumpAndSettle();

    expect(find.text('수집한 단어'), findsOneWidget);
    expect(find.text('Laundry'), findsOneWidget);
  });

  testWidgets('fits the scan experience on a small mobile viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EngApp());
    await tester.tap(find.text('스캔'));
    await tester.pumpAndSettle();

    expect(find.text('텍스트 스캔'), findsOneWidget);
    expect(find.text('텍스트 스캔 시작'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('library calendar filters words by collection date',
      (tester) async {
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EngApp());
    await tester.tap(find.text('라이브러리'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('library-mode-수집 기록')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('collection-calendar')), findsOneWidget);
    expect(find.text('8월 13일 목요일'), findsOneWidget);
    expect(find.text('2개 수집'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('calendar-day-12')));
    await tester.pumpAndSettle();

    expect(find.text('8월 12일 수요일'), findsOneWidget);
    expect(find.text('1개 수집'), findsOneWidget);
  });

  testWidgets('capture shows duration extraction before word matching',
      (tester) async {
    await tester.pumpWidget(const EngApp());
    await tester.tap(find.text('수집'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('소리 감지 시작'));
    await tester.pump();

    expect(find.text('소리의 길이를 기록하고 있어요'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pump();
    expect(find.text('반복되는 길이 패턴을 찾았어요'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump();
    expect(find.text('가까운 영어 음절을 찾는 중'), findsOneWidget);
    expect(find.text('LAUNDRY와 92% 가까워요'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pump();
    expect(find.text('새 리듬을 찾았어요!'), findsOneWidget);
  });

  testWidgets('word playback highlights syllables in sequence', (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (_) async => 1,
    );
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter_tts'), null);
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: WordDetailScreen(word: sampleWords.first),
      ),
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -520));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '발음과 진동 재생'));
    await tester.pump();
    var activeBlock = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('syllable-LAUN')),
    );
    expect((activeBlock.decoration! as BoxDecoration).color,
        sampleWords.first.color);

    await tester.pump(const Duration(milliseconds: 900));
    activeBlock = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('syllable-dry')),
    );
    expect((activeBlock.decoration! as BoxDecoration).color,
        sampleWords.first.color);

    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('detail card uses one duration bar per syllable and flips',
      (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: WordDetailScreen(word: sampleWords.first),
      ),
    );

    final pattern = tester.widget<SoundLengthPattern>(
      find.byType(SoundLengthPattern).first,
    );
    expect(pattern.lengths.length, sampleWords.first.syllables.length);
    expect(find.byKey(const ValueKey('word-card-front')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('word-flip-card')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('word-card-back')), findsOneWidget);
    expect(find.text(sampleWords.first.rhythmDescription), findsOneWidget);
    expect(find.text(sampleWords.first.exampleSentence), findsOneWidget);
  });
}
