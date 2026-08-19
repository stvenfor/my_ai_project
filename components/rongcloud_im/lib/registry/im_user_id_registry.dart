import 'dart:convert';

import 'package:module_global_cache/prefs/sp_keys.dart';
import 'package:module_global_cache/prefs/sp_manager.dart';
import 'package:module_utils/module_utils.dart';
import 'package:uuid/uuid.dart';

/// 业务 userId ↔ 独立 imUserId 映射（Mock：本地生成并持久化）。
class ImUserIdRegistry {
  ImUserIdRegistry({SpManager? sp}) : _sp = sp ?? SpManager.instance;

  final SpManager _sp;
  final _uuid = const Uuid();
  Map<String, String>? _cache;

  Future<String> resolveImUserId(String bizUserId) async {
    await _ensureLoaded();
    final existing = _cache![bizUserId];
    if (existing != null) return existing;

    final imUserId = 'im_u_${_uuid.v4().replaceAll('-', '').substring(0, 16)}';
    _cache![bizUserId] = imUserId;
    await _persist();
    LogUtils.i('[ImUserIdRegistry] mapped biz=$bizUserId im=$imUserId');
    return imUserId;
  }

  Future<void> _ensureLoaded() async {
    if (_cache != null) return;
    final raw = _sp.getString(SpKeys.imBizToImUserId);
    if (raw == null || raw.isEmpty) {
      _cache = {};
      return;
    }
    try {
      _cache = Map<String, String>.from(jsonDecode(raw) as Map);
    } catch (_) {
      _cache = {};
    }
  }

  Future<void> _persist() async {
    await _sp.setString(SpKeys.imBizToImUserId, jsonEncode(_cache));
  }
}
