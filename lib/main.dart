import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'core/theme/app_theme.dart';
import 'data/sample_data.dart';
import 'repositories/word_repository.dart';

void main() {
  runApp(const EngApp());
}

class EngApp extends StatefulWidget {
  const EngApp({super.key});

  @override
  State<EngApp> createState() => _EngAppState();
}

class _EngAppState extends State<EngApp> {
  late final WordRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = WordRepository(sampleWords);
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '-ENG',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AppShell(repository: _repository),
    );
  }
}
