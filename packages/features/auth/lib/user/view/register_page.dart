import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:module_auth/user/controller/auth_controller.dart';
import 'package:module_auth/user/theme/auth_theme.dart';
import 'package:module_route/route/route_path.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthController>();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        title: const Text('注册', style: TextStyle(color: AuthTheme.titleBlack)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AuthTheme.primaryBlue,
          unselectedLabelColor: AuthTheme.textGray,
          indicatorColor: AuthTheme.primaryBlue,
          tabs: const [
            Tab(text: '邮箱注册'),
            Tab(text: '手机注册'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _EmailRegisterForm(
              controller: _controller,
              bottomInset: bottomInset,
            ),
            _PhoneRegisterForm(
              controller: _controller,
              bottomInset: bottomInset,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmailRegisterForm extends StatelessWidget {
  const _EmailRegisterForm({
    required this.controller,
    required this.bottomInset,
  });

  final AuthController controller;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(28, 24, 28, 24 + bottomInset),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '邮箱 + 密码注册',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AuthTheme.titleBlack,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            onChanged: controller.updateEmail,
            decoration: const InputDecoration(
              labelText: '邮箱',
              hintText: 'name@example.com',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: controller.updateDisplayName,
            decoration: const InputDecoration(
              labelText: '昵称（可选）',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            obscureText: true,
            onChanged: controller.updatePassword,
            decoration: const InputDecoration(
              labelText: '密码',
                  hintText: '8-16 位',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            obscureText: true,
            onChanged: controller.updateConfirmPassword,
            decoration: const InputDecoration(
              labelText: '确认密码',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          _PrivacyRow(controller: controller),
          const SizedBox(height: 24),
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: controller.isRegisterPasswordMatch &&
                        !controller.isLoading.value
                    ? controller.registerWithEmail
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AuthTheme.primaryBlue,
                  disabledBackgroundColor: AuthTheme.buttonDisabled,
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
                    : const Text('注册'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Get.offNamed(RoutePath.login),
            child: const Text('已有账号？去登录'),
          ),
        ],
      ),
    );
  }
}

class _PhoneRegisterForm extends StatelessWidget {
  const _PhoneRegisterForm({
    required this.controller,
    required this.bottomInset,
  });

  final AuthController controller;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(28, 24, 28, 24 + bottomInset),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '手机号 + 短信验证码注册',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AuthTheme.titleBlack,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '首次验证通过后将自动创建账号',
            style: TextStyle(color: AuthTheme.textGray, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AuthTheme.countryCodeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('+86'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  onChanged: controller.updatePhone,
                  decoration: const InputDecoration(
                    labelText: '手机号',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _PrivacyRow(controller: controller),
          const SizedBox(height: 24),
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: !controller.isLoading.value
                    ? controller.registerWithPhone
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AuthTheme.primaryBlue,
                  disabledBackgroundColor: AuthTheme.buttonDisabled,
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
                    : const Text('获取验证码'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Get.offNamed(RoutePath.login),
            child: const Text('已有账号？去登录'),
          ),
        ],
      ),
    );
  }
}

class _PrivacyRow extends StatelessWidget {
  const _PrivacyRow({required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
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
          const Expanded(
            child: Text(
              '我已阅读并同意《某个隐私条款》',
              style: TextStyle(fontSize: 13, color: AuthTheme.textGray),
            ),
          ),
        ],
      ),
    );
  }
}
