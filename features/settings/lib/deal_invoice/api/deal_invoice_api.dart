import 'package:module_auth/api/auth_http_config.dart';
import 'package:module_http/module_http.dart';
import 'package:module_settings/deal_invoice/model/deal_invoice_models.dart';

/// 新车成交发票 SessionAuth API。
class DealInvoiceApi {
  static const _base = '/api/v1/deal-invoices';

  Future<DealInvoiceSummary> fetchSummary() async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.get<ResultModel<DealInvoiceSummary>>(
      '$_base/summary',
      converter: (json) => ResultModel.fromJson(
        json as Map<String, dynamic>,
        (data) => DealInvoiceSummary.fromJson(data as Map<String, dynamic>),
      ),
    );
    return _data(result.data, '加载摘要失败');
  }

  Future<({List<DealInvoiceItem> list, bool hasMore})> fetchList({
    required DealInvoiceTab tab,
    required int page,
    int size = 10,
  }) async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance
        .get<ResultModel<ListData<DealInvoiceItem>>>(
      _base,
      queryParameters: {
        'page': page,
        'size': size,
        'status': tab.apiStatus,
      },
      converter: (json) => ResultModel.listPage(
        json as Map<String, dynamic>,
        DealInvoiceItem.fromJson,
      ),
    );
    final listData = _data(result.data, '加载列表失败');
    final total = listData.pagination?.total ?? listData.list.length;
    final hasMore = page * size < total;
    return (list: listData.list, hasMore: hasMore);
  }

  Future<DealInvoiceItem> fetchDetail(String invoiceId) async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.get<ResultModel<DealInvoiceItem>>(
      '$_base/$invoiceId',
      converter: (json) => ResultModel.fromJson(
        json as Map<String, dynamic>,
        (data) => DealInvoiceItem.fromJson(data as Map<String, dynamic>),
      ),
    );
    return _data(result.data, '加载详情失败');
  }

  Future<List<DealInvoiceCustomer>> fetchCustomers({
    int page = 1,
    int size = 50,
    String? q,
  }) async {
    AuthHttpConfig.ensureInitialized();
    final query = <String, dynamic>{'page': page, 'size': size};
    if (q != null && q.trim().isNotEmpty) {
      query['q'] = q.trim();
    }
    final result = await HttpManager.instance
        .get<ResultModel<ListData<DealInvoiceCustomer>>>(
      '$_base/customers',
      queryParameters: query,
      converter: (json) => ResultModel.listPage(
        json as Map<String, dynamic>,
        DealInvoiceCustomer.fromJson,
      ),
    );
    return _data(result.data, '加载客户失败').list;
  }

  Future<DealInvoiceItem> create({
    required int customerId,
    String? imageUrl,
  }) async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.post<ResultModel<DealInvoiceItem>>(
      _base,
      data: {
        'customer_id': customerId,
        'image_url': imageUrl,
      },
      converter: (json) => ResultModel.fromJson(
        json as Map<String, dynamic>,
        (data) => DealInvoiceItem.fromJson(data as Map<String, dynamic>),
      ),
    );
    return _data(result.data, '提交失败');
  }

  Future<DealInvoiceItem> resubmit({
    required String invoiceId,
    String? imageUrl,
  }) async {
    AuthHttpConfig.ensureInitialized();
    final result =
        await HttpManager.instance.patch<ResultModel<DealInvoiceItem>>(
      '$_base/$invoiceId/resubmit',
      data: {'image_url': imageUrl},
      converter: (json) => ResultModel.fromJson(
        json as Map<String, dynamic>,
        (data) => DealInvoiceItem.fromJson(data as Map<String, dynamic>),
      ),
    );
    return _data(result.data, '重提失败');
  }

  T _data<T>(ResultModel<T>? model, String fallback) {
    if (model == null || !model.isSuccess || model.data == null) {
      throw HttpRequestException(
        message: (model?.message.isNotEmpty ?? false) ? model!.message : fallback,
        code: model?.code.toString(),
      );
    }
    return model.data as T;
  }
}
