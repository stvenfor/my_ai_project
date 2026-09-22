import 'package:module_auth/api/auth_http_config.dart';
import 'package:module_auth/api/user_profile_models.dart';
import 'package:module_core/core.dart';
import 'package:module_http/module_http.dart';

/// 用户资料 HTTP：GET/PATCH `/api/v1/profiles/me`。
/// 身份只认 Session 头；不在 query/body 再传 user_id。
class UserProfileApi {
  static const mePath = '/api/v1/profiles/me';
  static const storesPath = '/api/v1/me/stores';

  Future<UserProfile> fetchMe({String? storeId}) async {
    AuthHttpConfig.ensureInitialized();
    try {
      final result = await HttpManager.instance.get<ResultModel<UserProfile>>(
        mePath,
        queryParameters: {
          if (storeId != null && storeId.trim().isNotEmpty)
            'store_id': storeId.trim(),
        },
        converter: _parseProfile,
      );
      final model = result.data;
      if (model == null || !model.isSuccess || model.data == null) {
        throw _mapFailure(model?.code, model?.message);
      }
      return model.data!;
    } on AuthFailure {
      rethrow;
    } on HttpRequestException catch (error) {
      throw _mapFailure(int.tryParse(error.code ?? ''), error.message);
    } catch (error) {
      throw _mapFailure(null, error.toString());
    }
  }

  /// GET `/api/v1/me/stores`，当前用户可切换的经销商列表。
  Future<UserStoreListResult> listMyStores() async {
    AuthHttpConfig.ensureInitialized();
    try {
      final result = await HttpManager.instance.get<ResultModel<UserStoreListResult>>(
        storesPath,
        converter: (json) => ResultModel.object(
          json as Map<String, dynamic>,
          UserStoreListResult.fromJson,
        ),
      );
      final model = result.data;
      if (model == null || !model.isSuccess || model.data == null) {
        throw _mapFailure(model?.code, model?.message);
      }
      return model.data!;
    } on AuthFailure {
      rethrow;
    } on HttpRequestException catch (error) {
      throw _mapFailure(int.tryParse(error.code ?? ''), error.message);
    } catch (error) {
      throw _mapFailure(null, error.toString());
    }
  }

  /// POST `/api/v1/profiles/me/store`，返回切换后的店铺统计。
  Future<UserStoreStats> switchStore(int storeId) async {
    AuthHttpConfig.ensureInitialized();
    try {
      final result = await HttpManager.instance.post<ResultModel<UserStoreStats>>(
        '$mePath/store',
        data: {'store_id': storeId},
        converter: (json) => ResultModel.object(
          json as Map<String, dynamic>,
          UserStoreStats.fromJson,
        ),
      );
      final model = result.data;
      if (model == null || !model.isSuccess || model.data == null) {
        throw _mapFailure(model?.code, model?.message);
      }
      return model.data!;
    } on AuthFailure {
      rethrow;
    } on HttpRequestException catch (error) {
      throw _mapFailure(int.tryParse(error.code ?? ''), error.message);
    } catch (error) {
      throw _mapFailure(null, error.toString());
    }
  }

  Future<UserProfile> updateMe(UpdateUserProfileRequest request) async {
    AuthHttpConfig.ensureInitialized();
    try {
      final result = await HttpManager.instance.patch<ResultModel<UserProfile>>(
        mePath,
        data: request.toJson(),
        converter: _parseProfile,
      );
      final model = result.data;
      if (model == null || !model.isSuccess || model.data == null) {
        throw _mapFailure(model?.code, model?.message);
      }
      return model.data!;
    } on AuthFailure {
      rethrow;
    } on HttpRequestException catch (error) {
      throw _mapFailure(int.tryParse(error.code ?? ''), error.message);
    } catch (error) {
      throw _mapFailure(null, error.toString());
    }
  }

  static ResultModel<UserProfile> _parseProfile(dynamic json) {
    return ResultModel.object(
      json as Map<String, dynamic>,
      UserProfile.fromJson,
    );
  }

  AuthFailure _mapFailure(int? code, String? message) {
    final text = message?.trim() ?? '';
    if (code == 10001 ||
        text.contains('avatar_base64') ||
        text.contains('avatar_mime') ||
        text.contains('头像过大') ||
        text.contains('参数错误')) {
      return UnknownAuthFailure(text.isEmpty ? '资料参数无效' : text);
    }
    if (code == 401 || text.contains('未授权') || text.contains('Unauthorized')) {
      return const UnknownAuthFailure('登录已失效，请重新登录');
    }
    return UnknownAuthFailure(text.isEmpty ? '资料请求失败' : text);
  }
}
