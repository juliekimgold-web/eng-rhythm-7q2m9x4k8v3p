import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../widgets/icon_tile.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  var _connected = true;
  var _vibration = 0.68;
  var _noiseFilter = true;
  var _autoPlay = true;

  void _playVibrationTest() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('진동 테스트: 약-강-약 패턴을 재생합니다.')),
    );
  }

  void _showConnectionManager() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('연결 관리', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text(
                'ENG Rhythm Band가 정상적으로 연결되어 있어요.',
                style: TextStyle(color: AppColors.inkSoft),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() => _connected = false);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side:
                      BorderSide(color: AppColors.error.withValues(alpha: .3)),
                ),
                icon: const Icon(Icons.link_off_rounded),
                label: const Text('디바이스 연결 해제'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 104),
        children: [
          Text('연동', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 7),
          const Text(
            'ENG 디바이스와 연결하고 리듬 감각을 조절하세요.',
            style: TextStyle(color: AppColors.inkSoft),
          ),
          const SizedBox(height: 22),
          _DeviceJourneyHero(connected: _connected),
          const SizedBox(height: 26),
          Text('연결 준비', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _ConnectionSteps(connected: _connected),
          const SizedBox(height: 12),
          if (_connected)
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: FilledButton.icon(
                    key: const ValueKey('device-vibration-test'),
                    onPressed: _playVibrationTest,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.vibration_rounded),
                    label: const Text('진동으로 확인'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextButton.icon(
                    key: const ValueKey('device-connection-manager'),
                    onPressed: _showConnectionManager,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.orangeDark,
                      backgroundColor: AppColors.cream,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.tune_rounded),
                    label: const Text('연결 관리'),
                  ),
                ),
              ],
            )
          else
            FilledButton.icon(
              onPressed: () => setState(() => _connected = true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.bluetooth_searching_rounded),
              label: const Text('디바이스 찾기'),
            ),
          const SizedBox(height: 30),
          Text('리듬 설정', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 13),
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.card),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      const IconTile(icon: Icons.vibration_rounded),
                      const SizedBox(width: 13),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '진동 강도',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 3),
                            Text(
                              '손에 편안하게 느껴지는 세기',
                              style: TextStyle(
                                color: AppColors.inkSoft,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${(_vibration * 100).round()}%',
                        style: const TextStyle(
                          color: AppColors.orangeDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Slider(
                    value: _vibration,
                    onChanged: (value) => setState(() => _vibration = value),
                  ),
                  const Divider(height: 28),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _noiseFilter,
                    onChanged: (value) => setState(() => _noiseFilter = value),
                    title: const Text(
                      '주변 잡음 필터링',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('반복되는 핵심 소리만 분리해요'),
                  ),
                  const Divider(height: 18),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _autoPlay,
                    onChanged: (value) => setState(() => _autoPlay = value),
                    title: const Text(
                      '스캔 단어 자동 재생',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('발견한 단어에서 진동을 바로 재생해요'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text('디바이스 정보', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 13),
          const _InfoRow(
            label: '배터리',
            value: '82%',
            icon: Icons.battery_5_bar_rounded,
          ),
          const _InfoRow(
            label: '펌웨어',
            value: 'v1.4.2',
            icon: Icons.memory_rounded,
          ),
          const _InfoRow(
            label: '마지막 동기화',
            value: '방금 전',
            icon: Icons.sync_rounded,
          ),
        ],
      ),
    );
  }
}

class _DeviceJourneyHero extends StatelessWidget {
  const _DeviceJourneyHero({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('device-journey-hero'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ConnectionStatus(connected: connected),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .72),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  connected ? '배터리 82%' : '연결 대기',
                  style: const TextStyle(
                    color: AppColors.inkSoft,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 124,
            child: Image.asset(
              'assets/images/eng_device.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              semanticLabel: '주황색 ENG Rhythm Band 디바이스',
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'ENG Rhythm Band',
            style: TextStyle(
              fontSize: 23,
              height: 1.18,
              fontWeight: FontWeight.w700,
              letterSpacing: -.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            connected ? '가까운 거리 · 신호 좋음 · 펌웨어 1.4.2' : '디바이스를 가까이 두고 연결해 보세요.',
            style: const TextStyle(
              color: AppColors.inkSoft,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionStatus extends StatelessWidget {
  const _ConnectionStatus({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    final color = connected ? const Color(0xFF2BA66F) : AppColors.inkSoft;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(
          connected ? '연결됨' : '연결되지 않음',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ConnectionSteps extends StatelessWidget {
  const _ConnectionSteps({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ConnectionStep(
            label: '디바이스 찾기',
            number: 1,
            done: connected,
            current: !connected,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _ConnectionStep(
            label: 'Bluetooth 연결',
            number: 2,
            done: connected,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _ConnectionStep(
            label: '감각 확인',
            number: 3,
            current: connected,
            icon: Icons.vibration_rounded,
          ),
        ),
      ],
    );
  }
}

class _ConnectionStep extends StatelessWidget {
  const _ConnectionStep({
    required this.label,
    required this.number,
    this.done = false,
    this.current = false,
    this.icon,
  });

  final String label;
  final int number;
  final bool done;
  final bool current;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final accent = done ? const Color(0xFF2BA66F) : AppColors.orangeDark;

    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.fromLTRB(10, 10, 8, 9),
      decoration: BoxDecoration(
        color: current ? AppColors.cream : AppColors.surface,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: done
                ? Icon(Icons.check_rounded, color: accent, size: 16)
                : icon != null
                    ? Icon(icon, color: accent, size: 15)
                    : Text(
                        '$number',
                        style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.control),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.orangeDark),
          const SizedBox(width: 12),
          Text(label),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
