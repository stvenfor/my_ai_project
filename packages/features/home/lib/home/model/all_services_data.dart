import 'package:module_home/home/model/all_services_model.dart';

/// 全部服务页静态数据。
abstract final class AllServicesData {
  static const minFavoriteCount = 3;
  static const maxFavoriteCount = 8;

  static const defaultFavoriteItems = <AllServiceItem>[
    AllServiceItem(label: '智慧网销', assetName: 'smart_online_marketing.png'),
    AllServiceItem(label: '在线获客', assetName: 'online_customer_acquisition.png'),
    AllServiceItem(label: '小视频', assetName: 'small_video.png'),
    AllServiceItem(label: '服务管理', assetName: 'service_management.png'),
    AllServiceItem(label: '展厅拍摄', assetName: 'exhibition_hall_shooting.png'),
    AllServiceItem(label: '智效任务', assetName: 'intelligence_task.png'),
    AllServiceItem(label: '新车进店', assetName: 'new_car_in_store.png'),
    AllServiceItem(label: '智能号', assetName: 'smart_number.png'),
  ];

  static const favoriteSectionMeta = (
    title: '常用服务',
    subtitle: '将按自定义顺序出现在首页',
  );

  static const catalogSections = <AllServiceSection>[
    AllServiceSection(
      title: '线索服务',
      items: [
        AllServiceItem(label: '智慧网销', assetName: 'smart_online_marketing.png'),
        AllServiceItem(label: '客户建档', assetName: 'customer_profile.png'),
        AllServiceItem(label: '智慧销售', assetName: 'smart_sale.png'),
        AllServiceItem(label: '在线获客', assetName: 'online_customer_acquisition.png'),
        AllServiceItem(label: '新车进店', assetName: 'new_car_in_store.png'),
        AllServiceItem(label: '新车成交', assetName: 'new_car_deal.png'),
        AllServiceItem(label: '智能号', assetName: 'smart_number.png'),
      ],
    ),
    AllServiceSection(
      title: '营销服务',
      items: [
        AllServiceItem(label: '展厅拍摄', assetName: 'exhibition_hall_shooting.png'),
        AllServiceItem(label: '营销', assetName: 'marketing.png'),
        AllServiceItem(label: '智效任务', assetName: 'intelligence_task.png'),
        AllServiceItem(label: 'V店', assetName: 'v_store.png'),
        AllServiceItem(label: '小视频', assetName: 'small_video.png'),
        AllServiceItem(label: '商家海报', assetName: 'business_poster.png'),
      ],
    ),
    AllServiceSection(
      title: '其他服务',
      items: [
        AllServiceItem(label: '售后专区', assetName: 'after_sales_area.png'),
        AllServiceItem(label: '计算器', assetName: 'calculator.png'),
        AllServiceItem(label: '服务管理', assetName: 'service_management.png'),
        AllServiceItem(label: '二手车', assetName: 'used_car.png'),
      ],
    ),
  ];

  static final Map<String, AllServiceItem> _catalogById = {
    for (final item in _allCatalogItems) item.id: item,
  };

  static List<AllServiceItem> get _allCatalogItems => [
        ...defaultFavoriteItems,
        for (final section in catalogSections) ...section.items,
      ];

  static AllServiceItem? findItemById(String id) => _catalogById[id];

  static List<AllServiceItem> resolveItems(List<String> ids) {
    return [
      for (final id in ids)
        if (_catalogById[id] != null) _catalogById[id]!,
    ];
  }

  static List<String> get defaultFavoriteIds =>
      defaultFavoriteItems.map((item) => item.id).toList();
}
