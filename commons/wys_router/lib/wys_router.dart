library wys_router;

// Module registry (from former module_route)
export 'src/container/mixin_router_container.dart';
export 'src/container/mixin_router_intercept_container.dart';
export 'src/container/uri_intercept_container.dart';
export 'src/module/feature_module.dart';
export 'src/module/module_host_context.dart';
export 'src/module/module_registry.dart';
export 'src/module/module_standalone_config.dart';
export 'src/module/module_standalone_runner.dart';
export 'src/module/module_tab_item.dart';
export 'src/mixin_router_utils.dart';
export 'src/route/login_redirect.dart';
export 'src/route/route_path.dart';
export 'src/route/route_utils.dart';

// URL / native bridge
export 'src/wys_capability_routes.dart';
export 'src/wys_flutter_util.dart';
export 'src/wys_get_page_routes.dart';
export 'src/wys_native_page_name_map.dart';
export 'src/wys_native_route_registry.dart';
export 'src/wys_route.dart';
export 'src/wys_route_configuration.dart';
export 'src/wys_route_interceptor.dart';
export 'src/wys_router.dart';
export 'src/wys_url_utils.dart';
