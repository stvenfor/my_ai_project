import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_settings/deal_invoice/model/deal_invoice_models.dart';

class DealInvoiceUploadViewModel extends GetxController {
  static const invoicePreviewUrl =
      'https://picsum.photos/seed/deal_invoice_doc/800/520';

  final phase = DealInvoiceUploadPhase.editing.obs;
  final selectedCustomer = Rxn<DealInvoiceCustomer>();
  final hasInvoiceImage = false.obs;
  final auditStatus = DealInvoiceStatus.pendingReview.obs;
  final submittedAt = Rxn<DateTime>();
  final rejectReason = RxnString();
  final ratingStars = RxnInt();
  final imageReplaced = false.obs;

  bool get isEditing => phase.value == DealInvoiceUploadPhase.editing;
  bool get isUploading => phase.value == DealInvoiceUploadPhase.uploading;
  bool get isDetail => phase.value == DealInvoiceUploadPhase.detail;

  bool get showSubmitButton {
    if (isDetail) {
      return auditStatus.value == DealInvoiceStatus.rejected;
    }
    return true;
  }

  bool get canSubmit {
    if (isUploading) return false;
    if (isDetail && auditStatus.value == DealInvoiceStatus.rejected) {
      return imageReplaced.value;
    }
    if (isEditing) {
      return selectedCustomer.value != null && hasInvoiceImage.value;
    }
    return false;
  }

  bool get showCustomerPicker => isEditing && !isUploading;

  bool get showPendingPlaceholder =>
      isDetail && auditStatus.value == DealInvoiceStatus.pendingReview;

  bool get showApprovedStamp {
    return isDetail &&
        (auditStatus.value == DealInvoiceStatus.approvedPendingRating ||
            auditStatus.value == DealInvoiceStatus.rated);
  }

  bool get showReuploadOverlay {
    if (isEditing && hasInvoiceImage.value) return false;
    return isDetail &&
        auditStatus.value == DealInvoiceStatus.rejected &&
        !imageReplaced.value;
  }

  bool get showRating =>
      isDetail && auditStatus.value == DealInvoiceStatus.rated;

  @override
  void onInit() {
    super.onInit();
    _initFromArgs(Get.arguments);
  }

  void _initFromArgs(dynamic args) {
    if (args is! DealInvoiceUploadArgs) return;

    switch (args.scene) {
      case DealInvoiceUploadScene.create:
        phase.value = DealInvoiceUploadPhase.editing;
      case DealInvoiceUploadScene.detail:
        _loadDetail(args.item);
      case DealInvoiceUploadScene.reupload:
        _loadReupload(args.item);
    }
  }

  void _loadDetail(DealInvoiceItem? item) {
    if (item == null) return;
    phase.value = DealInvoiceUploadPhase.detail;
    hasInvoiceImage.value =
        item.status != DealInvoiceStatus.pendingReview;
    auditStatus.value = item.status;
    submittedAt.value = item.submittedAt;
    rejectReason.value = item.rejectReason;
    ratingStars.value = item.ratingStars;
    imageReplaced.value = false;
    selectedCustomer.value = DealInvoiceCustomer(
      phone: item.phone,
      name: item.customerName ?? '',
    );
  }

  void _loadReupload(DealInvoiceItem? item) {
    if (item == null) return;
    phase.value = DealInvoiceUploadPhase.editing;
    hasInvoiceImage.value = false;
    auditStatus.value = DealInvoiceStatus.rejected;
    submittedAt.value = item.submittedAt;
    rejectReason.value = item.rejectReason;
    selectedCustomer.value = DealInvoiceCustomer(
      phone: item.phone,
      name: item.customerName ?? '',
    );
  }

  Future<void> pickCustomer() async {
    final picked = await Get.bottomSheet<DealInvoiceCustomer>(
      const _CustomerPickerSheet(),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
    if (picked != null) {
      selectedCustomer.value = picked;
    }
  }

  Future<void> pickInvoiceImage() async {
    if (isUploading) return;
    await Future<void>.delayed(const Duration(milliseconds: 300));
    hasInvoiceImage.value = true;
    if (isDetail && auditStatus.value == DealInvoiceStatus.rejected) {
      imageReplaced.value = true;
    }
  }

  Future<void> submit() async {
    if (!canSubmit) return;

    phase.value = DealInvoiceUploadPhase.uploading;
    await Future<void>.delayed(const Duration(milliseconds: 900));

    phase.value = DealInvoiceUploadPhase.detail;
    auditStatus.value = DealInvoiceStatus.pendingReview;
    submittedAt.value = DateTime.now();
    rejectReason.value = null;
    ratingStars.value = null;

    UiKitInitializer.toast('已提交审核');
  }

  String formatDateTime(DateTime? time) {
    if (time == null) return '—';
    final y = time.year;
    final m = time.month.toString().padLeft(2, '0');
    final d = time.day.toString().padLeft(2, '0');
    final h = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min:$s';
  }
}

class _CustomerPickerSheet extends StatelessWidget {
  const _CustomerPickerSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '选择购车客户',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final customer in DealInvoiceCustomer.mockList)
            ListTile(
              title: Text(customer.display),
              onTap: () => Get.back(result: customer),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
