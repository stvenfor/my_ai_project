/// 小视频播放页路由参数。
import 'package:module_video/short_video/model/short_video_models.dart';

class ShortVideoPlayArgs {
  const ShortVideoPlayArgs({
    this.initialIndex = 0,
    this.items = const [],
  });

  final int initialIndex;
  final List<ShortVideoItemModel> items;
}
