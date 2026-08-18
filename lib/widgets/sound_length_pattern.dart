import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// A duration-first rhythm visual. Segment width represents how long a sound
/// lasts; unlike a waveform, height does not represent amplitude.
class SoundLengthPattern extends StatelessWidget {
  const SoundLengthPattern({
    super.key,
    required this.lengths,
    this.color = AppColors.orange,
    this.activeIndex = -1,
    this.emphasisIndex = -1,
    this.height = 12,
    this.gap = 6,
    this.muted = false,
    this.progress,
  });

  final List<double> lengths;
  final Color color;
  final int activeIndex;
  final int emphasisIndex;
  final double height;
  final double gap;
  final bool muted;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final playbackProgress = progress?.clamp(0.0, 1.0);
    return Semantics(
      label: '소리 길이 패턴',
      value: playbackProgress == null
          ? null
          : '${(playbackProgress * 100).round()}%',
      child: SizedBox(
        key: const ValueKey('sound-length-pattern'),
        height: height + 6,
        child: playbackProgress == null
            ? _SegmentRow(
                lengths: lengths,
                color: color,
                activeIndex: activeIndex,
                emphasisIndex: emphasisIndex,
                height: height,
                gap: gap,
                muted: muted,
              )
            : Stack(
                children: [
                  Positioned.fill(
                    child: _SegmentRow(
                      lengths: lengths,
                      color: color,
                      activeIndex: -1,
                      emphasisIndex: -1,
                      height: height,
                      gap: gap,
                      muted: true,
                      fixedAlpha: 0.18,
                    ),
                  ),
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final trailWidth = constraints.maxWidth * 0.28;
                        final head = constraints.maxWidth * playbackProgress;
                        return ShaderMask(
                          key: const ValueKey('rhythm-whoosh'),
                          blendMode: BlendMode.dstIn,
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0x24FFFFFF),
                                Color(0xB8FFFFFF),
                                Colors.white,
                                Colors.transparent,
                              ],
                              stops: [0, 0.28, 0.64, 0.86, 1],
                            ).createShader(
                              Rect.fromLTWH(
                                head - trailWidth,
                                0,
                                trailWidth * 1.16,
                                bounds.height,
                              ),
                            );
                          },
                          child: _SegmentRow(
                            lengths: lengths,
                            color: color,
                            activeIndex: -1,
                            emphasisIndex: -1,
                            height: height,
                            gap: gap,
                            muted: false,
                            fixedAlpha: 1,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SegmentRow extends StatelessWidget {
  const _SegmentRow({
    required this.lengths,
    required this.color,
    required this.activeIndex,
    required this.emphasisIndex,
    required this.height,
    required this.gap,
    required this.muted,
    this.fixedAlpha,
  });

  final List<double> lengths;
  final Color color;
  final int activeIndex;
  final int emphasisIndex;
  final double height;
  final double gap;
  final bool muted;
  final double? fixedAlpha;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(lengths.length, (index) {
        final active = index == activeIndex;
        final emphasized = index == emphasisIndex;
        final flex = (lengths[index] * 100).round().clamp(20, 180);
        final alpha = fixedAlpha ??
            (muted
                ? active
                    ? 0.8
                    : 0.22
                : active
                    ? 1.0
                    : activeIndex >= 0
                        ? 0.24
                        : emphasized
                            ? 0.96
                            : emphasisIndex >= 0
                                ? 0.34
                                : 0.72);
        return Expanded(
          flex: flex,
          child: Padding(
            padding: EdgeInsets.only(
              right: index == lengths.length - 1 ? 0 : gap,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: fixedAlpha == null && active ? height + 4 : height,
              decoration: BoxDecoration(
                color: color.withValues(alpha: alpha),
                borderRadius: BorderRadius.circular(AppRadii.small),
              ),
            ),
          ),
        );
      }),
    );
  }
}
