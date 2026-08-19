import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_route/route/route_path.dart';
import 'package:module_video/dubbing/mock/dubbing_media_mock_data.dart';

class DubbingVideoListPage extends StatelessWidget {
  const DubbingVideoListPage({super.key});

  static const _primaryGreen = Color(0xFF52C41A);
  static const _background = Color(0xFFF5F5F5);
  static const _textGray = Color(0xFF8C8C8C);

  @override
  Widget build(BuildContext context) {
    final items = DubbingMediaMockData.videos;

    return AppPageScaffold(
      backgroundColor: _background,
      navBar: AppNavBar(
        title: '视频列表',
        showBackButton: true,
        onBack: () => Get.back<void>(),
        backgroundColor: _background,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return _VideoCard(
            item: item,
            onTap: () => Get.toNamed(
              RoutePath.dubbingVideoDetail,
              arguments: {'id': item.id},
            ),
          );
        },
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.item, required this.onTap});

  final DubbingVideoItem item;
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: Image.network(
                item.coverUrl,
                width: 120,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 120,
                  height: 90,
                  color: const Color(0xFFEEEEEE),
                  child: const Icon(Icons.movie, color: DubbingVideoListPage._textGray),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: item.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: tag.startsWith('难度') || tag == '合作'
                                ? DubbingVideoListPage._primaryGreen.withValues(alpha: 0.12)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10,
                              color: tag.startsWith('难度') || tag == '合作'
                                  ? DubbingVideoListPage._primaryGreen
                                  : DubbingVideoListPage._textGray,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.thumb_up_outlined, size: 14, color: DubbingVideoListPage._textGray),
                        const SizedBox(width: 4),
                        Text(
                          '${item.likeCount}',
                          style: const TextStyle(fontSize: 12, color: DubbingVideoListPage._textGray),
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right, size: 18, color: Color(0xFFBFBFBF)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
