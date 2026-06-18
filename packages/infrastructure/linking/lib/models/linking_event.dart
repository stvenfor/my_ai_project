/// 埋点事件类型。
enum LinkingEventType {
  pushArrive,
  pushClick,
  pushForegroundBannerShow,
  pushForegroundBannerClick,
  deeplinkOpen,
  navigateStart,
  navigateSuccess,
  navigateFailure,
  pushRegisterReport,
  pushAliasSet,
}

extension LinkingEventTypeX on LinkingEventType {
  String get eventName => switch (this) {
        LinkingEventType.pushArrive => 'push_arrive',
        LinkingEventType.pushClick => 'push_click',
        LinkingEventType.pushForegroundBannerShow => 'push_foreground_banner_show',
        LinkingEventType.pushForegroundBannerClick => 'push_foreground_banner_click',
        LinkingEventType.deeplinkOpen => 'deeplink_open',
        LinkingEventType.navigateStart => 'link_navigate_start',
        LinkingEventType.navigateSuccess => 'link_navigate_success',
        LinkingEventType.navigateFailure => 'link_navigate_failure',
        LinkingEventType.pushRegisterReport => 'push_register_report',
        LinkingEventType.pushAliasSet => 'push_alias_set',
      };
}
