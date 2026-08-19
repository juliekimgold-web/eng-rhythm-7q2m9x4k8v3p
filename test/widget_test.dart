import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dash_eng/core/theme/app_theme.dart';
import 'package:dash_eng/controllers/capture_controller.dart';
import 'package:dash_eng/data/sample_data.dart';
import 'package:dash_eng/main.dart';
import 'package:dash_eng/repositories/word_repository.dart';
import 'package:dash_eng/screens/word_detail_screen.dart';
import 'package:dash_eng/widgets/sound_length_pattern.dart';

void main() {
  test('word repository owns favorite state and exposes immutable results', () {
    final repository = WordRepository(sampleWords);
    final laundry = repository.findById('laundry')!;

    repository.toggleFavorite(laundry.id);

    expect(repository.findById('laundry')!.isFavorite, isFalse);
    expect(() => repository.words.add(laundry), throwsUnsupportedError);
  });

  test('capture controller advances through explicit stages', () async {
    final waits = <Completer<void>>[];
    final controller = CaptureController(delay: (_) {
      final wait = Completer<void>();
      waits.add(wait);
      return wait.future;
    });
    addTearDown(controller.dispose);

    final capture = controller.start();
    expect(controller.stage, CaptureStage.listening);

    waits.removeAt(0).complete();
    await Future<void>.delayed(Duration.zero);
    expect(controller.stage, CaptureStage.pattern);

    waits.removeAt(0).complete();
    await Future<void>.delayed(Duration.zero);
    expect(controller.stage, CaptureStage.matching);

    waits.removeAt(0).complete();
    await capture;
    expect(controller.stage, CaptureStage.result);
  });

  testWidgets('renders the primary navigation and opens library',
      (tester) async {
    await tester.pumpWidget(const EngApp());

    expect(find.byKey(const ValueKey('eng-logo')), findsWidgets);
    expect(find.text('Dashing towards better English'), findsNothing);
    expect(find.text('새 리듬 수집하기'), findsOneWidget);
    expect(find.text('말하기 · 발음 분석'), findsOneWidget);
    expect(find.text('연동'), findsOneWidget);
    expect(find.text('라이브러리'), findsOneWidget);
    expect(find.text('스캔'), findsOneWidget);
    expect(find.text('마이'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('floating-navigation-dock')),
      findsOneWidget,
    );

    await tester.tap(find.text('라이브러리'));
    await tester.pumpAndSettle();

    expect(find.text('수집한 단어'), findsOneWidget);
    expect(find.text('Laundry'), findsOneWidget);
  });

  testWidgets('home opens speaking practice as a direct secondary action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EngApp());

    expect(
      find.widgetWithText(FilledButton, '새 리듬 수집하기').hitTestable(),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(OutlinedButton, '말하기 · 발음 분석').hitTestable(),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('home-speak-practice')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('speak-practice-sheet')), findsOneWidget);
    expect(find.bySemanticsLabel('말하기 시작'), findsOneWidget);
  });

  testWidgets('home profile control opens the signed-in user page',
      (tester) async {
    await tester.pumpWidget(const EngApp());

    await tester.tap(find.text('김준희'));
    await tester.pumpAndSettle();

    expect(find.text('나의 영어 리듬 기록과 앱 설정을 관리해요.'), findsOneWidget);
    expect(find.text('Rhythm Explorer'), findsOneWidget);
  });

  testWidgets('opens connection and my pages from the new navigation',
      (tester) async {
    await tester.pumpWidget(const EngApp());

    await tester.tap(find.text('연동'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('eng-logo')), findsNothing);
    expect(find.text('ENG 디바이스와 연결하고 리듬 감각을 조절하세요.'), findsOneWidget);

    await tester.tap(find.text('마이'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('eng-logo')), findsNothing);
    expect(find.text('나의 영어 리듬 기록과 앱 설정을 관리해요.'), findsOneWidget);
    expect(find.text('김준희'), findsOneWidget);
    expect(find.text('학습 관리'), findsOneWidget);

    final summary = tester.widget<Container>(
      find.byKey(const ValueKey('my-activity-summary')),
    );
    expect((summary.decoration! as BoxDecoration).color, isNot(AppColors.ink));
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
    expect(find.byKey(const ValueKey('lens-empty-workspace')), findsOneWidget);
    expect(find.byKey(const ValueKey('lens-import-camera')), findsOneWidget);
    expect(find.byKey(const ValueKey('lens-import-photo')), findsOneWidget);
    expect(find.byKey(const ValueKey('lens-import-file')), findsOneWidget);
    expect(find.textContaining('돋보기처럼'), findsOneWidget);
    expect(find.textContaining('부착'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lens mode advances through recognition setup and live scan',
      (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EngApp());
    await tester.tap(find.text('스캔'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('lens-import-photo')));
    await tester.pump();
    expect(find.byKey(const ValueKey('lens-importing')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();
    expect(find.byKey(const ValueKey('lens-content-loaded')), findsOneWidget);
    expect(find.text('인식된 단어 3'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(
      tester.getSize(find.byKey(const ValueKey('lens-document'))).width,
      greaterThanOrEqualTo(360),
    );
    final highlightedWord = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('lens-highlight-everyday')),
    );
    expect(
      (highlightedWord.decoration! as BoxDecoration).borderRadius,
      isNotNull,
    );

    await tester.ensureVisible(find.byKey(const ValueKey('lens-open-setup')));
    await tester.tap(find.byKey(const ValueKey('lens-open-setup')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('lens-device-setup')), findsOneWidget);
    expect(find.textContaining('손으로 잡고'), findsOneWidget);
    expect(find.textContaining('부착'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('lens-ready-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('lens-scan-ready')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('lens-start-live')));
    await tester.tap(find.byKey(const ValueKey('lens-start-live')));
    await tester.pump();
    expect(find.byKey(const ValueKey('lens-live-scan')), findsOneWidget);
    expect(find.text('스캔 중'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 4900));
    final movingTop = tester
        .widget<Positioned>(find.byKey(const ValueKey('lens-scan-line')))
        .top!;
    await tester.pump(const Duration(milliseconds: 200));
    final pausedTop = tester
        .widget<Positioned>(find.byKey(const ValueKey('lens-scan-line')))
        .top!;
    expect(pausedTop, greaterThan(movingTop));

    await tester.pump(const Duration(milliseconds: 250));
    final heldTop = tester
        .widget<Positioned>(find.byKey(const ValueKey('lens-scan-line')))
        .top!;
    expect(heldTop, pausedTop);
    expect(find.text('everyday'), findsWidgets);
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

  testWidgets('library filters use centered mobile tap targets',
      (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EngApp());
    await tester.tap(find.text('라이브러리'));
    await tester.pumpAndSettle();

    final tab = find.byKey(const ValueKey('library-filter-전체'));
    final visual = find.byKey(const ValueKey('library-filter-visual-전체'));
    final label = find.descendant(of: tab, matching: find.text('전체'));

    expect(tester.getSize(tab).height, AppControlSize.compactHeight);
    expect(
      tester.getSize(visual).height,
      AppControlSize.compactVisualHeight,
    );
    expect(
      (tester.getCenter(tab).dy - tester.getCenter(label).dy).abs(),
      lessThan(1),
    );
    expect(Theme.of(tester.element(tab)).hoverColor, Colors.transparent);

    final laundry = tester.widget<SoundLengthPattern>(
      find.byKey(const ValueKey('library-rhythm-laundry')),
    );
    final everyday = tester.widget<SoundLengthPattern>(
      find.byKey(const ValueKey('library-rhythm-everyday')),
    );
    expect(laundry.color, AppColors.yellow);
    expect(everyday.color, AppColors.lavender);
    expect(laundry.color, isNot(everyday.color));
  });

  testWidgets('capture shows duration extraction before word matching',
      (tester) async {
    await tester.pumpWidget(const EngApp());
    await tester.tap(find.text('새 리듬 수집하기'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('eng-logo')), findsNothing);
    await tester.ensureVisible(find.text('소리 감지 시작'));
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
        home: WordDetailScreen(
          word: sampleWords.first,
          repository: WordRepository(sampleWords),
        ),
      ),
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -520));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '발음과 진동 재생'));
    await tester.pump();
    var activeSyllable = tester.widget<AnimatedDefaultTextStyle>(
      find.byKey(const ValueKey('syllable-laun')),
    );
    expect(activeSyllable.style.color, sampleWords.first.color);
    expect(find.byKey(const ValueKey('rhythm-whoosh')), findsOneWidget);
    expect(
      tester.widget(find.byKey(const ValueKey('rhythm-whoosh'))),
      isA<ShaderMask>(),
    );

    await tester.pump(const Duration(milliseconds: 260));
    final firstProgress = tester
        .widget<SoundLengthPattern>(find.byType(SoundLengthPattern).first)
        .progress!;
    expect(firstProgress, allOf(greaterThan(0), lessThan(1)));

    await tester.pump(const Duration(milliseconds: 120));
    final nextProgress = tester
        .widget<SoundLengthPattern>(find.byType(SoundLengthPattern).first)
        .progress!;
    expect(nextProgress, greaterThan(firstProgress));
    final syllableBoundary = sampleWords.first.syllableDurations.first /
        sampleWords.first.syllableDurations.reduce((a, b) => a + b);
    expect(nextProgress, lessThan(syllableBoundary));

    await tester.pump(const Duration(milliseconds: 520));
    activeSyllable = tester.widget<AnimatedDefaultTextStyle>(
      find.byKey(const ValueKey('syllable-dree')),
    );
    expect(activeSyllable.style.color, sampleWords.first.color);
    final secondSyllableProgress = tester
        .widget<SoundLengthPattern>(find.byType(SoundLengthPattern).first)
        .progress!;
    expect(secondSyllableProgress, greaterThanOrEqualTo(syllableBoundary));

    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('detail card uses one duration bar per syllable and flips',
      (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = WordRepository(sampleWords);
    final wasFavorite = repository.findById('laundry')!.isFavorite;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: WordDetailScreen(
          word: sampleWords.first,
          repository: repository,
        ),
      ),
    );

    final pattern = tester.widget<SoundLengthPattern>(
      find.byType(SoundLengthPattern).first,
    );
    expect(pattern.lengths.length, sampleWords.first.syllables.length);
    final cardSize = tester.getSize(
      find.byKey(const ValueKey('word-card-laundry')),
    );
    final rhythmBarSize = tester.getSize(find.byType(SoundLengthPattern).first);
    expect(cardSize.height, inInclusiveRange(470, 520));
    expect(rhythmBarSize.width, lessThan(cardSize.width * 0.8));
    expect(find.byKey(const ValueKey('word-card-front')), findsOneWidget);
    expect(find.byKey(const ValueKey('favorite-laundry')), findsOneWidget);
    expect(find.byKey(const ValueKey('card-play-laundry')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('favorite-laundry')));
    await tester.pump();
    expect(repository.findById('laundry')!.isFavorite, isNot(wasFavorite));
    expect(find.byKey(const ValueKey('word-card-front')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('word-flip-card')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('word-card-back')), findsOneWidget);
    expect(find.text(sampleWords.first.rhythmDescription), findsOneWidget);
    expect(find.text(sampleWords.first.exampleSentence), findsOneWidget);
  });

  testWidgets('detail card lifts on swipe and reveals the control sheet',
      (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: WordDetailScreen(
          word: sampleWords.first,
          repository: WordRepository(sampleWords),
        ),
      ),
    );

    expect(find.text('1 / 6  ·  좌우로 넘겨 다음 단어 보기'), findsOneWidget);
    expect(find.text('위로 밀어 리듬 조정'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, '발음과 진동 재생').hitTestable(),
      findsNothing,
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('word-card-page-view'))),
      kind: PointerDeviceKind.mouse,
    );
    await gesture.moveBy(const Offset(-40, 0));
    await tester.pump(const Duration(milliseconds: 16));
    await gesture.moveBy(const Offset(-180, 0));
    await tester.pump(const Duration(milliseconds: 16));

    final outgoingCard = tester.widget<Transform>(
      find.byKey(const ValueKey('swipe-transform-laundry')),
    );
    expect(outgoingCard.transform.getTranslation().y, lessThan(0));
    final outgoingRotation = tester.widget<Transform>(
      find.byKey(const ValueKey('swipe-rotation-laundry')),
    );
    expect(outgoingRotation.transform.storage[1].abs(), greaterThan(0));

    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('2 / 6  ·  좌우로 넘겨 다음 단어 보기'), findsOneWidget);

    await tester.dragFrom(
      tester.getCenter(find.byKey(const ValueKey('rhythm-sheet-handle'))),
      const Offset(0, -96),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();
    final sheetScale = tester.widget<AnimatedScale>(
      find.byKey(const ValueKey('detail-card-sheet-scale')),
    );
    expect(sheetScale.scale, 0.88);
    expect(find.byKey(const ValueKey('rhythm-control-sheet')), findsOneWidget);
    expect(
      find.text('리듬 조정').hitTestable(),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(FilledButton, '발음과 진동 재생').hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('speak practice uses a calm timer state without waveform',
      (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: WordDetailScreen(
          word: sampleWords.first,
          repository: WordRepository(sampleWords),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('rhythm-sheet-handle')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, '말해보기'));
    await tester.pumpAndSettle();
    final practiceSheetSize = tester.getSize(
      find.byKey(const ValueKey('speak-practice-sheet')),
    );
    expect(practiceSheetSize.width, 400);
    expect(practiceSheetSize.height, inInclusiveRange(420, 500));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('speak-practice-sheet')),
        matching: find.text('말해보기'),
      ),
      findsNothing,
    );
    await tester.tap(find.bySemanticsLabel('말하기 시작'));
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('녹음 중'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('speak-practice-sheet')),
        matching: find.byType(SoundLengthPattern),
      ),
      findsNothing,
    );

    await tester.tap(find.bySemanticsLabel('녹음 종료'));
    await tester.pump();
    expect(find.text('말하기가 끝났어요'), findsOneWidget);
    expect(
      find.widgetWithText(OutlinedButton, '내 발음 듣기'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(OutlinedButton, '원어민 발음'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(FilledButton, '다시 말해보기'),
      findsOneWidget,
    );
  });
}
