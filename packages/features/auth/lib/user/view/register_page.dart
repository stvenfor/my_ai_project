import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_auth/user/controller/auth_controller.dart';
import 'package:module_auth/user/theme/auth_theme.dart';
import 'package:module_auth/user/widgets/auth_form_widgets.dart';
import 'package:module_auth/user/widgets/phone_otp_form_section.dart';
import 'package:module_route/route/route_path.dart';

enum _RegisterMode { email, phone }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _registerMode = _RegisterMode.email.obs;
  late final AuthController _controller;
  late final TextEditingController _emailController;
  late final TextEditingController _displayNameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _phoneController;
  late final TextEditingController _otpController;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthController>();
    _emailController = TextEditingController(text: _controller.email.value);
    _displayNameController =
        TextEditingController(text: _controller.displayName.value);
    _passwordController =
        TextEditingController(text: _controller.password.value);
    _confirmPasswordController =
        TextEditingController(text: _controller.confirmPassword.value);
    _phoneController = TextEditingController(text: _controller.phone.value);
    _otpController = TextEditingController(text: _controller.otpCode.value);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          AppSafeInsets.top(context) + 8,
          24,
          24 + bottomInset,
        ),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthBackButton(),
            const SizedBox(height: 8),
            Text('创建账号', style: AuthTheme.largeTitle),
            const SizedBox(height: 8),
            Text('选择注册方式并填写信息', style: AuthTheme.subtitle),
            const SizedBox(height: 32),
            Obx(() => _buildModeSwitcher()),
            const SizedBox(height: 24),
            Obx(
              () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.04),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _registerMode.value == _RegisterMode.email
                    ? _EmailRegisterForm(
                        key: const ValueKey('email'),
                        controller: _controller,
                        emailController: _emailController,
                        displayNameController: _displayNameController,
                        passwordController: _passwordController,
                        confirmPasswordController: _confirmPasswordController,
                      )
                    : _PhoneRegisterForm(
                        key: const ValueKey('phone'),
                        controller: _controller,
                        phoneController: _phoneController,
                        otpController: _otpController,
                      ),
              ),
            ),
            const SizedBox(height: 24),
            AuthPrivacyRow(controller: _controller),
            const SizedBox(height: 32),
            Obx(() => _buildPrimaryButton()),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Get.offNamed(RoutePath.login),
                style: TextButton.styleFrom(
                  foregroundColor: AuthTheme.accent,
                  minimumSize: const Size(44, 44),
                ),
                child: Text(
                  '已有账号？去登录',
                  style: AuthTheme.caption.copyWith(color: AuthTheme.accent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSwitcher() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AuthTheme.fillSecondary,
        borderRadius: BorderRadius.circular(AuthTheme.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: CupertinoSlidingSegmentedControl<_RegisterMode>(
          groupValue: _registerMode.value,
          thumbColor: AuthTheme.surface,
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.all(2),
          children: const {
            _RegisterMode.email: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                '邮箱注册',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            _RegisterMode.phone: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                '手机注册',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          },
          onValueChanged: (value) {
            if (value != null) _registerMode.value = value;
          },
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    final isEmail = _registerMode.value == _RegisterMode.email;
    final canEmailRegister = isEmail && _controller.isRegisterPasswordMatch;
    final canPhoneRegister = !isEmail && _controller.canLoginWithPhoneOtp;
    final enabled = isEmail ? canEmailRegister : canPhoneRegister;

    return AuthPrimaryButton(
      label: '注册',
      enabled: enabled,
      isLoading: _controller.isLoading.value,
      onPressed: isEmail
          ? _controller.registerWithEmail
          : _controller.registerWithPhone,
    );
  }
}

class _EmailRegisterForm extends StatefulWidget {
  const _EmailRegisterForm({
    super.key,
    required this.controller,
    required this.emailController,
    required this.displayNameController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  final AuthController controller;
  final TextEditingController emailController;
  final TextEditingController displayNameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  @override
  State<_EmailRegisterForm> createState() => _EmailRegisterFormState();
}

class _EmailRegisterFormState extends State<_EmailRegisterForm> {
  var _passwordVisible = false;
  var _confirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('账号信息', style: AuthTheme.sectionLabel),
        const SizedBox(height: 8),
        AuthGroupedFormCard(
          children: [
            AuthGroupedTextField(
              controller: widget.emailController,
              hintText: '邮箱',
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              onChanged: widget.controller.updateEmail,
            ),
            AuthGroupedTextField(
              controller: widget.displayNameController,
              hintText: '昵称（可选）',
              textInputAction: TextInputAction.next,
              onChanged: widget.controller.updateDisplayName,
            ),
            AuthGroupedTextField(
              controller: widget.passwordController,
              hintText: '密码（至少 6 位）',
              obscureText: !_passwordVisible,
              textInputAction: TextInputAction.next,
              onChanged: widget.controller.updatePassword,
              suffixIcon: AuthPasswordToggle(
                visible: _passwordVisible,
                onToggle: () =>
                    setState(() => _passwordVisible = !_passwordVisible),
              ),
            ),
            AuthGroupedTextField(
              controller: widget.confirmPasswordController,
              hintText: '确认密码',
              obscureText: !_confirmPasswordVisible,
              textInputAction: TextInputAction.done,
              onChanged: widget.controller.updateConfirmPassword,
              suffixIcon: AuthPasswordToggle(
                visible: _confirmPasswordVisible,
                onToggle: () => setState(
                  () => _confirmPasswordVisible = !_confirmPasswordVisible,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PhoneRegisterForm extends StatelessWidget {
  const _PhoneRegisterForm({
    super.key,
    required this.controller,
    required this.phoneController,
    required this.otpController,
  });

  final AuthController controller;
  final TextEditingController phoneController;
  final TextEditingController otpController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('手机验证', style: AuthTheme.sectionLabel),
        const SizedBox(height: 8),
        Text('首次验证通过后将自动创建账号', style: AuthTheme.caption),
        const SizedBox(height: 16),
        PhoneOtpFormSection(
          controller: controller,
          phoneController: phoneController,
          otpController: otpController,
          fromRegister: true,
        ),
      ],
    );
  }
}
