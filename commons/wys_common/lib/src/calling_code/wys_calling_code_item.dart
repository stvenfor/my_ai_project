/// 国家 / 地区区号项，对齐安卓 `CallingCode` 与 CDN `countrycode.json`。
class WysCallingCodeItem {
  const WysCallingCodeItem({required this.name, required this.code});

  /// 展示名，如「中国」。
  final String name;

  /// 回传区号，形如 `+86`。
  final String code;
}
