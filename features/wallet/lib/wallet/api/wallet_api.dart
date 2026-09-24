import 'package:module_auth/api/auth_http_config.dart';
import 'package:module_http/module_http.dart';
import 'package:module_wallet/wallet/model/wallet_models.dart';

class WalletApi {
  static const base = '/api/v1/wallet';

  Future<WalletSummary> fetchSummary() {
    return _guarded(() async {
      final result = await HttpManager.instance.get<ResultModel<WalletSummary>>(
        base,
        converter: (json) => ResultModel.object(
          json as Map<String, dynamic>,
          WalletSummary.fromJson,
        ),
      );
      return _data(result.data, '加载钱包失败');
    });
  }

  Future<List<WalletLedgerEntry>> fetchLedger({
    int limit = 20,
    int offset = 0,
  }) {
    return _guarded(() async {
      final result = await HttpManager.instance
          .get<ResultModel<List<WalletLedgerEntry>>>(
        '$base/ledger',
        queryParameters: {'limit': limit, 'offset': offset},
        converter: (json) {
          final map = json as Map<String, dynamic>;
          final data = map['data'];
          final envelope = data is Map<String, dynamic> ? data : map;
          final items = envelope['items'] as List<dynamic>? ?? const [];
          final list = [
            for (final item in items)
              if (item is Map<String, dynamic>) WalletLedgerEntry.fromJson(item),
          ];
          if (map.containsKey('code')) {
            return ResultModel(
              code: (map['code'] as num?)?.toInt() ?? 0,
              message: map['message']?.toString() ?? '',
              data: list,
            );
          }
          return ResultModel(code: 0, message: 'success', data: list);
        },
      );
      return _data(result.data, '加载流水失败');
    });
  }

  Future<BankCard> bindCard({
    required String bankName,
    required String cardLast4,
    String holderName = '',
    bool isDefault = false,
  }) {
    return _guarded(() async {
      final result = await HttpManager.instance.post<ResultModel<BankCard>>(
        '$base/cards',
        data: {
          'bank_name': bankName,
          'card_last4': cardLast4,
          'holder_name': holderName,
          'is_default': isDefault,
        },
        converter: (json) => ResultModel.object(
          json as Map<String, dynamic>,
          BankCard.fromJson,
        ),
      );
      return _data(result.data, '绑卡失败');
    });
  }

  Future<void> setDefaultCard(int cardId) {
    return _guarded(() async {
      final result = await HttpManager.instance
          .post<ResultModel<Map<String, dynamic>>>(
        '$base/cards/$cardId/default',
        converter: (json) => ResultModel.object(
          json as Map<String, dynamic>,
          (m) => m,
        ),
      );
      _data(result.data, '设置默认卡失败');
    });
  }

  Future<void> deleteCard(int cardId) {
    return _guarded(() async {
      final result = await HttpManager.instance
          .delete<ResultModel<Map<String, dynamic>>>(
        '$base/cards/$cardId',
        converter: (json) => ResultModel.object(
          json as Map<String, dynamic>,
          (m) => m,
        ),
      );
      _data(result.data, '删除银行卡失败');
    });
  }

  Future<WalletRechargeResult> recharge({
    required String amount,
    required int channel,
    int? cardId,
  }) {
    return _guarded(() async {
      final result =
          await HttpManager.instance.post<ResultModel<WalletRechargeResult>>(
        '$base/recharge',
        data: {
          'amount': amount,
          'channel': channel,
          if (cardId != null) 'card_id': cardId,
        },
        converter: (json) => ResultModel.object(
          json as Map<String, dynamic>,
          WalletRechargeResult.fromJson,
        ),
      );
      return _data(result.data, '充值失败');
    });
  }

  Future<T> _guarded<T>(Future<T> Function() action) async {
    AuthHttpConfig.ensureInitialized();
    return action();
  }

  static T _data<T>(ResultModel<T>? model, String fallback) {
    if (model == null || !model.isSuccess || model.data == null) {
      throw HttpRequestException(
        message: (model?.message.isNotEmpty ?? false) ? model!.message : fallback,
        code: model?.code.toString(),
      );
    }
    return model.data as T;
  }
}
