import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    this.backgroundColor = AppColors.cream,
    this.iconColor = AppColors.orange,
    this.size = 40,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.small),
      ),
      child: Icon(icon, color: iconColor, size: size * 0.5),
    );
  }
}
