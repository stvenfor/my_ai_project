import 'package:module_core/core.dart';
import 'package:module_home/home/api/transaction_api.dart';
import 'package:module_home/home/model/transaction_model.dart';
import 'package:module_http/module_http.dart';

/// =============================================================================
/// TransactionRepository — UI 与 Api 之间的薄层
///
/// 职责：解包 ResultModel → PageResult/实体，UI 不直接接触 HTTP 信封。
/// =============================================================================
class TransactionRepository {
  TransactionRepository({TransactionApi? api}) : _api = api ?? TransactionApi();

  final TransactionApi _api;

  static const pageSize = 20;

  Future<PageResult<TransactionModel>> fetchPage({
    required int page,
    String? type,
  }) async {
    final result = await _api.fetchPage(
      page: page,
      size: pageSize,
      type: type,
    );
    final listData = result.data;
    if (listData == null) {
      return const PageResult(list: [], hasMore: false);
    }
    return PageResult.fromListData(listData, pageSize: pageSize);
  }

  Future<TransactionModel> fetchById(int id) async {
    final result = await _api.getTransaction(id);
    final item = result.data;
    if (item == null) {
      throw StateError('交易记录不存在');
    }
    return item;
  }

  String get sourceLabel => 'my_go_study HTTP API';
}

/// 把底层异常翻译成用户可读中文（401 → 重新登录）。
String formatTransactionLoadError(Object error) {
  if (error is HttpRequestException) {
    if (error.statusCode == 401 ||
        error.message.contains('未授权') ||
        error.message.contains('Unauthorized') ||
        error.message.contains('其他设备登录') ||
        error.message.contains('会话无效')) {
      return error.message.contains('其他设备登录')
          ? '账号已在其他设备登录，请重新登录'
          : '登录已过期，请重新登录';
    }
    return error.message;
  }
  if (error is AuthFailure) {
    return error.message;
  }
  final text = error.toString();
  if (text.contains('Connection refused') ||
      text.contains('connection error') ||
      text.contains('网络连接异常')) {
    return '无法连接后端，请确认 my_go_study 已启动（默认 http://127.0.0.1:8080）';
  }
  return text;
}
