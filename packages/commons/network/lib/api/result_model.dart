/// my_go_study 统一 API 响应信封。
class ResultModel<T> {
  const ResultModel({
    required this.code,
    required this.message,
    this.data,
    this.timestamp,
  });

  factory ResultModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) dataFromJson,
  ) {
    final rawData = json['data'];
    return ResultModel(
      code: (json['code'] as num?)?.toInt() ?? -1,
      message: json['message']?.toString() ?? '',
      data: rawData == null ? null : dataFromJson(rawData),
      timestamp: (json['timestamp'] as num?)?.toInt(),
    );
  }

  final int code;
  final String message;
  final T? data;
  final int? timestamp;

  bool get isSuccess => code == 0;

  static ResultModel<ListData<Item>> listPage<Item>(
    Map<String, dynamic> json,
    Item Function(Map<String, dynamic> json) itemFromJson,
  ) {
    return ResultModel.fromJson(
      json,
      (data) => ListData.fromJson(data, itemFromJson),
    );
  }

  static ResultModel<Item> object<Item>(
    Map<String, dynamic> json,
    Item Function(Map<String, dynamic> json) itemFromJson,
  ) {
    return ResultModel.fromJson(
      json,
      (data) => itemFromJson(data as Map<String, dynamic>),
    );
  }
}

/// 列表页 `data.pagination`（可能不存在）。
class PaginationModel {
  const PaginationModel({
    required this.page,
    required this.size,
    required this.total,
    this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: (json['page'] as num?)?.toInt() ?? 1,
      size: (json['size'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt(),
    );
  }

  final int page;
  final int size;
  final int total;
  final int? totalPages;

  bool get hasMore {
    if (totalPages != null && totalPages! > 0) {
      return page < totalPages!;
    }
    if (size > 0) {
      return page * size < total;
    }
    return false;
  }
}

/// 列表页 `data` 结构：`{ list, pagination? }`。
class ListData<T> {
  const ListData({
    required this.list,
    this.pagination,
  });

  factory ListData.fromJson(
    dynamic json,
    T Function(Map<String, dynamic> json) itemFromJson,
  ) {
    if (json is List) {
      return ListData(
        list: json
            .whereType<Map<String, dynamic>>()
            .map(itemFromJson)
            .toList(),
      );
    }

    if (json is Map<String, dynamic>) {
      final rawList = json['list'] ?? json['items'];
      final list = rawList is List
          ? rawList
              .whereType<Map<String, dynamic>>()
              .map(itemFromJson)
              .toList()
          : <T>[];

      PaginationModel? pagination;
      final rawPagination = json['pagination'];
      if (rawPagination is Map<String, dynamic>) {
        pagination = PaginationModel.fromJson(rawPagination);
      }

      return ListData(list: list, pagination: pagination);
    }

    return const ListData(list: []);
  }

  final List<T> list;
  final PaginationModel? pagination;

  bool resolveHasMore(int pageSize) {
    if (pagination != null) {
      return pagination!.hasMore;
    }
    if (pageSize <= 0) return false;
    return list.length >= pageSize;
  }
}

/// Repository 层使用的列表页结果（屏蔽 ResultModel 信封）。
class PageResult<T> {
  const PageResult({
    required this.list,
    required this.hasMore,
    this.pagination,
  });

  final List<T> list;
  final bool hasMore;
  final PaginationModel? pagination;

  factory PageResult.fromListData(ListData<T> data, {required int pageSize}) {
    return PageResult(
      list: data.list,
      hasMore: data.resolveHasMore(pageSize),
      pagination: data.pagination,
    );
  }
}
