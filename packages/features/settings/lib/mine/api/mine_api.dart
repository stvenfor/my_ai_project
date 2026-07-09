import 'package:flutter/foundation.dart';
import 'package:module_http/module_http.dart';
import 'package:module_settings/mine/api/mine_http_config.dart';
import 'package:module_settings/mine/model/harmony_index_model.dart';

class MineApi {
  /// HTTP 调试页：请求 my_go_study transactions 列表并映射为展示模型。
  Future<HarmonyIndexModel> fetchHarmonyIndex() async {
    _ensureHttpReady();
    final result =
        await HttpManager.instance.get<ResultModel<ListData<Map<String, dynamic>>>>(
      MineHttpConfig.transactionsPath,
      queryParameters: const {'page': 1, 'size': 20},
      converter: (json) => ResultModel.listPage(
        json as Map<String, dynamic>,
        (item) => item,
      ),
    );
    final listData = result.data?.data;
    if (listData == null) {
      throw HttpRequestException(message: '接口返回数据为空');
    }
    return HarmonyIndexModel.fromListData(listData);
  }

  void _ensureHttpReady() {
    if (HttpManager.instance.isInitialized) return;
    MineHttpConfig.init(enableLog: kDebugMode, maxRetries: 3);
  }
}
