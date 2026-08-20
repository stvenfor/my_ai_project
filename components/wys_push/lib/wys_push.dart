// 极光推送虚拟 API 层，对齐安卓 `libPush` 模块。
//
// 对齐安卓调用点：
// - `SFApp.kt` → `PushManager.instance.init`
// - `SplashActivity.kt` → `PushManager.instance.reInit`
// - `HomeFragment.kt` → `PushManager.instance.setAlias`（传入 serialNo）
// - `MainActivity.kt` → `PushManager.instance.setBadgeNum`（清除角标）
// - `SettingActivity.kt` → `PushManager.instance.deleteAlias`（退出登录）
export 'src/push_config.dart';
export 'src/push_coordinator.dart';
export 'src/push_event.dart';
export 'src/push_event_dispatcher.dart';
export 'src/push_manager.dart';
export 'src/jpush_manager.dart';
export 'src/push_payload_parser.dart';
