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

  static final List<ShortVideoItem> feedItems = [
    for (var i = 0; i < kVideoMockSources.length; i++)
      ShortVideoItem(
        id: 'demo_${kVideoMockSources[i].id}',
        url: kVideoMockSources[i].url,
        coverUrl: _covers[i],
        title: kVideoMockSources[i].title,
      ),
  ];
}
