import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_auth/user/controller/auth_controller.dart';
import 'package:module_auth/user/theme/auth_theme.dart';
import 'package:module_auth/user/view/login_footer_links.dart';

class LoginPasswordPage extends GetView<AuthController> {
  const LoginPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
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
                '请输入你的密码',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AuthTheme.titleBlack,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                onChanged: controller.updatePassword,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  hintText: '6-16位密码',
                  hintStyle: TextStyle(color: AuthTheme.inputHint),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: AuthTheme.dividerGray),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AuthTheme.dividerGray),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AuthTheme.primaryBlue),
                  ),
                  contentPadding: EdgeInsets.only(bottom: 8),
                ),
              ),
              const SizedBox(height: 40),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: controller.isPasswordValid &&
                            !controller.isLoading.value
                        ? controller.loginWithPassword
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
              const SizedBox(height: 20),
              const LoginFooterLinks(),
            ],
          ),
        ),
      ),
    );
  }
}
