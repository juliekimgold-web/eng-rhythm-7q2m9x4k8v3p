import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const EngApp());
}

class EngApp extends StatelessWidget {
  const EngApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '-ENG',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppShell(),
    );
  }
}
