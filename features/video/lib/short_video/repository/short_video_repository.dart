import 'package:module_video/short_video/model/short_video_models.dart';

class ShortVideoListPage {
  const ShortVideoListPage({
    required this.list,
    required this.hasMore,
  });

  final List<ShortVideoItemModel> list;
  final bool hasMore;
}

/// 小视频数据源。
abstract class ShortVideoRepository {
  Future<ShortVideoProfileModel> fetchProfile({String? userId});

  Future<ShortVideoListPage> fetchList({
    required String scope,
    String? userId,
    int page = 0,
    int pageSize = 5,
  });

  Future<ShortVideoItemModel> create({
    required String title,
    String? topicId,
  });

  Future<void> delete(String id);

  Future<ShortVideoItemModel> toggleLike(String id, bool liked);

  Future<int> reportView(String id);
}
