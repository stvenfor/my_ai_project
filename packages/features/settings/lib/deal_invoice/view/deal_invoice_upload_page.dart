import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_settings/deal_invoice/model/deal_invoice_models.dart';
import 'package:module_settings/deal_invoice/viewmodel/deal_invoice_upload_viewmodel.dart';
import 'package:module_settings/deal_invoice/widgets/deal_invoice_info_row.dart';
import 'package:module_settings/deal_invoice/widgets/deal_invoice_upload_image_area.dart';

/// 上传发票页（新建 / 待审核 / 已通过 / 未通过）。
class DealInvoiceUploadPage extends GetView<DealInvoiceUploadViewModel> {
  const DealInvoiceUploadPage({super.key});

  static const _bgColor = Color(0xFFF5F6F8);

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      backgroundColor: _bgColor,
      navBar: const AppNavBar(title: '上传发票', showBackButton: true),
      body: Obx(() {
        final vm = controller;
        final isDetail = vm.isDetail;
        final showPicker = vm.showCustomerPicker;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showPicker) ...[
                      _CustomerRow(
                        customer: vm.selectedCustomer.value,
                        onTap: vm.pickCustomer,
                      ),
                      const SizedBox(height: 16),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '新车发票',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    DealInvoiceUploadImageArea(controller: vm),
                    if (isDetail || vm.selectedCustomer.value != null) ...[
                      const SizedBox(height: 16),
                      _InfoSection(controller: vm),
                    ],
                  ],
                ),
              ),
            ),
            if (vm.showSubmitButton) _SubmitBar(controller: vm),
          ],
        );
      }),
    );
  }
}

class _CustomerRow extends StatelessWidget {
  const _CustomerRow({
    required this.customer,
    required this.onTap,
  });

  final DealInvoiceCustomer? customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Text(
                '购车客户',
                style: TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
              ),
              const Spacer(),
              Text(
                customer?.display ?? '选择客户',
                style: TextStyle(
                  fontSize: 15,
                  color: customer == null
                      ? Colors.grey.shade500
                      : const Color(0xFF666666),
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.controller});

  final DealInvoiceUploadViewModel controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final customer = controller.selectedCustomer.value;
      final status = controller.auditStatus.value;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            if (customer != null)
              DealInvoiceInfoRow(
                label: '购车客户',
                value: customer.display,
              ),
            if (controller.isDetail)
              DealInvoiceInfoRow(
                label: '提交时间',
                value: controller.formatDateTime(controller.submittedAt.value),
              ),
            if (controller.isDetail)
              DealInvoiceInfoRow(
                label: '审核状态',
                value: status.auditLabel,
                valueColor: status.auditColor,
              ),
            if (controller.isDetail &&
                status == DealInvoiceStatus.rejected &&
                controller.rejectReason.value != null)
              DealInvoiceInfoRow(
                label: '未通过原因',
                value: controller.rejectReason.value,
                valueColor: const Color(0xFFE53935),
              ),
            if (controller.showRating)
              DealInvoiceInfoRow(
                label: '客户评价',
                trailing: DealInvoiceStarRating(
                  stars: controller.ratingStars.value ?? 0,
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({required this.controller});

  final DealInvoiceUploadViewModel controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final enabled = controller.canSubmit;
      final uploading = controller.isUploading;

      return Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          AppSafeInsets.bottom(context) + 12,
        ),
        child: SizedBox(
          height: 48,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: enabled && !uploading ? controller.submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B8CFF),
              disabledBackgroundColor: const Color(0xFFE0E0E0),
              disabledForegroundColor: Colors.white,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: uploading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    '提交审核',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      );
    });
  }
}
