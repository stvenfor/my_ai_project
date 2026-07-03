/// Web Bridge action 常量表。
///
/// - **Core**：壳工程 [WebKitCoreHandlers] 统一注册，业务模块禁止覆盖。
/// - **Module**：各 [FeatureModule.onRegister] 通过 [WebBridgeRegistry.registerModule] 扩展。
class WebBridgeActions {
  WebBridgeActions._();

  // ── Core（统一注册）────────────────────────────────────────

  static const showToast = 'showToast';
  static const closeWithResult = 'closeWithResult';
  static const getEnvironment = 'getEnvironment';
  static const switchEnvironment = 'switchEnvironment';
  static const getUserInfo = 'getUserInfo';

  static const Set<String> coreActions = {
    showToast,
    closeWithResult,
    getEnvironment,
    switchEnvironment,
    getUserInfo,
  };

  // ── Module 扩展（业务模块注册）──────────────────────────────

  static const refreshDashboard = 'refreshDashboard';

  static const Set<String> moduleActions = {
    refreshDashboard,
  };

  static bool isCoreAction(String action) => coreActions.contains(action);

  static bool isModuleAction(String action) => moduleActions.contains(action);

  static bool isKnownAction(String action) =>
      isCoreAction(action) || isModuleAction(action);
}
