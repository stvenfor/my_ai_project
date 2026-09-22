import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:module_auth/api/user_profile_api.dart';
import 'package:module_auth/api/user_profile_models.dart';
import 'package:module_auth/session/user_profile_sync.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_community/community/repository/http_post_repository.dart';
import 'package:module_community/community/repository/post_repository.dart';
import 'package:module_core/core.dart';
import 'package:module_http/module_http.dart';
import 'package:module_utils/module_utils.dart';
import 'package:module_video/short_video/model/short_video_models.dart';
import 'package:module_video/short_video/repository/http_short_video_repository.dart';
import 'package:module_video/short_video/repository/short_video_repository.dart';
import 'package:module_video/short_video/utils/short_video_capture_permission.dart';
import 'package:wys_router/src/route/route_path.dart';

/// 小视频列表 / 资料 / 删除 / 分页。
///
/// 顶栏身份（昵称/头像/职务/门店）与「我的」同源：`UserService` + `GET /profiles/me`；
/// 视频统计仍来自 `GET /short-videos/profile`。
class ShortVideoController extends GetxController {
  ShortVideoController({
    ShortVideoRepository? repository,
    UserProfileApi? profileApi,
  })  : _repo = repository ?? HttpShortVideoRepository(),
        _profileApi = profileApi ?? UserProfileApi();

  final ShortVideoRepository _repo;
  final UserProfileApi _profileApi;

  static const pageSize = 5;
  /// 与 MineController 同一占位图。
  static const _defaultAvatar =
      'https://picsum.photos/seed/mine_profile/200/200';

  final profile = Rxn<ShortVideoProfileModel>();
  final items = <ShortVideoItemModel>[].obs;
  final loading = false.obs;
  final refreshing = false.obs;
  final loadingMore = false.obs;
  final hasMore = true.obs;

  /// 本人职务 / 门店 / 头像（来自 `/profiles/me`，与「我的」一致）。
  final roleBadge = '销售顾问'.obs;
  final storeName = ''.obs;
  final identityAvatar = ''.obs;
  final identityName = ''.obs;

  int _page = 0;

  List<ShortVideoItemModel> get gridItems => [
        ShortVideoItemModel.publishTile,
        ...items,
      ];

  /// 本人身份对齐「我的」。
  ShortVideoProfileModel get displayProfile {
    final p = profile.value;
    final user = Get.find<UserService>().currentUser.value;
    final stats = p?.stats ?? ShortVideoStatsModel.empty;
    final isMe = p?.isMe ?? true;

    if (!isMe && p != null) {
      return ShortVideoProfileModel(
        userId: p.userId,
        displayName: p.displayName.isNotEmpty ? p.displayName : '用户',
        avatarUrl:
            p.avatarUrl?.isNotEmpty == true ? p.avatarUrl : _defaultAvatar,
        roleBadge: p.roleBadge.isNotEmpty ? p.roleBadge : '',
        storeName: p.storeName,
        isMe: false,
        stats: stats,
      );
    }

    // 优先级与 Mine 一致：UserService → profiles/me 缓存 → 默认
    final name = _firstNonEmpty([
      user?.name,
      identityName.value,
      p?.displayName,
      '东东枪',
    ]);
    final avatar = _firstNonEmpty([
      user?.avatar,
      identityAvatar.value,
      p?.avatarUrl,
      _defaultAvatar,
    ]);

    return ShortVideoProfileModel(
      userId: p?.userId ?? user?.id,
      displayName: name,
      avatarUrl: avatar,
      roleBadge: roleBadge.value.isNotEmpty ? roleBadge.value : '销售顾问',
      storeName: storeName.value.isNotEmpty
          ? storeName.value
          : '[4S]北京沃德龙鼎吉利',
      isMe: true,
      stats: stats,
    );
  }

  static String _firstNonEmpty(List<String?> candidates) {
    for (final c in candidates) {
      if (c != null && c.trim().isNotEmpty) return c.trim();
    }
    return '';
  }

  @override
  void onInit() {
    super.onInit();
    ensureCommunityTopicsRepo();
    load();
  }

  static void ensureCommunityTopicsRepo() {
    if (!Get.isRegistered<PostRepository>()) {
      Get.put<PostRepository>(HttpPostRepository());
    }
  }

  Future<void> load() async {
    loading.value = true;
    _page = 0;
    try {
      await Future.wait([_loadProfile(), _loadList(reset: true)]);
    } finally {
      loading.value = false;
    }
  }

  Future<void> refreshAll() async {
    refreshing.value = true;
    _page = 0;
    try {
      await Future.wait([_loadProfile(), _loadList(reset: true)]);
    } finally {
      refreshing.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value || loadingMore.value || loading.value) return;
    loadingMore.value = true;
    try {
      _page += 1;
      await _loadList(reset: false);
    } finally {
      loadingMore.value = false;
    }
  }

  Future<void> _loadProfile() async {
    try {
      // 先 hydrate，保证 UserService 头像与「我的」一致（含 data: URL）
      await UserProfileSync.hydrateQuietly();

      final results = await Future.wait([
        _repo.fetchProfile(),
        _profileApi.fetchMe(),
      ]);
      profile.value = results[0] as ShortVideoProfileModel;
      _applyMineIdentity(results[1] as UserProfile);
    } catch (e) {
      // 视频 profile 失败再尝试只拉身份
      try {
        await UserProfileSync.hydrateQuietly();
        final me = await _profileApi.fetchMe();
        _applyMineIdentity(me);
      } catch (_) {}
      if (profile.value == null) {
        _toastErr(e, '加载资料失败');
      }
    }
  }

  void _applyMineIdentity(UserProfile me) {
    final name = me.displayName.isNotEmpty ? me.displayName : me.userName;
    final avatar = me.avatarUrl.trim();
    final label = me.stats.roleLabel.trim();
    final store = me.stats.storeName.trim();

    if (name.isNotEmpty) identityName.value = name;
    if (avatar.isNotEmpty) identityAvatar.value = avatar;
    if (label.isNotEmpty) roleBadge.value = label;
    if (store.isNotEmpty) storeName.value = store;

    final p = profile.value;
    if (p != null && p.isMe) {
      profile.value = ShortVideoProfileModel(
        userId: p.userId,
        displayName: name.isNotEmpty ? name : p.displayName,
        avatarUrl: avatar.isNotEmpty ? avatar : p.avatarUrl,
        roleBadge: roleBadge.value,
        storeName: storeName.value,
        isMe: true,
        stats: p.stats,
      );
    }
  }

  Future<void> _loadList({required bool reset}) async {
    try {
      final page = await _repo.fetchList(
        scope: 'user',
        page: _page,
        pageSize: pageSize,
      );
      if (reset) {
        items.assignAll(page.list);
      } else {
        items.addAll(page.list);
      }
      hasMore.value = page.hasMore;
    } catch (e) {
      if (!reset) _page = (_page - 1).clamp(0, 1 << 30);
      _toastErr(e, '加载小视频失败');
    }
  }

  Future<void> startPublishFlow() async {
    final source = await MediaSourceBottomSheet.show();
    if (source == null) return;
    try {
      if (source == MediaPickSource.camera) {
        final ok = await ShortVideoCapturePermission.ensureForCameraCapture();
        if (!ok) return;
      }
      final path = await ImagePickerUtils.pickVideo(
        source,
        skipPermissionCheck: source == MediaPickSource.camera,
      );
      if (path == null || path.isEmpty) return;
      await Get.toNamed(
        RoutePath.shortVideoPublish,
        arguments: {'local_video_path': path},
      );
    } on PlatformException catch (_) {
      UiKitInitializer.toastError('无法选择视频，请检查相册或相机权限');
    } catch (_) {
      UiKitInitializer.toastError('选择视频失败');
    }
  }

  Future<bool> deleteVideo(String id) async {
    try {
      await _repo.delete(id);
      items.removeWhere((e) => e.id == id);
      await _loadProfile();
      return true;
    } catch (e) {
      _toastErr(e, '删除失败');
      return false;
    }
  }

  Future<void> toggleLike(String id, bool liked) async {
    try {
      final frag = await _repo.toggleLike(id, liked);
      final i = items.indexWhere((e) => e.id == id);
      if (i >= 0) {
        items[i] = items[i].copyWith(
          likeCount: frag.likeCount,
          isLiked: frag.isLiked,
        );
      }
      await _loadProfile();
    } catch (e) {
      _toastErr(e, '操作失败');
    }
  }

  Future<void> reportView(String id) async {
    try {
      final n = await _repo.reportView(id);
      final i = items.indexWhere((e) => e.id == id);
      if (i >= 0) {
        items[i] = items[i].copyWith(viewCount: n);
      }
    } catch (_) {}
  }

  void _toastErr(Object e, String fallback) {
    final msg = e is HttpRequestException
        ? (e.message.isNotEmpty ? e.message : fallback)
        : fallback;
    UiKitInitializer.toast(msg);
  }
}
