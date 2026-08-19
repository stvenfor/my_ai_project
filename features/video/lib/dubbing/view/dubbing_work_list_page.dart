import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_route/route/route_path.dart';
import 'package:module_video/dubbing/mock/dubbing_media_mock_data.dart';

class DubbingWorkListPage extends StatelessWidget {
  const DubbingWorkListPage({super.key});

  static const _background = Color(0xFFF5F5F5);
  static const _textGray = Color(0xFF8C8C8C);

  @override
  Widget build(BuildContext context) {
    final items = DubbingMediaMockData.works;

    return AppPageScaffold(
      backgroundColor: _background,
      navBar: AppNavBar(
        title: '作品列表',
        showBackButton: true,
        onBack: () => Get.back<void>(),
        backgroundColor: _background,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _WorkCard(
            item: item,
            onTap: () => Get.toNamed(
              RoutePath.dubbingWorkDetail,
              arguments: {'id': item.id},
            ),
          );
        },
      ),
    );
  }
}

class _WorkCard extends StatelessWidget {
  const _WorkCard({required this.item, required this.onTap});

  final DubbingWorkItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    item.coverUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: const Color(0xFFEEEEEE),
                      child: const Icon(Icons.play_circle_outline, size: 40),
                    ),
                  ),
                ),
                if (item.duration != null)
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.duration!,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                if (item.badge != null)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.badge == '精选' ? Colors.pink : Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.badge!,
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
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundImage: NetworkImage(item.authorAvatar),
                        onBackgroundImageError: (_, __) {},
                        child: const Text('', style: TextStyle(fontSize: 8)),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.authorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: DubbingWorkListPage._textGray),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.thumb_up_outlined, size: 12, color: DubbingWorkListPage._textGray),
                      const SizedBox(width: 2),
                      Text('${item.likeCount}', style: const TextStyle(fontSize: 11, color: DubbingWorkListPage._textGray)),
                      const SizedBox(width: 8),
                      const Icon(Icons.chat_bubble_outline, size: 12, color: DubbingWorkListPage._textGray),
                      const SizedBox(width: 2),
                      Text('${item.commentCount}', style: const TextStyle(fontSize: 11, color: DubbingWorkListPage._textGray)),
                    ],
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
