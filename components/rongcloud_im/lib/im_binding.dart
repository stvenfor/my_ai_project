import 'package:get/get.dart';
import 'package:module_core/service/environment_service.dart';
import 'package:module_core/service/im_backup_service.dart';
import 'package:module_core/service/im_session_service.dart';
import 'package:module_core/service/im_user_profile_service.dart';
import 'package:module_rongcloud_im/api/im_session_api.dart';
import 'package:module_rongcloud_im/api/im_user_profile_api.dart';
import 'package:module_rongcloud_im/backup/mock_im_backup_service.dart';
import 'package:module_rongcloud_im/cache/cached_im_user_profile_service.dart';
import 'package:module_rongcloud_im/engine/rong_engine_holder.dart';
import 'package:module_rongcloud_im/registry/im_user_id_registry.dart';
import 'package:module_rongcloud_im/session/im_session_service_impl.dart';
import 'package:module_rongcloud_im/telemetry/im_telemetry.dart';

class ImBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ImTelemetry>()) {
      Get.put(ImTelemetry(), permanent: true);
    }
    if (!Get.isRegistered<ImUserIdRegistry>()) {
      Get.put(ImUserIdRegistry(), permanent: true);
    }
    if (!Get.isRegistered<RongEngineHolder>()) {
      Get.put(
        RongEngineHolder(
          envService: Get.isRegistered<EnvironmentService>()
              ? Get.find<EnvironmentService>()
              : null,
        ),
        permanent: true,
      );
    }
    if (!Get.isRegistered<ImSessionApi>()) {
      Get.put(
        ImSessionApi(
          registry: Get.find<ImUserIdRegistry>(),
          envService: Get.isRegistered<EnvironmentService>()
              ? Get.find<EnvironmentService>()
              : null,
        ),
        permanent: true,
      );
    }
    if (!Get.isRegistered<ImUserProfileApi>()) {
      Get.put(ImUserProfileApi(), permanent: true);
    }
    if (!Get.isRegistered<ImUserProfileService>()) {
      Get.put<ImUserProfileService>(
        CachedImUserProfileService(api: Get.find<ImUserProfileApi>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<ImBackupService>()) {
      Get.put<ImBackupService>(MockImBackupService(), permanent: true);
    }
    if (!Get.isRegistered<ImSessionService>()) {
      Get.put<ImSessionService>(
        ImSessionServiceImpl(
          sessionApi: Get.find<ImSessionApi>(),
          engineHolder: Get.find<RongEngineHolder>(),
        ),
        permanent: true,
      );
    }
  }
}
