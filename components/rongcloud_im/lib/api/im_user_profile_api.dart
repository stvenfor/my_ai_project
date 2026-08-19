import 'package:module_core/model/im/im_user_profile.dart';
import 'package:module_utils/module_utils.dart';

/// GET /im/users/profile Mock。
class ImUserProfileApi {
  Future<Map<String, ImUserProfile>> fetchProfiles(List<String> imUserIds) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final result = <String, ImUserProfile>{};
    for (final id in imUserIds) {
      result[id] = ImUserProfile(
        imUserId: id,
        displayName: _mockName(id),
        avatarUrl: 'https://picsum.photos/seed/$id/200/200',
      );
    }
    LogUtils.d('[ImUserProfileApi] mock profiles count=${result.length}');
    return result;
  }

  String _mockName(String imUserId) {
    if (imUserId.contains('mock_peer')) {
      return 'Mock好友${imUserId.substring(imUserId.length - 2)}';
    }
    return '用户${imUserId.substring(imUserId.length.clamp(0, 4))}';
  }
}
