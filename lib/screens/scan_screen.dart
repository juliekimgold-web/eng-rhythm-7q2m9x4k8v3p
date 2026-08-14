import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../widgets/eng_logo.dart';
import '../widgets/icon_tile.dart';
import '../widgets/sound_length_pattern.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  var _scanned = false;
  var _playingWord = '';

  Future<void> _scan() async {
    setState(() => _scanned = false);
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (mounted) setState(() => _scanned = true);
  }

  Future<void> _play(String word) async {
    setState(() => _playingWord = word);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (mounted && _playingWord == word) setState(() => _playingWord = '');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
            sliver: SliverList.list(
              children: [
                Row(
                  children: [
                    const EngLogo(compact: true),
                    const Spacer(),
                    IconButton.filledTonal(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('갤러리에서 이미지를 불러옵니다.')),
                        );
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.orangeDark,
                        side: const BorderSide(color: AppColors.line),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.small),
                        ),
                      ),
                      icon: const Icon(Icons.photo_library_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text('텍스트 스캔',
                    style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 7),
                const Text(
                  '읽던 문장 속에서 수집한 리듬을 다시 만나보세요.',
                  style: TextStyle(color: AppColors.inkSoft),
                ),
                const SizedBox(height: 24),
                _ScannerPreview(scanned: _scanned),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _scan,
                  icon: Icon(_scanned
                      ? Icons.refresh_rounded
                      : Icons.document_scanner_rounded),
                  label: Text(_scanned ? '다시 스캔하기' : '텍스트 스캔 시작'),
                ),
                if (_scanned) ...[
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Text('발견한 단어',
                          style: Theme.of(context).textTheme.titleLarge),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(AppRadii.small),
                        ),
                        child: const Text(
                          '3개',
                          style: TextStyle(
                              color: AppColors.orangeDark,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  _ScanResultCard(
                    word: 'Everyday',
                    rhythm: 'EV · ry · day',
                    color: AppColors.lavender,
                    playing: _playingWord == 'Everyday',
                    onPlay: () => _play('Everyday'),
                  ),
                  const SizedBox(height: 11),
                  _ScanResultCard(
                    word: 'Really',
                    rhythm: 'RE · ally',
                    color: AppColors.blue,
                    playing: _playingWord == 'Really',
                    onPlay: () => _play('Really'),
                  ),
                  const SizedBox(height: 11),
                  _ScanResultCard(
                    word: 'Together',
                    rhythm: 'to · GE · ther',
                    color: AppColors.coral,
                    playing: _playingWord == 'Together',
                    onPlay: () => _play('Together'),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(AppRadii.card),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.sensors_rounded, color: AppColors.orange),
                        SizedBox(width: 13),
                        Expanded(
                          child: Text(
                            '단어를 누르면 발음과 진동이 동시에 재생됩니다.',
                            style: TextStyle(color: Colors.white, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerPreview extends StatelessWidget {
  const _ScannerPreview({required this.scanned});

  final bool scanned;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      height: 350,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: scanned ? Colors.white : const Color(0xFFEEEAE7),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
            color: scanned ? AppColors.orange : AppColors.line,
            width: scanned ? 1.5 : 1),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: scanned ? 1 : 0.52,
              child: _ArticleSample(highlighted: scanned),
            ),
          ),
          if (!scanned)
            Positioned.fill(
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 17, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.ink.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(AppRadii.small),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.center_focus_strong_rounded,
                          color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '텍스트를 프레임에 맞춰주세요',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ..._corners(scanned ? AppColors.orange : Colors.white),
        ],
      ),
    );
  }

  List<Widget> _corners(Color color) {
    Widget corner({required Alignment alignment, required Border border}) {
      return Align(
        alignment: alignment,
        child: Container(
            width: 28, height: 28, decoration: BoxDecoration(border: border)),
      );
    }

    return [
      corner(
        alignment: Alignment.topLeft,
        border: Border(
            top: BorderSide(color: color, width: 3),
            left: BorderSide(color: color, width: 3)),
      ),
      corner(
        alignment: Alignment.topRight,
        border: Border(
            top: BorderSide(color: color, width: 3),
            right: BorderSide(color: color, width: 3)),
      ),
      corner(
        alignment: Alignment.bottomLeft,
        border: Border(
            bottom: BorderSide(color: color, width: 3),
            left: BorderSide(color: color, width: 3)),
      ),
      corner(
        alignment: Alignment.bottomRight,
        border: Border(
            bottom: BorderSide(color: color, width: 3),
            right: BorderSide(color: color, width: 3)),
      ),
    ];
  }
}

class _ArticleSample extends StatelessWidget {
  const _ArticleSample({required this.highlighted});

  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    TextSpan hit(String text, Color color) {
      return TextSpan(
        text: text,
        style: TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w800,
          backgroundColor:
              highlighted ? color.withValues(alpha: 0.45) : Colors.transparent,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'A BETTER WAY TO SPEAK',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4),
          ),
          const SizedBox(height: 14),
          const Text(
            'Finding your own rhythm',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w900, height: 1.1),
          ),
          const SizedBox(height: 17),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 280,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: AppColors.inkSoft,
                      fontSize: 15,
                      height: 1.75,
                    ),
                    children: [
                      const TextSpan(text: 'We speak '),
                      hit('everyday', AppColors.lavender),
                      const TextSpan(
                        text:
                            ', but we do not always listen to the patterns around us. A familiar sound can ',
                      ),
                      hit('really', AppColors.blue),
                      const TextSpan(
                        text:
                            ' change how a word feels. When sound and movement work ',
                      ),
                      hit('together', AppColors.coral),
                      const TextSpan(
                        text: ', a new rhythm becomes easier to remember.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('12', style: TextStyle(fontSize: 11)),
              ),
              Expanded(child: Divider()),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScanResultCard extends StatelessWidget {
  const _ScanResultCard({
    required this.word,
    required this.rhythm,
    required this.color,
    required this.playing,
    required this.onPlay,
  });

  final String word;
  final String rhythm;
  final Color color;
  final bool playing;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final lengths = rhythm
        .split('·')
        .map((part) => part.trim().length.clamp(1, 5).toDouble())
        .toList();
    return Card(
      color: Color.alphaBlend(color.withValues(alpha: 0.09), Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
      ),
      child: InkWell(
        onTap: onPlay,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              IconTile(
                icon: playing
                    ? Icons.graphic_eq_rounded
                    : Icons.volume_up_rounded,
                backgroundColor: AppColors.surfaceMuted,
                iconColor: color,
                size: 46,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(word, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(rhythm,
                        style: const TextStyle(color: AppColors.inkSoft)),
                  ],
                ),
              ),
              SizedBox(
                width: 66,
                child: SoundLengthPattern(
                  lengths: lengths,
                  color: color,
                  activeIndex: playing ? 0 : -1,
                  height: 8,
                  gap: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
