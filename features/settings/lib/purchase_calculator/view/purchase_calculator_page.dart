import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_settings/purchase_calculator/controller/purchase_calculator_controller.dart';
import 'package:module_settings/purchase_calculator/model/purchase_calculator_models.dart';

class PurchaseCalculatorPage extends GetView<PurchaseCalculatorController> {
  const PurchaseCalculatorPage({super.key});

  static const _bg = Color(0xFFF5F6F8);

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: _bg,
      navBar: const AppNavBar(title: '购车计算器', showBackButton: true),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('付款方式', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('全款'),
                        selected: controller.mode.value == 'cash',
                        onSelected: (_) => controller.setMode('cash'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('贷款'),
                        selected: controller.mode.value == 'loan',
                        onSelected: (_) => controller.setMode('loan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _numField(
                    label: '裸车价（元）',
                    controller: controller.barePriceCtrl,
                  ),
                  const SizedBox(height: 8),
                  _numField(
                    label: '计税价格（可选，默认裸车价/1.13）',
                    controller: controller.taxablePriceCtrl,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('计入商业险粗算'),
                    value: !controller.disableCommercial.value,
                    onChanged: (on) => controller.disableCommercial.value = !on,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('金融产品',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      if (controller.loadingProducts.value)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        TextButton(
                          onPressed: controller.loadProducts,
                          child: const Text('刷新'),
                        ),
                    ],
                  ),
                  if (controller.products.isEmpty &&
                      controller.errorMessage.value.isNotEmpty)
                    Text(controller.errorMessage.value,
                        style: const TextStyle(color: Colors.redAccent))
                  else
                    ...controller.products.map((p) {
                      final selected =
                          controller.selectedProductId.value == p.id;
                      return RadioListTile<int>(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        value: p.id,
                        groupValue: controller.selectedProductId.value,
                        onChanged: (v) {
                          if (v != null) controller.selectProduct(v);
                        },
                        title: Text(p.name),
                        subtitle: Text(
                          '年利率 ${p.annualRatePercent}% · 最低首付 ${p.minDownPaymentPercent}%'
                          '${p.subsidyType == 1 ? ' · 贴息减 ${p.subsidyRateCutPercent}%' : ''}'
                          '${p.subsidyType == 2 ? ' · 减本金 ¥${p.subsidyAmountCut.toStringAsFixed(0)}' : ''}',
                        ),
                        selected: selected,
                      );
                    }),
                  if (controller.mode.value == 'loan') ...[
                    const SizedBox(height: 8),
                    _numField(
                      label: '首付（元）',
                      controller: controller.downPaymentCtrl,
                    ),
                    const SizedBox(height: 8),
                    const Text('贷款期数（月）'),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final t in controller
                                .selectedProduct?.allowedTermsMonths ??
                            const <int>[])
                          ChoiceChip(
                            label: Text('$t'),
                            selected:
                                controller.selectedTermMonths.value == t,
                            onSelected: (_) =>
                                controller.selectedTermMonths.value = t,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed:
                    controller.quoting.value ? null : controller.submitQuote,
                child: controller.quoting.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('计算报价'),
              ),
            ),
            if (controller.errorMessage.value.isNotEmpty &&
                controller.quote.value == null) ...[
              const SizedBox(height: 12),
              Text(
                controller.errorMessage.value,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
            if (controller.quote.value != null) ...[
              const SizedBox(height: 16),
              _quoteCard(controller.quote.value!),
            ],
          ],
        );
      }),
    );
  }

  Widget _section({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _numField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _quoteCard(PurchaseQuote q) {
    return _section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q.mode == 'loan' ? '贷款方案（服务端）' : '全款方案（服务端）',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          if (q.productName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(q.productName,
                  style: TextStyle(color: Colors.grey.shade700)),
            ),
          const SizedBox(height: 12),
          for (final line in q.lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text(line.label)),
                  Text('¥${line.amount.toStringAsFixed(2)}'),
                ],
              ),
            ),
          const Divider(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text('首期/一次性应付',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text(
                '¥${q.initialPayment.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Expanded(
                child: Text('合计参考',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text(
                '¥${q.totalDue.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0070F3),
                ),
              ),
            ],
          ),
          if (q.mode == 'loan') ...[
            const SizedBox(height: 6),
            Text(
              '有效年利率 ${q.effectiveAnnualRate}% · ${q.termMonths} 期',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
