import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:module_auth/user/controller/auth_controller.dart';
import 'package:module_auth/user/theme/auth_theme.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final phoneController = TextEditingController(text: '18614031080');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.updatePhone(phoneController.text);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Text(
                controller.greeting,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AuthTheme.titleBlack,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 48),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AuthTheme.countryCodeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '+86',
                      style: TextStyle(
                        fontSize: 16,
                        color: AuthTheme.titleBlack,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                      decoration: const InputDecoration(
                        hintText: '请输入手机号',
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
                      onChanged: controller.updatePhone,
                    ),
                  ),
                  if (phoneController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.cancel, color: AuthTheme.textGray),
                      onPressed: () {
                        phoneController.clear();
                        controller.updatePhone('');
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Obx(
                () => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: controller.agreedPrivacy.value,
                        activeColor: AuthTheme.primaryBlue,
                        onChanged: controller.togglePrivacy,
                        shape: const CircleBorder(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 13,
                            color: AuthTheme.textGray,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(text: '我已阅读并同意'),
                            TextSpan(
                              text: '《某个隐私条款》',
                              style: TextStyle(color: AuthTheme.primaryBlue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: controller.goToPasswordPage,
                  style: FilledButton.styleFrom(
                    backgroundColor: AuthTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    '下一步',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      '短信验证码登录',
                      style: TextStyle(color: AuthTheme.linkGray, fontSize: 13),
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          '我要注册',
                          style: TextStyle(
                            color: AuthTheme.linkGray,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 12,
                        color: AuthTheme.dividerGray,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          '忘记密码',
                          style: TextStyle(
                            color: AuthTheme.linkGray,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
