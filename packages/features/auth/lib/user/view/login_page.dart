import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_auth/user/controller/auth_controller.dart';
import 'package:module_auth/user/theme/auth_theme.dart';
import 'package:module_auth/user/view/login_footer_links.dart';
import 'package:module_core/core.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthController>();
    _emailController = TextEditingController(text: _controller.email.value);
    _phoneController = TextEditingController(text: _controller.phone.value);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AppPageScaffold(
      layout: AppPageLayout.edgeToEdge,
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          28,
          AppSafeInsets.top(context) + 48,
          28,
          24 + bottomInset,
        ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _controller.greeting,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AuthTheme.titleBlack,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 32),
              Obx(
                () => SegmentedButton<AuthCredentialMode>(
                  segments: const [
                    ButtonSegment(
                      value: AuthCredentialMode.email,
                      label: Text('邮箱登录'),
                      icon: Icon(Icons.mail_outline, size: 18),
                    ),
                    ButtonSegment(
                      value: AuthCredentialMode.phone,
                      label: Text('短信登录'),
                      icon: Icon(Icons.sms_outlined, size: 18),
                    ),
                  ],
                  selected: {_controller.credentialMode.value},
                  onSelectionChanged: (selection) {
                    _controller.switchCredentialMode(selection.first);
                  },
                ),
              ),
              const SizedBox(height: 32),
              Obx(
                () => _controller.credentialMode.value ==
                        AuthCredentialMode.email
                    ? _buildEmailForm()
                    : _buildPhoneForm(),
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
                        value: _controller.agreedPrivacy.value,
                        activeColor: AuthTheme.primaryBlue,
                        onChanged: _controller.togglePrivacy,
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
              Obx(
                () {
                  final isEmail =
                      _controller.credentialMode.value == AuthCredentialMode.email;
                  final canDirectLogin =
                      isEmail && _controller.canLoginDirectlyFromLoginPage;
                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _controller.isLoading.value
                          ? null
                          : isEmail
                              ? (canDirectLogin
                                  ? _controller.loginWithPassword
                                  : _controller.goToPasswordPage)
                              : _controller.sendPhoneOtpAndGo,
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
                          : Text(
                              isEmail
                                  ? (canDirectLogin ? '登录' : '下一步')
                                  : '获取验证码',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const LoginFooterLinks(),
            ],
          ),
        ),
    );
  }

  Widget _buildEmailForm() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      decoration: const InputDecoration(
        hintText: '请输入邮箱',
        hintStyle: TextStyle(color: AuthTheme.inputHint),
        prefixIcon: Icon(Icons.mail_outline, color: AuthTheme.textGray),
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
      onChanged: _controller.updateEmail,
    );
  }

  Widget _buildPhoneForm() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AuthTheme.countryCodeBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            '+86',
            style: TextStyle(fontSize: 16, color: AuthTheme.titleBlack),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _phoneController,
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
            onChanged: _controller.updatePhone,
          ),
        ),
      ],
    );
  }
}
