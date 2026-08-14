import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../repositories/word_repository.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key, required this.repository});

  final WordRepository repository;

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  var _collectionReminder = true;

  void _showReadyMessage(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title 기능을 준비하고 있어요.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
        children: [
          Text('마이', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 7),
          const Text(
            '나의 영어 리듬 기록과 앱 설정을 관리해요.',
            style: TextStyle(color: AppColors.inkSoft),
          ),
          const SizedBox(height: 24),
          _ProfileCard(onEdit: () => _showReadyMessage('프로필 수정')),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: widget.repository,
            builder: (context, _) {
              final favoriteCount = widget.repository.words
                  .where((word) => word.isFavorite)
                  .length;
              return _ActivitySummary(
                wordCount: widget.repository.words.length,
                favoriteCount: favoriteCount,
              );
            },
          ),
          const SizedBox(height: 30),
          Text('학습 관리', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _SettingsGroup(
            children: [
              _MenuTile(
                icon: Icons.track_changes_outlined,
                title: '나의 학습 목표',
                subtitle: '하루 3개 리듬 수집',
                onTap: () => _showReadyMessage('학습 목표'),
              ),
              const Divider(height: 1, indent: 64, color: AppColors.line),
              SwitchListTile.adaptive(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                activeThumbColor: AppColors.orangeDark,
                activeTrackColor: AppColors.peach,
                secondary: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.inkSoft,
                ),
                value: _collectionReminder,
                onChanged: (value) =>
                    setState(() => _collectionReminder = value),
                title: const Text(
                  '수집 리마인더',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  '매일 오후 8시',
                  style: TextStyle(color: AppColors.inkSoft, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text('앱 관리', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _SettingsGroup(
            children: [
              _MenuTile(
                icon: Icons.tune_rounded,
                title: '앱 설정',
                onTap: () => _showReadyMessage('앱 설정'),
              ),
              const Divider(height: 1, indent: 64, color: AppColors.line),
              _MenuTile(
                icon: Icons.help_outline_rounded,
                title: '도움말',
                onTap: () => _showReadyMessage('도움말'),
              ),
              const Divider(height: 1, indent: 64, color: AppColors.line),
              _MenuTile(
                icon: Icons.info_outline_rounded,
                title: '서비스 정보',
                trailing: const Text(
                  'v1.0.0',
                  style: TextStyle(color: AppColors.inkSoft, fontSize: 12),
                ),
                onTap: () => _showReadyMessage('서비스 정보'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.cream,
              border: Border.all(color: AppColors.peach),
              shape: BoxShape.circle,
            ),
            child: const Text(
              '준',
              style: TextStyle(
                color: AppColors.orangeDark,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '김준희',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 4),
                Text(
                  'Rhythm Explorer',
                  style: TextStyle(color: AppColors.inkSoft, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.inkSoft,
          ),
        ],
      ),
    );
  }
}

class _ActivitySummary extends StatelessWidget {
  const _ActivitySummary({
    required this.wordCount,
    required this.favoriteCount,
  });

  final int wordCount;
  final int favoriteCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('my-activity-summary'),
      padding: const EdgeInsets.symmetric(vertical: 19),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        children: [
          _StatItem(value: '$wordCount', label: '수집한 단어'),
          const SizedBox(
            height: 42,
            child: VerticalDivider(color: AppColors.line),
          ),
          const _StatItem(value: '5일', label: '연속 수집'),
          const SizedBox(
            height: 42,
            child: VerticalDivider(color: AppColors.line),
          ),
          _StatItem(value: '$favoriteCount', label: '즐겨찾기'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.inkSoft, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      leading: Icon(icon, color: AppColors.inkSoft),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: const TextStyle(color: AppColors.inkSoft, fontSize: 12),
            ),
      trailing: trailing ??
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.inkSoft,
          ),
      onTap: onTap,
    );
  }
}
