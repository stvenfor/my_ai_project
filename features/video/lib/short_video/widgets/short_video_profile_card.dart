import 'package:flutter/material.dart';
import 'package:module_utils/module_utils.dart';
import 'package:module_video/short_video/model/short_video_models.dart';

class ShortVideoProfileCard extends StatelessWidget {
  const ShortVideoProfileCard({super.key, required this.profile});

  final ShortVideoProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _UserInfo(profile: profile)),
              CacheImageUtils.circle(profile.avatarUrl ?? '', size: 48.r),
            ],
          ),
          SizedBox(height: 16.h),
          _StatsRow(stats: profile.stats),
        ],
      ),
    );
  }
}

class _UserInfo extends StatelessWidget {
  const _UserInfo({required this.profile});

  final ShortVideoProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                profile.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1890FF),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                profile.roleBadge,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.storefront_outlined, size: 16.sp, color: Colors.grey.shade500),
          ],
        ),
        SizedBox(height: 6.h),
        Text(
          profile.storeName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final ShortVideoStatsModel stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      (stats.videoCount, '视频数'),
      (stats.viewCount, '浏览量'),
      (stats.likeCount, '点赞数'),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Container(
              width: 1,
              height: 28.h,
              color: const Color(0xFFE8E8E8),
            ),
          Expanded(
            child: Column(
              children: [
                Text(
                  items[i].$1,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  items[i].$2,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
