import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

class PayPage extends StatelessWidget {
  const PayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      navBar: const AppNavBar(title: '支付'),
      body: const Center(child: Text('Pay 模块')),
    );
  }
}
