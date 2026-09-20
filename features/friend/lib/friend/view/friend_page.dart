import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

class FriendPage extends StatelessWidget {
  const FriendPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = VercelTokens.of(context);
    final textTheme = Theme.of(context).textTheme;

    return AppPageScaffold(
      navBar: const AppNavBar(title: '好友'),
      body: Center(
        child: Text(
          'Friend 模块',
          style: textTheme.bodyLarge?.copyWith(
            color: tokens.ink,
            fontFamily: VercelTypography.fontFamily,
          ),
        ),
      ),
    );
  }
}
