import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:module_auth/session/auth_token_refresh_interceptor.dart';
import 'package:module_auth/session/session_guard.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/core.dart';
import 'package:module_global_cache/module_global_cache.dart';
import 'package:module_http/module_http.dart';
import 'package:module_sample/app/app_binding.dart';
import 'package:module_sample/app/app_controller.dart';
import 'package:module_sample/bootstrap/app_runner_debug.dart'
    if (dart.vm.product) 'package:module_sample/bootstrap/app_runner_release.dart';
import 'package:module_linking/linking_binding.dart';
import 'package:module_linking/linking_initializer.dart';
import 'package:module_realtime/realtime_initializer.dart';
import 'package:module_rongcloud_im/im_initializer.dart';
import 'package:module_sample/config/module_manifest.dart';
import 'package:module_settings/env/environment_session.dart';
import 'package:module_utils/module_utils.dart';
import 'package:wys_login_share_pay/wys_login_share_pay.dart';
import 'package:wys_network/wys_network.dart' as wys_net;
import 'package:wys_router/wys_router.dart';

class AppInitializer {
  /// 壳工程最小 DI：进 UI 前必须已有 [AppController]。
  /// init 超时 / 半完成后仍可安全调用（幂等）。
  static void ensureShellBindings() {
    if (!Get.isRegistered<AppController>()) {
      AppBinding().dependencies();
    }
  }

  static Future<void> init() async {
    await ModuleUtilsInitializer.initialize(
      config: ModuleUtilsConfig(
        enableLog: kDebugMode,
        logTag: 'module_sample',
      ),
    );

    await VideoMockSourceLoader.load();

    await SpManager.init();
    await AppDatabase.init();

    // 尽早注册，避免 init 后半段超时后 runApp 找不到 AppController。
    ensureShellBindings();

    await EnvironmentSession.register();
    _syncWysAppEnvironment();
    _wireEnvironmentHttpRefresh();
    AppHttpBootstrap.initialize(
      headerProvider: const AuthHeaderProvider(),
      responseHook: SessionGuardHook(),
      interceptors: [AuthTokenRefreshInterceptor()],
      enableLog: kDebugMode,
      maxRetries: 3,
    );

    await AuthSession.register();
    await AuthSession.refreshIfNeeded();

    await UiKitInitializer.initialize();

    final webRegistry = await WebKitInitializer.initialize();
    WebKitCoreHandlers.register(webRegistry);

    _configureWysRouter();

    ModuleRegistry.registerAll(buildEnabledModules());

    final hostContext = ModuleHostContext.integrated(
      enableHttpLog: kDebugMode,
      httpMaxRetries: 3,
    );
    await ModuleRegistry.bootstrap(hostContext);

    ensureShellBindings();
    LinkingBinding().dependencies();
    await ImInitializer.initDeferred();
    for (final binding in ModuleRegistry.collectBindings()) {
      binding.dependencies();
    }
    LogUtils.i('[App] bindings ready, loading settings');
    await Get.find<AppController>().loadSettings();
    LogUtils.i('[App] settings loaded');

    await LinkingInitializer.initDeferred();
    await RealtimeInitializer.initDeferred();

    if (WysWechatConfig.isConfigured) {
      final ok = await WysWechatService.instance.init();
      LogUtils.i('[App] wechat sdk init=$ok appId=${WysWechatConfig.appId}');
    } else {
      LogUtils.i('[App] wechat sdk skipped (WysWechatConfig 未填 AppID/UL)');
    }

    final wsClient = RealtimeInitializer.client;
    LogUtils.i(
      '[App] 应用初始化完成 env=${Get.find<EnvironmentService>().config.label} '
      'baseUrl=${AppHttpBootstrap.resolveBaseUrl()} '
      'BACKEND_HOST=${BackendHttpConfig.effectiveBackendHost.isEmpty ? "(未注入)" : BackendHttpConfig.effectiveBackendHost} '
      'loggedIn=${AuthSession.isLoggedIn} '
      'ws=${wsClient?.currentState.label ?? '未初始化'}',
    );
  }

  static void _configureWysRouter() {
    WysRouter.configure(
      WysRouteConfiguration(
        scheme: 'xiaomao',
        onUnknownRoute: (urlOrPath, arguments) async {
          LogUtils.w('[WysRouter] unknown route: $urlOrPath');
          return null;
        },
      ),
    );
    WysRouter.registerPath(WysCapabilityRoutes.h5, RoutePath.web);
    WysRouter.registerPath(WysCapabilityRoutes.web, RoutePath.web);
  }

  /// 把壳工程 [EnvironmentService] 同步到 wys_network [AppEnvironment]
  ///（PushConfig / HttpsClient 等依赖）。
  /// wys 的 AppEnv.debug/release 是历史命名，表示业务环境档，不是 Flutter 包类型。
  static void _syncWysAppEnvironment() {
    final svc = Get.find<EnvironmentService>();
    final appEnv = svc.currentEnv.value;
    final wysEnv = appEnv == AppEnv.production
        ? wys_net.AppEnv.release
        : wys_net.AppEnv.debug;
    final net = appEnv == AppEnv.production
        ? wys_net.WysNetEnvironment.product
        : wys_net.WysNetEnvironment.test;
    wys_net.AppEnvironment.initialize(
      wysEnv,
      netEnvironment: net,
      baseUrl: svc.backendBaseUrl,
    );
  }

  static void _wireEnvironmentHttpRefresh() {
    Get.find<EnvironmentService>().onEnvChanged = (_) async {
      _syncWysAppEnvironment();
      AppHttpBootstrap.reinitialize(
        headerProvider: const AuthHeaderProvider(),
        responseHook: SessionGuardHook(),
        interceptors: [AuthTokenRefreshInterceptor()],
        enableLog: kDebugMode,
        maxRetries: 3,
      );
    };
  }
}

Future<void> main() => AppRunner.launch();
