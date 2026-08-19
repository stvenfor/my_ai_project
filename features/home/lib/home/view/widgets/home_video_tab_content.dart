import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/theme/home_dashboard_theme.dart';
import 'package:module_route/route/route_path.dart';
import 'package:module_utils/module_utils.dart';

class HomeVideoTabContent extends StatelessWidget {
  const HomeVideoTabContent({super.key});

  static const _shortcuts = [
    _Shortcut('会员专享', CupertinoIcons.play_rectangle, Color(0xFF007AFF)),
    _Shortcut('配音专栏', CupertinoIcons.book, Color(0xFFFF9500)),
    _Shortcut('其他课程', CupertinoIcons.folder, Color(0xFF5856D6)),
    _Shortcut('功能教程', CupertinoIcons.pencil, Color(0xFF34C759)),
  ];

  static const _dailyItems = [
    _VideoItem('带你玩转 ETF', '直播中', 'https://picsum.photos/seed/v1/120/120'),
    _VideoItem('新能源赛道解读', '回放', 'https://picsum.photos/seed/v2/120/120'),
    _VideoItem('门店短视频运营', '直播中', 'https://picsum.photos/seed/v3/120/120'),
  ];

  static const _courses = [
    _CourseItem(
      '【配置】当星舰撞上算力',
      '尤国梁',
      'https://picsum.photos/seed/c1/400/240',
      true,
    ),
    _CourseItem(
      '黄金恐贪定投实战',
      '策略组',
      'https://picsum.photos/seed/c2/400/240',
      false,
      isMember: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShortcutRow(),
        _buildSection(
          title: '每日推荐',
          trailing: '更多',
          child: Column(
            children: _dailyItems
                .map((item) => _DailyRecommendTile(item: item))
                .toList(),
          ),
        ),
        _buildSection(
          title: '热门课程',
          trailing: '更多',
          child: SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _courses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _HotCourseCard(course: _courses[index]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: GestureDetector(
            onTap: () => Get.toNamed(RoutePath.homeDubbingFeed),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: HomeDashboardTheme.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
                border: Border.all(
                  color: HomeDashboardTheme.accent.withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: Text(
                  '进入配音视频专区',
                  style: TextStyle(
                    color: HomeDashboardTheme.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: _shortcuts
            .map(
              (s) => Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: s.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(s.icon, color: s.color, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.label,
                      style: HomeDashboardTheme.sectionLabel.copyWith(
                        color: HomeDashboardTheme.labelPrimary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String trailing,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: HomeDashboardTheme.sectionTitle),
              ),
              Text(
                '$trailing >',
                style: HomeDashboardTheme.sectionLabel.copyWith(
                  color: HomeDashboardTheme.labelSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DailyRecommendTile extends StatelessWidget {
  const _DailyRecommendTile({required this.item});

  final _VideoItem item;

  @override
  Widget build(BuildContext context) {
    final isLive = item.tag == '直播中';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HomeDashboardTheme.surface,
        borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
        border: Border.all(color: HomeDashboardTheme.separator, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isLive
                  ? const Color(0x14FF3B30)
                  : HomeDashboardTheme.fillSecondary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              item.tag,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isLive
                    ? const Color(0xFFFF3B30)
                    : HomeDashboardTheme.labelSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.title,
              style: HomeDashboardTheme.sectionTitle.copyWith(fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CacheImageUtils.network(
              item.avatarUrl,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class _HotCourseCard extends StatelessWidget {
  const _HotCourseCard({required this.course});

  final _CourseItem course;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: HomeDashboardTheme.surface,
          borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
          border: Border.all(color: HomeDashboardTheme.separator, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CacheImageUtils.network(
                    course.coverUrl,
                    width: 168,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      course.isLive ? '直播中' : '回放',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: HomeDashboardTheme.sectionTitle.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(course.author, style: HomeDashboardTheme.sectionLabel),
                  if (course.isMember) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0x14FF9500),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'V 会员专属',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFFF9500),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Shortcut {
  const _Shortcut(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

class _VideoItem {
  const _VideoItem(this.title, this.tag, this.avatarUrl);
  final String title;
  final String tag;
  final String avatarUrl;
}

class _CourseItem {
  const _CourseItem(this.title, this.author, this.coverUrl, this.isLive,
      {this.isMember = true});
  final String title;
  final String author;
  final String coverUrl;
  final bool isLive;
  final bool isMember;
}
