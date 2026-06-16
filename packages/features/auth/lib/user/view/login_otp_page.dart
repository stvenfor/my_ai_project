import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:module_auth/user/controller/auth_controller.dart';
import 'package:module_auth/user/theme/auth_theme.dart';
import 'package:module_core/core.dart';

class LoginOtpPage extends GetView<AuthController> {
  const LoginOtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AuthTheme.titleBlack,
          onPressed: () => Get.back<void>(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(28, 16, 28, 24 + bottomInset),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '输入验证码',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AuthTheme.titleBlack,
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => Text(
                  '验证码已发送至 ${controller.maskedPendingPhone}',
                  style: const TextStyle(color: AuthTheme.textGray, fontSize: 14),
                ),
              ),
              if (Get.isRegistered<AuthService>() &&
                  Get.find<AuthService>() is MockAuthService) ...[
                const SizedBox(height: 8),
                Text(
                  'Mock 模式验证码：${MockAuthService.mockOtpCode}',
                  style: const TextStyle(
                    color: AuthTheme.primaryBlue,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 40),
              TextField(
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: controller.updateOtpCode,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                decoration: const InputDecoration(
                  hintText: '6 位验证码',
                  hintStyle: TextStyle(color: AuthTheme.inputHint, letterSpacing: 0),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: AuthTheme.dividerGray),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AuthTheme.dividerGray),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AuthTheme.primaryBlue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: controller.canResendOtp
                        ? controller.resendPhoneOtp
                        : null,
                    child: Text(
                      controller.otpCooldownSeconds.value > 0
                          ? '${controller.otpCooldownSeconds.value}s 后重发'
                          : '重新发送',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: controller.isOtpValid && !controller.isLoading.value
                        ? controller.verifyPhoneOtp
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AuthTheme.primaryBlue,
                      disabledBackgroundColor: AuthTheme.buttonDisabled,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            '登录',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
