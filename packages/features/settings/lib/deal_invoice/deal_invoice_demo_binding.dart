import 'package:get/get.dart';
import 'package:module_settings/deal_invoice/viewmodel/deal_invoice_demo_viewmodel.dart';
import 'package:module_settings/deal_invoice/viewmodel/deal_invoice_upload_viewmodel.dart';

class DealInvoiceDemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DealInvoiceDemoViewModel>(
      DealInvoiceDemoViewModel.new,
      fenix: true,
    );
  }
}

class DealInvoiceUploadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DealInvoiceUploadViewModel>(
      DealInvoiceUploadViewModel.new,
    );
  }
}
