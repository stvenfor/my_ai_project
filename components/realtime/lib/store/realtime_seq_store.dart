import 'dart:async';
import 'dart:convert';

import 'package:module_global_cache/prefs/sp_keys.dart';
import 'package:module_global_cache/prefs/sp_manager.dart';
import 'package:module_realtime/config/realtime_config.dart';

/// 全局 seq 与 notifyId 去重。
class RealtimeSeqStore {
  int _lastSeq = 0;

  int get lastSeq => _lastSeq;

  Future<void> load() async {
    final raw = SpManager.instance.getString(SpKeys.realtimeLastSeq);
    _lastSeq = int.tryParse(raw ?? '') ?? 0;
  }

  Future<void> save() async {
    await SpManager.instance.setString(
      SpKeys.realtimeLastSeq,
      '$_lastSeq',
    );
  }

  bool acceptSeq(int? seq) {
    if (seq == null) return true;
    if (seq <= _lastSeq) return false;
    _lastSeq = seq;
    unawaited(save());
    return true;
  }

  void setLastSeq(int seq) {
    if (seq > _lastSeq) {
      _lastSeq = seq;
      unawaited(save());
    }
  }
}

class NotifyDedupStore {
  final List<String> _ids = [];

  Future<void> load() async {
    final raw = SpManager.instance.getString(SpKeys.realtimeNotifyDedup);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _ids
        ..clear()
        ..addAll(list.map((e) => e.toString()));
    } catch (_) {
      _ids.clear();
    }
  }

  Future<bool> shouldProcess(String notifyId) async {
    if (notifyId.isEmpty) return true;
    if (_ids.contains(notifyId)) return false;
    _ids.insert(0, notifyId);
    if (_ids.length > RealtimeConfig.notifyDedupMax) {
      _ids.removeRange(RealtimeConfig.notifyDedupMax, _ids.length);
    }
    await SpManager.instance.setString(
      SpKeys.realtimeNotifyDedup,
      jsonEncode(_ids),
    );
    return true;
  }
}
