import 'package:module_http/module_http.dart';
import 'package:module_rongcloud_im/config/rong_im_config.dart';

class ImFreeGroupResult {
  const ImFreeGroupResult({
    required this.groupId,
    required this.name,
    required this.ownerUserId,
  });

  final String groupId;
  final String name;
  final String ownerUserId;

  factory ImFreeGroupResult.fromJson(Map<String, dynamic> json) {
    return ImFreeGroupResult(
      groupId: (json['group_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      ownerUserId: (json['owner_user_id'] ?? '').toString(),
    );
  }
}

class ImStoreGroupResult {
  const ImStoreGroupResult({
    required this.storeId,
    required this.groupId,
  });

  final String storeId;
  final String groupId;

  factory ImStoreGroupResult.fromJson(Map<String, dynamic> json) {
    return ImStoreGroupResult(
      storeId: (json['store_id'] ?? '').toString(),
      groupId: (json['group_id'] ?? '').toString(),
    );
  }
}

class ImGroupApi {
  Future<ImStoreGroupResult> syncStoreGroup(String storeId) async {
    final result = await HttpManager.instance.post<ResultModel<Map<String, dynamic>>>(
      RongImConfig.storeGroupSyncPath,
      data: {'store_id': storeId},
      converter: (json) => ResultModel.object(
        Map<String, dynamic>.from(json as Map),
        (m) => m,
      ),
    );
    final data = result.data?.data;
    if (result.data?.isSuccess != true || data == null) {
      throw HttpRequestException(
        message: result.data?.message ?? '门店群同步失败',
        code: result.data?.code.toString(),
      );
    }
    return ImStoreGroupResult.fromJson(data);
  }

  Future<ImFreeGroupResult> createFreeGroup({
    required String name,
    List<String> memberIds = const [],
  }) async {
    final result = await HttpManager.instance.post<ResultModel<Map<String, dynamic>>>(
      RongImConfig.freeGroupPath,
      data: {
        'name': name,
        'member_ids': memberIds,
      },
      converter: (json) => ResultModel.object(
        Map<String, dynamic>.from(json as Map),
        (m) => m,
      ),
    );
    final data = result.data?.data;
    if (result.data?.isSuccess != true || data == null) {
      throw HttpRequestException(
        message: result.data?.message ?? '建群失败',
        code: result.data?.code.toString(),
      );
    }
    return ImFreeGroupResult.fromJson(data);
  }

  Future<void> invite({
    required String groupId,
    required List<String> memberIds,
  }) async {
    await _postOk('${RongImConfig.freeGroupPath}/$groupId/invite', {
      'member_ids': memberIds,
    });
  }

  Future<void> kick({
    required String groupId,
    required List<String> memberIds,
  }) async {
    await _postOk('${RongImConfig.freeGroupPath}/$groupId/kick', {
      'member_ids': memberIds,
    });
  }

  Future<void> quit(String groupId) async {
    await _postOk('${RongImConfig.freeGroupPath}/$groupId/quit', {});
  }

  Future<void> dismiss(String groupId) async {
    await _postOk('${RongImConfig.freeGroupPath}/$groupId/dismiss', {});
  }

  Future<void> _postOk(String path, Map<String, dynamic> data) async {
    final result = await HttpManager.instance.post<ResultModel<Map<String, dynamic>>>(
      path,
      data: data,
      converter: (json) => ResultModel.object(
        Map<String, dynamic>.from(json as Map),
        (m) => m,
      ),
    );
    if (result.data?.isSuccess != true) {
      throw HttpRequestException(
        message: result.data?.message ?? '群操作失败',
        code: result.data?.code.toString(),
      );
    }
  }
}
