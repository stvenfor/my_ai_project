import 'package:module_video/short_video/model/short_video_models.dart';

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
    ShortVideoItemModel(
      type: ShortVideoCellType.video,
      id: '1',
      title: '吉利星越2021款全新到店吉越...',
      coverUrl: _covers[0],
      viewCount: 5467,
      duration: '12:30',
      aspectRatio: 1.3,
      status: ShortVideoStatus.reviewing,
    ),
    ShortVideoItemModel(
      type: ShortVideoCellType.video,
      id: '2',
      title: '吉利星越2021款全新到店吉越...',
      coverUrl: _covers[1],
      viewCount: 5467,
      duration: '12:30',
      aspectRatio: 0.75,
    ),
    ShortVideoItemModel(
      type: ShortVideoCellType.video,
      id: '3',
      title: '吉利星越2021款全新到店吉越...',
      coverUrl: _covers[2],
      viewCount: 5467,
      duration: '12:30',
      aspectRatio: 1.15,
      status: ShortVideoStatus.uploading,
    ),
    ShortVideoItemModel(
      type: ShortVideoCellType.video,
      id: '4',
      title: '吉利星越2021款全新到店吉越...',
      coverUrl: _covers[3],
      viewCount: 5467,
      duration: '12:30',
      aspectRatio: 0.85,
    ),
    ShortVideoItemModel(
      type: ShortVideoCellType.video,
      id: '5',
      title: '吉利星越2021款全新到店吉越...',
      coverUrl: _covers[4],
      viewCount: 5467,
      duration: '12:30',
      aspectRatio: 1.25,
    ),
    ShortVideoItemModel(
      type: ShortVideoCellType.video,
      id: '6',
      title: '吉利星越2021款全新到店吉越...',
      coverUrl: _covers[5],
      viewCount: 5467,
      duration: '12:30',
      aspectRatio: 0.9,
    ),
  ];
}
