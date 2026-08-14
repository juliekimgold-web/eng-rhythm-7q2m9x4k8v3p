import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class EngLogo extends StatelessWidget {
  const EngLogo({super.key, this.compact = false, this.onDark = false});

  final bool compact;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final color = onDark ? Colors.white : AppColors.orange;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: compact ? 18 : 28, height: 3, color: color),
            Text(
              'ENG',
              style: TextStyle(
                color: color,
                fontSize: compact ? 22 : 30,
                fontWeight: FontWeight.w900,
                height: 0.9,
                letterSpacing: -1.8,
              ),
            ),
          ],
        ),
        if (!compact) ...[
          const SizedBox(height: 5),
          Text(
            'Dashing towards better English',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color.withValues(alpha: 0.82),
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
