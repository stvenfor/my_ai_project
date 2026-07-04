import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_music/controller/music_playback_controller.dart';
import 'package:module_music/view/music_list_page.dart';
import 'package:module_music/view/now_playing_page.dart';
import 'package:module_route/module/feature_module.dart';
import 'package:module_route/route/route_path.dart';

class MusicModule extends FeatureModule {
  @override
  String get moduleId => 'music';

  @override
  Bindings? createBinding() => MusicPlaybackBinding();

  @override
  Map<String, WidgetBuilder> routes() => {
        RoutePath.musicList: (_) => const MusicListPage(),
        RoutePath.musicNowPlaying: (_) => const NowPlayingPage(),
      };
}
