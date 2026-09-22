import 'package:module_auth/api/auth_http_config.dart';
import 'package:module_http/module_http.dart';
import 'package:module_settings/mine/address/model/address_model.dart';

/// 收货地址 API。身份只认 Session 头。
class AddressApi {
  Future<List<AddressModel>> list() async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.get<ResultModel<Map<String, dynamic>>>(
      '/api/v1/user/addresses',
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        (data) => Map<String, dynamic>.from(data),
      ),
    );
    final data = _data(result.data, '加载地址失败');
    final items = data['items'] as List<dynamic>? ?? const [];
    return [
      for (final e in items)
        if (e is Map<String, dynamic>) AddressModel.fromJson(e),
    ];
  }

  Future<AddressModel> create(Map<String, dynamic> body) async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.post<ResultModel<AddressModel>>(
      '/api/v1/user/addresses',
      data: body,
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        AddressModel.fromJson,
      ),
    );
    return _data(result.data, '保存失败');
  }

  Future<AddressModel> update(int addressId, Map<String, dynamic> body) async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.patch<ResultModel<AddressModel>>(
      '/api/v1/user/addresses/$addressId',
      data: body,
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        AddressModel.fromJson,
      ),
    );
    return _data(result.data, '保存失败');
  }

  Future<AddressModel> setDefault(int addressId) async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.post<ResultModel<AddressModel>>(
      '/api/v1/user/addresses/$addressId/default',
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        AddressModel.fromJson,
      ),
    );
    return _data(result.data, '设置默认失败');
  }

  Future<void> delete(int addressId) async {
    AuthHttpConfig.ensureInitialized();
    final result = await HttpManager.instance.delete<ResultModel<Map<String, dynamic>>>(
      '/api/v1/user/addresses/$addressId',
      converter: (json) => ResultModel.object(
        json as Map<String, dynamic>,
        (data) => Map<String, dynamic>.from(data),
      ),
    );
    _data(result.data, '删除失败');
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
