import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_wallet/wallet/controller/wallet_controller.dart';

class WalletPage extends GetView<WalletController> {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的钱包')),
      body: Obx(() {
        if (controller.loading.value && controller.summary.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty &&
            controller.summary.value == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(controller.errorMessage.value),
                TextButton(onPressed: controller.refreshAll, child: const Text('重试')),
              ],
            ),
          );
        }
        final sum = controller.summary.value;
        return RefreshIndicator(
          onRefresh: controller.refreshAll,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('余额（元）', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(
                        sum?.balance ?? '0.00',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('充值', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: controller.amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: '金额 0.01–50000',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Obx(() {
                return Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('支付宝'),
                      selected: controller.rechargeChannel.value == 1,
                      onSelected: (_) => controller.rechargeChannel.value = 1,
                    ),
                    ChoiceChip(
                      label: const Text('微信'),
                      selected: controller.rechargeChannel.value == 2,
                      onSelected: (_) => controller.rechargeChannel.value = 2,
                    ),
                    ChoiceChip(
                      label: const Text('银行卡'),
                      selected: controller.rechargeChannel.value == 3,
                      onSelected: (_) => controller.rechargeChannel.value = 3,
                    ),
                    for (final a in ['10', '50', '100'])
                      ActionChip(
                        label: Text(a),
                        onPressed: () => controller.amountCtrl.text = a,
                      ),
                  ],
                );
              }),
              if ((sum?.cards.isNotEmpty ?? false))
                Obx(() {
                  if (controller.rechargeChannel.value != 3) {
                    return const SizedBox.shrink();
                  }
                  return DropdownButton<int>(
                    isExpanded: true,
                    value: controller.selectedCardId.value,
                    hint: const Text('选择银行卡'),
                    items: [
                      for (final c in sum!.cards)
                        DropdownMenuItem(value: c.cardId, child: Text(c.display)),
                    ],
                    onChanged: (v) => controller.selectedCardId.value = v,
                  );
                }),
              const SizedBox(height: 8),
              Obx(() => FilledButton(
                    onPressed: controller.acting.value ? null : controller.recharge,
                    child: const Text('确认充值'),
                  )),
              const SizedBox(height: 24),
              const Text('银行卡', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: controller.bankNameCtrl,
                decoration: const InputDecoration(
                  hintText: '银行名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.last4Ctrl,
                maxLength: 4,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '卡号后四位',
                  border: OutlineInputBorder(),
                ),
              ),
              FilledButton.tonal(
                onPressed: controller.bindCard,
                child: const Text('绑定银行卡'),
              ),
              for (final c in sum?.cards ?? const [])
                ListTile(
                  title: Text(c.display),
                  subtitle: Text(c.isDefault ? '默认卡' : ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!c.isDefault)
                        TextButton(
                          onPressed: () => controller.setDefault(c.cardId),
                          child: const Text('设默认'),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => controller.deleteCard(c.cardId),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              const Text('流水', style: TextStyle(fontWeight: FontWeight.bold)),
              for (final e in controller.ledger)
                ListTile(
                  title: Text(e.reasonLabel),
                  subtitle: Text(e.refId.isEmpty ? '' : 'ref ${e.refId}'),
                  trailing: Text(
                    e.deltaYuan,
                    style: TextStyle(
                      color: e.deltaFen < 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (controller.ledger.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('暂无流水')),
                ),
            ],
          ),
        );
      }),
    );
  }
}
