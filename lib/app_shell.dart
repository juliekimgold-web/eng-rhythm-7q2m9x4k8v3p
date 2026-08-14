import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'repositories/word_repository.dart';
import 'screens/capture_screen.dart';
import 'screens/device_screen.dart';
import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/my_page_screen.dart';
import 'screens/scan_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.repository});

  final WordRepository repository;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  bool _scanImmersive = false;

  late final List<Widget> _pages = [
    HomeScreen(
      repository: widget.repository,
      onStartCapture: _openCapture,
      onOpenLibrary: () => _setIndex(2),
      onOpenProfile: () => _setIndex(4),
    ),
    const DeviceScreen(),
    LibraryScreen(repository: widget.repository),
    ScanScreen(
      repository: widget.repository,
      onImmersiveChanged: (active) {
        if (mounted) setState(() => _scanImmersive = active);
      },
    ),
    MyPageScreen(repository: widget.repository),
  ];

  void _setIndex(int index) => setState(() => _index = index);

  void _openCapture() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CaptureScreen(repository: widget.repository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: _scanImmersive
          ? null
          : DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: SafeArea(
                top: false,
                child: BottomNavigationBar(
                  currentIndex: _index,
                  onTap: _setIndex,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  selectedItemColor: AppColors.orangeDark,
                  unselectedItemColor: AppColors.inkSoft,
                  selectedFontSize: 10,
                  unselectedFontSize: 10,
                  iconSize: 27,
                  selectedLabelStyle:
                      const TextStyle(fontWeight: FontWeight.w700),
                  unselectedLabelStyle:
                      const TextStyle(fontWeight: FontWeight.w500),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home_rounded),
                      label: '홈',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.cast_outlined),
                      activeIcon: Icon(Icons.cast_connected_rounded),
                      label: '연동',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.assignment_outlined),
                      activeIcon: Icon(Icons.assignment_rounded),
                      label: '라이브러리',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.crop_free_rounded),
                      activeIcon: Icon(Icons.center_focus_strong_rounded),
                      label: '스캔',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline_rounded),
                      activeIcon: Icon(Icons.person_rounded),
                      label: '마이',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
