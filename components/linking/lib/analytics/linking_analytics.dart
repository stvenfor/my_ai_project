import 'package:module_linking/models/app_route_intent.dart';
import 'package:module_linking/models/linking_event.dart';
import 'package:module_utils/module_utils.dart';

/// Push / Deeplink 埋点（LogUtils + EventBus）。
class LinkingAnalytics {
  void track(LinkingEventType type, {Map<String, dynamic>? params}) {
    final payload = {
      'event': type.eventName,
      if (params != null) ...params,
    };
    LogUtils.i('[LinkingAnalytics] $payload');
    EventBusUtils.post(
      CustomEvent<String, Map<String, dynamic>>(
        eventType: type.eventName,
        eventValue: payload,
      ),
    );
  }

  void trackDeeplinkOpen(AppRouteIntent intent) {
    track(LinkingEventType.deeplinkOpen, params: intent.toAnalyticsMap());
  }

  void trackNavigateStart(AppRouteIntent intent) {
    track(LinkingEventType.navigateStart, params: intent.toAnalyticsMap());
  }

  void trackNavigateSuccess(AppRouteIntent intent) {
    track(LinkingEventType.navigateSuccess, params: intent.toAnalyticsMap());
  }

  void trackNavigateFailure(AppRouteIntent intent, String reason) {
    track(
      LinkingEventType.navigateFailure,
      params: {...intent.toAnalyticsMap(), 'reason': reason},
    );
  }

  void trackPushArrive({String? msgId, Map<String, dynamic>? extras}) {
    track(
      LinkingEventType.pushArrive,
      params: {'msgId': msgId, if (extras != null) 'extras': extras},
    );
  }

  void trackPushClick({String? msgId, String? deeplink}) {
    track(
      LinkingEventType.pushClick,
      params: {'msgId': msgId, 'deeplink': deeplink},
    );
  }

  void trackPushBannerShow({String? msgId}) {
    track(LinkingEventType.pushForegroundBannerShow, params: {'msgId': msgId});
  }

  void trackPushBannerClick({String? msgId}) {
    track(LinkingEventType.pushForegroundBannerClick, params: {'msgId': msgId});
  }

  void trackPushRegister({
    required String registrationId,
    String? alias,
    bool mock = false,
  }) {
    track(
      LinkingEventType.pushRegisterReport,
      params: {
        'registrationId': registrationId,
        'alias': alias,
        'mock': mock,
      },
    );
  }

  void trackPushAliasSet(String alias) {
    track(LinkingEventType.pushAliasSet, params: {'alias': alias});
  }
}
