import 'package:get/get.dart';
import 'package:module_core/web/web_bridge_actions.dart';
import 'package:module_core/web/web_message.dart';

/// 全局 Web Bridge handler 注册表，各业务模块在 [FeatureModule.onRegister] 中注册。
class WebBridgeRegistry extends GetxService {
  final Map<String, WebBridgeHandler> _handlers = {};

  /// 注册 action 处理器；同 action 后注册覆盖先注册。
  void register(String action, WebBridgeHandler handler) {
    _handlers[action] = handler;
  }

  /// 业务模块扩展注册；禁止覆盖 [WebBridgeActions.coreActions]。
  void registerModule(String action, WebBridgeHandler handler) {
    if (WebBridgeActions.isCoreAction(action)) {
      throw ArgumentError(
        'action "$action" 属于 Core 能力，请在 WebKitCoreHandlers 统一维护',
      );
    }
    register(action, handler);
  }

  void unregister(String action) => _handlers.remove(action);

  bool hasHandler(String action) => _handlers.containsKey(action);

  /// 分发 H5 消息；未注册 action 返回错误结构。
  Future<dynamic> dispatch(WebMessage message) async {
    final action = message.action;
    if (action.isEmpty) {
      return {'ok': false, 'message': 'action 不能为空'};
    }
    final handler = _handlers[action];
    if (handler == null) {
      return {'ok': false, 'message': '未注册的 action: $action'};
    }
    try {
      final result = await handler(message);
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
      return {'ok': true, 'data': result};
    } catch (error) {
      return {'ok': false, 'message': error.toString()};
    }
  }
}
