import 'package:module_home/home/theme/dubbing_home_theme.dart';

enum HotRankCategory {
  hotRead('热读榜'),
  newBook('新书榜'),
  fairyTale('童话榜'),
  hotSearch('热搜榜'),
  science('科普榜'),
  highScore('高分榜');

  const HotRankCategory(this.label);

  final String label;
}

enum HotRankAgeFilter {
  age1to2('1-2岁'),
  age3toKindergarten('3岁到大班'),
  grade1to3('1-3年级'),
  grade4plus('4年级以上');

  const HotRankAgeFilter(this.label);

  final String label;
}

class HotRankDetailItem {
  const HotRankDetailItem({
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

class HotRankDetailState {
  const HotRankDetailState({
    required this.title,
    required this.subtitle,
    required this.theme,
    required this.categories,
    required this.itemsByCategory,
    required this.selectedCategory,
    required this.selectedAgeFilter,
    this.showAgeFilterMenu = false,
  });

  final String title;
  final String subtitle;
  final HotRankCardTheme theme;
  final List<HotRankCategory> categories;
  final Map<HotRankCategory, List<HotRankDetailItem>> itemsByCategory;
  final HotRankCategory selectedCategory;
  final HotRankAgeFilter selectedAgeFilter;
  final bool showAgeFilterMenu;

  List<HotRankDetailItem> get currentItems =>
      itemsByCategory[selectedCategory] ?? const [];

  HotRankDetailState copyWith({
    HotRankCategory? selectedCategory,
    HotRankAgeFilter? selectedAgeFilter,
    bool? showAgeFilterMenu,
  }) {
    return HotRankDetailState(
      title: title,
      subtitle: subtitle,
      theme: theme,
      categories: categories,
      itemsByCategory: itemsByCategory,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedAgeFilter: selectedAgeFilter ?? this.selectedAgeFilter,
      showAgeFilterMenu: showAgeFilterMenu ?? this.showAgeFilterMenu,
    );
  }
}

abstract final class HotRankDetailAssets {
  static const package = 'module_home';
  static const basePath = 'assets/dubbing_home/hot_rank';

  static String path(String assetName) => '$basePath/$assetName';
}
