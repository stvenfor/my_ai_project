import '../https_client.dart';
import 'wys_rsa_util.dart';

abstract final class WysPaySecurityApi {
  WysPaySecurityApi._();

  static const getPublicKey = '/out-api/auth/login/getPublicKey';
  static const payPwdSet = '/member-v2/my/payPwdSet';
  /// Android `SettingService.validPayPwd`：验证支付密码。
  static const validPayPwd = '/member-v2/my/validPayPwd';
}

/// 小葵花支付密码：公钥获取、RSA 加密、设置/修改支付密码。
class WysPaySecurityRepository {
  WysPaySecurityRepository({HttpsClient? client})
    : _client = client ?? HttpsClient.instance;

  final HttpsClient _client;
  String? _cachedPublicKey;

  Future<String?> fetchPublicKey({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedPublicKey != null && _cachedPublicKey!.isNotEmpty) {
      return _cachedPublicKey;
    }
    final res = await _client.getApi<dynamic>(WysPaySecurityApi.getPublicKey);
    if (!res.isSuccess) return null;
    final data = res.data;
    String? key;
    if (data is Map) {
      key = data['publicKey']?.toString();
    } else if (data is String) {
      key = data;
    }
    if (key == null || key.isEmpty) return null;
    _cachedPublicKey = key;
    return key;
  }

  Future<String?> encryptPassword(String password) async {
    final key = await fetchPublicKey();
    if (key == null || key.isEmpty) return null;
    try {
      return WysRsaUtil.encode(password, key);
    } catch (_) {
      return null;
    }
  }

  Future<({bool ok, String? message})> setPayPassword({
    required String payPasswordPlain,
    required String ackPayPasswordPlain,
    int? checkType,
    String? oldPayPasswordPlain,
    Map<String, dynamic>? identityDTO,
    Map<String, dynamic>? validCodeDTO,
  }) async {
    final key = await fetchPublicKey();
    if (key == null || key.isEmpty) {
      return (ok: false, message: '获取加密密钥失败');
    }
    final payPassword = WysRsaUtil.encode(payPasswordPlain, key);
    final ackPayPassword = WysRsaUtil.encode(ackPayPasswordPlain, key);
    final payload = <String, dynamic>{
      'payPassword': payPassword,
      'ackPayPassword': ackPayPassword,
      if (checkType != null) 'checkType': checkType,
    };
    if (oldPayPasswordPlain != null && oldPayPasswordPlain.isNotEmpty) {
      payload['oldPayPassword'] = WysRsaUtil.encode(oldPayPasswordPlain, key);
    }
    if (identityDTO != null) {
      payload['identityDTO'] = identityDTO;
    }
    if (validCodeDTO != null) {
      payload['validCodeDTO'] = validCodeDTO;
    }
    final res = await _client.postApi<dynamic>(
      WysPaySecurityApi.payPwdSet,
      data: payload,
    );
    return (ok: res.isSuccess, message: res.message);
  }

  /// 对齐 Android `setttingUtils.matchPayPsw`：RSA 后校验旧支付密码。
  Future<({bool ok, bool matched, String? message})> verifyPayPassword({
    required String payPasswordPlain,
  }) async {
    final key = await fetchPublicKey();
    if (key == null || key.isEmpty) {
      return (ok: false, matched: false, message: '获取加密密钥失败');
    }
    final encoded = WysRsaUtil.encode(payPasswordPlain, key);
    final res = await _client.postApi<dynamic>(
      WysPaySecurityApi.validPayPwd,
      data: <String, dynamic>{
        'payPassword': encoded,
        'ackPayPassword': encoded,
      },
    );
    if (!res.isSuccess) {
      return (ok: false, matched: false, message: res.message);
    }
    final data = res.data;
    final matched = data == true || data == 1 || data == '1' || data == 'true';
    return (ok: true, matched: matched, message: res.message);
  }
}
