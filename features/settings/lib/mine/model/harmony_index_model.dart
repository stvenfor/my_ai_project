import 'package:module_http/api/result_model.dart';

class HarmonyIndexModel {
  HarmonyIndexModel({
    this.links,
    this.openSources,
    this.tools,
  });

  factory HarmonyIndexModel.fromJson(Map<String, dynamic> json) {
    return HarmonyIndexModel(
      links: json['links'] != null
          ? HarmonySectionModel.fromJson(json['links'])
          : null,
      openSources: json['open_sources'] != null
          ? HarmonySectionModel.fromJson(json['open_sources'])
          : null,
      tools: json['tools'] != null
          ? HarmonySectionModel.fromJson(json['tools'])
          : null,
    );
  }

  /// 将 my_go_study transactions 列表映射为 HTTP 调试页展示结构。
  factory HarmonyIndexModel.fromListData(
    ListData<Map<String, dynamic>> data,
  ) {
    final articles = <HarmonyArticleModel>[];
    for (final item in data.list) {
      final category = item['category']?.toString() ?? '未分类';
      final amount = item['amount'];
      final date = item['date']?.toString() ?? '';
      final note = item['note']?.toString();
      articles.add(
        HarmonyArticleModel(
          id: item['id'],
          title: '$category · ${amount ?? '-'}',
          desc: note,
          niceDate: date,
          author: item['type']?.toString(),
        ),
      );
    }
    return HarmonyIndexModel(
      links: HarmonySectionModel(
        name: 'transactions',
        desc: 'my_go_study /api/v1/transactions',
        articleList: articles,
      ),
    );
  }

  /// @deprecated 使用 [fromListData]。
  factory HarmonyIndexModel.fromTransactions(Map<String, dynamic> json) {
    return HarmonyIndexModel.fromListData(
      ListData.fromJson(json, (item) => item),
    );
  }

  final HarmonySectionModel? links;
  final HarmonySectionModel? openSources;
  final HarmonySectionModel? tools;

  List<HarmonySectionModel> get allSections {
    return [
      if (links != null) links!,
      if (openSources != null) openSources!,
      if (tools != null) tools!,
    ];
  }

  int get totalArticleCount {
    return allSections.fold(0, (sum, section) => sum + section.articleCount);
  }
}

class HarmonySectionModel {
  HarmonySectionModel({
    this.name,
    this.desc,
    this.articleList,
  });

  factory HarmonySectionModel.fromJson(Map<String, dynamic> json) {
    final articles = <HarmonyArticleModel>[];
    final rawList = json['articleList'];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          articles.add(HarmonyArticleModel.fromJson(item));
        }
      }
    }
    return HarmonySectionModel(
      name: json['name']?.toString(),
      desc: json['desc']?.toString(),
      articleList: articles,
    );
  }

  final String? name;
  final String? desc;
  final List<HarmonyArticleModel>? articleList;

  int get articleCount => articleList?.length ?? 0;
}

class HarmonyArticleModel {
  HarmonyArticleModel({
    this.id,
    this.title,
    this.desc,
    this.link,
    this.chapterName,
    this.niceDate,
    this.author,
  });

  factory HarmonyArticleModel.fromJson(Map<String, dynamic> json) {
    return HarmonyArticleModel(
      id: json['id'],
      title: json['title']?.toString(),
      desc: json['desc']?.toString(),
      link: json['link']?.toString(),
      chapterName: json['chapterName']?.toString(),
      niceDate: json['niceDate']?.toString(),
      author: json['author']?.toString(),
    );
  }

  final num? id;
  final String? title;
  final String? desc;
  final String? link;
  final String? chapterName;
  final String? niceDate;
  final String? author;
}
