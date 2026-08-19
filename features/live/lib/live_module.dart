import 'package:flutter/material.dart';
import 'package:module_live/live/view/live_page.dart';
import 'package:module_live/live/view/live_room_page.dart';
import 'package:module_route/module/feature_module.dart';
import 'package:module_route/route/route_path.dart';

class LiveModule extends FeatureModule {
  @override
  String get moduleId => 'live';

  @override
  Map<String, WidgetBuilder> routes() => {
        RoutePath.live: (_) => const LivePage(),
        RoutePath.liveRoom: (_) => const LiveRoomPage(),
      };
}
