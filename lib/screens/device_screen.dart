import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  var _connected = true;
  var _vibration = 0.68;
  var _autoPlay = true;

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
              Text(
                '연결 및 디바이스 설정',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _connected
                    ? 'ENG Rhythm Band가 정상적으로 연결되어 있어요.'
                    : '디바이스를 가까이 두고 다시 연결해 주세요.',
                style: const TextStyle(color: AppColors.inkSoft),
              ),
              const SizedBox(height: 20),
              if (_connected)
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() => _connected = false);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: .28),
                    ),
                  ),
                  icon: const Icon(Icons.link_off_rounded),
                  label: const Text('디바이스 연결 해제'),
                )
              else
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() => _connected = true);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.bluetooth_searching_rounded),
                  label: const Text('디바이스 다시 연결'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVibrationControl() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('진동 강도', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                const Text(
                  '손에 편안하게 느껴지는 세기로 조절하세요.',
                  style: TextStyle(color: AppColors.inkSoft),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Text('약하게'),
                    Expanded(
                      child: Slider(
                        value: _vibration,
                        onChanged: (value) {
                          setState(() => _vibration = value);
                          setModalState(() {});
                        },
                      ),
                    ),
                    const Text('강하게'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _vibrationLabel {
    if (_vibration < .4) return '약함';
    if (_vibration < .75) return '중간';
    return '강함';
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
            '연결 상태와 주요 설정을 한눈에 확인해요.',
            style: TextStyle(color: AppColors.inkSoft),
          ),
          const SizedBox(height: 20),
          _DeviceDashboardCard(
            connected: _connected,
            onManage: _showConnectionManager,
          ),
          const SizedBox(height: 28),
          Text('빠른 설정', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Material(
            key: const ValueKey('device-quick-settings'),
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.card),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _QuickSettingRow(
                  icon: Icons.vibration_rounded,
                  label: '진동 강도',
                  value: _vibrationLabel,
                  onTap: _showVibrationControl,
                ),
                const Divider(indent: 16, endIndent: 16),
                _QuickSettingRow(
                  icon: Icons.playlist_play_rounded,
                  label: '스캔 단어 자동 재생',
                  trailing: Switch.adaptive(
                    value: _autoPlay,
                    onChanged: (value) => setState(() => _autoPlay = value),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceDashboardCard extends StatelessWidget {
  const _DeviceDashboardCard({
    required this.connected,
    required this.onManage,
  });

  final bool connected;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('device-dashboard-card'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              key: const ValueKey('device-image-stage'),
              height: 156,
              color: AppColors.cream,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Image.asset(
                'assets/images/eng_device_complete.png',
                fit: BoxFit.fitWidth,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
                semanticLabel: '주황색 ENG Rhythm Band 디바이스 전체 이미지',
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              connected ? AppColors.success : AppColors.inkSoft,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          connected
                              ? 'ENG Rhythm Band 연결됨'
                              : 'ENG Rhythm Band 연결되지 않음',
                          style: TextStyle(
                            color: connected
                                ? AppColors.success
                                : AppColors.inkSoft,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: _DeviceMetric(value: '82%', label: '배터리'),
                          ),
                          VerticalDivider(),
                          Expanded(
                            child: _DeviceMetric(value: '좋음', label: '신호'),
                          ),
                          VerticalDivider(),
                          Expanded(
                            child: _DeviceMetric(value: '1.4.2', label: '펌웨어'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    key: const ValueKey('device-connection-manager'),
                    onPressed: onManage,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.ink,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.tune_rounded, size: 19),
                    label: const Text('연결 및 디바이스 설정'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceMetric extends StatelessWidget {
  const _DeviceMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(color: AppColors.inkSoft, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _QuickSettingRow extends StatelessWidget {
  const _QuickSettingRow({
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 58),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: AppColors.orange, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (value != null)
                Text(value!, style: const TextStyle(color: AppColors.inkSoft)),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
