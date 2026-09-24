import 'package:module_http/module_http.dart';
import 'package:module_rongcloud_im/config/rong_im_config.dart';

class ImFriendUser {
  const ImFriendUser({
    required this.userId,
    required this.displayName,
    this.phoneMasked = '',
  });

  final String userId;
  final String displayName;
  final String phoneMasked;

  factory ImFriendUser.fromJson(Map<String, dynamic> json) {
    return ImFriendUser(
      userId: (json['user_id'] ?? '').toString(),
      displayName: (json['display_name'] ?? '').toString(),
      phoneMasked: (json['phone_masked'] ?? '').toString(),
    );
  }
}

class ImFriendApi {
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
