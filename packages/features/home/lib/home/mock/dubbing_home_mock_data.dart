import 'package:module_home/home/model/dubbing_home_model.dart';
import 'package:module_home/home/theme/dubbing_home_theme.dart';

abstract final class DubbingHomeMockData {
  static DubbingHomeData build() {
    return DubbingHomeData(
      banners: _banners,
      features: _features,
      recentLearning: _recentLearning,
      expertShowcase: _expertShowcase,
      hotRankBoards: _hotRankBoards,
      editorPicks: _editorPicks,
      albums: _albums,
      guessYouLike: _guessYouLike,
    );
  }

  static final _banners = <DubbingHomeBannerItem>[
    const DubbingHomeBannerItem(
      id: 'banner_1',
      title: '身体的奥秘',
      imageAsset: 'banner_main.png',
    ),
    const DubbingHomeBannerItem(
      id: 'banner_2',
      title: '萌宠部落',
      imageAsset: 'cover_assessment.png',
    ),
    const DubbingHomeBannerItem(
      id: 'banner_3',
      title: '完美的世界',
      imageAsset: 'cover_01.png',
    ),
  ];

  static final _features = <DubbingHomeFeatureItem>[
    const DubbingHomeFeatureItem(
      label: '每日打卡',
      iconAsset: 'feature_check_in.png',
    ),
    const DubbingHomeFeatureItem(
      label: '影视单词',
      iconAsset: 'feature_movie_words.png',
    ),
    const DubbingHomeFeatureItem(
      label: '经典剧场',
      iconAsset: 'feature_classic_theater.png',
    ),
    const DubbingHomeFeatureItem(
      label: '排行榜',
      iconAsset: 'feature_rank.png',
      action: DubbingHomeFeatureAction.scrollToHotRank,
    ),
    const DubbingHomeFeatureItem(
      label: '全部视频',
      iconAsset: 'feature_all_videos.png',
      action: DubbingHomeFeatureAction.openAllServices,
    ),
  ];

  static final _recentLearning = <DubbingHomeMediaItem>[
    _media('recent_1', '穿梭在迷宫的勇士', 'cover_05.png', duration: '03:24'),
    _media('recent_2', '萌宠部落', 'cover_06.png', duration: '02:18'),
    _media('recent_3', '完美的世界', 'cover_07.png', duration: '04:05'),
    _media('recent_4', '小猪佩奇', 'cover_08.png', duration: '01:56'),
  ];

  static final _expertShowcase = <DubbingHomeMediaItem>[
    _media('expert_1', '英语启蒙课堂', 'cover_09.png',
        userName: '蓝儿老师Joyue', avatarAsset: 'thumb_default.png',
        subtitle: '跟读练习 · 初级'),
    _media('expert_2', '趣味配音挑战', 'cover_10.png',
        userName: '配音达人', avatarAsset: 'thumb_default.png',
        subtitle: '动画配音 · 中级'),
    _media('expert_3', '诵读之星', 'cover_11.png',
        userName: '朗读爱好者', avatarAsset: 'thumb_default.png',
        subtitle: '经典诵读'),
    _media('expert_4', '动画配音秀', 'cover_12.png',
        userName: '动画迷', avatarAsset: 'thumb_default.png',
        subtitle: '角色模仿'),
  ];

  static final _hotRankBoards = <DubbingHomeHotRankBoard>[
    DubbingHomeHotRankBoard(
      id: 'hot_heat',
      title: '热度榜',
      theme: HotRankCardTheme.pink,
      items: _buildRankItems('heat'),
    ),
    DubbingHomeHotRankBoard(
      id: 'hot_search',
      title: '热搜榜',
      theme: HotRankCardTheme.blue,
      items: _buildRankItems('search'),
    ),
  ];

  static final _editorPicks = <DubbingHomeMediaItem>[
    _media('editor_1', '经典动画配音', 'cover_01.png',
        subtitle: '跟佩奇一起快乐学英语', badge: 'AD'),
    _media('editor_2', '英语启蒙课堂', 'cover_02.png',
        subtitle: '零基础也能开口说', badge: 'New'),
    _media('editor_3', '趣味配音挑战', 'cover_03.png',
        subtitle: '模仿经典电影片段'),
    _media('editor_4', '每日跟读练习', 'cover_04.png',
        subtitle: '坚持打卡领奖励', badge: 'New'),
  ];

  static final _albums = <DubbingHomeAlbumItem>[
    const DubbingHomeAlbumItem(
      id: 'album_1',
      title: '小猪佩奇',
      coverAsset: 'cover_05.png',
      episodeCount: '52集',
    ),
    const DubbingHomeAlbumItem(
      id: 'album_2',
      title: '冰雪奇缘',
      coverAsset: 'cover_06.png',
      episodeCount: '12集',
    ),
    const DubbingHomeAlbumItem(
      id: 'album_3',
      title: '狮子王',
      coverAsset: 'cover_07.png',
      episodeCount: '8集',
    ),
    const DubbingHomeAlbumItem(
      id: 'album_4',
      title: '海底总动员',
      coverAsset: 'cover_08.png',
      episodeCount: '16集',
    ),
  ];

  static final _guessYouLike = <DubbingHomeMediaItem>[
    _media('guess_1', '趣味英语配音', 'cover_09.png',
        playCount: '6.8万', duration: '05:12'),
    _media('guess_2', '经典电影片段', 'cover_10.png',
        playCount: '9.2万', duration: '03:45'),
  ];

  static DubbingHomeMediaItem _media(
    String id,
    String title,
    String cover, {
    String? subtitle,
    String? playCount,
    String? duration,
    String? userName,
    String? avatarAsset,
    String? badge,
  }) {
    return DubbingHomeMediaItem(
      id: id,
      title: title,
      coverAsset: cover,
      subtitle: subtitle,
      playCount: playCount,
      duration: duration,
      userName: userName,
      avatarAsset: avatarAsset,
      badge: badge,
    );
  }

  static List<DubbingHomeHotRankItem> _buildRankItems(String prefix) {
    final titles = [
      ('穿梭在迷宫的勇士', '有一年我也见过，在那片...', 19874),
      ('萌宠部落', '一场关于...的冒险，正在...', 28590),
      ('完美的世界', '开启你的奇幻冒险之旅', 22702),
      ('小猪佩奇', '跟佩奇一起快乐学英语', 18560),
      ('冰雪奇缘', 'Let it go 经典配音', 16230),
      ('狮子王', '荣耀大地上的冒险', 14890),
      ('海底总动员', '尼莫的奇妙旅程', 13540),
      ('玩具总动员', '胡迪与巴斯的故事', 12200),
      ('疯狂动物城', '朱迪警官的配音挑战', 11880),
      ('寻梦环游记', '记住我，经典旋律', 10560),
    ];
    final covers = [
      'thumb_default.png',
      'cover_05.png',
      'cover_06.png',
      'cover_07.png',
      'cover_08.png',
      'cover_09.png',
      'cover_10.png',
      'cover_11.png',
      'cover_12.png',
      'cover_01.png',
    ];

    return [
      for (var i = 0; i < titles.length; i++)
        DubbingHomeHotRankItem(
          id: '${prefix}_rank_${i + 1}',
          rank: i + 1,
          title: titles[i].$1,
          subtitle: titles[i].$2,
          heat: titles[i].$3,
          coverAsset: covers[i],
        ),
    ];
  }
}
