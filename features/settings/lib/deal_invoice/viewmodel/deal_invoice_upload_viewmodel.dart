import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_http/module_http.dart';
import 'package:module_settings/deal_invoice/api/deal_invoice_api.dart';
import 'package:module_settings/deal_invoice/model/deal_invoice_models.dart';
import 'package:module_utils/module_utils.dart';

class DealInvoiceUploadViewModel extends GetxController {
  DealInvoiceUploadViewModel({DealInvoiceApi? api}) : _api = api ?? DealInvoiceApi();

  final DealInvoiceApi _api;

  final phase = DealInvoiceUploadPhase.editing.obs;
  final selectedCustomer = Rxn<DealInvoiceCustomer>();
  final hasInvoiceImage = false.obs;
  final localImagePath = RxnString();
  final auditStatus = DealInvoiceStatus.pendingReview.obs;
  final submittedAt = Rxn<DateTime>();
  final rejectReason = RxnString();
  final ratingStars = RxnInt();
  final imageReplaced = false.obs;
  final remoteImageUrl = RxnString();

  String? _invoiceId;
  DealInvoiceUploadScene _scene = DealInvoiceUploadScene.create;

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
    _scene = args.scene;

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
    _invoiceId = item.id;
    phase.value = DealInvoiceUploadPhase.detail;
    hasInvoiceImage.value = item.status != DealInvoiceStatus.pendingReview;
    remoteImageUrl.value = item.imageUrl;
    auditStatus.value = item.status;
    submittedAt.value = item.submittedAt;
    rejectReason.value = item.rejectReason;
    ratingStars.value = item.ratingStars;
    imageReplaced.value = false;
    selectedCustomer.value = DealInvoiceCustomer(
      id: 0,
      phone: item.phone,
      name: item.customerName ?? '',
    );
  }

  void _loadReupload(DealInvoiceItem? item) {
    if (item == null) return;
    _invoiceId = item.id;
    phase.value = DealInvoiceUploadPhase.editing;
    hasInvoiceImage.value = false;
    localImagePath.value = null;
    remoteImageUrl.value = item.imageUrl;
    auditStatus.value = DealInvoiceStatus.rejected;
    submittedAt.value = item.submittedAt;
    rejectReason.value = item.rejectReason;
    selectedCustomer.value = DealInvoiceCustomer(
      id: 0,
      phone: item.phone,
      name: item.customerName ?? '',
    );
  }

  Future<void> pickCustomer() async {
    try {
      final customers = await _api.fetchCustomers();
      if (customers.isEmpty) {
        UiKitInitializer.toastError('当前店暂无购车客户');
        return;
      }
      final picked = await Get.bottomSheet<DealInvoiceCustomer>(
        _CustomerPickerSheet(customers: customers),
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      );
      if (picked != null) {
        selectedCustomer.value = picked;
      }
    } on HttpRequestException catch (e) {
      UiKitInitializer.toastError(e.message);
    } catch (_) {
      UiKitInitializer.toastError('加载客户失败');
    }
  }

  Future<void> pickInvoiceImage() async {
    if (isUploading) return;
    final source = await MediaSourceBottomSheet.show();
    if (source == null) return;
    try {
      if (source == MediaPickSource.camera) {
        final granted = await ImagePickerUtils.ensureCameraPermission();
        if (!granted) {
          UiKitInitializer.toastError('需要相机权限才能拍摄');
          return;
        }
      }
      final path = await ImagePickerUtils.pickImage(source, maxWidth: 1600);
      if (path == null || path.isEmpty) return;
      localImagePath.value = path;
      hasInvoiceImage.value = true;
      if (isDetail && auditStatus.value == DealInvoiceStatus.rejected) {
        imageReplaced.value = true;
      }
      if (_scene == DealInvoiceUploadScene.reupload ||
          (isDetail && auditStatus.value == DealInvoiceStatus.rejected)) {
        imageReplaced.value = true;
      }
    } catch (_) {
      UiKitInitializer.toastError('选择图片失败');
    }
  }

  Future<void> submit() async {
    if (!canSubmit) return;

    phase.value = DealInvoiceUploadPhase.uploading;
    try {
      final DealInvoiceItem item;
      if (_invoiceId != null &&
          (auditStatus.value == DealInvoiceStatus.rejected ||
              _scene == DealInvoiceUploadScene.reupload)) {
        item = await _api.resubmit(invoiceId: _invoiceId!);
      } else {
        final customer = selectedCustomer.value;
        if (customer == null || customer.id <= 0) {
          UiKitInitializer.toastError('请选择购车客户');
          phase.value = DealInvoiceUploadPhase.editing;
          return;
        }
        item = await _api.create(customerId: customer.id);
      }

      _invoiceId = item.id;
      phase.value = DealInvoiceUploadPhase.detail;
      auditStatus.value = item.status;
      submittedAt.value = item.submittedAt;
      rejectReason.value = item.rejectReason;
      ratingStars.value = item.ratingStars;
      remoteImageUrl.value = item.imageUrl;
      imageReplaced.value = false;
      UiKitInitializer.toast('已提交审核');
    } on HttpRequestException catch (e) {
      phase.value = DealInvoiceUploadPhase.editing;
      UiKitInitializer.toastError(e.message);
    } catch (_) {
      phase.value = DealInvoiceUploadPhase.editing;
      UiKitInitializer.toastError('提交失败');
    }
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
  const _CustomerPickerSheet({required this.customers});

  final List<DealInvoiceCustomer> customers;

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
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.5,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];
                return ListTile(
                  title: Text(customer.display),
                  onTap: () => Get.back(result: customer),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
