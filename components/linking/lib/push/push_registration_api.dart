import 'package:module_linking/analytics/linking_analytics.dart';
import 'package:module_utils/module_utils.dart';

/// RegistrationId / Alias 上报（mock 接口）。
class PushRegistrationApi {
  PushRegistrationApi({required LinkingAnalytics analytics}) : _analytics = analytics;

  final LinkingAnalytics _analytics;

  Future<void> report({
    required String registrationId,
    String? alias,
    bool mock = true,
  }) async {
    LogUtils.i(
      '[PushRegistrationApi] mock=$mock registrationId=$registrationId alias=$alias',
    );
    _analytics.trackPushRegister(
      registrationId: registrationId,
      alias: alias,
      mock: mock,
    );
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
