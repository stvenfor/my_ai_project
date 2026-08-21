import 'package:get/get.dart';

import 'wys_route_entry.dart';

/// 由 GetX [GetPage] 列表生成 [WysRouteEntry]（path 与 [GetPage.name] 一一对应，单一数据源）。
abstract final class WysGetPageRoutes {
  WysGetPageRoutes._();

  static List<WysRouteEntry> fromGetPages(List<GetPage<dynamic>> pages) {
    return [
      for (final page in pages)
        if (page.name.isNotEmpty)
          WysRouteEntry(
            pattern: page.name,
            getPath: (_, __) => page.name,
          ),
    ];
  }
}
