import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_classroom/data/classroom_mock_data.dart';
import 'package:module_classroom/model/classroom_models.dart';
import 'package:module_classroom/theme/classroom_theme.dart';
import 'package:module_classroom/view/widgets/dubbing_settings_sheet.dart';
import 'package:module_common_ui/module_common_ui.dart';

class VideoDetailPage extends StatefulWidget {
  const VideoDetailPage({super.key});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPartIndex = 0;

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

  Future<void> _showDubbingSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DubbingSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parts = ClassroomMockData.videoAlbumParts;

    return AppPageScaffold(
      layout: AppPageLayout.edgeToEdge,
      backgroundColor: ClassroomColors.background,
      body: Column(
        children: [
          _VideoHeader(onBack: () => Get.back<void>()),
          TabBar(
            controller: _tabController,
            labelColor: ClassroomColors.primaryGreen,
            unselectedLabelColor: ClassroomColors.textGray,
            indicatorColor: ClassroomColors.primaryGreen,
            tabs: const [
              Tab(text: '简介'),
              Tab(text: '评论 22'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _IntroTab(
                  parts: parts,
                  selectedIndex: _selectedPartIndex,
                  onPartSelected: (i) => setState(() => _selectedPartIndex = i),
                ),
                const _CommentsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(onStartDubbing: _showDubbingSettings),
    );
  }
}

class _VideoHeader extends StatelessWidget {
  const _VideoHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 220,
          width: double.infinity,
          color: Colors.black87,
          child: const Center(
            child: Icon(Icons.play_circle_fill, size: 64, color: Colors.white54),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ClassroomMockData.videoTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'It\'s said they can accelerate faster than a Ferrari.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Text(
                '据说他们能比法拉利更快地加速',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IntroTab extends StatelessWidget {
  const _IntroTab({
    required this.parts,
    required this.selectedIndex,
    required this.onPartSelected,
  });

  final List<VideoAlbumPart> parts;
  final int selectedIndex;
  final ValueChanged<int> onPartSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Icon(Icons.thumb_up_outlined, size: 18),
            const SizedBox(width: 4),
            const Text('3983'),
            const SizedBox(width: 16),
            const Icon(Icons.thumb_down_outlined, size: 18),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _Tag(label: '合作', color: ClassroomColors.primaryGreen),
            _Tag(label: '10句'),
            _Tag(label: '难度 PreA1'),
            _Tag(label: '漫威'),
            _Tag(label: '经典大片'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const CircleAvatar(radius: 16, child: Text('趣')),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                '上传者 小趣友宁Sir',
                style: TextStyle(fontSize: 13),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4EC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('打赏', style: TextStyle(fontSize: 12, color: Colors.pink)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '视频专辑 (20)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            Text(
              '+ 添加学习计划',
              style: TextStyle(fontSize: 13, color: ClassroomColors.primaryGreen),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: parts.length,
            itemBuilder: (context, index) {
              final part = parts[index];
              final selected = index == selectedIndex;
              return GestureDetector(
                onTap: () => onPartSelected(index),
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selected
                          ? ClassroomColors.primaryGreen
                          : ClassroomColors.divider,
                      width: selected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (part.badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: part.badge == '试听'
                                ? ClassroomColors.primaryGreenLight
                                : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            part.badge!,
                            style: TextStyle(
                              fontSize: 10,
                              color: part.badge == '试听'
                                  ? ClassroomColors.primaryGreen
                                  : ClassroomColors.orange,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Text(
                        part.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '点赞榜',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _LeaderboardItem(),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color?.withValues(alpha: 0.15) ?? ClassroomColors.background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color ?? ClassroomColors.textGray,
        ),
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('🥇', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        const CircleAvatar(radius: 18, child: Text('美')),
        const SizedBox(width: 8),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('美诺明年夏天见', style: TextStyle(fontSize: 13)),
              Text(
                '2020-11-03 · 杭州市',
                style: TextStyle(fontSize: 11, color: ClassroomColors.textGray),
              ),
            ],
          ),
        ),
        const Icon(Icons.thumb_up, color: Colors.red, size: 16),
        const Text(' 1.1万', style: TextStyle(fontSize: 12)),
      ],
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
          leading: CircleAvatar(child: Text('A')),
          title: Text('评论用户A'),
          subtitle: Text('配音很棒！'),
        ),
        ListTile(
          leading: CircleAvatar(child: Text('B')),
          title: Text('评论用户B'),
          subtitle: Text('发音标准，继续加油'),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onStartDubbing});

  final VoidCallback onStartDubbing;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.star_border, size: 22),
            const SizedBox(width: 4),
            const Text('收藏', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 16),
            const Icon(Icons.share_outlined, size: 22),
            const SizedBox(width: 4),
            const Text('分享', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: onStartDubbing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ClassroomColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  '开启配音',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
