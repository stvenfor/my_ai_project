/// 收货人 / 手机号等联系信息校验（地址簿等表单共用）。
abstract final class WysContactValidators {
  WysContactValidators._();

  /// 收货人 / 昵称最大字数。
  static const int maxNameLength = 12;

  /// 国内手机号最大位数。
  static const int maxCnMobileLength = 11;

  /// 收货人非空且不超过 [maxNameLength]。
  static bool isNameValid(String name) {
    final t = name.trim();
    return t.isNotEmpty && t.length <= maxNameLength;
  }

  /// 国内手机号：仅数字、以 `1` 开头、恰好 [maxCnMobileLength] 位。
  static bool isCnMobile(String phone) {
    final digits = digitsOnly(phone);
    return RegExp(r'^1\d{10}$').hasMatch(digits);
  }

  /// 去掉非数字字符。
  static String digitsOnly(String input) =>
      input.replaceAll(RegExp(r'\D'), '');
}
