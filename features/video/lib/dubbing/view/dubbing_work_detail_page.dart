import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_video/dubbing/mock/dubbing_media_mock_data.dart';
import 'package:module_video/dubbing/widgets/playable_video_header.dart';

class DubbingWorkDetailPage extends StatefulWidget {
  const DubbingWorkDetailPage({super.key});

  @override
  State<DubbingWorkDetailPage> createState() => _DubbingWorkDetailPageState();
}

class _DubbingWorkDetailPageState extends State<DubbingWorkDetailPage>
    with SingleTickerProviderStateMixin {
  static const _primaryGreen = Color(0xFF52C41A);
  static const _textGray = Color(0xFF8C8C8C);

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = DubbingMediaMockData.resolveId(Get.arguments);
    final item = DubbingMediaMockData.findWorkById(id);
    if (item == null) {
      return AppPageScaffold(
        navBar: AppNavBar(title: '作品详情', showBackButton: true, onBack: Get.back),
        body: const Center(child: Text('作品不存在')),
      );
    }

    final moreWorks = DubbingMediaMockData.works.where((w) => w.id != item.id).take(2).toList();

    return VideoPlaybackImmersiveScope(
      child: AppPageScaffold(
        layout: AppPageLayout.edgeToEdge,
        backgroundColor: const Color(0xFFF5F5F5),
        body: Column(
        children: [
          PlayableVideoHeader(videoUrl: item.videoUrl),
          Material(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: _primaryGreen,
              unselectedLabelColor: _textGray,
              indicatorColor: _primaryGreen,
              tabs: [
                const Tab(text: '简介'),
                Tab(text: '评论 ${item.commentCount}'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _IntroTab(item: item, moreWorks: moreWorks),
                const _CommentsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        likeCount: item.likeCount,
        onStartDubbing: () => UiKitInitializer.toast('开启配音（开发中）'),
      ),
      ),
    );
  }
}

class _IntroTab extends StatelessWidget {
  const _IntroTab({required this.item, required this.moreWorks});

  final DubbingWorkItem item;
  final List<DubbingWorkItem> moreWorks;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(item.authorAvatar),
              onBackgroundImageError: (_, __) {},
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.authorName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${item.location} · 粉丝1.5K',
                    style: const TextStyle(fontSize: 12, color: _DubbingWorkDetailPageState._textGray),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: _DubbingWorkDetailPageState._primaryGreen,
                side: const BorderSide(color: _DubbingWorkDetailPageState._primaryGreen),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('已关注', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.badge != null)
              Container(
                margin: const EdgeInsets.only(right: 6, top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.pink.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(item.badge!, style: const TextStyle(fontSize: 10, color: Colors.pink)),
              ),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${item.publishedAt} 12:09',
          style: const TextStyle(fontSize: 12, color: _DubbingWorkDetailPageState._textGray),
        ),
        const SizedBox(height: 16),
        const Text('99+ 人也配了这个视频', style: TextStyle(fontSize: 13, color: _DubbingWorkDetailPageState._textGray)),
        const SizedBox(height: 20),
        const Text('Ta的更多作品', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...moreWorks.map((w) => _MoreWorkRow(work: w)),
      ],
    );
  }
}

class _MoreWorkRow extends StatelessWidget {
  const _MoreWorkRow({required this.work});

  final DubbingWorkItem work;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              work.coverUrl,
              width: 80,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 56,
                color: const Color(0xFFEEEEEE),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (work.badge != null)
                  Text(work.badge!, style: const TextStyle(fontSize: 10, color: Colors.orange)),
                Text(
                  work.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.thumb_up_outlined, size: 12, color: _DubbingWorkDetailPageState._textGray),
                    Text(' ${work.likeCount}', style: const TextStyle(fontSize: 11, color: _DubbingWorkDetailPageState._textGray)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentsTab extends StatelessWidget {
  const _CommentsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: CircleAvatar(child: Text('B')),
          title: Text('乌克丽丽'),
          subtitle: Text('发音标准，继续加油'),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.likeCount, required this.onStartDubbing});

  final int likeCount;
  final VoidCallback onStartDubbing;

  @override
  Widget build(BuildContext context) {
    final bottomInset = AppSafeInsets.bottom(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottomInset),
      child: Row(
        children: [
          const Icon(Icons.thumb_up_outlined, size: 22),
          const SizedBox(width: 4),
          Text('$likeCount', style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 16),
          const Icon(Icons.share_outlined, size: 22),
          const SizedBox(width: 4),
          const Text('分享', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: onStartDubbing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _DubbingWorkDetailPageState._primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                child: const Text('开启配音', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
