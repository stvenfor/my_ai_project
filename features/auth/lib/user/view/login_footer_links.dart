import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_auth/user/theme/auth_theme.dart';
import 'package:module_route/route/route_path.dart';

class LoginFooterLinks extends StatelessWidget {
  const LoginFooterLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _FooterLink(
          label: '我要注册',
          onPressed: () => Get.toNamed(RoutePath.register),
        ),
        Container(
          width: 1,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: AuthTheme.separator,
        ),
        _FooterLink(
          label: '忘记密码',
          onPressed: () {},
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: const Size(44, 44),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: AuthTheme.accent,
        ),
        child: Text(
          label,
          style: AuthTheme.caption.copyWith(
            color: AuthTheme.accent,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
