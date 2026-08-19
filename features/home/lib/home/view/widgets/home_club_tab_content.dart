import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/theme/home_dashboard_theme.dart';
import 'package:module_route/route/route_path.dart';
import 'package:module_utils/module_utils.dart';

class HomeClubTabContent extends StatelessWidget {
  const HomeClubTabContent({super.key});

  static const _filters = ['最新', '嘉宾分享', '资料'];

  static const _posts = [
    _ClubPost(
      author: '莫听官方',
      avatar: 'https://picsum.photos/seed/club1/80/80',
      date: '06-24',
      content: '【官方纪要】本期聚焦 AI 算力与产业趋势，内容仅供合格投资者参考。',
      hasPdf: true,
      pdfName: '【莫听Club第78期】聊聊AI最靓的仔.pdf',
    ),
    _ClubPost(
      author: '策略研究员',
      avatar: 'https://picsum.photos/seed/club2/80/80',
      date: '06-20',
      content: '当星舰遇到算力：嘉宾分享回顾与延伸阅读。',
      hasPdf: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: HomeDashboardTheme.surface,
              borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
              border: Border.all(color: HomeDashboardTheme.separator, width: 0.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 52,
                      height: 52,
                      color: const Color(0xFF1C1C3A),
                      alignment: Alignment.center,
                      child: const Text(
                        'Club',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('莫听Club', style: HomeDashboardTheme.sectionTitle),
                        const SizedBox(height: 4),
                        Text(
                          '动态 127 | 成员 1040',
                          style: HomeDashboardTheme.sectionLabel,
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: HomeDashboardTheme.accent,
                    borderRadius: BorderRadius.circular(20),
                    onPressed: () => Get.toNamed(RoutePath.community),
                    child: const Text(
                      '+ 加入',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 24),
            itemBuilder: (context, index) {
              final active = index == 0;
              return Column(
                children: [
                  Text(
                    _filters[index],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active
                          ? HomeDashboardTheme.labelPrimary
                          : HomeDashboardTheme.labelSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: active ? 20 : 0,
                    height: 2,
                    color: HomeDashboardTheme.accent,
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        ..._posts.map((post) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _ClubPostCard(post: post),
            )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () => Get.toNamed(RoutePath.community),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: HomeDashboardTheme.surface,
                borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
                border: Border.all(color: HomeDashboardTheme.separator, width: 0.5),
              ),
              child: Center(
                child: Text(
                  '进入社区查看更多',
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
}

class _ClubPostCard extends StatelessWidget {
  const _ClubPostCard({required this.post});

  final _ClubPost post;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: HomeDashboardTheme.surface,
        borderRadius: BorderRadius.circular(HomeDashboardTheme.radiusMd),
        border: Border.all(color: HomeDashboardTheme.separator, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CacheImageUtils.circle(post.avatar, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.author, style: HomeDashboardTheme.sectionTitle.copyWith(fontSize: 15)),
                      Text(post.date, style: HomeDashboardTheme.sectionLabel),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.content, style: HomeDashboardTheme.sectionLabel.copyWith(
              color: HomeDashboardTheme.labelPrimary,
              fontSize: 15,
            )),
            if (post.hasPdf) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: HomeDashboardTheme.fillSecondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.doc_text, color: HomeDashboardTheme.accent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        post.pdfName!,
                        style: HomeDashboardTheme.sectionLabel.copyWith(
                          color: HomeDashboardTheme.labelPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _ActionIcon(icon: CupertinoIcons.arrowshape_turn_up_right, label: '分享'),
                const SizedBox(width: 20),
                _ActionIcon(icon: CupertinoIcons.chat_bubble, label: '评论'),
                const SizedBox(width: 20),
                _ActionIcon(icon: CupertinoIcons.heart, label: '点赞'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: HomeDashboardTheme.labelSecondary),
        const SizedBox(width: 4),
        Text(label, style: HomeDashboardTheme.sectionLabel),
      ],
    );
  }
}

class _ClubPost {
  const _ClubPost({
    required this.author,
    required this.avatar,
    required this.date,
    required this.content,
    this.hasPdf = false,
    this.pdfName,
  });

  final String author;
  final String avatar;
  final String date;
  final String content;
  final bool hasPdf;
  final String? pdfName;
}
