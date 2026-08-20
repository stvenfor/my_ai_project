import 'package:phone_numbers_parser/phone_numbers_parser.dart';

/// 账号侧手机号校验，对齐 Android `AccountUtils` + `PhoneUtils`（Google libphonenumber）。
///
/// Android 流程：
/// 1. `isValidCountryCallingCode(callingCode)`
/// 2. `formatNumberToE164("+{cc}{national}")`
/// 3. `isValidMobileNumber`（有效号且类型为 MOBILE / FIXED_LINE_OR_MOBILE / PERSONAL_NUMBER）
abstract final class WysPhoneAccountUtils {
  WysPhoneAccountUtils._();

  /// [callingCode] 形如 `+86` / `86`；[phone] 为国家码之后的国内号段。
  static bool isValidPhone(String callingCode, String phone) {
    return fullPhoneE164(callingCode, phone) != null;
  }

  /// 返回 E.164（如 `+8613800138000`）；非法则 `null`。
  static String? fullPhoneE164(String callingCode, String phone) {
    final cc = _digitsOnly(callingCode.replaceAll('+', ''));
    var national = _digitsOnly(phone);
    if (cc.isEmpty || national.isEmpty) return null;
    if (national.startsWith('0')) {
      national = national.substring(1);
      if (national.isEmpty) return null;
    }

    final PhoneNumber parsed;
    try {
      parsed = PhoneNumber.parse('+$cc$national');
    } catch (_) {
      return null;
    }

    // 区号必须与解析结果一致（对齐 Android 先校验 calling code 再拼 E164）。
    if (parsed.countryCode != cc) return null;

    // 对齐 PhoneUtils.isValidMobileNumber：手机 / 固话或手机 / 个人号码。
    final isMobile = parsed.isValid(type: PhoneNumberType.mobile);
    final isPersonal = parsed.isValid(type: PhoneNumberType.personalNumber);
    // FIXED_LINE_OR_MOBILE：仅固话 pattern 命中且手机未命中时排除；
    // 若手机元数据为空而 general 有效，用「有效且非纯固话」兜底。
    final isFixedOnly =
        parsed.isValid(type: PhoneNumberType.fixedLine) && !isMobile;
    final ok =
        isMobile || isPersonal || (parsed.isValid() && !isFixedOnly);
    if (!ok) return null;
    return parsed.international;
  }

  /// 发码 / 业务提交用账号串：国内 `+86` 传 11 位国号，其它区号传 E.164。
  ///
  /// 对齐本仓登录实测与 CancelAccountController.phoneForMsgSend 口径。
  static String? phoneForMsgSend(String callingCode, String phone) {
    final e164 = fullPhoneE164(callingCode, phone);
    if (e164 == null) return null;
    if (e164.startsWith('+86')) {
      final national = e164.substring(3);
      return national.isEmpty ? null : national;
    }
    return e164;
  }

  static String _digitsOnly(String input) =>
      input.replaceAll(RegExp(r'\D'), '');
}
