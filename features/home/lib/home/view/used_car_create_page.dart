import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_home/home/controller/used_car_create_controller.dart';

class UsedCarCreatePage extends GetView<UsedCarCreateController> {
  const UsedCarCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      navBar: const AppNavBar(title: '新建业务单', showBackButton: true),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('业务类型', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final entry in const [
                  ('trade_in', '置换'),
                  ('consign', '专卖'),
                  ('purchase', '收车'),
                ])
                  ChoiceChip(
                    label: Text(entry.$2),
                    selected: controller.kind.value == entry.$1,
                    onSelected: (_) => controller.kind.value = entry.$1,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('客户', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: controller.selectedCustomer.value?.customerId,
              items: [
                for (final c in controller.customers)
                  DropdownMenuItem<int>(
                    value: c.customerId,
                    child: Text('${c.displayName} ${c.phone}'),
                  ),
              ],
              onChanged: (id) {
                if (id == null) return;
                for (final c in controller.customers) {
                  if (c.customerId == id) {
                    controller.selectedCustomer.value = c;
                    break;
                  }
                }
              },
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _field(controller.vehicleModelCtrl, '车型名'),
            _field(controller.plateNoCtrl, '车牌'),
            _field(controller.vinCtrl, 'VIN'),
            _field(controller.mileageCtrl, '里程(km)', keyboard: TextInputType.number),
            _field(controller.yearCtrl, '年款', keyboard: TextInputType.number),
            _field(controller.amountCtrl, '金额(元)', keyboard: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: controller.submitting.value
                  ? null
                  : () async {
                      final ok = await controller.submit();
                      if (ok) Get.back(result: true);
                    },
              child: controller.submitting.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('提交'),
            ),
          ],
        );
      }),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
