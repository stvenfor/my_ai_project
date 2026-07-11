import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_auth/user/controller/auth_controller.dart';
import 'package:module_auth/user/theme/auth_theme.dart';

class AuthPrivacyRow extends StatelessWidget {
  const AuthPrivacyRow({super.key, required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AuthTheme.radiusMd),
          onTap: () => controller.togglePrivacy(!controller.agreedPrivacy.value),
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
                        color: controller.agreedPrivacy.value
                            ? AuthTheme.accent
                            : Colors.transparent,
                        border: Border.all(
                          color: controller.agreedPrivacy.value
                              ? AuthTheme.accent
                              : AuthTheme.separator,
                          width: 1.5,
                        ),
                      ),
                      child: controller.agreedPrivacy.value
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
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AuthTheme.buttonHeight,
      child: FilledButton(
        onPressed: enabled && !isLoading ? onPressed : null,
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
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label, style: AuthTheme.buttonLabel),
      ),
    );
  }
}

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed ?? () => Get.back<void>(),
        child: const Icon(
          CupertinoIcons.back,
          size: 24,
          color: AuthTheme.accent,
        ),
      ),
    );
  }
}

class AuthGroupedTextField extends StatelessWidget {
  const AuthGroupedTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.autocorrect = true,
    this.onChanged,
    this.suffixIcon,
  });

  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool autocorrect;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AuthTheme.fieldHeight,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        autocorrect: autocorrect,
        style: AuthTheme.fieldText,
        decoration: AuthTheme.groupedFieldDecoration(
          hintText: hintText,
          suffixIcon: suffixIcon,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class AuthGroupedFormCard extends StatelessWidget {
  const AuthGroupedFormCard({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i < children.length - 1) {
        rows.add(AuthTheme.groupedDivider);
      }
    }

    return DecoratedBox(
      decoration: AuthTheme.groupedCardDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AuthTheme.radiusMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        ),
      ),
    );
  }
}

class AuthPasswordToggle extends StatelessWidget {
  const AuthPasswordToggle({
    super.key,
    required this.visible,
    required this.onToggle,
  });

  final bool visible;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      icon: Icon(
        visible ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
        size: 20,
        color: AuthTheme.labelSecondary,
      ),
      splashRadius: 20,
      tooltip: visible ? '隐藏密码' : '显示密码',
    );
  }
}
