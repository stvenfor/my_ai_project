import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_auth/user/theme/auth_theme.dart';
import 'package:module_route/route/route_path.dart';

class LoginFooterLinks extends StatelessWidget {
  const LoginFooterLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Get.toNamed(RoutePath.register),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            '我要注册',
            style: TextStyle(color: AuthTheme.linkGray, fontSize: 13),
          ),
        ),
        Container(
          width: 1,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          color: AuthTheme.dividerGray,
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            '忘记密码',
            style: TextStyle(color: AuthTheme.linkGray, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
