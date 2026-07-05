enum SearchRankTab {
  hotDubbing('热配榜'),
  reading('诵读榜'),
  series('剧集榜'),
  record('记录榜'),
  collaboration('合作榜');

  const SearchRankTab(this.label);

  final String label;
}

class SearchRankItem {
  const SearchRankItem({
    required this.id,
    required this.rank,
    required this.title,
    required this.subtitle,
    required this.coverUrl,
  });

  final String id;
  final int rank;
  final String title;
  final String subtitle;
  final String coverUrl;
}
