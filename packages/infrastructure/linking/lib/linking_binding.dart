import 'package:get/get.dart';
import 'package:module_linking/analytics/linking_analytics.dart';
import 'package:module_linking/deeplink/app_link_parser.dart';
import 'package:module_linking/navigation/app_navigator.dart';
import 'package:module_linking/navigation/main_tab_controller.dart';
import 'package:module_linking/privacy/privacy_consent_service.dart';
import 'package:module_linking/ui/in_app_push_banner_controller.dart';

class LinkingBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<LinkingAnalytics>()) {
      Get.put(LinkingAnalytics(), permanent: true);
    }
    if (!Get.isRegistered<MainTabController>()) {
      Get.put(MainTabController(), permanent: true);
    }
    if (!Get.isRegistered<InAppPushBannerController>()) {
      Get.put(InAppPushBannerController(), permanent: true);
    }
    if (!Get.isRegistered<AppLinkParser>()) {
      Get.put(AppLinkParser(), permanent: true);
    }
    if (!Get.isRegistered<PrivacyConsentService>()) {
      Get.put(PrivacyConsentService(), permanent: true);
    }
    if (!Get.isRegistered<AppNavigator>()) {
      Get.put(
        AppNavigator(
          analytics: Get.find<LinkingAnalytics>(),
          tabController: Get.find<MainTabController>(),
        ),
        permanent: true,
      );
    }
  }
}
