import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:module_auth/user/controller/auth_controller.dart';
import 'package:module_auth/user/theme/auth_theme.dart';
import 'package:module_core/core.dart';

/// 手机号 + 验证码同页表单（登录 / 注册复用）。
class PhoneOtpFormSection extends StatelessWidget {
  const PhoneOtpFormSection({
    super.key,
    required this.controller,
    required this.phoneController,
    required this.otpController,
    this.fromRegister = false,
  });

  final AuthController controller;
  final TextEditingController phoneController;
  final TextEditingController otpController;
  final bool fromRegister;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: AuthTheme.fieldHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AuthTheme.surface,
                borderRadius: BorderRadius.circular(AuthTheme.radiusMd),
                border: Border.all(color: AuthTheme.separator, width: 0.5),
              ),
              child: const Text(
                '+86',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: AuthTheme.labelPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: AuthTheme.fieldHeight,
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  style: AuthTheme.fieldText.copyWith(letterSpacing: 0.5),
                  decoration: AuthTheme.filledFieldDecoration(
                    hintText: '手机号',
                    prefixIcon: Icons.smartphone_rounded,
                  ),
                  onChanged: controller.updatePhone,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                height: AuthTheme.fieldHeight,
                child: TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  style: AuthTheme.fieldText.copyWith(
                    letterSpacing: 6,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  decoration: AuthTheme.filledFieldDecoration(
                    hintText: '验证码',
                    prefixIcon: Icons.sms_outlined,
                  ),
                  onChanged: controller.updateOtpCode,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _SendOtpButton(
              controller: controller,
              fromRegister: fromRegister,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.phoneOtpSent.value &&
              controller.maskedPendingPhone.isNotEmpty) {
            return Text(
              '验证码已发送至 ${controller.maskedPendingPhone}',
              style: AuthTheme.caption,
            );
          }
          if (_showTestPhoneHint()) {
            return Text(
              '测试号 ${MockAuthService.mockTestPhone}，验证码 ${MockAuthService.mockOtpCode}',
              style: AuthTheme.caption.copyWith(color: AuthTheme.accent),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  bool _showTestPhoneHint() {
    if (Get.isRegistered<AuthService>() &&
        Get.find<AuthService>() is MockAuthService) {
      return true;
    }
    if (!AppAuthConfig.useMockAuth &&
        Get.isRegistered<EnvironmentService>() &&
        Get.find<EnvironmentService>().currentEnv.value == AppEnv.test) {
      return true;
    }
    return false;
  }
}

class _SendOtpButton extends StatelessWidget {
  const _SendOtpButton({
    required this.controller,
    required this.fromRegister,
  });

  final AuthController controller;
  final bool fromRegister;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cooldown = controller.otpCooldownSeconds.value;
      final canSend = controller.canSendPhoneOtp;

      return SizedBox(
        height: AuthTheme.fieldHeight,
        child: TextButton(
          onPressed: canSend
              ? () => controller.sendPhoneOtp(fromRegister: fromRegister)
              : null,
          style: TextButton.styleFrom(
            foregroundColor: AuthTheme.accent,
            disabledForegroundColor: AuthTheme.labelTertiary,
            backgroundColor: AuthTheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            minimumSize: const Size(96, AuthTheme.fieldHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AuthTheme.radiusMd),
              side: const BorderSide(color: AuthTheme.separator, width: 0.5),
            ),
          ),
          child: Text(
            cooldown > 0 ? '${cooldown}s' : '获取验证码',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    });
  }
}
