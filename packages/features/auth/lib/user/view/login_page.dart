import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_auth/user/controller/auth_controller.dart';
import 'package:module_auth/user/theme/auth_theme.dart';
import 'package:module_auth/user/view/login_footer_links.dart';
import 'package:module_auth/user/widgets/phone_otp_form_section.dart';
import 'package:module_core/core.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _phoneController;
  late final TextEditingController _otpController;
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthController>();
    _emailController = TextEditingController(text: _controller.email.value);
    _passwordController =
        TextEditingController(text: _controller.password.value);
    _phoneController = TextEditingController(text: _controller.phone.value);
    _otpController = TextEditingController(text: _controller.otpCode.value);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AppPageScaffold(
      layout: AppPageLayout.edgeToEdge,
      backgroundColor: AuthTheme.background,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          AppSafeInsets.top(context) + 32,
          24,
          24 + bottomInset,
        ),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_controller.greeting, style: AuthTheme.largeTitle),
            const SizedBox(height: 8),
            Text('登录以继续使用', style: AuthTheme.subtitle),
            const SizedBox(height: 40),
            Obx(() => _buildCredentialSwitcher()),
            const SizedBox(height: 24),
            Obx(
              () => _controller.credentialMode.value ==
                      AuthCredentialMode.email
                  ? _buildEmailForm()
                  : _buildPhoneForm(),
            ),
            const SizedBox(height: 24),
            Obx(() => _buildPrivacyRow()),
            const SizedBox(height: 32),
            Obx(() => _buildPrimaryButton()),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.center,
              child: LoginFooterLinks(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialSwitcher() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AuthTheme.fillSecondary,
        borderRadius: BorderRadius.circular(AuthTheme.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: CupertinoSlidingSegmentedControl<AuthCredentialMode>(
          groupValue: _controller.credentialMode.value,
          thumbColor: AuthTheme.surface,
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.all(2),
          children: const {
            AuthCredentialMode.email: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                '邮箱登录',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            AuthCredentialMode.phone: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                '短信登录',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          },
          onValueChanged: (value) {
            if (value != null) _controller.switchCredentialMode(value);
          },
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Column(
      children: [
        SizedBox(
          height: AuthTheme.fieldHeight,
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            style: AuthTheme.fieldText,
            decoration: AuthTheme.filledFieldDecoration(
              hintText: '邮箱',
              prefixIcon: Icons.mail_outline_rounded,
            ),
            onChanged: _controller.updateEmail,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: AuthTheme.fieldHeight,
          child: TextField(
            controller: _passwordController,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            style: AuthTheme.fieldText,
            decoration: AuthTheme.filledFieldDecoration(
              hintText: '密码',
              prefixIcon: Icons.lock_outline_rounded,
            ),
            onChanged: _controller.updatePassword,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneForm() {
    return PhoneOtpFormSection(
      controller: _controller,
      phoneController: _phoneController,
      otpController: _otpController,
    );
  }

  Widget _buildPrivacyRow() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AuthTheme.radiusMd),
        onTap: () => _controller.togglePrivacy(!_controller.agreedPrivacy.value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _controller.agreedPrivacy.value
                          ? AuthTheme.accent
                          : Colors.transparent,
                      border: Border.all(
                        color: _controller.agreedPrivacy.value
                            ? AuthTheme.accent
                            : AuthTheme.separator,
                        width: 1.5,
                      ),
                    ),
                    child: _controller.agreedPrivacy.value
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: RichText(
                    text: TextSpan(
                      style: AuthTheme.caption,
                      children: const [
                        TextSpan(text: '我已阅读并同意'),
                        TextSpan(
                          text: '《某个隐私条款》',
                          style: TextStyle(color: AuthTheme.accent),
                        ),
                      ],
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

  Widget _buildPrimaryButton() {
    final isEmail =
        _controller.credentialMode.value == AuthCredentialMode.email;
    final canEmailLogin = isEmail &&
        _controller.validateEmail(_controller.email.value) &&
        _controller.isLoginPasswordValid;
    final canPhoneLogin = !isEmail && _controller.canLoginWithPhoneOtp;
    final enabled = !_controller.isLoading.value &&
        (isEmail ? canEmailLogin : canPhoneLogin);

    return SizedBox(
      width: double.infinity,
      height: AuthTheme.buttonHeight,
      child: FilledButton(
        onPressed: enabled
            ? (isEmail
                ? _controller.loginWithPassword
                : _controller.verifyPhoneOtp)
            : null,
        style: FilledButton.styleFrom(
          backgroundColor: AuthTheme.accent,
          disabledBackgroundColor: AuthTheme.buttonDisabled,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuthTheme.radiusLg),
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
                '登录',
                style: AuthTheme.buttonLabel,
              ),
      ),
    );
  }
}
