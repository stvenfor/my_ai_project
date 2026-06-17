import 'package:module_utils/player/mock/video_mock_sources.dart';
import 'package:module_video/short_video/model/short_video_models.dart';

/// 小视频列表 Mock（映射 [kVideoMockSources]，业务接入后替换为 Repository）。
class ShortVideoMockData {
  ShortVideoMockData._();

  static const _covers = [
    'https://picsum.photos/seed/sv1/400/520',
    'https://picsum.photos/seed/sv2/400/300',
    'https://picsum.photos/seed/sv3/400/460',
    'https://picsum.photos/seed/sv4/400/340',
    'https://picsum.photos/seed/sv5/400/500',
    'https://picsum.photos/seed/sv6/400/360',
  ];

  static final List<ShortVideoItemModel> listItems = [
    ShortVideoItemModel(type: ShortVideoCellType.publish, aspectRatio: 1.45),
    _videoItem(
      id: '1',
      sourceIndex: 0,
      coverIndex: 0,
      aspectRatio: 1.3,
      status: ShortVideoStatus.reviewing,
    ),
    _videoItem(id: '2', sourceIndex: 0, coverIndex: 1, aspectRatio: 0.75),
    _videoItem(
      id: '3',
      sourceIndex: 1,
      coverIndex: 2,
      aspectRatio: 1.15,
      status: ShortVideoStatus.uploading,
    ),
    _videoItem(id: '4', sourceIndex: 1, coverIndex: 3, aspectRatio: 0.85),
    _videoItem(id: '5', sourceIndex: 2, coverIndex: 4, aspectRatio: 1.25),
    _videoItem(id: '6', sourceIndex: 2, coverIndex: 5, aspectRatio: 0.9),
  ];

  static ShortVideoItemModel _videoItem({
    required String id,
    required int sourceIndex,
    required int coverIndex,
    required double aspectRatio,
    ShortVideoStatus status = ShortVideoStatus.normal,
  }) {
    final source = videoMockSourceAt(sourceIndex);
    return ShortVideoItemModel(
      type: ShortVideoCellType.video,
      id: id,
      title: source.title,
      coverUrl: _covers[coverIndex],
      videoUrl: source.url,
      viewCount: 5467,
      duration: '12:30',
      aspectRatio: aspectRatio,
      status: status,
    );
  }
}
