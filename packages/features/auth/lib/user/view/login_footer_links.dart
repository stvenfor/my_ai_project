import 'package:flutter/material.dart';
import 'package:module_auth/user/theme/auth_theme.dart';

class LoginFooterLinks extends StatelessWidget {
  const LoginFooterLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              '短信验证码登录',
              style: TextStyle(color: AuthTheme.linkGray, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {},
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
        ),
      ],
    );
  }
}
