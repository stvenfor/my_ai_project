import 'package:get/get.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_auth/user/binding/auth_binding.dart';
import 'package:module_auth/user/controller/auth_controller.dart';
import 'package:module_core/web/web_page_config.dart';
import 'package:module_linking/analytics/linking_analytics.dart';
import 'package:module_linking/models/app_route_intent.dart';
import 'package:module_linking/navigation/main_tab_controller.dart';
import 'package:module_linking/navigation/pending_navigation.dart';
import 'package:module_route/module/module_registry.dart';
import 'package:module_route/route/route_path.dart';
import 'package:module_utils/module_utils.dart';

/// 统一导航：Tab 切换 + 子页 push。
class AppNavigator {
  AppNavigator({
    required LinkingAnalytics analytics,
    required MainTabController tabController,
  })  : _analytics = analytics,
        _tabController = tabController;

  final LinkingAnalytics _analytics;
  final MainTabController _tabController;

  Future<void> navigate(AppRouteIntent intent) async {
    _analytics.trackNavigateStart(intent);
    try {
      if (_requiresLogin(intent) && !AuthSession.isLoggedIn) {
        PendingNavigation.set(intent);
        if (!Get.isRegistered<AuthController>()) {
          AuthBinding().dependencies();
        }
        await Get.toNamed(RoutePath.login);
        _analytics.trackNavigateFailure(intent, 'login_required');
        return;
      }

      if (Get.currentRoute != RoutePath.main) {
        PendingNavigation.set(intent);
        if (Get.currentRoute != RoutePath.splash) {
          ModuleRegistry.ensureBindings();
          await Get.offAllNamed(RoutePath.main);
        }
        return;
      }

      if (intent.tabModuleId != null) {
        final switched = await _tabController.switchToModule(intent.tabModuleId!);
        if (!switched) {
          throw StateError('Tab module not found: ${intent.tabModuleId}');
        }
        await Future<void>.delayed(const Duration(milliseconds: 120));
      }

      final args = _resolveArguments(intent);
      if (intent.route == RoutePath.main) {
        _analytics.trackNavigateSuccess(intent);
        return;
      }

      await Get.toNamed(intent.route, arguments: args);
      _analytics.trackNavigateSuccess(intent);
    } catch (e, st) {
      LogUtils.e('[AppNavigator] navigate failed route=${intent.route}', e, st);
      _analytics.trackNavigateFailure(intent, e.toString());
    }
  }

  bool _requiresLogin(AppRouteIntent intent) {
    return intent.tabModuleId == 'community';
  }

  Object? _resolveArguments(AppRouteIntent intent) {
    final args = intent.arguments;
    if (args is WebPageConfig) return args;
    if (intent.route == RoutePath.shortVideoPlay && args is Map) {
      final raw = args['initialIndex'] ?? args['index'] ?? 0;
      if (raw is int) return raw;
      if (raw is String) return int.tryParse(raw) ?? 0;
    }
    return args;
  }
}
