import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_home/home/controller/dubbing_home_controller.dart';
import 'package:module_home/home/model/dubbing_home_model.dart';
import 'package:module_home/home/theme/dubbing_home_theme.dart';
import 'package:module_home/home/view/widgets/dubbing_home/dubbing_home_section_header.dart';
import 'package:module_utils/module_utils.dart';

class DubbingHomeAlbumSelection extends GetView<DubbingHomeController> {
  const DubbingHomeAlbumSelection({
    super.key,
    required this.albums,
  });

  final List<DubbingHomeAlbumItem> albums;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DubbingHomeSectionHeader(
          title: '专属为你',
          subtitle: '根据你的学习兴趣为你推荐',
          style: DubbingSectionHeaderStyle.refresh,
        ),
        SizedBox(
          height: 196.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: albums.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final album = albums[index];
              return GestureDetector(
                onTap: () => controller.onAlbumTap(album),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 108.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(DubbingHomeTheme.thumbRadius.r),
                        child: Stack(
                          children: [
                            Image.asset(
                              DubbingHomeAssets.path(album.coverAsset),
                              package: DubbingHomeAssets.package,
                              width: 108.w,
                              height: 152.h,
                              fit: BoxFit.cover,
                            ),
                            if (index == 0)
                              Positioned(
                                top: 6.h,
                                right: 6.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B35),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    'New',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        album.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: DubbingHomeTheme.titleBlack,
                        ),
                      ),
                      if (album.episodeCount != null)
                        Text(
                          album.episodeCount!,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: DubbingHomeTheme.subtitleGray,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
