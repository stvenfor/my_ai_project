import 'package:flutter/foundation.dart';
import 'package:module_http/module_http.dart';
import 'package:module_settings/mine/mine_http_config.dart';
import 'package:module_settings/mine/model/harmony_index_model.dart';

class MineApi {
  static Future<HarmonyIndexModel> fetchHarmonyIndex() async {
    _ensureHttpReady();
    final result = await HttpManager.instance.get<HarmonyIndexModel>(
      MineHttpConfig.harmonyIndexPath,
      converter: (json) =>
          HarmonyIndexModel.fromJson(json as Map<String, dynamic>),
    );
    final data = result.data;
    if (data == null) {
      throw HttpRequestException(message: '接口返回数据为空');
    }
    return data;
  }

  static void _ensureHttpReady() {
    if (HttpManager.instance.isInitialized) return;
    MineHttpConfig.init(enableLog: kDebugMode);
  }
}
