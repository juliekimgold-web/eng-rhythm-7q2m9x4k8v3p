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
          : _FloatingNavigationBar(
              currentIndex: _index,
              onTap: _setIndex,
            ),
    );
  }
}

class _FloatingNavigationBar extends StatelessWidget {
  const _FloatingNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _destinations = <({String label, _NavIconData icon})>[
    (label: '홈', icon: _NavIconData.home),
    (label: '연동', icon: _NavIconData.connection),
    (label: '라이브러리', icon: _NavIconData.library),
    (label: '스캔', icon: _NavIconData.scan),
    (label: '마이', icon: _NavIconData.profile),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Container(
          key: const ValueKey('floating-navigation-dock'),
          height: 66,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            border: Border.all(color: AppColors.line.withValues(alpha: 0.85)),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x16000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(21),
            child: Row(
              children: [
                for (var index = 0; index < _destinations.length; index++)
                  Expanded(
                    child: _FloatingNavigationItem(
                      label: _destinations[index].label,
                      icon: _destinations[index].icon,
                      selected: currentIndex == index,
                      onTap: () => onTap(index),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingNavigationItem extends StatelessWidget {
  const _FloatingNavigationItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final _NavIconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.orange : AppColors.inkSoft;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        overlayColor: WidgetStatePropertyAll(
          AppColors.orange.withValues(alpha: 0.07),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: AppMotion.base,
                curve: Curves.easeOutCubic,
                width: 36,
                height: 28,
                decoration: BoxDecoration(
                  color: selected ? AppColors.cream : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.center,
                child: _ThinNavigationIcon(icon: icon, color: color),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: AppMotion.base,
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  color: color,
                  fontFamily: 'Pretendard',
                  fontSize: AppTypeScale.navigation,
                  height: 1.18,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: -0.05,
                ),
                child: Text(label, maxLines: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _NavIconData { home, connection, library, scan, profile }

class _ThinNavigationIcon extends StatelessWidget {
  const _ThinNavigationIcon({required this.icon, required this.color});

  final _NavIconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(21),
      painter: _ThinNavigationIconPainter(icon: icon, color: color),
    );
  }
}

class _ThinNavigationIconPainter extends CustomPainter {
  const _ThinNavigationIconPainter({required this.icon, required this.color});

  final _NavIconData icon;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.55
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();

    switch (icon) {
      case _NavIconData.home:
        path
          ..moveTo(2.5, 9.5)
          ..lineTo(10.5, 2.7)
          ..lineTo(18.5, 9.5)
          ..moveTo(4.5, 8.2)
          ..lineTo(4.5, 18.2)
          ..lineTo(16.5, 18.2)
          ..lineTo(16.5, 8.2)
          ..moveTo(8.2, 18.2)
          ..lineTo(8.2, 12.5)
          ..lineTo(12.8, 12.5)
          ..lineTo(12.8, 18.2);
        canvas.drawPath(path, paint);
        break;
      case _NavIconData.connection:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(2.5, 3.2, 16, 13.5),
            const Radius.circular(2),
          ),
          paint,
        );
        canvas.drawCircle(const Offset(5, 18.4), 0.7, paint);
        canvas.drawArc(
          const Rect.fromLTWH(3.4, 14.9, 5.1, 5.1),
          -1.57,
          1.57,
          false,
          paint,
        );
        canvas.drawArc(
          const Rect.fromLTWH(3.4, 12.3, 8, 8),
          -1.57,
          1.57,
          false,
          paint,
        );
        break;
      case _NavIconData.library:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(4, 2.5, 13, 16),
            const Radius.circular(2),
          ),
          paint,
        );
        path
          ..moveTo(7.2, 2.5)
          ..lineTo(7.2, 18.5)
          ..moveTo(9.8, 6.4)
          ..lineTo(14.3, 6.4)
          ..moveTo(9.8, 10)
          ..lineTo(14.3, 10);
        canvas.drawPath(path, paint);
        break;
      case _NavIconData.scan:
        path
          ..moveTo(7.3, 3)
          ..lineTo(3, 3)
          ..lineTo(3, 7.3)
          ..moveTo(13.7, 3)
          ..lineTo(18, 3)
          ..lineTo(18, 7.3)
          ..moveTo(18, 13.7)
          ..lineTo(18, 18)
          ..lineTo(13.7, 18)
          ..moveTo(7.3, 18)
          ..lineTo(3, 18)
          ..lineTo(3, 13.7)
          ..moveTo(6.5, 10.5)
          ..lineTo(14.5, 10.5);
        canvas.drawPath(path, paint);
        break;
      case _NavIconData.profile:
        canvas.drawCircle(const Offset(10.5, 7), 3.4, paint);
        canvas.drawArc(
          const Rect.fromLTWH(3.7, 11.4, 13.6, 8.2),
          3.3,
          2.83,
          false,
          paint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(_ThinNavigationIconPainter oldDelegate) {
    return icon != oldDelegate.icon || color != oldDelegate.color;
  }
}
