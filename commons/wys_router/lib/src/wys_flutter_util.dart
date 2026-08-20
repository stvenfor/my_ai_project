import 'wys_router.dart';

/// 与旧 Boost / 混编约定对齐的静态入口。
abstract final class FlutterUtil {
  FlutterUtil._();

  static Future<dynamic> pushPage(
    String pageName, {
    required Map<String, dynamic> arguments,
    bool withContainer = false,
    bool opaque = true,
    bool secure = false,
  }) =>
      WysRouter.pushPage(
        pageName,
        arguments: arguments,
        withContainer: withContainer,
        opaque: opaque,
        secure: secure,
      );

  static void popFlutterPage(dynamic result) => WysRouter.pop(result);

  static Map<String, dynamic>? getparams([dynamic context]) {
    return WysRouter.currentArguments();
  }
}