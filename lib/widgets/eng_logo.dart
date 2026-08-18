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
          width: compact ? 19 : 26,
          height: compact ? 3 : 3.5,
          color: onDark ? Colors.white : AppColors.orange,
        ),
        Text(
          'ENG',
          style: TextStyle(
            color: onDark ? Colors.white : AppColors.orange,
            fontSize: compact ? 29 : 36,
            fontWeight: FontWeight.w900,
            height: 0.9,
            letterSpacing: compact ? -2.6 : -3.2,
          ),
        ),
      ],
    );

    return SizedBox(
      key: ValueKey(onDark ? 'eng-logo-on-dark' : 'eng-logo'),
      height: compact ? 44 : null,
      child: Align(
        alignment: Alignment.centerLeft,
        child: mark,
      ),
    );
  }
}
