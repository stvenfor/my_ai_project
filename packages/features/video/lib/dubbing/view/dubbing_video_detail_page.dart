import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_video/dubbing/mock/dubbing_media_mock_data.dart';
import 'package:module_video/dubbing/widgets/playable_video_header.dart';

class DubbingVideoDetailPage extends StatefulWidget {
  const DubbingVideoDetailPage({super.key});

  @override
  State<DubbingVideoDetailPage> createState() => _DubbingVideoDetailPageState();
}

class _DubbingVideoDetailPageState extends State<DubbingVideoDetailPage> {
  static const _primaryGreen = Color(0xFF52C41A);
  static const _textGray = Color(0xFF8C8C8C);
  static const _titleBlack = Color(0xFF1A1A1A);

  var _descExpanded = false;
  var _selectedPartIndex = 0;

  @override
  Widget build(BuildContext context) {
    final id = DubbingMediaMockData.resolveId(Get.arguments);
    final item = DubbingMediaMockData.findVideoById(id);
    if (item == null) {
      return AppPageScaffold(
        navBar: AppNavBar(title: '视频详情', showBackButton: true, onBack: Get.back),
        body: const Center(child: Text('视频不存在')),
      );
    }

    return VideoPlaybackImmersiveScope(
      child: AppPageScaffold(
        layout: AppPageLayout.edgeToEdge,
        backgroundColor: Colors.white,
        body: Column(
          children: [
            PlayableVideoHeader(
              videoUrl: item.videoUrl,
              subtitleEn: item.subtitleEn,
              subtitleZh: item.subtitleZh,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  _TitleSection(item: item),
                  _TagsSection(tags: item.tags),
                  _DescriptionSection(
                    desc: item.desc,
                    expanded: _descExpanded,
                    onToggle: () => setState(() => _descExpanded = !_descExpanded),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  _UploaderSection(name: item.uploaderName),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  _AlbumSection(
                    item: item,
                    selectedIndex: _selectedPartIndex,
                    onPartSelected: (i) => setState(() => _selectedPartIndex = i),
                  ),
                  const Divider(height: 12, color: Color(0xFFF5F5F5), thickness: 8),
                  _LatestWorksSection(avatars: item.latestWorkAvatars),
                  const Divider(height: 12, color: Color(0xFFF5F5F5), thickness: 8),
                  if (item.leaderboard != null)
                    _LeaderboardSection(entry: item.leaderboard!),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _DubbingBottomBar(
          onFavorite: () => UiKitInitializer.toast('已收藏'),
          onShare: () => UiKitInitializer.toast('分享（开发中）'),
          onStartDubbing: () => UiKitInitializer.toast('开启配音（开发中）'),
        ),
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection({required this.item});

  final DubbingVideoItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _DubbingVideoDetailPageState._titleBlack,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              const Icon(Icons.thumb_up, color: Color(0xFFE85D5D), size: 22),
              Text(
                '${item.likeCount}',
                style: const TextStyle(fontSize: 12, color: _DubbingVideoDetailPageState._textGray),
              ),
              const SizedBox(height: 8),
              const Icon(Icons.thumb_down_outlined, color: _DubbingVideoDetailPageState._textGray, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class _TagsSection extends StatelessWidget {
  const _TagsSection({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: tags.map((tag) {
          final isGreen = tag == '合作' || tag.startsWith('难度') || tag == '漫威' || tag == '经典大片' || tag == '超级英雄';
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isGreen
                  ? _DubbingVideoDetailPageState._primaryGreen.withValues(alpha: 0.12)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 11,
                color: isGreen
                    ? _DubbingVideoDetailPageState._primaryGreen
                    : _DubbingVideoDetailPageState._textGray,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({
    required this.desc,
    required this.expanded,
    required this.onToggle,
  });

  final String desc;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: GestureDetector(
        onTap: onToggle,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                desc,
                maxLines: expanded ? null : 1,
                overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: _DubbingVideoDetailPageState._textGray),
              ),
            ),
            Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 18,
              color: _DubbingVideoDetailPageState._textGray,
            ),
          ],
        ),
      ),
    );
  }
}

class _UploaderSection extends StatelessWidget {
  const _UploaderSection({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFE8F8E8),
            child: Text('趣', style: TextStyle(color: _DubbingVideoDetailPageState._primaryGreen, fontSize: 14)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '上传者 $name',
              style: const TextStyle(fontSize: 14, color: _DubbingVideoDetailPageState._titleBlack),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4EC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.card_giftcard, size: 14, color: Colors.pink),
                SizedBox(width: 4),
                Text('打赏', style: TextStyle(fontSize: 13, color: Colors.pink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlbumSection extends StatelessWidget {
  const _AlbumSection({
    required this.item,
    required this.selectedIndex,
    required this.onPartSelected,
  });

  final DubbingVideoItem item;
  final int selectedIndex;
  final ValueChanged<int> onPartSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '视频专辑 (${item.albumCount})',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Icon(Icons.chevron_right, size: 18, color: _DubbingVideoDetailPageState._textGray),
              const Spacer(),
              Text(
                '+ 添加学习计划',
                style: TextStyle(fontSize: 13, color: _DubbingVideoDetailPageState._primaryGreen),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 108,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: item.albumParts.length,
              itemBuilder: (context, index) {
                final part = item.albumParts[index];
                final selected = index == selectedIndex;
                return GestureDetector(
                  onTap: () => onPartSelected(index),
                  child: Container(
                    width: 148,
                    margin: EdgeInsets.only(right: index == item.albumParts.length - 1 ? 0 : 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? _DubbingVideoDetailPageState._primaryGreen
                            : const Color(0xFFEEEEEE),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Part ${index + 1}',
                              style: const TextStyle(fontSize: 11, color: _DubbingVideoDetailPageState._textGray),
                            ),
                            if (part.badge != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: part.badge == '试听'
                                      ? _DubbingVideoDetailPageState._primaryGreen.withValues(alpha: 0.12)
                                      : const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  part.badge!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: part.badge == '试听'
                                        ? _DubbingVideoDetailPageState._primaryGreen
                                        : const Color(0xFFFF8A34),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          part.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LatestWorksSection extends StatelessWidget {
  const _LatestWorksSection({required this.avatars});

  final List<String> avatars;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('最新作品', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              Icon(Icons.chevron_right, size: 18, color: _DubbingVideoDetailPageState._textGray),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: avatars.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(avatars[index]),
                  onBackgroundImageError: (_, __) {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardSection extends StatelessWidget {
  const _LeaderboardSection({required this.entry});

  final DubbingLeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('点赞榜', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('🥇', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(entry.avatarUrl),
                    onBackgroundImageError: (_, __) {},
                  ),
                  Positioned(
                    right: -4,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD54F),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        entry.level,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.userName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${entry.date} · ${entry.location}',
                      style: const TextStyle(fontSize: 12, color: _DubbingVideoDetailPageState._textGray),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.favorite, color: Color(0xFFE85D5D), size: 18),
              const SizedBox(width: 4),
              Text(
                entry.likeCount >= 10000
                    ? '${(entry.likeCount / 10000).toStringAsFixed(1)}万'
                    : '${entry.likeCount}',
                style: const TextStyle(fontSize: 13, color: _DubbingVideoDetailPageState._textGray),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 底部操作条：白底延伸至安全区底部。
class _DubbingBottomBar extends StatelessWidget {
  const _DubbingBottomBar({
    required this.onFavorite,
    required this.onShare,
    required this.onStartDubbing,
  });

  final VoidCallback onFavorite;
  final VoidCallback onShare;
  final VoidCallback onStartDubbing;

  @override
  Widget build(BuildContext context) {
    final bottomInset = AppSafeInsets.bottom(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottomInset),
      child: Row(
        children: [
          _BottomAction(
            icon: Icons.star_border,
            label: '收藏',
            onTap: onFavorite,
          ),
          const SizedBox(width: 20),
          _BottomAction(
            icon: Icons.share_outlined,
            label: '分享',
            onTap: onShare,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: onStartDubbing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _DubbingVideoDetailPageState._primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '开启配音',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: _DubbingVideoDetailPageState._titleBlack),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: _DubbingVideoDetailPageState._textGray),
          ),
        ],
      ),
    );
  }
}
