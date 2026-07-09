import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_auth/user/controller/auth_controller.dart';
import 'package:module_auth/user/theme/auth_theme.dart';
import 'package:module_auth/user/view/login_footer_links.dart';

class LoginPasswordPage extends StatefulWidget {
  const LoginPasswordPage({super.key});

  @override
  State<LoginPasswordPage> createState() => _LoginPasswordPageState();
}

class _LoginPasswordPageState extends State<LoginPasswordPage> {
  late final TextEditingController _passwordController;
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthController>();
    _passwordController = TextEditingController(text: _controller.password.value);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AppPageScaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      navBar: AppNavBar(
        showBackButton: true,
        onBack: () => Get.back<void>(),
        backgroundColor: Colors.white,
        foregroundColor: AuthTheme.titleBlack,
      ),
      body: SingleChildScrollView(
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
                controller: _passwordController,
                autofocus: _controller.password.value.isEmpty,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                onChanged: _controller.updatePassword,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  hintText: '至少6位密码',
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
                    onPressed: _controller.isLoginPasswordValid &&
                            !_controller.isLoading.value
                        ? _controller.loginWithPassword
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AuthTheme.primaryBlue,
                      disabledBackgroundColor: AuthTheme.buttonDisabled,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: _controller.isLoading.value
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
    );
  }
}
