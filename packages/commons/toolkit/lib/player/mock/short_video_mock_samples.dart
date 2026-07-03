import 'package:module_utils/player/mock/video_mock_sources.dart';
import 'package:module_utils/player/models/short_video_models.dart';

/// P0 演示数据（业务可替换为接口数据）。
class ShortVideoMockSamples {
  ShortVideoMockSamples._();

  static const _covers = [
    'https://picsum.photos/seed/sv_play_1/400/700',
    'https://picsum.photos/seed/sv_play_2/400/700',
    'https://picsum.photos/seed/sv_play_3/400/700',
  ];

  static List<ShortVideoItem> get feedItems {
    final sources = kVideoMockSources;
    return [
      for (var i = 0; i < sources.length; i++)
        ShortVideoItem(
          id: 'demo_${sources[i].id}',
          url: sources[i].url,
          coverUrl: _covers[i % _covers.length],
          title: sources[i].title,
        ),
    ];
  }
}
