import 'package:module_utils/player/models/short_video_models.dart';
import 'package:module_video/short_video/model/short_video_models.dart';

/// 业务模型 → 播放器模型映射。
class ShortVideoPlayerMapper {
  ShortVideoPlayerMapper._();

  static List<ShortVideoItemModel> playableItems(
    List<ShortVideoItemModel> items,
  ) {
    return items.where((item) => !item.isPublish).toList();
  }

  static List<ShortVideoItem> toPlayerItems(List<ShortVideoItemModel> items) {
    return playableItems(items)
        .map(
          (item) => ShortVideoItem(
            id: item.id ?? '',
            url: item.videoUrl ?? '',
            coverUrl: item.coverUrl,
            title: item.title,
            aspectRatio: item.aspectRatio,
          ),
        )
        .where((item) => item.url.isNotEmpty)
        .toList();
  }

  static int indexForModelId(List<ShortVideoItemModel> items, String id) {
    final playable = playableItems(items);
    final index = playable.indexWhere((item) => item.id == id);
    return index < 0 ? 0 : index;
  }
}
