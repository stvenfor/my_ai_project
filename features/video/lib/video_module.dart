import 'package:flutter/material.dart';
import 'package:wys_router/src/module/feature_module.dart';
import 'package:wys_router/src/route/route_path.dart';
import 'package:module_video/dubbing/view/dubbing_video_detail_page.dart';
import 'package:module_video/dubbing/view/dubbing_video_list_page.dart';
import 'package:module_video/dubbing/view/dubbing_work_detail_page.dart';
import 'package:module_video/dubbing/view/dubbing_work_list_page.dart';
import 'package:module_video/short_video/view/short_video_page.dart';
import 'package:module_video/short_video/view/short_video_play_page.dart';
import 'package:module_video/videos/view/video_page.dart';

class VideoModule extends FeatureModule {
  @override
  String get moduleId => 'video';

  @override
  Map<String, WidgetBuilder> routes() => {
        RoutePath.video: (_) => const VideoPage(),
        RoutePath.shortVideo: (_) => const ShortVideoPage(),
        RoutePath.shortVideoPlay: shortVideoPlayPageBuilder,
        RoutePath.dubbingVideoList: (_) => const DubbingVideoListPage(),
        RoutePath.dubbingVideoDetail: (_) => const DubbingVideoDetailPage(),
        RoutePath.dubbingWorkList: (_) => const DubbingWorkListPage(),
        RoutePath.dubbingWorkDetail: (_) => const DubbingWorkDetailPage(),
      };
}
