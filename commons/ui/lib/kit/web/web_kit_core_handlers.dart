import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:module_common_ui/kit/ui_kit_initializer.dart';
import 'package:module_core/core.dart';
import 'package:module_utils/utils/image_picker_utils.dart';

/// Core 级 Bridge handler，壳工程启动时统一注册（业务模块禁止覆盖）。
class WebKitCoreHandlers {
  WebKitCoreHandlers._();

  static void register(WebBridgeRegistry registry) {
    registry.register(WebBridgeActions.showToast, (message) async {
      final text = message.payload?['text']?.toString() ?? '';
      if (text.isEmpty) {
        return {'ok': false, 'message': 'toast 内容为空'};
      }
      UiKitInitializer.toast(text);
      return {'ok': true};
    });

    registry.register(WebBridgeActions.closeWithResult, (message) async {
      Get.back(result: message.payload);
      return {'ok': true};
    });

    registry.register(WebBridgeActions.getEnvironment, (message) async {
      if (!Get.isRegistered<EnvironmentService>()) {
        return {'ok': false, 'message': 'EnvironmentService 未注册'};
      }
      final env = Get.find<EnvironmentService>();
      return {
        'ok': true,
        'env': env.currentEnv.value.name,
        'label': env.config.label,
        'baseUrl': env.backendBaseUrl,
      };
    });

    registry.register(WebBridgeActions.switchEnvironment, (message) async {
      if (!Get.isRegistered<EnvironmentService>()) {
        return {'ok': false, 'message': 'EnvironmentService 未注册'};
      }
      final raw = message.payload?['env']?.toString();
      if (raw == null || raw.isEmpty) {
        return {'ok': false, 'message': '缺少 payload.env'};
      }
      final target = AppEnv.fromKey(raw);
      await Get.find<EnvironmentService>().setEnv(target);
      return {
        'ok': true,
        'env': target.name,
        'label': target.label,
      };
    });

    registry.register(WebBridgeActions.pickImage, (message) async {
      final sourceRaw = message.payload?['source']?.toString() ?? '';
      final MediaPickSource? source = switch (sourceRaw) {
        'gallery' => MediaPickSource.gallery,
        'camera' => MediaPickSource.camera,
        _ => null,
      };
      if (source == null) {
        return {'ok': false, 'message': 'payload.source 需为 gallery 或 camera'};
      }

      final path = source == MediaPickSource.camera
          ? await ImagePickerUtils.pickFromCamera()
          : await ImagePickerUtils.pickFromGallery();
      if (path == null || path.isEmpty) {
        return {'ok': true, 'cancelled': true};
      }

      final bytes = await File(path).readAsBytes();
      final mime = _imageMime(path);
      return {
        'ok': true,
        'cancelled': false,
        'mime': mime,
        'base64': base64Encode(bytes),
      };
    });

    registry.register(WebBridgeActions.getUserInfo, (message) async {
      if (!Get.isRegistered<UserService>()) {
        return {'ok': false, 'message': 'UserService 未注册'};
      }
      final user = Get.find<UserService>().currentUser.value;
      if (user == null) {
        return {'ok': true, 'loggedIn': false};
      }
      return {
        'ok': true,
        'loggedIn': true,
        'userId': user.id,
        'name': user.name,
        'avatar': user.avatar,
      };
    });
  }

  static String _imageMime(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}
