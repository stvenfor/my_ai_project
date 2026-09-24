import 'package:module_http/module_http.dart';
import 'package:module_rongcloud_im/config/rong_im_config.dart';

class ImFriendUser {
  const ImFriendUser({
    required this.userId,
    required this.displayName,
    this.avatarUrl = '',
    this.phoneMasked = '',
  });

  final String userId;
  final String displayName;
  final String avatarUrl;
  final String phoneMasked;

  factory ImFriendUser.fromJson(Map<String, dynamic> json) {
    return ImFriendUser(
      userId: (json['user_id'] ?? '').toString(),
      displayName: (json['display_name'] ?? '').toString(),
      avatarUrl: (json['avatar_url'] ?? '').toString(),
      phoneMasked: (json['phone_masked'] ?? '').toString(),
    );
  }
}

class ImFriendRequest {
  const ImFriendRequest({
    required this.id,
    required this.fromUserId,
    required this.displayName,
    this.avatarUrl = '',
    this.phoneMasked = '',
    this.status = 'pending',
    this.createdAt = '',
  });

  final String id;
  final String fromUserId;
  final String displayName;
  final String avatarUrl;
  final String phoneMasked;
  final String status;
  final String createdAt;

  factory ImFriendRequest.fromJson(Map<String, dynamic> json) {
    return ImFriendRequest(
      id: (json['id'] ?? '').toString(),
      fromUserId: (json['from_user_id'] ?? '').toString(),
      displayName: (json['display_name'] ?? '').toString(),
      avatarUrl: (json['avatar_url'] ?? '').toString(),
      phoneMasked: (json['phone_masked'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }
}

class ImFriendApi {
  /// 把后端英文错误转成可读提示；重复申请视为「已发送」。
  static String friendlyError(Object e, {String fallback = '操作失败'}) {
    final raw = e is HttpRequestException ? e.message : e.toString();
    final m = raw.toLowerCase();
    if (m.contains('already pending')) return '已发送过申请，等待对方同意';
    if (m.contains('already friends')) return '你们已经是好友了';
    if (m.contains('cannot friend yourself')) return '不能添加自己';
    if (m.contains('user not found')) return '用户不存在';
    if (m.contains('not the request recipient')) return '无权处理该申请';
    if (raw.trim().isEmpty || raw.startsWith('HttpRequestException')) {
      return fallback;
    }
    return raw;
  }

  Future<List<ImFriendUser>> search(String q) async {
    final result = await HttpManager.instance.get<ResultModel<Map<String, dynamic>>>(
      RongImConfig.usersSearchPath,
      queryParameters: {'q': q},
      converter: (json) => ResultModel.object(
        Map<String, dynamic>.from(json as Map),
        (m) => m,
      ),
    );
    final data = result.data?.data;
    if (result.data?.isSuccess != true || data == null) {
      throw HttpRequestException(
        message: result.data?.message ?? '搜索失败',
        code: result.data?.code.toString(),
      );
    }
    final items = (data['items'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => ImFriendUser.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return items;
  }

  Future<List<ImFriendUser>> listFriends() async {
    final result = await HttpManager.instance.get<ResultModel<Map<String, dynamic>>>(
      RongImConfig.friendsPath,
      converter: (json) => ResultModel.object(
        Map<String, dynamic>.from(json as Map),
        (m) => m,
      ),
    );
    final data = result.data?.data;
    if (result.data?.isSuccess != true || data == null) {
      throw HttpRequestException(
        message: result.data?.message ?? '好友列表失败',
        code: result.data?.code.toString(),
      );
    }
    return (data['items'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => ImFriendUser.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<ImFriendRequest>> listIncomingRequests() async {
    final result = await HttpManager.instance.get<ResultModel<Map<String, dynamic>>>(
      RongImConfig.friendRequestsPath,
      converter: (json) => ResultModel.object(
        Map<String, dynamic>.from(json as Map),
        (m) => m,
      ),
    );
    final data = result.data?.data;
    if (result.data?.isSuccess != true || data == null) {
      throw HttpRequestException(
        message: result.data?.message ?? '申请列表失败',
        code: result.data?.code.toString(),
      );
    }
    return (data['items'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => ImFriendRequest.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> requestFriend(String toUserId) async {
    final result = await HttpManager.instance.post<ResultModel<Map<String, dynamic>>>(
      RongImConfig.friendRequestsPath,
      data: {'to_user_id': toUserId},
      converter: (json) => ResultModel.object(
        Map<String, dynamic>.from(json as Map),
        (m) => m,
      ),
    );
    if (result.data?.isSuccess != true) {
      throw HttpRequestException(
        message: result.data?.message ?? '申请失败',
        code: result.data?.code.toString(),
      );
    }
  }

  Future<void> respondFriend(String requestId, {required bool accept}) async {
    final result = await HttpManager.instance.post<ResultModel<Map<String, dynamic>>>(
      '${RongImConfig.friendRequestsPath}/$requestId/respond',
      data: {'accept': accept},
      converter: (json) => ResultModel.object(
        Map<String, dynamic>.from(json as Map),
        (m) => m,
      ),
    );
    if (result.data?.isSuccess != true) {
      throw HttpRequestException(
        message: result.data?.message ?? '处理失败',
        code: result.data?.code.toString(),
      );
    }
  }

  Future<bool> canPrivateChat(String peerUserId) async {
    final result = await HttpManager.instance.get<ResultModel<Map<String, dynamic>>>(
      RongImConfig.privateAdmissionPath,
      queryParameters: {'peer_user_id': peerUserId},
      converter: (json) => ResultModel.object(
        Map<String, dynamic>.from(json as Map),
        (m) => m,
      ),
    );
    return result.data?.data?['allowed'] == true;
  }
}
