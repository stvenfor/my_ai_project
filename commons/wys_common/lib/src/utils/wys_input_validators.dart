/// 表单输入公共校验（地址收货人 / 资料昵称 / 大陆手机号）。
abstract final class WysInputValidators {
  WysInputValidators._();

  /// 昵称、收货人姓名上限（字数）。
  static const int maxNicknameLength = 12;

  /// 大陆手机号位数上限。
  static const int maxCnMobileLength = 11;

  /// 昵称 / 收货人：trim 后非空且不超过 [maxNicknameLength]。
  static bool isNicknameValid(String value) {
    final t = value.trim();
    return t.isNotEmpty && t.length <= maxNicknameLength;
  }

  /// 是否超长（用于输入中提示）；空串不算超长。
  static bool isNicknameTooLong(String value) =>
      value.trim().length > maxNicknameLength;

  /// 仅保留数字。
  static String digitsOnly(String input) =>
      input.replaceAll(RegExp(r'\D'), '');

  /// 大陆手机号：以 `1` 开头、纯数字、恰好 11 位（不超过 11）。
  static bool isCnMobile(String phone) {
    final digits = digitsOnly(phone);
    return RegExp(r'^1\d{10}$').hasMatch(digits);
  }
}
