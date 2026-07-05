import 'package:module_utils/player/mock/short_video_mock_samples.dart';
import 'package:module_utils/player/mock/video_mock_sources.dart';
import 'package:module_video/short_video/model/short_video_models.dart';

/// 小视频列表 Mock（严格映射 [video_mock_sources.json]，业务接入后替换为 Repository）。
class ShortVideoMockData {
  ShortVideoMockData._();

  static const _aspectRatios = [1.3, 0.85, 1.15];

  /// 列表项：发布入口 + JSON 中每条视频各一条（均可播放）。
  static List<ShortVideoItemModel> get listItems {
    final sources = kVideoMockSources;
    return [
      const ShortVideoItemModel(type: ShortVideoCellType.publish, aspectRatio: 1.45),
      for (var i = 0; i < sources.length; i++)
        ShortVideoItemModel(
          type: ShortVideoCellType.video,
          id: '${sources[i].id}',
          title: sources[i].title,
          coverUrl: ShortVideoMockSamples.coverAt(i),
          videoUrl: sources[i].url,
          viewCount: 1200 + i * 337,
          duration: '${1 + i}:${10 + i * 5}',
          aspectRatio: _aspectRatios[i % _aspectRatios.length],
          status: ShortVideoStatus.normal,
        ),
    ];
  }
}
