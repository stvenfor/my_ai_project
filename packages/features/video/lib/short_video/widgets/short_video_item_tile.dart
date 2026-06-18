import 'package:flutter/material.dart';
import 'package:module_utils/module_utils.dart';
import 'package:module_video/short_video/model/short_video_models.dart';

class ShortVideoItemTile extends StatelessWidget {
  const ShortVideoItemTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  final ShortVideoItemModel item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxWidth * item.aspectRatio;
        return SizedBox(
          height: height,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              borderRadius: BorderRadius.circular(8.r),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (item.coverUrl != null && item.coverUrl!.isNotEmpty)
                      CacheImageUtils.network(
                        item.coverUrl!,
                        fit: BoxFit.cover,
                      )
                    else
                      Container(
                        color: const Color(0xFF2A2A2A),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 48.sp,
                          color: Colors.white54,
                        ),
                      ),
                    if (item.status == ShortVideoStatus.uploading)
                      Container(
                        color: Colors.white.withValues(alpha: 0.55),
                        child: Center(
                          child: Icon(
                            Icons.refresh_rounded,
                            size: 36.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    if (item.status == ShortVideoStatus.reviewing)
                      Positioned(
                        left: 8.w,
                        top: 8.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            '审核中',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(8.w, 24.h, 8.w, 8.h),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xCC000000)],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.title ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.play_arrow_rounded,
                                  size: 14.sp,
                                  color: Colors.white70,
                                ),
                                Text(
                                  '${item.viewCount ?? 0}',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11.sp,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  item.duration ?? '',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
