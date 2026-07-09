import 'package:module_home/home/api/home_http_config.dart';
import 'package:module_home/home/model/transaction_model.dart';
import 'package:module_http/module_http.dart';

/// =============================================================================
/// TransactionApi — 二手车/收支列表 HTTP 层
///
/// GET /api/v1/transactions?limit=&offset=
/// 需已登录：HttpManager 自动带 Authorization: Bearer <Supabase token>
///
/// 初学者导读：my_go_study/docs/transactions-beginner-walkthrough.md
/// =============================================================================
class TransactionApi {
  static const transactionsPath = '/api/v1/transactions';

  /// [page] 为 0-based；后端用 offset = page * size（与 Go listLegacy 对齐）。
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

  /// 兼容两种后端 JSON：ResultModel 信封 或 直出 { items: [] }。
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
