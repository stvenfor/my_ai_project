import 'wys_prefs.dart';

/// App 首次隐私协议同意状态的统一入口。
abstract final class WysPrivacyConsent {
  WysPrivacyConsent._();

  static const String storageKey = 'splash.is_first_use';

  static Future<bool> isAccepted() async {
    final isFirstUse = await WysPrefs.getBool(storageKey, defaultValue: true);
    return !isFirstUse;
  }

  static Future<void> accept() => WysPrefs.save(storageKey, false);
}
