/// 字符串 / 展示文案小工具。
abstract final class WysText {
  WysText._();

  static bool isBlank(String? s) => s == null || s.trim().isEmpty;

  static bool isNotBlank(String? s) => !isBlank(s);

  /// 手机号中间 4 位掩码。
  static String maskPhone(String phone) {
    final p = phone.trim();
    if (p.length < 7) return p;
    return '${p.substring(0, 3)}****${p.substring(p.length - 4)}';
  }

  /// 价格展示（分 → 元，或已是元字符串）。
  static String priceYuan(num? centsOrYuan, {bool inputIsFen = false}) {
    if (centsOrYuan == null) return '0.00';
    final yuan = inputIsFen ? centsOrYuan / 100 : centsOrYuan;
    return yuan.toStringAsFixed(2);
  }
}