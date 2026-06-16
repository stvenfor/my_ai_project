/// 中国大陆手机号校验与 E.164 格式化（Supabase Phone OTP 要求 +86 前缀）。
class PhoneAuthUtils {
  PhoneAuthUtils._();

  static bool isValidChinaMobile(String raw) {
    final digits = raw.replaceAll(RegExp(r'\s+'), '');
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(digits);
  }

  static String normalizeDigits(String raw) =>
      raw.replaceAll(RegExp(r'\s+'), '');

  static String toE164China(String raw) {
    final digits = normalizeDigits(raw);
    if (digits.startsWith('+86')) return digits;
    if (digits.startsWith('86') && digits.length == 13) return '+$digits';
    return '+86$digits';
  }
}
