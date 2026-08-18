import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class RhythmWave extends StatelessWidget {
  const RhythmWave({
    super.key,
    this.height = 54,
    this.color = AppColors.orange,
    this.bars = 24,
    this.emphasis = 0.62,
  });

  final double height;
  final Color color;
  final int bars;
  final double emphasis;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth =
              constraints.hasBoundedWidth ? constraints.maxWidth : bars * 6.0;
          final preferredGap = bars > 18 ? 3.0 : 5.0;
          final gap = math.min(
            preferredGap,
            availableWidth / math.max(1, bars * 3),
          );
          final barWidth = math.max(
            1.0,
            (availableWidth - gap * (bars - 1)) / bars,
          );
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(bars, (index) {
              final phase = index / math.max(1, bars - 1);
              final primary = math.sin(phase * math.pi * 3.1).abs();
              final envelope = 0.42 + math.sin(phase * math.pi).abs() * 0.58;
              final value = 0.18 + primary * envelope * emphasis;
              return Padding(
                padding: EdgeInsets.only(right: index == bars - 1 ? 0 : gap),
                child: SizedBox(
                  width: barWidth,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOutCubic,
                    height: math.max(6, height * value),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(barWidth),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class RhythmDots extends StatelessWidget {
  const RhythmDots({
    super.key,
    required this.count,
    required this.stressIndex,
    this.color = AppColors.orange,
  });

  final int count;
  final int stressIndex;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final stressed = index == stressIndex;
        return Container(
          width: stressed ? 24 : 12,
          height: stressed ? 5 : 3,
          margin: EdgeInsets.only(right: index == count - 1 ? 0 : 4),
          decoration: BoxDecoration(
            color: stressed ? color : color.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
