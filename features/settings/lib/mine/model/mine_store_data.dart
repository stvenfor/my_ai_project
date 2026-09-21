import 'package:module_settings/mine/model/mine_store_model.dart';

abstract final class MineStoreData {
  static const defaultStoreId = '1';

  static const stores = <MineStoreOption>[
    MineStoreOption(
      id: '1',
      name: '[4S]北京沃德龙鼎吉利',
    ),
    MineStoreOption(
      id: '2',
      name: '[4S]北京腾远吉利',
    ),
  ];

  static final Map<String, MineStoreOption> _byId = {
    for (final store in stores) store.id: store,
  };

  static MineStoreOption? findById(String id) => _byId[id];

  static String resolveStoreName(String id) =>
      findById(id)?.name ?? stores.first.name;
}
