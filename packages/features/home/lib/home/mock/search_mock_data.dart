import 'package:module_home/home/model/search_page_model.dart';

abstract final class SearchMockData {
  static const defaultKeyword = '新标准三年级';

  static const searchHistory = [
    '极限文字一排两个显示',
    '极限文字超出九个字...',
    '宫崎骏宫漫作品',
    '龙猫',
    '闪光少女',
  ];

  static const searchDiscovery = [
    '罗振宇2026跨年演讲',
    '极限文字超出九个字...',
    '小猪佩奇全系列',
    '百家讲坛全集',
    '罗振宇2026跨年演讲',
    '百家讲坛明朝',
  ];

  static const filterTags = [
    '3-5 个句子的配音',
    '较慢的语速',
    '初级难度',
    '女声',
    '1 分钟以内的视频',
  ];

  static const _coverUrls = [
    'https://picsum.photos/seed/search-rank-1/144/144',
    'https://picsum.photos/seed/search-rank-2/144/144',
    'https://picsum.photos/seed/search-rank-3/144/144',
    'https://picsum.photos/seed/search-rank-4/144/144',
    'https://picsum.photos/seed/search-rank-5/144/144',
    'https://picsum.photos/seed/search-rank-6/144/144',
    'https://picsum.photos/seed/search-rank-7/144/144',
    'https://picsum.photos/seed/search-rank-8/144/144',
  ];

  static List<SearchRankItem> rankListForTab(SearchRankTab tab) {
    switch (tab) {
      case SearchRankTab.hotDubbing:
        return _buildList(
          tab,
          titles: const [
            '穿条纹睡衣的男孩',
            '蛮荒故事',
            '爱冒险的朵拉',
            '小王子',
            '寻梦环游记',
            '飞屋环游记',
            '头脑特工队',
            '疯狂动物城',
          ],
          subtitles: const [
            '某日布鲁诺决定，去铁丝网的另外...',
            '六个独立故事，荒诞与黑色幽默交织...',
            '和朵拉一起开启奇妙冒险之旅...',
            '来自 B612 小行星的小王子...',
            '米格在亡灵节追寻音乐梦想...',
            '卡尔用气球带着房子去冒险...',
            '情绪小人在大脑里协作成长...',
            '兔子警官与狐狸搭档破案...',
          ],
        );
      case SearchRankTab.reading:
        return _buildList(
          tab,
          titles: const [
            '静夜思',
            '春晓',
            '登鹳雀楼',
            '望庐山瀑布',
            '悯农',
          ],
          subtitles: const [
            '床前明月光，疑是地上霜...',
            '春眠不觉晓，处处闻啼鸟...',
            '白日依山尽，黄河入海流...',
            '日照香炉生紫烟，遥看瀑布挂前川...',
            '锄禾日当午，汗滴禾下土...',
          ],
        );
      case SearchRankTab.series:
        return _buildList(
          tab,
          titles: const [
            '小猪佩奇',
            '汪汪队立大功',
            '超级飞侠',
            '熊出没',
            '喜羊羊与灰太狼',
          ],
          subtitles: const [
            '佩奇和乔治的日常生活...',
            '莱德队长带领狗狗们救援...',
            '乐迪环游世界送包裹...',
            '熊大熊二与光头强的故事...',
            '羊村与狼堡的欢乐对决...',
          ],
        );
      case SearchRankTab.record:
        return _buildList(
          tab,
          titles: const [
            '我的第一次配音',
            '英语朗读打卡',
            '亲子共读记录',
            '班级作业精选',
            '周末练习成果',
          ],
          subtitles: const [
            '完成度 98%，发音清晰自然...',
            '连续打卡 30 天，进步明显...',
            '与孩子一起完成的温馨朗读...',
            '老师推荐的优秀作业展示...',
            '周末集中练习的成果汇总...',
          ],
        );
      case SearchRankTab.collaboration:
        return _buildList(
          tab,
          titles: const [
            'BBC 合作专区',
            '迪士尼经典合作',
            '国家地理探索',
            '牛津阅读树',
            '剑桥少儿英语',
          ],
          subtitles: const [
            'BBC 精选纪录片配音素材...',
            '迪士尼动画经典片段...',
            '探索自然与科学的配音...',
            '分级阅读配套配音练习...',
            '剑桥体系标准发音示范...',
          ],
        );
    }
  }

  static List<SearchRankItem> _buildList(
    SearchRankTab tab, {
    required List<String> titles,
    required List<String> subtitles,
  }) {
    return List.generate(titles.length, (index) {
      return SearchRankItem(
        id: '${tab.name}_$index',
        rank: index + 1,
        title: titles[index],
        subtitle: subtitles[index],
        coverUrl: _coverUrls[index % _coverUrls.length],
      );
    });
  }
}
