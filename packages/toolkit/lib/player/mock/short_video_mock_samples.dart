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
    ShortVideoItem(
      id: 'demo_1',
      url:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      coverUrl: _covers[0],
      title: '吉利星越2021款全新到店',
    ),
    ShortVideoItem(
      id: 'demo_2',
      url:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      coverUrl: _covers[1],
      title: '到店试驾体验',
    ),
    ShortVideoItem(
      id: 'demo_3',
      url:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
      coverUrl: _covers[2],
      title: '展厅实拍',
    ),
  ];
}
