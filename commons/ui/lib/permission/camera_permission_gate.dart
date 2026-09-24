import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/dialog/confirm_dialog.dart';
import 'package:module_common_ui/kit/ui_kit_initializer.dart';
import 'package:module_common_ui/theme/vercel_tokens.dart';
import 'package:module_utils/module_utils.dart';

/// 相机（+可选麦克风）权限门：系统弹窗 → 引导弹框 → 去设置。
abstract final class CameraPermissionGate {
  CameraPermissionGate._();

  /// 已授权返回 true；否则已展示引导，返回 false。
  static Future<bool> ensure({
    bool withMicrophone = false,
    String deniedToast = '需要相机权限才能继续，请在系统弹窗中允许',
    String settingsTitle = '开启相机权限',
    String? settingsMessage,
  }) async {
    final result = await ImagePickerUtils.requestCameraAccess(
      withMicrophone: withMicrophone,
    );
    switch (result) {
      case MediaPermissionResult.granted:
        return true;
      case MediaPermissionResult.denied:
        // 刚拒系统框：给「再试一次」，避免只 toast 像没申请。
        final retry = await _showGuideDialog(
          title: settingsTitle,
          withMicrophone: withMicrophone,
          headline: '未获得相机权限，请在下次系统弹窗中点「允许」。',
          confirmText: '再试一次',
          showSettingsSteps: false,
        );
        if (retry != true) return false;
        final again = await ImagePickerUtils.requestCameraAccess(
          withMicrophone: withMicrophone,
        );
        if (again == MediaPermissionResult.granted) return true;
        if (again == MediaPermissionResult.permanentlyDenied) {
          return _guideToSettings(
            title: settingsTitle,
            withMicrophone: withMicrophone,
            settingsMessage: settingsMessage,
          );
        }
        UiKitInitializer.toastError(deniedToast);
        return false;
      case MediaPermissionResult.permanentlyDenied:
        return _guideToSettings(
          title: settingsTitle,
          withMicrophone: withMicrophone,
          settingsMessage: settingsMessage,
        );
    }
  }

  static Future<bool> _guideToSettings({
    required String title,
    required bool withMicrophone,
    String? settingsMessage,
  }) async {
    final go = await _showGuideDialog(
      title: title,
      withMicrophone: withMicrophone,
      headline: settingsMessage ??
          (withMicrophone
              ? '相机或麦克风权限未开启，开启后即可拍摄。'
              : '相机权限未开启，开启后即可拍摄。'),
      confirmText: '去设置',
      showSettingsSteps: true,
    );
    if (go == true) {
      await ImagePickerUtils.openPermissionSettings();
    }
    return false;
  }

  static Future<bool?> _showGuideDialog({
    required String title,
    required bool withMicrophone,
    required String headline,
    required String confirmText,
    required bool showSettingsSteps,
  }) {
    return Get.dialog<bool>(
      ConfirmDialog(
        title: title,
        confirmText: confirmText,
        cancelText: '取消',
        showCloseButton: false,
        content: _CameraPermissionGuideBody(
          headline: headline,
          withMicrophone: withMicrophone,
          showSettingsSteps: showSettingsSteps,
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
    );
  }
}

/// 权限引导正文：图标 + 说明 +（可选）系统设置路径。
class _CameraPermissionGuideBody extends StatelessWidget {
  const _CameraPermissionGuideBody({
    required this.headline,
    required this.withMicrophone,
    required this.showSettingsSteps,
  });

  final String headline;
  final bool withMicrophone;
  final bool showSettingsSteps;

  @override
  Widget build(BuildContext context) {
    final tokens = VercelTokens.of(context);
    final steps = showSettingsSteps ? _settingsSteps() : const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: tokens.linkBgSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.photo_camera_outlined,
              size: 28.sp,
              color: tokens.link,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          headline,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            height: 1.55,
            color: tokens.body,
          ),
        ),
        if (steps.isNotEmpty) ...[
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h),
            decoration: BoxDecoration(
              color: tokens.canvasSoft2,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: tokens.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '开启路径',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: tokens.mute,
                  ),
                ),
                SizedBox(height: 8.h),
                for (var i = 0; i < steps.length; i++) ...[
                  _StepRow(index: i + 1, text: steps[i]),
                  if (i != steps.length - 1) SizedBox(height: 8.h),
                ],
                SizedBox(height: 4.h),
                Text(
                  _settingsHint,
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.45,
                    color: tokens.mute,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// iOS App 页常不显示「相机」开关（需至少弹过一次系统框，或去隐私页）；
  /// Android 需再点进「权限」。文案按平台分开，避免空跑一趟设置。
  List<String> _settingsSteps() {
    final mic = withMicrophone;
    if (!kIsWeb && Platform.isIOS) {
      return [
        '打开「设置」里的本应用',
        '若有「相机」${mic ? '「麦克风」' : ''}开关，直接打开',
        '若没有开关：设置 → 隐私与安全性 → 相机'
            '${mic ? ' / 麦克风' : ''} → 找到本应用并打开',
      ];
    }
    return [
      '进入本应用的「应用信息」',
      '点「权限」',
      '打开「相机」${mic ? '和「麦克风」' : ''}并允许',
    ];
  }

  String get _settingsHint {
    if (!kIsWeb && Platform.isIOS) {
      return '提示：从未弹出过授权框时，应用设置页可能没有相机项，请走「隐私与安全性」。';
    }
    return '提示：部分机型在「应用信息」首页看不到权限，需先点进「权限」列表。';
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = VercelTokens.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20.w,
          height: 20.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tokens.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$index',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: tokens.onPrimary,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.45,
              color: tokens.ink,
            ),
          ),
        ),
      ],
    );
  }
}
