import 'package:flutter/material.dart';

class PayPage extends StatelessWidget {
  const PayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('支付')),
      body: const Center(child: Text('Pay 模块')),
    );
  }
}
