import 'dart:async';

import 'package:module_global_cache/prefs/sp_keys.dart';
import 'package:module_global_cache/prefs/sp_manager.dart';
import 'package:module_utils/module_utils.dart';

typedef PrivacyGrantedCallback = Future<void> Function();

/// 应用级隐私协议（未同意前禁止初始化 JPush）。
class PrivacyConsentService {
  static PrivacyGrantedCallback? onGranted;

  bool get isGranted =>
      SpManager.instance.getBool(SpKeys.privacyConsentGranted) ?? false;

  Future<void> grant() async {
    await SpManager.instance.setBool(SpKeys.privacyConsentGranted, true);
    LogUtils.i('[Privacy] user granted privacy consent');
    // Push / Realtime / IM 初始化走后台，避免 Splash 一直转圈。
    final cb = onGranted;
    if (cb != null) {
      unawaited(cb());
    }
  }

  Future<void> revokeForDebug() async {
    await SpManager.instance.setBool(SpKeys.privacyConsentGranted, false);
    LogUtils.w('[Privacy] consent revoked (debug)');
  }
}
