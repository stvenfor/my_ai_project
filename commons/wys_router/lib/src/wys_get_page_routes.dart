import 'package:get/get.dart';

import 'wys_route.dart';

/// 由 GetX [GetPage] 列表生成 [WysRoute]（path 与 [GetPage.name] 一一对应，单一数据源）。
abstract final class WysGetPageRoutes {
  WysGetPageRoutes._();

  static List<WysRoute> fromGetPages(List<GetPage<dynamic>> pages) {
    return [
      for (final page in pages)
        if (page.name.isNotEmpty)
          WysRoute(
            pattern: page.name,
            getPath: (_, __) => page.name,
          ),
    ];
  }
}