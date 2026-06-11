import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:module_auth/user/controller/auth_controller.dart';
import 'package:module_auth/user/theme/auth_theme.dart';
import 'package:module_auth/user/view/login_footer_links.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _phoneController;
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthController>();
    _phoneController = TextEditingController(text: '18614031080');
    _controller.updatePhone(_phoneController.text);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(28, 48, 28, 24 + bottomInset),
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
                  if (_phoneController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.cancel, color: AuthTheme.textGray),
                      onPressed: () {
                        _phoneController.clear();
                        _controller.updatePhone('');
                        setState(() {});
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
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _controller.goToPasswordPage,
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
              const LoginFooterLinks(),
            ],
          ),
        ),
      ),
    );
  }
}
