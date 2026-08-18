import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../widgets/icon_tile.dart';
import '../widgets/rhythm_wave.dart';

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
        children: [
          Text('연동', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 7),
          const Text('ENG 디바이스와 연결하고 리듬 감각을 조절하세요.',
              style: TextStyle(color: AppColors.inkSoft)),
          const SizedBox(height: 24),
          _DeviceHero(connected: _connected),
          const SizedBox(height: 15),
          if (_connected)
            OutlinedButton.icon(
              onPressed: () => setState(() => _connected = false),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              icon: const Icon(Icons.link_off_rounded),
              label: const Text('연결 해제'),
            )
          else
            FilledButton.icon(
              onPressed: () => setState(() => _connected = true),
              icon: const Icon(Icons.bluetooth_searching_rounded),
              label: const Text('디바이스 찾기'),
            ),
          const SizedBox(height: 30),
          Text('리듬 설정', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 13),
          Card(
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
                            Text('진동 강도',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(height: 3),
                            Text('손에 편안하게 느껴지는 세기',
                                style: TextStyle(
                                    color: AppColors.inkSoft, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text(
                        '${(_vibration * 100).round()}%',
                        style: const TextStyle(
                            color: AppColors.orangeDark,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Slider(
                      value: _vibration,
                      onChanged: (value) => setState(() => _vibration = value)),
                  const Divider(height: 28),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _noiseFilter,
                    onChanged: (value) => setState(() => _noiseFilter = value),
                    title: const Text('주변 잡음 필터링',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('반복되는 핵심 소리만 분리해요'),
                  ),
                  const Divider(height: 18),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _autoPlay,
                    onChanged: (value) => setState(() => _autoPlay = value),
                    title: const Text('스캔 단어 자동 재생',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('발견한 단어에서 진동을 바로 재생해요'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _connected
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('진동 테스트: 약-강-약 패턴을 재생합니다.')),
                    );
                  }
                : null,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              side: const BorderSide(color: AppColors.line),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.control)),
            ),
            icon: const Icon(Icons.play_circle_outline_rounded),
            label: const Text('진동 패턴 테스트'),
          ),
          const SizedBox(height: 30),
          Text('디바이스 정보', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 13),
          const _InfoRow(
              label: '배터리', value: '82%', icon: Icons.battery_5_bar_rounded),
          const _InfoRow(
              label: '펌웨어', value: 'v1.4.2', icon: Icons.memory_rounded),
          const _InfoRow(
              label: '마지막 동기화', value: '방금 전', icon: Icons.sync_rounded),
        ],
      ),
    );
  }
}

class _DeviceHero extends StatelessWidget {
  const _DeviceHero({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 208,
                height: 116,
                decoration: BoxDecoration(
                  color: connected ? AppColors.orange : const Color(0xFF8A817A),
                  borderRadius: BorderRadius.circular(58),
                  border: Border.all(color: const Color(0xFFFFB477), width: 5),
                ),
              ),
              Container(
                width: 126,
                height: 78,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1B1A),
                  borderRadius: BorderRadius.circular(48),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: RhythmWave(
                    bars: 12,
                    height: 42,
                    color:
                        connected ? AppColors.orange : const Color(0xFF77706B),
                    emphasis: connected ? 0.82 : 0.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.circle,
                size: 9,
                color: connected
                    ? const Color(0xFF71E078)
                    : const Color(0xFF9E9690),
              ),
              const SizedBox(width: 7),
              Text(
                connected ? 'ENG Pocket · 연결됨' : '연결되지 않음',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            connected ? '리듬을 느낄 준비가 되었어요' : '가까운 디바이스를 찾아보세요',
            style: const TextStyle(color: AppColors.inkSoft, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.control),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.inkSoft),
          const SizedBox(width: 12),
          Text(label),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
