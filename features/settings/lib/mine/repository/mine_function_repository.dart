import 'package:module_settings/mine/model/mine_function_data.dart';
import 'package:module_settings/mine/model/mine_function_item.dart';
import 'package:module_utils/module_utils.dart';

class MineFunctionRepository {
  MineFunctionRepository._();

  static const _orderIdsKey = 'mine_function_order_ids';

  static List<String> loadOrderIds() {
    final stored = SpUtils.getStringList(_orderIdsKey);
    if (stored.isEmpty) {
      return List<String>.from(MineFunctionData.defaultOrderIds);
    }
    return stored;
  }

  static Future<void> saveOrderIds(List<String> ids) async {
    await SpUtils.setStringList(_orderIdsKey, ids);
  }

  static List<MineFunctionItem> normalizeFunctions(List<MineFunctionItem> items) {
    return MineFunctionData.resolveOrderedItems(
      items.map((item) => item.id).toList(),
    );
  }

  static Future<List<MineFunctionItem>> loadFunctions() async {
    final stored = SpUtils.getStringList(_orderIdsKey);
    if (stored.isEmpty) {
      final defaults = List<MineFunctionItem>.from(MineFunctionData.catalog);
      await saveFunctions(defaults);
      return defaults;
    }

    final resolved = MineFunctionData.resolveOrderedItems(stored);
    final normalizedIds = resolved.map((item) => item.id).toList();
    if (normalizedIds.length != stored.length ||
        !_sameIds(normalizedIds, stored)) {
      await saveOrderIds(normalizedIds);
    }
    return resolved;
  }

  static Future<void> saveFunctions(List<MineFunctionItem> items) async {
    await saveOrderIds(items.map((item) => item.id).toList());
  }

  static bool _sameIds(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
