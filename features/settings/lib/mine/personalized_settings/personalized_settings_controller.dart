import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_utils/module_utils.dart';

class PersonalizedSettingsController extends GetxController {
  static const _prefix = 'personalized_settings.';

  final teachingMode = false.obs;
  final contentRecommendation = true.obs;
  final adRecommendation = true.obs;
  final oralScoring = true.obs;
  final cellularVideoReminder = false.obs;
  final uploadStatusMonitor = false.obs;
  final eyeProtectionMode = '关闭'.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void _load() {
    if (!SpUtils.isInitialized) return;
    teachingMode.value =
        SpUtils.getBool('${_prefix}teaching_mode', defaultValue: false);
    contentRecommendation.value = SpUtils.getBool(
      '${_prefix}content_recommendation',
      defaultValue: true,
    );
    adRecommendation.value =
        SpUtils.getBool('${_prefix}ad_recommendation', defaultValue: true);
    oralScoring.value =
        SpUtils.getBool('${_prefix}oral_scoring', defaultValue: true);
    cellularVideoReminder.value = SpUtils.getBool(
      '${_prefix}cellular_video_reminder',
      defaultValue: false,
    );
    uploadStatusMonitor.value = SpUtils.getBool(
      '${_prefix}upload_status_monitor',
      defaultValue: false,
    );
    eyeProtectionMode.value = SpUtils.getString(
          '${_prefix}eye_protection_mode',
          defaultValue: '关闭',
        ) ??
        '关闭';
  }

  Future<void> setTeachingMode(bool value) async {
    teachingMode.value = value;
    await _persistBool('teaching_mode', value);
  }

  Future<void> setContentRecommendation(bool value) async {
    contentRecommendation.value = value;
    await _persistBool('content_recommendation', value);
  }

  Future<void> setAdRecommendation(bool value) async {
    adRecommendation.value = value;
    await _persistBool('ad_recommendation', value);
  }

  Future<void> setOralScoring(bool value) async {
    oralScoring.value = value;
    await _persistBool('oral_scoring', value);
  }

  Future<void> setCellularVideoReminder(bool value) async {
    cellularVideoReminder.value = value;
    await _persistBool('cellular_video_reminder', value);
  }

  Future<void> setUploadStatusMonitor(bool value) async {
    uploadStatusMonitor.value = value;
    await _persistBool('upload_status_monitor', value);
  }

  Future<void> setEyeProtectionMode(String value) async {
    eyeProtectionMode.value = value;
    if (SpUtils.isInitialized) {
      await SpUtils.setString('${_prefix}eye_protection_mode', value);
    }
  }

  Future<void> _persistBool(String key, bool value) async {
    if (!SpUtils.isInitialized) return;
    await SpUtils.setBool('$_prefix$key', value);
  }

  void openDecorationCenter() =>
      UiKitInitializer.toast('装扮中心（开发中）');

  void showHelp(String title) {
    UiKitInitializer.toast('$title：功能说明开发中');
  }

  Future<void> pickEyeProtectionMode() async {
    const options = ['关闭', '开启', '跟随系统'];
    final picked = await Get.bottomSheet<String>(
      _OptionSheet(
        title: '护眼模式',
        options: options,
        selected: eyeProtectionMode.value,
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
    );
    if (picked != null) {
      await setEyeProtectionMode(picked);
    }
  }
}

class _OptionSheet extends StatelessWidget {
  const _OptionSheet({
    required this.title,
    required this.options,
    required this.selected,
  });

  final String title;
  final List<String> options;
  final String selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
          for (final option in options)
            ListTile(
              title: Text(option),
              trailing: option == selected
                  ? const Icon(Icons.check_rounded, color: Color(0xFF53D65B))
                  : null,
              onTap: () => Get.back<String>(result: option),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
