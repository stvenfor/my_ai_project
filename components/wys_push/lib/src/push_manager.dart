import 'dart:async';

import 'push_event.dart';

/// 推送事件回调函数类型
typedef PushEventCallback = void Function(PushEvent event);

/// 推送别名操作结果回调
typedef PushAliasCallback = void Function(bool success, String? error);

/// 推送虚拟管理器，对齐安卓 `PushManager`。
///
/// 该类是抽象接口，各平台通过继承实现具体逻辑。
/// 当前提供 [StubPushManager] 作为空实现，后续接入极光 SDK 后替换为真实实现。
abstract class PushManager {
  /// 子类可调用的受保护构造函数。
  ///
  /// 名称不以 `_` 开头，确保组件内的平台实现
  /// 的子类能正确调用 `super.protected()`。
  PushManager.protected();

  static PushManager? _instance;

  /// 获取全局实例
  static PushManager get instance {
    return _instance ??= StubPushManager();
  }

  /// 设置全局实例（用于注入平台实现）
  static set instance(PushManager? manager) {
    _instance = manager;
  }

  /// 初始化推送，对齐安卓 `PushManager.init(context)`。
  ///
  /// 首次安装时 [isFirstUse] 为 true，需设置隐私授权为 false。
  void init({bool isFirstUse = false});

  /// 隐私同意后重新初始化，对齐安卓 `PushManager.reInit()`。
  ///
  /// 用户同意隐私协议后调用，设置隐私授权为 true。
  void reInit();

  /// 设置别名，对齐安卓 `PushManager.setAlias(ctx, seq, alias)`。
  ///
  /// 通常在获取用户信息后调用，传入用户的 `serialNo` 作为别名。
  /// 返回 `true` 表示设置成功；超时等可重试错误会在实现内自动重试。
  Future<bool> setAlias(String alias);

  /// 删除别名，对齐安卓 `PushManager.deleteAlias(ctx, seq)`。
  ///
  /// 通常在退出登录时调用。
  Future<void> deleteAlias();

  /// 设置角标数，对齐安卓 `PushManager.setBadgeNum(num)`。
  Future<void> setBadgeNum(int num);

  /// 获取注册 ID（RegistrationID）。
  Future<String?> getRegistrationID();

  /// 添加推送事件监听。
  ///
  /// 对齐安卓 `JPushMessageReceiver` 的三个回调：
  /// - `onNotifyMessageArrived` → [PushEventType.notificationArrived]
  /// - `onNotifyMessageOpened` → [PushEventType.notificationOpened]
  /// - `onMessage` → [PushEventType.customMessage]
  Stream<PushEvent> get onEvent;

  /// 当前是否已初始化
  bool get isInitialized;

  /// 发送测试推送通知（仅用于调试）。
  ///
  /// 默认实现返回 `false`，表示当前平台不支持。
  /// [StubPushManager] 会向事件流注入一条测试通知，触发
  /// `PushEventType.notificationArrived` 事件。
  Future<bool> sendTestNotification() async => false;
}

/// 空实现，所有方法均为 no-op。
///
/// 在尚未接入极光 SDK 的平台上使用，保证业务代码可编译运行。
class StubPushManager extends PushManager {
  StubPushManager() : super.protected();

  bool _initialized = false;
  final _eventController = StreamController<PushEvent>.broadcast();

  @override
  void init({bool isFirstUse = false}) {
    _initialized = true;
  }

  @override
  void reInit() {}

  @override
  Future<bool> setAlias(String alias) async => true;

  @override
  Future<void> deleteAlias() async {}

  @override
  Future<void> setBadgeNum(int num) async {}

  @override
  Future<String?> getRegistrationID() async => null;

  @override
  Stream<PushEvent> get onEvent => _eventController.stream;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<bool> sendTestNotification() async {
    _eventController.add(
      const PushEvent(
        type: PushEventType.notificationArrived,
        notification: PushNotification(
          id: 0,
          title: '测试推送',
          content: '这是一条测试推送消息',
        ),
      ),
    );
    return true;
  }
}
