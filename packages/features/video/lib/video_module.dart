import 'package:flutter/material.dart';
import 'package:module_route/module/feature_module.dart';
import 'package:module_route/route/route_path.dart';
import 'package:module_video/videos/view/video_page.dart';

class VideoModule extends FeatureModule {
  @override
  String get moduleId => 'video';

  @override
  Map<String, WidgetBuilder> routes() => {
        RoutePath.video: (_) => const VideoPage(),
      };
}
