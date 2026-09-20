import 'package:wys_network/wys_network.dart';

import 'src/account_repository.dart';
import 'src/models/account_user.dart';

export 'src/account_repository.dart';
export 'src/account_extra_utils.dart';
export 'src/mock/mock_account_session.dart';
export 'src/models/account_user.dart';

/// 账号模块入口：初始化后各 feature module 通过 [AccountRepository] 读登录态。
///
/// 已废弃：产品 Session Owner 为 `module_auth`（`AuthLifecycle` / `UserService`）。
/// 勿在新代码中调用 [initialize]；见 ADR 0009。
@Deprecated(
  'Use module_auth (AuthLifecycle / UserService). '
  'Do not initialize WysAccount in new code. See ADR 0009.',
)
abstract final class WysAccount {
  /// 应用启动时调用一次（建议在 main 里、runApp 前）。
  static Future<void> initialize({
    bool bindNetHeaders = true,
    bool? enableMockSession,
  }) async {
    await AccountRepository.ensureInitialized(
      enableMockSession: enableMockSession,
    );
    if (bindNetHeaders) {
      globalHeaderProvider = () {
        final token = AccountRepository.instance.token;
        if (token == null || token.isEmpty) {
          WysNetworkConfig.accessToken = '';
          return <String, String>{};
        }
        WysNetworkConfig.accessToken = token;
        return <String, String>{
          'Authorization': 'Bearer $token',
          'token': token,
        };
      };
      final t = AccountRepository.instance.token;
      if (t != null && t.isNotEmpty) WysNetworkConfig.accessToken = t;
    }
  }

  static AccountRepository get repo => AccountRepository.instance;

  static bool get isLoggedIn => AccountRepository.instance.isLoggedIn;

  static AccountUser? get currentUser => AccountRepository.instance.currentUser;

  static String? get token => AccountRepository.instance.token;

  static Future<void> setSession(AccountUser user) =>
      AccountRepository.instance.setSession(user);

  static Future<void> logout() => AccountRepository.instance.logout();
}
