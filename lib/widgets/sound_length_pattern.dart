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
  });

  final List<double> lengths;
  final Color color;
  final int activeIndex;
  final int emphasisIndex;
  final double height;
  final double gap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '소리 길이 패턴',
      child: SizedBox(
        key: const ValueKey('sound-length-pattern'),
        height: height + 6,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(lengths.length, (index) {
            final active = index == activeIndex;
            final emphasized = index == emphasisIndex;
            final flex = (lengths[index] * 100).round().clamp(20, 180);
            return Expanded(
              flex: flex,
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == lengths.length - 1 ? 0 : gap,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  height: active ? height + 4 : height,
                  decoration: BoxDecoration(
                    color: muted
                        ? color.withValues(alpha: active ? 0.8 : 0.22)
                        : color.withValues(
                            alpha: active
                                ? 1
                                : activeIndex >= 0
                                    ? 0.24
                                    : emphasized
                                        ? 0.96
                                        : emphasisIndex >= 0
                                            ? 0.34
                                            : 0.72,
                          ),
                    borderRadius: BorderRadius.circular(AppRadii.small),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.24),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
