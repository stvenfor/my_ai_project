import 'package:module_home/home/model/dubbing_home_model.dart';
import 'package:module_home/home/model/hot_rank_detail_model.dart';
import 'package:module_home/home/theme/dubbing_home_theme.dart';

abstract final class HotRankDetailMockData {
  static HotRankDetailState build({DubbingHomeHotRankBoard? seedBoard}) {
    final theme = seedBoard?.theme ?? HotRankCardTheme.pink;
    final title = seedBoard?.title == '热度榜' ? '热搜榜' : (seedBoard?.title ?? '热搜榜');

    return HotRankDetailState(
      title: title,
      subtitle: '趣配音用户近期热搜内容',
      theme: theme,
      categories: HotRankCategory.values,
      selectedCategory: HotRankCategory.hotSearch,
      selectedAgeFilter: HotRankAgeFilter.grade1to3,
      itemsByCategory: {
        for (final category in HotRankCategory.values)
          category: _itemsForCategory(category, seedBoard),
      },
    );
  }

  static List<HotRankDetailItem> _itemsForCategory(
    HotRankCategory category,
    DubbingHomeHotRankBoard? seedBoard,
  ) {
    final prefix = category.name;

    return [
      for (var i = 0; i < _displayCount; i++)
        HotRankDetailItem(
          id: '${prefix}_item_${i + 1}',
          rank: _ranks[i],
          title: _titles[i % _titles.length],
          subtitle: _subtitles[i % _subtitles.length],
          heat: _heats[i % _heats.length],
          coverAsset: _covers[i % _covers.length],
        ),
    ];
  }

  static const _displayCount = 20;

  static const _ranks = [1, 2, 3, 88, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];

  static const _titles = [
    '穿条纹睡衣的...',
    '蛮荒故事',
    '爱冒险的朵拉',
    '道奇小狗',
    '你好，小朋友',
    '完美的世界',
    '萌宠部落',
    '穿梭在迷宫的勇士',
  ];

  static const _subtitles = [
    '某日布鲁诺决定...',
    '一种近似父子的不寻常感情',
    '开启你的奇幻冒险之旅',
    '跟佩奇一起快乐学英语',
    '经典动画配音练习',
    '趣味英语启蒙课堂',
  ];

  static const _heats = [39274, 28390, 22007, 19874, 18560, 16230, 14890, 13540];

  static const _covers = [
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
}
