import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/controller/ledger_detail_controller.dart';
import 'package:module_home/home/widgets/transaction_list_item.dart';

class LedgerDetailPage extends GetView<LedgerDetailController> {
  const LedgerDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      navBar: const AppNavBar(title: '收支详情', showBackButton: true),
      body: Obx(() {
        final t = controller.transaction.value;
        if (controller.isLoading.value && t == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (t == null) {
          return Center(child: Text(controller.errorMessage.value ?? '记录不存在'));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(t.category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(TransactionListItem.formatAmount(t.amount),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Text('类型：${t.type}'),
            Text('日期：${t.date}'),
            if (t.note != null) Text('备注：${t.note}'),
          ],
        );
      }),
    );
  }
}
