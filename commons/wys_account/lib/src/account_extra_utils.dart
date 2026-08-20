/// 登录态 extra 可能是 LoginEntity.toJson() 的
/// `{ raw: { currentUser: {...} } }` 结构。
Map<String, dynamic> flattenAccountExtra(Map<String, dynamic>? extra) {
  if (extra == null || extra.isEmpty) return const {};
  final flat = Map<String, dynamic>.from(extra);
  final raw = extra['raw'];
  if (raw is Map) {
    final rawMap = Map<String, dynamic>.from(raw);
    flat.addAll(rawMap);
    final currentUser = rawMap['currentUser'];
    if (currentUser is Map) {
      for (final entry in Map<String, dynamic>.from(currentUser).entries) {
        flat.putIfAbsent(entry.key, () => entry.value);
      }
    }
  }
  return flat;
}
