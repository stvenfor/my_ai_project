import 'package:module_linking/analytics/linking_analytics.dart';
import 'package:module_linking/deeplink/app_link_parser.dart';

/// App Links / Universal Link 监听（Deeplink 关闭时为 no-op）。
class AppLinkListener {
  AppLinkListener({
    required AppLinkParser parser,
    required LinkingAnalytics analytics,
  });

  Future<void> start() async {}

  Future<void> dispose() async {}
}
