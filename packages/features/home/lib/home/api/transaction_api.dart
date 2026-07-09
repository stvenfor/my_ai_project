import 'package:module_home/home/api/home_http_config.dart';
import 'package:module_home/home/model/transaction_model.dart';
import 'package:module_http/module_http.dart';

class TransactionApi {
  static const transactionsPath = '/api/v1/transactions';

  /// [page] 为 0-based 页码，请求时转换为后端 `offset`。
  Future<TransactionListResult> fetchPage({
    required int page,
    int size = 20,
    String? type,
  }) async {
    HomeHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.get<TransactionListResult>(
      transactionsPath,
      queryParameters: {
        'limit': size,
        'offset': page * size,
        if (type != null && type.isNotEmpty) 'type': type,
      },
      converter: _parseListResult,
    );
    return result.data ??
        ResultModel(
          code: 0,
          message: 'success',
          data: const ListData<TransactionModel>(list: []),
        );
  }

  Future<TransactionDetailResult> getTransaction(int id) async {
    HomeHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.get<TransactionDetailResult>(
      '$transactionsPath/$id',
      converter: _parseDetailResult,
    );
    final data = result.data;
    if (data == null || data.data == null) {
      throw HttpRequestException(message: '交易记录不存在');
    }
    return data;
  }

  static TransactionListResult _parseListResult(dynamic json) {
    final map = json as Map<String, dynamic>;
    if (map.containsKey('code')) {
      return ResultModel.listPage(map, TransactionModel.fromJson);
    }
    return ResultModel(
      code: 0,
      message: 'success',
      data: ListData.fromJson(map, TransactionModel.fromJson),
    );
  }

  static TransactionDetailResult _parseDetailResult(dynamic json) {
    final map = json as Map<String, dynamic>;
    if (map.containsKey('code')) {
      return ResultModel.object(map, TransactionModel.fromJson);
    }
    return ResultModel(
      code: 0,
      message: 'success',
      data: TransactionModel.fromJson(map),
    );
  }
}
