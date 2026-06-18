import 'dart:convert';

import 'package:module_core/model/im/im_user_profile.dart';
import 'package:module_global_cache/prefs/sp_keys.dart';
import 'package:module_global_cache/prefs/sp_manager.dart';
import 'package:module_rongcloud_im/api/im_user_profile_api.dart';
import 'package:module_rongcloud_im/config/rong_im_config.dart';
import 'package:module_core/service/im_user_profile_service.dart';

/// 业务用户资料 + 客户端缓存。
class CachedImUserProfileService implements ImUserProfileService {
  CachedImUserProfileService({
    required ImUserProfileApi api,
    SpManager? sp,
  })  : _api = api,
        _sp = sp ?? SpManager.instance;

  final ImUserProfileApi _api;
  final SpManager _sp;
  final _memory = <String, _CacheEntry>{};

  @override
  Future<ImUserProfile?> getProfile(String imUserId) async {
    final map = await getProfiles([imUserId]);
    return map[imUserId];
  }

  @override
  Future<Map<String, ImUserProfile>> getProfiles(List<String> imUserIds) async {
    if (imUserIds.isEmpty) return {};
    await _loadDiskCache();
    final result = <String, ImUserProfile>{};
    final missing = <String>[];

    for (final id in imUserIds) {
      final cached = _memory[id];
      if (cached != null && !cached.isExpired) {
        result[id] = cached.profile;
      } else {
        missing.add(id);
      }
    }

    if (missing.isNotEmpty) {
      final remote = await _api.fetchProfiles(missing);
      final now = DateTime.now();
      for (final entry in remote.entries) {
        _memory[entry.key] = _CacheEntry(entry.value, now);
        result[entry.key] = entry.value;
      }
      await _persistDiskCache();
    }

    return result;
  }

  @override
  Future<void> prefetch(List<String> imUserIds) async {
    await getProfiles(imUserIds);
  }

  Future<void> _loadDiskCache() async {
    if (_memory.isNotEmpty) return;
    final raw = _sp.getString(SpKeys.imProfileCache);
    if (raw == null || raw.isEmpty) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in map.entries) {
        final value = entry.value as Map<String, dynamic>;
        final profile = ImUserProfile(
          imUserId: value['imUserId'] as String,
          displayName: value['displayName'] as String? ?? '',
          avatarUrl: value['avatarUrl'] as String? ?? '',
        );
        final cachedAt = DateTime.tryParse(value['cachedAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        _memory[entry.key] = _CacheEntry(profile, cachedAt);
      }
    } catch (_) {}
  }

  Future<void> _persistDiskCache() async {
    final map = <String, dynamic>{};
    for (final entry in _memory.entries) {
      map[entry.key] = {
        'imUserId': entry.value.profile.imUserId,
        'displayName': entry.value.profile.displayName,
        'avatarUrl': entry.value.profile.avatarUrl,
        'cachedAt': entry.value.cachedAt.toIso8601String(),
      };
    }
    await _sp.setString(SpKeys.imProfileCache, jsonEncode(map));
  }
}

class _CacheEntry {
  _CacheEntry(this.profile, this.cachedAt);

  final ImUserProfile profile;
  final DateTime cachedAt;

  bool get isExpired =>
      DateTime.now().difference(cachedAt) > RongImConfig.profileCacheTtl;
}
