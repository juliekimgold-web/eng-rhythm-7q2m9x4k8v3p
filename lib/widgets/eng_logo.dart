import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class EngLogo extends StatelessWidget {
  const EngLogo({super.key, this.compact = false, this.onDark = false});

  final bool compact;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final mark = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 12 : 26,
          height: compact ? 2.5 : 3.5,
          color: Colors.white,
        ),
        Text(
          'ENG',
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 21 : 36,
            fontWeight: FontWeight.w900,
            height: 0.9,
            letterSpacing: compact ? -2.1 : -3.2,
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onDark)
          mark
        else
          ShaderMask(
            key: const ValueKey('eng-logo-gradient'),
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0x1AFFB982),
                Color(0xFFFFA04C),
                AppColors.orange,
                Color(0xFFFF6467),
              ],
              stops: [0, 0.27, 0.62, 1],
            ).createShader(bounds),
            child: mark,
          ),
      ],
    );
  }
}
