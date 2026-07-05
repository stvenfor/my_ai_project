import 'package:module_home/home/theme/dubbing_home_theme.dart';

enum DubbingHomeCategory {
  svip('SVIP'),
  dubbing('配音'),
  listening('听力'),
  miniTheater('小剧场'),
  special('专题');

  const DubbingHomeCategory(this.label);

  final String label;
}

class DubbingHomeBannerItem {
  const DubbingHomeBannerItem({
    required this.id,
    required this.title,
    required this.imageAsset,
  });

  final String id;
  final String title;
  final String imageAsset;
}

class DubbingHomeFeatureItem {
  const DubbingHomeFeatureItem({
    required this.label,
    required this.iconAsset,
    this.action,
  });

  final String label;
  final String iconAsset;
  final DubbingHomeFeatureAction? action;
}

enum DubbingHomeFeatureAction {
  scrollToHotRank,
  openAllServices,
}

class DubbingHomeMediaItem {
  const DubbingHomeMediaItem({
    required this.id,
    required this.title,
    required this.coverAsset,
    this.subtitle,
    this.playCount,
    this.duration,
    this.avatarAsset,
    this.userName,
    this.badge,
  });

  final String id;
  final String title;
  final String coverAsset;
  final String? subtitle;
  final String? playCount;
  final String? duration;
  final String? avatarAsset;
  final String? userName;
  /// AD / New / etc.
  final String? badge;
}

class DubbingHomeHotRankItem {
  const DubbingHomeHotRankItem({
    required this.id,
    required this.rank,
    required this.title,
    required this.subtitle,
    required this.heat,
    required this.coverAsset,
  });

  final String id;
  final int rank;
  final String title;
  final String subtitle;
  final int heat;
  final String coverAsset;
}

class DubbingHomeHotRankBoard {
  const DubbingHomeHotRankBoard({
    required this.id,
    required this.title,
    required this.theme,
    required this.items,
  });

  final String id;
  final String title;
  final HotRankCardTheme theme;
  final List<DubbingHomeHotRankItem> items;
}

class DubbingHomeAlbumItem {
  const DubbingHomeAlbumItem({
    required this.id,
    required this.title,
    required this.coverAsset,
    this.episodeCount,
  });

  final String id;
  final String title;
  final String coverAsset;
  final String? episodeCount;
}

class DubbingHomeData {
  const DubbingHomeData({
    required this.banners,
    required this.features,
    required this.recentLearning,
    required this.expertShowcase,
    required this.hotRankBoards,
    required this.editorPicks,
    required this.albums,
    required this.guessYouLike,
  });

  final List<DubbingHomeBannerItem> banners;
  final List<DubbingHomeFeatureItem> features;
  final List<DubbingHomeMediaItem> recentLearning;
  final List<DubbingHomeMediaItem> expertShowcase;
  final List<DubbingHomeHotRankBoard> hotRankBoards;
  final List<DubbingHomeMediaItem> editorPicks;
  final List<DubbingHomeAlbumItem> albums;
  final List<DubbingHomeMediaItem> guessYouLike;
}
