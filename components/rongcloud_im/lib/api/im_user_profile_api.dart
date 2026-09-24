import 'package:module_core/model/im/im_user_profile.dart';
import 'package:module_core/service/environment_service.dart';
import 'package:module_http/module_http.dart';
import 'package:module_rongcloud_im/config/rong_im_config.dart';
import 'package:module_utils/module_utils.dart';

/// GET /api/v1/im/users/profile（Mock 仅在 PLACEHOLDER / USE_MOCK_IM）。
class ImUserProfileApi {
  ImUserProfileApi({EnvironmentService? envService}) : _envService = envService;

  final EnvironmentService? _envService;

  bool get _mock => RongImConfig.useMockImFor(_envService?.rongAppKey);

  Future<Map<String, ImUserProfile>> fetchProfiles(List<String> imUserIds) async {
    final ids = imUserIds.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (ids.isEmpty) return {};

    if (_mock) {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final result = <String, ImUserProfile>{};
      for (final id in ids) {
        result[id] = ImUserProfile(
          imUserId: id,
          displayName: _mockName(id),
          avatarUrl: 'https://picsum.photos/seed/$id/200/200',
        );
      }
      LogUtils.d('[ImUserProfileApi] mock profiles count=${result.length}');
      return result;
    }

    final result = await HttpManager.instance.get<ResultModel<Map<String, dynamic>>>(
      RongImConfig.profilePath,
      queryParameters: {'user_ids': ids.join(',')},
      converter: (json) => ResultModel.object(
        Map<String, dynamic>.from(json as Map),
        (m) => m,
      ),
    );
    final data = result.data?.data;
    if (result.data?.isSuccess != true || data == null) {
      throw HttpRequestException(
        message: result.data?.message ?? '拉取 IM 用户资料失败',
        code: result.data?.code.toString(),
      );
    }
    final items = (data['items'] as List? ?? const []).whereType<Map>();
    final out = <String, ImUserProfile>{};
    for (final raw in items) {
      final m = Map<String, dynamic>.from(raw);
      final id = (m['user_id'] ?? m['im_user_id'] ?? '').toString();
      if (id.isEmpty) continue;
      out[id] = ImUserProfile(
        imUserId: id,
        displayName: (m['display_name'] ?? '').toString(),
        avatarUrl: (m['avatar_url'] ?? '').toString(),
      );
    }
    LogUtils.d('[ImUserProfileApi] real profiles count=${out.length}');
    return out;
  }

  String _mockName(String imUserId) {
    if (imUserId.contains('mock_peer')) {
      return 'Mock好友${imUserId.substring(imUserId.length - 2)}';
    }
    final tail = imUserId.length <= 4 ? imUserId : imUserId.substring(0, 4);
    return '用户$tail';
  }
}
