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
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          104,
        ),
        children: [
          _MyPageHeader(onOpenSettings: () => _showReadyMessage('앱 설정')),
          const SizedBox(height: AppSpacing.page),
          _ProfileCard(onEdit: () => _showReadyMessage('프로필 수정')),
          const SizedBox(height: AppSpacing.md),
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
          const SizedBox(height: AppSpacing.section),
          const _MySectionTitle(
            title: '학습 관리',
            caption: '매일 이어갈 리듬 목표와 알림을 관리해요.',
          ),
          const SizedBox(height: AppSpacing.sm),
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
                contentPadding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
                activeThumbColor: AppColors.orangeDark,
                activeTrackColor: AppColors.peach,
                secondary: const _SettingsIcon(
                  icon: Icons.notifications_none_rounded,
                ),
                value: _collectionReminder,
                onChanged: (value) =>
                    setState(() => _collectionReminder = value),
                title: const Text(
                  '수집 리마인더',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  '매일 오후 8시',
                  style: TextStyle(color: AppColors.inkSoft, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.section),
          const _MySectionTitle(
            title: '앱 관리',
            caption: '사용 환경과 서비스 정보를 확인해요.',
          ),
          const SizedBox(height: AppSpacing.sm),
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

class _MyPageHeader extends StatelessWidget {
  const _MyPageHeader({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('my-page-header'),
      children: [
        Expanded(
          child: Text(
            '마이',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 26,
                  letterSpacing: -.7,
                ),
          ),
        ),
        IconButton(
          onPressed: onOpenSettings,
          tooltip: '앱 설정',
          icon: const Icon(Icons.settings_outlined, size: 22),
          color: AppColors.ink,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            minimumSize: const Size.square(AppControlSize.minTouchTarget),
          ),
        ),
      ],
    );
  }
}

class _MySectionTitle extends StatelessWidget {
  const _MySectionTitle({required this.title, required this.caption});

  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          caption,
          style: const TextStyle(
            color: AppColors.inkSoft,
            fontSize: AppTypeScale.caption,
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.page),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.ink,
              shape: BoxShape.circle,
            ),
            child: const Text(
              '준',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: AppColors.orange,
                      size: 15,
                    ),
                    SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Rhythm Explorer · 5일 연속',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.inkSoft,
                          fontSize: AppTypeScale.caption,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.inkSoft,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
              minimumSize: const Size.square(AppControlSize.minTouchTarget),
            ),
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
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '이번 주 학습',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: AppTypeScale.bodyLarge,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Text(
                '목표의 71%',
                style: TextStyle(
                  color: AppColors.orangeDark,
                  fontSize: AppTypeScale.caption,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: const LinearProgressIndicator(
              value: .71,
              minHeight: 7,
              color: AppColors.orange,
              backgroundColor: AppColors.surfaceMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.page),
          Row(
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
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.inkSoft,
              fontSize: AppTypeScale.caption,
            ),
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
      elevation: 1,
      shadowColor: const Color(0x16000000),
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
      minTileHeight: 64,
      contentPadding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
      leading: _SettingsIcon(icon: icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
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

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.small),
      ),
      child: Icon(icon, color: AppColors.inkSoft, size: 20),
    );
  }
}
